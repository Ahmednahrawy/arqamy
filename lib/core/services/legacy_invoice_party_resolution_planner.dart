import 'package:arqamy/core/helpers/customer_name_key.dart';
import 'package:arqamy/core/helpers/invoice_action.dart';
import 'package:arqamy/core/services/legacy_invoice_preflight_service.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';

enum LegacyPartyResolutionStatus {
  resolvedByExistingId,
  resolvedByName,
  missingParty,
  ambiguousName,
  roleMismatch,
  unknownAction,
  heldByPreflight,
}

/// A read-only view of a party and the roles already assigned to it.
class LegacyPartyCandidate {
  const LegacyPartyCandidate({
    required this.party,
    required this.roles,
  });

  final LedgerParty party;
  final Set<LedgerPartyRole> roles;
}

class LegacyPartyOccurrenceResolution {
  const LegacyPartyOccurrenceResolution({
    required this.sourceOccurrenceKey,
    required this.sourceIndex,
    required this.invoiceId,
    required this.status,
    this.expectedRole,
    this.partyId,
    this.partyDisplayName,
    this.candidatePartyIds = const [],
  });

  final String sourceOccurrenceKey;
  final int sourceIndex;
  final String? invoiceId;
  final LegacyPartyResolutionStatus status;
  final LedgerPartyRole? expectedRole;
  final String? partyId;
  final String? partyDisplayName;
  final List<String> candidatePartyIds;

  bool get isResolved =>
      status == LegacyPartyResolutionStatus.resolvedByExistingId ||
      status == LegacyPartyResolutionStatus.resolvedByName;
}

class LegacyPartyResolutionReport {
  const LegacyPartyResolutionReport({
    required this.snapshotSha256,
    required this.resolutions,
  });

  final String snapshotSha256;
  final List<LegacyPartyOccurrenceResolution> resolutions;

  int count(LegacyPartyResolutionStatus status) =>
      resolutions.where((item) => item.status == status).length;

  int get resolvedCount => resolutions.where((item) => item.isResolved).length;
  int get heldCount => resolutions.length - resolvedCount;
}

/// Plans party identity and role resolution per source occurrence.
///
/// This planner is deliberately read-only. It never creates or changes parties,
/// assigns roles, links invoices, or writes to the database. Name normalization
/// is used only to find candidates; it never authorizes a merge.
class LegacyInvoicePartyResolutionPlanner {
  const LegacyInvoicePartyResolutionPlanner();

  LegacyPartyResolutionReport plan({
    required LegacyInvoicePreflightReport preflight,
    required Iterable<LegacyPartyCandidate> parties,
  }) {
    final partyList = parties.toList(growable: false);
    final byId = <String, LegacyPartyCandidate>{
      for (final candidate in partyList) candidate.party.id: candidate,
    };

    final resolutions = <LegacyPartyOccurrenceResolution>[];
    for (final occurrence in preflight.occurrences) {
      final invoice = occurrence.invoice;
      if (preflight.fatalIssue != null ||
          occurrence.classification !=
              LegacyInvoicePreflightClassification.ready ||
          invoice == null) {
        resolutions.add(_result(
          occurrence,
          LegacyPartyResolutionStatus.heldByPreflight,
        ));
        continue;
      }

      final action = InvoiceAction.tryParse(invoice.invoiceAction);
      final expectedRole = switch (action) {
        InvoiceAction.sale || InvoiceAction.storage => LedgerPartyRole.customer,
        InvoiceAction.purchase => LedgerPartyRole.supplier,
        null => null,
      };
      if (expectedRole == null) {
        resolutions.add(_result(
          occurrence,
          LegacyPartyResolutionStatus.unknownAction,
        ));
        continue;
      }

      final existingId = invoice.customerId;
      if (existingId != null && existingId.trim().isNotEmpty) {
        final candidate = byId[existingId];
        if (candidate == null) {
          resolutions.add(_result(
            occurrence,
            LegacyPartyResolutionStatus.missingParty,
            expectedRole: expectedRole,
          ));
        } else if (candidate.roles.contains(expectedRole)) {
          resolutions.add(_result(
            occurrence,
            LegacyPartyResolutionStatus.resolvedByExistingId,
            expectedRole: expectedRole,
            party: candidate.party,
          ));
        } else {
          resolutions.add(_result(
            occurrence,
            LegacyPartyResolutionStatus.roleMismatch,
            expectedRole: expectedRole,
            candidatePartyIds: [candidate.party.id],
          ));
        }
        continue;
      }

      final nameKey = customerNameKey(invoice.customerName);
      if (nameKey.isEmpty) {
        resolutions.add(_result(
          occurrence,
          LegacyPartyResolutionStatus.missingParty,
          expectedRole: expectedRole,
        ));
        continue;
      }

      final sameName = partyList
          .where((candidate) =>
              customerNameKey(candidate.party.displayName) == nameKey)
          .toList(growable: false);
      final roleMatches = sameName
          .where((candidate) => candidate.roles.contains(expectedRole))
          .toList(growable: false);

      if (roleMatches.length == 1) {
        resolutions.add(_result(
          occurrence,
          LegacyPartyResolutionStatus.resolvedByName,
          expectedRole: expectedRole,
          party: roleMatches.single.party,
        ));
      } else if (roleMatches.length > 1) {
        resolutions.add(_result(
          occurrence,
          LegacyPartyResolutionStatus.ambiguousName,
          expectedRole: expectedRole,
          candidatePartyIds: roleMatches.map((item) => item.party.id).toList(),
        ));
      } else if (sameName.isNotEmpty) {
        resolutions.add(_result(
          occurrence,
          LegacyPartyResolutionStatus.roleMismatch,
          expectedRole: expectedRole,
          candidatePartyIds: sameName.map((item) => item.party.id).toList(),
        ));
      } else {
        resolutions.add(_result(
          occurrence,
          LegacyPartyResolutionStatus.missingParty,
          expectedRole: expectedRole,
        ));
      }
    }

    return LegacyPartyResolutionReport(
      snapshotSha256: preflight.snapshotSha256,
      resolutions: List.unmodifiable(resolutions),
    );
  }

  LegacyPartyOccurrenceResolution _result(
    LegacyInvoicePreflightOccurrence occurrence,
    LegacyPartyResolutionStatus status, {
    LedgerPartyRole? expectedRole,
    LedgerParty? party,
    List<String> candidatePartyIds = const [],
  }) {
    return LegacyPartyOccurrenceResolution(
      sourceOccurrenceKey: occurrence.sourceOccurrenceIdentity.key,
      sourceIndex: occurrence.sourceIndex,
      invoiceId: occurrence.invoiceId,
      status: status,
      expectedRole: expectedRole,
      partyId: party?.id,
      partyDisplayName: party?.displayName,
      candidatePartyIds: List.unmodifiable(candidatePartyIds),
    );
  }
}
