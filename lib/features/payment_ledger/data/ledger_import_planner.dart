import 'package:arqamy/core/helpers/money.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart' as legacy;
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:arqamy/features/payment_ledger/data/legacy_invoice_audit.dart';

/// An invoice that can be imported with no guesswork.
class LedgerImportItem {
  const LedgerImportItem({
    required this.invoiceId,
    required this.partyId,
    required this.partyRole,
    required this.draft,
  });

  final String invoiceId;
  final String partyId;
  final LedgerPartyRole partyRole;

  /// Fully resolved except for the financial account, which is created or
  /// found when the import is executed.
  final LedgerInvoiceDraft draft;
}

/// An invoice that must wait for a human decision. It is never changed.
class HeldInvoice {
  const HeldInvoice({
    required this.invoiceId,
    required this.serial,
    required this.issues,
    this.storageRoleUndecided = false,
  });

  final String invoiceId;
  final String serial;
  final List<LegacyInvoiceIssue> issues;

  /// Storage invoices wait until the owner decides which role they belong to.
  final bool storageRoleUndecided;
}

class LedgerImportPlan {
  const LedgerImportPlan({
    required this.currency,
    required this.ready,
    required this.held,
  });

  final LedgerCurrency currency;
  final List<LedgerImportItem> ready;
  final List<HeldInvoice> held;

  /// The financial accounts the ready invoices need, one per party and role.
  Set<({String partyId, LedgerPartyRole role})> get accountsNeeded => {
    for (final item in ready) (partyId: item.partyId, role: item.partyRole),
  };
}

/// Proposes how legacy invoices would enter the ledger. Read-only: it creates
/// no records and fixes nothing. The currency must be confirmed by the owner
/// and is never assumed (Decision 38).
class LedgerImportPlanner {
  LedgerImportPlanner({
    required this.currency,
    LedgerInvoiceMapper mapper = const LedgerInvoiceMapper(),
  }) : _mapper = mapper {
    if (currency.minorUnitScale != 2) {
      throw ArgumentError.value(
        currency.minorUnitScale,
        'currency',
        'Only two-decimal currencies are supported for now.',
      );
    }
  }

  final LedgerCurrency currency;
  final LedgerInvoiceMapper _mapper;

  /// A stable key for one saved invoice, so repeating an import never
  /// duplicates it.
  static String legacyRecordKeyFor(legacy.Invoice invoice) =>
      'saved_invoices/${invoice.id}';

  LedgerImportPlan plan(Iterable<legacy.Invoice> invoices) {
    final list = invoices.toList();
    final idCounts = <String, int>{};
    for (final invoice in list) {
      idCounts[invoice.id] = (idCounts[invoice.id] ?? 0) + 1;
    }

    final ready = <LedgerImportItem>[];
    final held = <HeldInvoice>[];
    for (final invoice in list) {
      final issues = <LegacyInvoiceIssue>[
        if (idCounts[invoice.id]! > 1) LegacyInvoiceIssue.duplicateInvoiceId,
        ...?LegacyInvoiceAudit.run([invoice]).findings.firstOrNull?.issues,
      ];
      final draftAction = _mapper
          .fromExistingInvoice(
            invoice,
            sourceRecordKey: legacyRecordKeyFor(invoice),
          )
          .action;
      final storage = draftAction == LedgerInvoiceAction.storage;

      if (issues.isNotEmpty || storage) {
        held.add(
          HeldInvoice(
            invoiceId: invoice.id,
            serial: invoice.invoiceSerial,
            issues: List.unmodifiable(issues),
            storageRoleUndecided: storage,
          ),
        );
        continue;
      }

      final role = draftAction == LedgerInvoiceAction.purchase
          ? LedgerPartyRole.supplier
          : LedgerPartyRole.customer;
      final partyId = invoice.customerId!;
      ready.add(
        LedgerImportItem(
          invoiceId: invoice.id,
          partyId: partyId,
          partyRole: role,
          draft: _resolve(invoice, partyId, role),
        ),
      );
    }

    return LedgerImportPlan(
      currency: currency,
      ready: List.unmodifiable(ready),
      held: List.unmodifiable(held),
    );
  }

  LedgerInvoiceDraft _resolve(
    legacy.Invoice invoice,
    String partyId,
    LedgerPartyRole role,
  ) {
    final base = _mapper.fromExistingInvoice(
      invoice,
      sourceRecordKey: legacyRecordKeyFor(invoice),
    );
    return LedgerInvoiceDraft(
      id: base.id,
      serial: base.serial,
      legacyRecordKey: base.legacyRecordKey,
      legacyInvoiceId: base.legacyInvoiceId,
      sourceJson: base.sourceJson,
      partyId: partyId,
      partyRole: role,
      currencyCode: currency.code,
      action: base.action,
      legacyAction: base.legacyAction,
      totalMinor: Money.fromDouble(invoice.totalCost).minorUnits,
      legacyTotalValue: base.legacyTotalValue,
      legacyPaidValue: base.legacyPaidValue,
      legacyRemainingValue: base.legacyRemainingValue,
      issuedAt: base.issuedAt,
      lines: [
        for (var index = 0; index < base.lines.length; index++)
          LedgerInvoiceLineDraft(
            id: base.lines[index].id,
            lineIndex: base.lines[index].lineIndex,
            productName: base.lines[index].productName,
            quantityDecimal: base.lines[index].quantityDecimal,
            packageWeightDecimal: base.lines[index].packageWeightDecimal,
            packageCount: base.lines[index].packageCount,
            unitPriceDecimal: base.lines[index].unitPriceDecimal,
            lineTotalMinor: invoice.products[index].lineTotal.minorUnits,
            currencyCode: currency.code,
            sourceJson: base.lines[index].sourceJson,
          ),
      ],
    );
  }
}