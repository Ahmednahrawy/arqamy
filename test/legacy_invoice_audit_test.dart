import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/payment_ledger/data/legacy_invoice_audit.dart';
import 'package:flutter_test/flutter_test.dart';

Product _line(double weight, double price) => Product(
  name: 'قمح',
  weight: weight,
  packageWeight: 0,
  numberPackage: 0,
  price: price,
);

Invoice _invoice({
  String id = 'a',
  String? action = 'بيع',
  String? customerId = 'customer-1',
  List<Product>? products,
  double total = 50,
  double paid = 20,
  double rest = 30,
}) {
  return Invoice(
    id: id,
    customerName: 'أحمد',
    products: products ?? [_line(10, 5)],
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

void expectOnly(Invoice invoice, LegacyInvoiceIssue issue) {
  final report = LegacyInvoiceAudit.run([invoice]);
  expect(report.findings, hasLength(1));
  expect(report.findings.single.issues, [issue]);
}

void main() {
  test('a consistent invoice has no findings', () {
    final report = LegacyInvoiceAudit.run([_invoice()]);

    expect(report.invoiceCount, 1);
    expect(report.findings, isEmpty);
    expect(report.cleanCount, 1);
  });

  test('an empty list gives an empty report', () {
    final report = LegacyInvoiceAudit.run([]);

    expect(report.invoiceCount, 0);
    expect(report.cleanCount, 0);
  });

  test('unknown or missing type', () {
    expectOnly(_invoice(action: null), LegacyInvoiceIssue.unknownAction);
    expectOnly(_invoice(action: 'other'), LegacyInvoiceIssue.unknownAction);
  });

  test('a spelling variant of a known type is not flagged', () {
    expect(
      LegacyInvoiceAudit.run([_invoice(action: 'بي\u0640ع')]).findings,
      isEmpty,
    );
  });

  test('no customer ID yet', () {
    expectOnly(_invoice(customerId: null), LegacyInvoiceIssue.noCustomerId);
  });

  test('more than two decimals', () {
    expectOnly(
      _invoice(total: 50.001, rest: 30.001),
      LegacyInvoiceIssue.moreThanTwoDecimals,
    );
  });

  test('negative payment', () {
    expectOnly(
      _invoice(paid: -5, rest: 55),
      LegacyInvoiceIssue.negativePaid,
    );
  });

  test('negative total', () {
    expectOnly(
      _invoice(products: [_line(-10, 5)], total: -50, paid: 0, rest: 50),
      LegacyInvoiceIssue.negativeTotal,
    );
  });

  test('zero total', () {
    expectOnly(
      _invoice(products: [_line(0, 5)], total: 0, paid: 0, rest: 0),
      LegacyInvoiceIssue.zeroTotal,
    );
  });

  test('paid more than the total', () {
    expectOnly(_invoice(paid: 80, rest: -30), LegacyInvoiceIssue.overpaid);
  });

  test('remainder that is not total minus paid', () {
    expectOnly(
      _invoice(rest: 25),
      LegacyInvoiceIssue.restDiffersFromTotalMinusPaid,
    );
  });

  test('total that differs from the product lines', () {
    expectOnly(
      _invoice(total: 60, rest: 40),
      LegacyInvoiceIssue.totalDiffersFromLines,
    );
  });

  test('no products', () {
    final report = LegacyInvoiceAudit.run([
      _invoice(products: [], total: 0, paid: 0, rest: 0),
    ]);

    expect(
      report.findings.single.issues,
      unorderedEquals([
        LegacyInvoiceIssue.noProducts,
        LegacyInvoiceIssue.zeroTotal,
      ]),
    );
  });

  test('an amount too large to represent', () {
    expectOnly(
      _invoice(total: 1e15, rest: 1e15),
      LegacyInvoiceIssue.amountOutOfRange,
    );
  });

  test('duplicate invoice ids flag every copy', () {
    final report = LegacyInvoiceAudit.run([_invoice(), _invoice()]);

    expect(report.findings, hasLength(2));
    expect(
      report.findingsFor(LegacyInvoiceIssue.duplicateInvoiceId),
      hasLength(2),
    );
  });

  test('counts are reported per issue', () {
    final report = LegacyInvoiceAudit.run([
      _invoice(id: 'a', customerId: null),
      _invoice(id: 'b', customerId: null),
      _invoice(id: 'c'),
    ]);

    expect(report.cleanCount, 1);
    expect(report.countsByIssue, {LegacyInvoiceIssue.noCustomerId: 2});
    expect(
      report.findingsFor(LegacyInvoiceIssue.noCustomerId).map((f) => f.serial),
      ['S-a', 'S-b'],
    );
  });
}