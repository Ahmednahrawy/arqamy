import 'package:arqamy/core/services/legacy_invoice_party_resolution_planner.dart';
import 'package:arqamy/core/services/legacy_invoice_preflight_service.dart';
import 'package:arqamy/core/services/legacy_invoice_source_occurrence_identity.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:flutter_test/flutter_test.dart';

const _snapshotHash = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

Invoice _invoice({
  required String id,
  required String name,
  String? customerId,
  String? action = 'بيع',
}) {
  return Invoice(
    id: id,
    customerName: name,
    products: [
      Product(
        name: 'Product',
        weight: 1,
        packageWeight: 0,
        numberPackage: 0,
        price: 10,
      ),
    ],
    totalCost: 10,
    paid: 0,
    rest: 10,
    formattedDate: 'Nov 25, 2026',
    formattedTime: '10:00',
    invoiceAction: action,
    invoiceSerial: id,
    customerId: customerId,
  );
}

LegacyInvoicePreflightOccurrence _occurrence(
  int index,
  Invoice invoice, {
  LegacyInvoicePreflightClassification classification =
      LegacyInvoicePreflightClassification.ready,
}) {
  final raw = '{"occurrence":$index}';
  return LegacyInvoicePreflightOccurrence(
    sourceIndex: index,
    sourceOccurrenceIdentity: LegacyInvoiceSourceOccurrenceIdentity.create(
      snapshotSha256: _snapshotHash,
      sourceIndex: index,
      rawJson: raw,
    ),
    classification: classification,
    invoiceId: invoice.id,
    serial: invoice.invoiceSerial,
    issues: const [],
    malformedReasons: const [],
    rawJson: raw,
    invoice: invoice,
  );
}

LegacyInvoicePreflightReport _preflight(
  List<LegacyInvoicePreflightOccurrence> occurrences,
) {
  return LegacyInvoicePreflightReport(
    snapshotSha256: _snapshotHash,
    sourceExists: true,
    occurrences: occurrences,
  );
}

LegacyPartyCandidate _party(
  String id,
  String name,
  Set<LedgerPartyRole> roles,
) =>
    LegacyPartyCandidate(
      party: LedgerParty(id: id, displayName: name),
      roles: roles,
    );

void main() {
  const planner = LegacyInvoicePartyResolutionPlanner();

  test('resolves existing party IDs only when the required role is present', () {
    final report = planner.plan(
      preflight: _preflight([
        _occurrence(0, _invoice(
          id: 'sale',
          name: 'Customer',
          customerId: 'customer-1',
        )),
        _occurrence(1, _invoice(
          id: 'purchase',
          name: 'Supplier',
          customerId: 'supplier-1',
          action: 'شراء',
        )),
      ]),
      parties: [
        _party('customer-1', 'Customer', {LedgerPartyRole.customer}),
        _party('supplier-1', 'Supplier', {LedgerPartyRole.supplier}),
      ],
    );

    expect(report.resolvedCount, 2);
    expect(report.resolutions[0].status,
        LegacyPartyResolutionStatus.resolvedByExistingId);
    expect(report.resolutions[0].expectedRole, LedgerPartyRole.customer);
    expect(report.resolutions[1].status,
        LegacyPartyResolutionStatus.resolvedByExistingId);
    expect(report.resolutions[1].expectedRole, LedgerPartyRole.supplier);
  });

  test('storage documents require the customer role', () {
    final report = planner.plan(
      preflight: _preflight([
        _occurrence(0, _invoice(id: 'storage', name: 'Customer',
            customerId: 'party-1', action: 'تخزين')),
      ]),
      parties: [
        _party('party-1', 'Customer', {LedgerPartyRole.customer}),
      ],
    );

    expect(report.resolutions.single.isResolved, isTrue);
    expect(report.resolutions.single.expectedRole, LedgerPartyRole.customer);
  });

  test('resolves a unique normalized name only within the expected role', () {
    final report = planner.plan(
      preflight: _preflight([
        _occurrence(0, _invoice(id: 'sale', name: 'احمد علي')),
      ]),
      parties: [
        _party('customer-1', 'أحمد علي', {LedgerPartyRole.customer}),
      ],
    );

    final result = report.resolutions.single;
    expect(result.status, LegacyPartyResolutionStatus.resolvedByName);
    expect(result.partyId, 'customer-1');
  });

  test('does not use a customer as a supplier based on a matching name', () {
    final report = planner.plan(
      preflight: _preflight([
        _occurrence(0, _invoice(
          id: 'purchase',
          name: 'أحمد علي',
          action: 'شراء',
        )),
      ]),
      parties: [
        _party('customer-1', 'احمد علي', {LedgerPartyRole.customer}),
      ],
    );

    final result = report.resolutions.single;
    expect(result.status, LegacyPartyResolutionStatus.roleMismatch);
    expect(result.partyId, isNull);
    expect(result.candidatePartyIds, ['customer-1']);
  });

  test('holds ambiguous normalized names instead of selecting one', () {
    final report = planner.plan(
      preflight: _preflight([
        _occurrence(0, _invoice(id: 'sale', name: 'أحمد')),
      ]),
      parties: [
        _party('customer-1', 'أحمد', {LedgerPartyRole.customer}),
        _party('customer-2', 'احمد', {LedgerPartyRole.customer}),
      ],
    );

    final result = report.resolutions.single;
    expect(result.status, LegacyPartyResolutionStatus.ambiguousName);
    expect(result.candidatePartyIds, ['customer-1', 'customer-2']);
    expect(result.partyId, isNull);
  });

  test('holds an existing party ID when its role is incompatible', () {
    final report = planner.plan(
      preflight: _preflight([
        _occurrence(0, _invoice(
          id: 'sale',
          name: 'Customer',
          customerId: 'supplier-1',
        )),
      ]),
      parties: [
        _party('supplier-1', 'Customer', {LedgerPartyRole.supplier}),
      ],
    );

    expect(report.resolutions.single.status,
        LegacyPartyResolutionStatus.roleMismatch);
  });

  test('reports missing party IDs and names without creating parties', () {
    final report = planner.plan(
      preflight: _preflight([
        _occurrence(0, _invoice(
          id: 'id-missing',
          name: 'Customer',
          customerId: 'missing-id',
        )),
        _occurrence(1, _invoice(id: 'name-missing', name: 'Unknown')),
        _occurrence(2, _invoice(id: 'blank-name', name: '   ')),
      ]),
      parties: const [],
    );

    expect(report.count(LegacyPartyResolutionStatus.missingParty), 3);
    expect(report.resolvedCount, 0);
  });

  test('holds unknown invoice actions', () {
    final report = planner.plan(
      preflight: _preflight([
        _occurrence(0, _invoice(
          id: 'unknown',
          name: 'Customer',
          action: 'غير معروف',
        )),
      ]),
      parties: [
        _party('customer-1', 'Customer', {LedgerPartyRole.customer}),
      ],
    );

    expect(report.resolutions.single.status,
        LegacyPartyResolutionStatus.unknownAction);
    expect(report.resolutions.single.expectedRole, isNull);
  });

  test('holds preflight records that are not classified ready', () {
    final report = planner.plan(
      preflight: _preflight([
        _occurrence(
          0,
          _invoice(id: 'duplicate', name: 'Customer'),
          classification: LegacyInvoicePreflightClassification.duplicateIdentity,
        ),
      ]),
      parties: [
        _party('customer-1', 'Customer', {LedgerPartyRole.customer}),
      ],
    );

    expect(report.resolutions.single.status,
        LegacyPartyResolutionStatus.heldByPreflight);
  });

  test('keeps duplicate legacy invoice IDs distinct by source occurrence', () {
    final report = planner.plan(
      preflight: _preflight([
        _occurrence(0, _invoice(id: 'duplicate', name: 'Customer')),
        _occurrence(1, _invoice(id: 'duplicate', name: 'Customer')),
      ]),
      parties: [
        _party('customer-1', 'Customer', {LedgerPartyRole.customer}),
      ],
    );

    expect(report.resolutions, hasLength(2));
    expect(report.resolutions.map((item) => item.sourceOccurrenceKey).toSet(),
        hasLength(2));
    expect(report.resolutions.map((item) => item.sourceIndex), [0, 1]);
    expect(report.resolutions.every((item) => item.isResolved), isTrue);
  });
}
