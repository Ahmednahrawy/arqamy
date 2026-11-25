import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:arqamy/core/services/legacy_invoice_party_resolution_planner.dart';

enum LegacyPartyReviewAction {
  acceptSuggestedMatch,
  selectParty,
  keepHeld,
}

/// An explicit human decision for one immutable source occurrence.
///
/// Decisions are validated against the exact snapshot and occurrence key.
/// This value object is not persisted by this review service.
class LegacyPartyReviewDecision {
  const LegacyPartyReviewDecision({
    required this.snapshotSha256,
    required this.sourceOccurrenceKey,
    required this.action,
    required this.reviewerId,
    required this.decidedAtUtc,
    this.selectedPartyId,
  });

  final String snapshotSha256;
  final String sourceOccurrenceKey;
  final LegacyPartyReviewAction action;
  final String reviewerId;
  final DateTime decidedAtUtc;
  final String? selectedPartyId;
}

class LegacyPartyReviewedOccurrence {
  const LegacyPartyReviewedOccurrence({
    required this.resolution,
    required this.isApproved,
    this.decision,
    this.partyId,
    this.partyDisplayName,
  });

  final LegacyPartyOccurrenceResolution resolution;
  final LegacyPartyReviewDecision? decision;
  final bool isApproved;
  final String? partyId;
  final String? partyDisplayName;

  LedgerPartyRole? get partyRole => resolution.expectedRole;
}

class LegacyPartyReviewReport {
  const LegacyPartyReviewReport({
    required this.snapshotSha256,
    required this.occurrences,
  });

  final String snapshotSha256;
  final List<LegacyPartyReviewedOccurrence> occurrences;

  int get approvedCount => occurrences.where((item) => item.isApproved).length;
  int get heldCount => occurrences.length - approvedCount;
  int get reviewedCount =>
      occurrences.where((item) => item.decision != null).length;
}

/// Applies explicit party-resolution review decisions in memory only.
///
/// It does not create parties, change party roles, link invoices, write a
/// migration journal, or persist decisions. Persistence requires the separately
/// approved migration-journal schema and workflow.
class LegacyInvoicePartyResolutionReview {
  const LegacyInvoicePartyResolutionReview();

  LegacyPartyReviewReport review({
    required LegacyPartyResolutionReport plan,
    required Iterable<LegacyPartyReviewDecision> decisions,
    required Iterable<LegacyPartyCandidate> parties,
  }) {
    final partyById = <String, LegacyPartyCandidate>{};
    for (final candidate in parties) {
      if (partyById.containsKey(candidate.party.id)) {
        throw ArgumentError('Duplicate party ID: ${candidate.party.id}');
      }
      partyById[candidate.party.id] = candidate;
    }

    final resolutionByKey = {
      for (final resolution in plan.resolutions)
        resolution.sourceOccurrenceKey: resolution,
    };
    if (resolutionByKey.length != plan.resolutions.length) {
      throw ArgumentError('The plan contains duplicate source occurrence keys.');
    }

    final decisionByKey = <String, LegacyPartyReviewDecision>{};
    for (final decision in decisions) {
      if (decision.snapshotSha256 != plan.snapshotSha256) {
        throw ArgumentError('Review decision belongs to a different snapshot.');
      }
      if (decision.sourceOccurrenceKey.trim().isEmpty ||
          !resolutionByKey.containsKey(decision.sourceOccurrenceKey)) {
        throw ArgumentError('Review decision references an unknown occurrence.');
      }
      if (decision.reviewerId.trim().isEmpty) {
        throw ArgumentError('Reviewer ID must not be empty.');
      }
      if (!decision.decidedAtUtc.isUtc) {
        throw ArgumentError('Decision timestamp must be UTC.');
      }
      if (decisionByKey.containsKey(decision.sourceOccurrenceKey)) {
        throw ArgumentError('An occurrence can have only one decision per review.');
      }
      decisionByKey[decision.sourceOccurrenceKey] = decision;
    }

    final reviewed = <LegacyPartyReviewedOccurrence>[];
    for (final resolution in plan.resolutions) {
      final decision = decisionByKey[resolution.sourceOccurrenceKey];
      if (decision == null) {
        reviewed.add(LegacyPartyReviewedOccurrence(
          resolution: resolution,
          isApproved: false,
        ));
        continue;
      }

      switch (decision.action) {
        case LegacyPartyReviewAction.keepHeld:
          if (decision.selectedPartyId != null) {
            throw ArgumentError('keepHeld must not select a party.');
          }
          reviewed.add(LegacyPartyReviewedOccurrence(
            resolution: resolution,
            decision: decision,
            isApproved: false,
          ));

        case LegacyPartyReviewAction.acceptSuggestedMatch:
          if (decision.selectedPartyId != null || !resolution.isResolved) {
            throw ArgumentError('There is no valid suggested match to accept.');
          }
          final party = partyById[resolution.partyId];
          if (party == null ||
              resolution.expectedRole == null ||
              !party.roles.contains(resolution.expectedRole)) {
            throw ArgumentError('Suggested party is missing or has an invalid role.');
          }
          reviewed.add(LegacyPartyReviewedOccurrence(
            resolution: resolution,
            decision: decision,
            isApproved: true,
            partyId: party.party.id,
            partyDisplayName: party.party.displayName,
          ));

        case LegacyPartyReviewAction.selectParty:
          final selectedId = decision.selectedPartyId;
          final party = selectedId == null ? null : partyById[selectedId];
          final expectedRole = resolution.expectedRole;
          if (party == null ||
              expectedRole == null ||
              !party.roles.contains(expectedRole)) {
            throw ArgumentError('Selected party does not exist or has an invalid role.');
          }
          reviewed.add(LegacyPartyReviewedOccurrence(
            resolution: resolution,
            decision: decision,
            isApproved: true,
            partyId: party.party.id,
            partyDisplayName: party.party.displayName,
          ));
      }
    }

    return LegacyPartyReviewReport(
      snapshotSha256: plan.snapshotSha256,
      occurrences: List.unmodifiable(reviewed),
    );
  }
}
