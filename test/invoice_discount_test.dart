import 'dart:convert';

import 'package:arqamy/core/helpers/invoice_backup.dart';
import 'package:arqamy/core/helpers/invoice_discount.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _invoice({InvoiceDiscount? discount, double? subtotal}) {
  return Invoice(
    id: 'discount-invoice',
    customerName: 'Test customer',
    products: [
      Product(
        name: 'Rice',
        weight: 2,
        packageWeight: 0,
        numberPackage: 0,
        price: 10,
      ),
    ],
    totalCost: InvoiceDiscount.payableTotal(20, discount),
    paid: 5,
    rest: InvoiceDiscount.payableTotal(20, discount) - 5,
    formattedDate: 'Oct 28, 2026',
    formattedTime: '12:34',
    invoiceAction: 'sale',
    invoiceSerial: '1001',
    subtotalCost: discount == null ? null : (subtotal ?? 20),
    discount: discount,
  );
}

void main() {
  tearDown(() => InvoiceDiscount.lastUsedType = InvoiceDiscountType.amount);

  test('amount discount reduces the payable total by the entered amount', () {
    final discount = InvoiceDiscount.fromText('25', InvoiceDiscountType.amount, 200);

    expect(discount, isNotNull);
    expect(discount!.type, InvoiceDiscountType.amount);
    expect(discount.value, 25);
    expect(discount.amount, 25);
    expect(InvoiceDiscount.payableTotal(200, discount), 175);
  });

  test('percentage discount resolves to the rounded currency amount', () {
    final discount = InvoiceDiscount.fromText(
      '7.5',
      InvoiceDiscountType.percent,
      200,
    );

    expect(discount, isNotNull);
    expect(discount!.type, InvoiceDiscountType.percent);
    expect(discount.value, 7.5);
    expect(discount.amount, 15);
    expect(InvoiceDiscount.payableTotal(200, discount), 185);
  });

  test('validation rejects invalid, negative, over-percent and over-total input',
      () {
    expect(
      InvoiceDiscount.validateText('abc', InvoiceDiscountType.amount, 200),
      InvoiceDiscountValidationError.invalidNumber,
    );
    expect(
      InvoiceDiscount.validateText('-1', InvoiceDiscountType.amount, 200),
      InvoiceDiscountValidationError.negative,
    );
    expect(
      InvoiceDiscount.validateText('101', InvoiceDiscountType.percent, 200),
      InvoiceDiscountValidationError.percentOutOfRange,
    );
    expect(
      InvoiceDiscount.validateText('201', InvoiceDiscountType.amount, 200),
      InvoiceDiscountValidationError.exceedsSubtotal,
    );
    expect(
      InvoiceDiscount.validateText('', InvoiceDiscountType.amount, 200),
      isNull,
    );
  });

  test('100 percent discount leaves a zero payable total', () {
    final discount = InvoiceDiscount.fromText(
      '100',
      InvoiceDiscountType.percent,
      82.25,
    );

    expect(discount, isNotNull);
    expect(discount!.amount, 82.25);
    expect(InvoiceDiscount.payableTotal(82.25, discount), 0);
  });

  test('selected mode is remembered for the current app session', () {
    expect(InvoiceDiscount.lastUsedType, InvoiceDiscountType.amount);
    InvoiceDiscount.lastUsedType = InvoiceDiscountType.percent;
    expect(InvoiceDiscount.lastUsedType, InvoiceDiscountType.percent);
  });

  test('discount and payable total survive invoice JSON round trip', () {
    final discount = InvoiceDiscount.fromText(
      '10',
      InvoiceDiscountType.percent,
      20,
    );
    final original = _invoice(discount: discount);
    final json = original.toJson();
    final restored = Invoice.fromJson(json);

    expect(json['subtotalCost'], 20);
    expect(json['discount']['type'], 'percent');
    expect(json['discount']['value'], 10);
    expect(json['discount']['amount'], 2);
    expect(restored.subtotalCost, 20);
    expect(restored.discount!.type, InvoiceDiscountType.percent);
    expect(restored.discount!.value, 10);
    expect(restored.totalCost, 18);
  });

  test('backup decode keeps a percentage discount and rejects a tampered one',
      () {
    final discount = InvoiceDiscount.fromText(
      '5',
      InvoiceDiscountType.percent,
      20,
    );
    final text = InvoiceBackup.encode(
      [_invoice(discount: discount)],
      exportedAt: DateTime.utc(2026, 10, 28),
    );
    final restored = InvoiceBackup.decode(text).single;
    expect(restored.discount!.type, InvoiceDiscountType.percent);
    expect(restored.totalCost, 19);
    expect(restored.rest, 14);

    final root = jsonDecode(text) as Map<String, dynamic>;
    final invoices = root['invoices'] as List<dynamic>;
    final invoice = (invoices.single as Map<String, dynamic>);
    (invoice['discount'] as Map<String, dynamic>)['amount'] = 999;
    expect(
      () => InvoiceBackup.decode(jsonEncode(root)),
      throwsA(isA<InvoiceBackupFormatException>()),
    );
  });
}
