import 'package:arqamy/features/orderscreen/data/models/invoice.dart' as legacy;
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_import_planner.dart';
import 'package:arqamy/features/payment_ledger/data/legacy_invoice_audit.dart';
import 'package:flutter_test/flutter_test.dart';

const _egp = LedgerCurrency(
  code: 'EGP',
  minorUnitScale: 2,
  displayName: 'Egyptian pound',
);

legacy.Invoice _invoice({
  String id = 'a',
  String? action = 'بيع',
  String? customerId = 'customer-1',
  double total = 50,
  double paid = 20,
  double rest = 30,
  double weight = 10,
}) {
  return legacy.Invoice(
    id: id,
    customerName: 'أحمد',
    products: [
      Product(
        name: 'قمح',
        weight: weight,
        packageWeight: 0,
        numberPackage: 0,
        price: 5,
      ),
    ],
    totalCost: total,
    paid: paid,
    rest: rest,
    formattedDate: 'Nov 21, 2026',
    formattedTime: '10:30',
    invoiceAction: action,
    invoiceSerial: 'S-$id',
    customerId: customerId,
  );
}

LedgerImportPlanner _planner() => LedgerImportPlanner(currency: _egp);

void main() {
  test('a clean sale resolves party, role, currency and exact amounts', () {
    final plan = _planner().plan([_invoice()]);

    expect(plan.held, isEmpty);
    final item = plan.ready.single;
    expect(item.invoiceId, 'a');
    expect(item.partyId, 'customer-1');
    expect(item.partyRole, LedgerPartyRole.customer);

    final draft = item.draft;
    expect(draft.partyId, 'customer-1');
    expect(draft.partyRole, LedgerPartyRole.customer);
    expect(draft.currencyCode, 'EGP');
    expect(draft.action, LedgerInvoiceAction.sale);
    expect(draft.totalMinor, 5000);
    expect(draft.legacyRecordKey, 'saved_invoices/a');
    expect(draft.legacyInvoiceId, 'a');
    expect(draft.serial, 'S-a');
    expect(draft.legacyTotalValue, '50.0');
    expect(draft.legacyPaidValue, '20.0');
    expect(draft.legacyRemainingValue, '30.0');

    final line = draft.lines.single;
    expect(line.lineTotalMinor, 5000);
    expect(line.currencyCode, 'EGP');
    expect(line.quantityDecimal, '10.0');
    expect(line.unitPriceDecimal, '5.0');
    expect(line.productName, 'قمح');
  });

  test('a purchase belongs to the supplier role', () {
    final plan = _planner().plan([_invoice(action: 'شراء')]);

    expect(plan.ready.single.partyRole, LedgerPartyRole.supplier);
    expect(plan.ready.single.draft.action, LedgerInvoiceAction.purchase);
  });

  test('a storage invoice is a service for a customer, like a sale', () {
    final plan = _planner().plan([_invoice(action: 'تخزين')]);

    expect(plan.held, isEmpty);
    final item = plan.ready.single;
    expect(item.partyRole, LedgerPartyRole.customer);
    expect(item.draft.partyRole, LedgerPartyRole.customer);
    expect(item.draft.action, LedgerInvoiceAction.storage);
    expect(item.draft.currencyCode, 'EGP');
  });
  test('an invoice not linked to a customer is held, never guessed', () {
    final plan = _planner().plan([_invoice(customerId: null)]);

    expect(plan.ready, isEmpty);
    expect(plan.held.single.issues, [LegacyInvoiceIssue.noCustomerId]);
  });

  test('extra decimals are held and never rounded', () {
    final plan = _planner().plan([_invoice(total: 50.001, rest: 30.001)]);

    expect(plan.ready, isEmpty);
    expect(
      plan.held.single.issues,
      contains(LegacyInvoiceIssue.moreThanTwoDecimals),
    );
  });

  test('unknown type, overpayment and zero total are held', () {
    final plan = _planner().plan([
      _invoice(id: 'u', action: 'other'),
      _invoice(id: 'o', paid: 80, rest: -30),
      _invoice(id: 'z', weight: 0, total: 0, paid: 0, rest: 0),
    ]);

    expect(plan.ready, isEmpty);
    expect(plan.held.map((held) => held.invoiceId), ['u', 'o', 'z']);
    expect(
      plan.held[0].issues,
      contains(LegacyInvoiceIssue.unknownAction),
    );
    expect(plan.held[1].issues, contains(LegacyInvoiceIssue.overpaid));
    expect(plan.held[2].issues, contains(LegacyInvoiceIssue.zeroTotal));
  });

  test('invoices sharing an id are all held', () {
    final plan = _planner().plan([_invoice(), _invoice(), _invoice(id: 'ok')]);

    expect(plan.ready.map((item) => item.invoiceId), ['ok']);
    expect(plan.held, hasLength(2));
    expect(
      plan.held.every(
        (held) => held.issues.contains(LegacyInvoiceIssue.duplicateInvoiceId),
      ),
      isTrue,
    );
  });

  test('accounts needed are one per party and role', () {
    final plan = _planner().plan([
      _invoice(id: 'a'),
      _invoice(id: 'b'),
      _invoice(id: 'c', action: 'شراء'),
      _invoice(id: 'd', customerId: 'customer-2'),
    ]);

    expect(plan.accountsNeeded, {
      (partyId: 'customer-1', role: LedgerPartyRole.customer),
      (partyId: 'customer-1', role: LedgerPartyRole.supplier),
      (partyId: 'customer-2', role: LedgerPartyRole.customer),
    });
  });

  test('every resolved draft and line gets its own id and a unique key', () {
    final plan = _planner().plan([_invoice(id: 'a'), _invoice(id: 'b')]);

    final drafts = plan.ready.map((item) => item.draft).toList();
    expect(drafts.map((draft) => draft.id).toSet(), hasLength(2));
    expect(drafts.map((draft) => draft.legacyRecordKey).toSet(), hasLength(2));
    final lineIds = [for (final d in drafts) ...d.lines.map((l) => l.id)];
    expect(lineIds.toSet(), hasLength(2));
  });

  test('a currency with other than two decimals is not supported yet', () {
    expect(
      () => LedgerImportPlanner(
        currency: const LedgerCurrency(
          code: 'KWD',
          minorUnitScale: 3,
          displayName: 'Kuwaiti dinar',
        ),
      ),
      throwsArgumentError,
    );
  });

  test('an empty list gives an empty plan', () {
    final plan = _planner().plan([]);

    expect(plan.ready, isEmpty);
    expect(plan.held, isEmpty);
    expect(plan.accountsNeeded, isEmpty);
  });
}