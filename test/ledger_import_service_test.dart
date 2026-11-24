import 'dart:convert';

import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_import_service.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _invoice(String id, {String? customerId}) {
  return Invoice(
    id: id,
    customerName: 'منى',
    products: [
      Product(
        name: 'قمح',
        weight: 10,
        packageWeight: 0,
        numberPackage: 0,
        price: 5,
      ),
    ],
    totalCost: 50,
    paid: 20,
    rest: 30,
    formattedDate: 'Nov 21, 2026',
    formattedTime: '10:30',
    invoiceAction: 'بيع',
    invoiceSerial: id,
    customerId: customerId,
  );
}

void main() {
  String? stored;
  late InvoiceProvider provider;

  setUp(() {
    stored = null;
    provider = InvoiceProvider.withStorageWriter(
      (_) async => true,
      invoiceStorageReader: () async => stored,
    );
  });

  test('the preview plans the saved invoices in confirmed EGP', () async {
    stored = jsonEncode([
      _invoice('a', customerId: 'customer-1').toJson(),
      _invoice('b').toJson(),
    ]);

    final plan = await LedgerImportService.preview(provider);

    expect(plan.currency.code, 'EGP');
    expect(plan.currency.minorUnitScale, 2);
    expect(plan.ready.map((item) => item.invoiceId), ['a']);
    expect(plan.held.map((held) => held.invoiceId), ['b']);
  });

  test('the preview reads storage again each time', () async {
    stored = jsonEncode([_invoice('a', customerId: 'customer-1').toJson()]);
    final first = await LedgerImportService.preview(provider);

    stored = jsonEncode([
      _invoice('a', customerId: 'customer-1').toJson(),
      _invoice('c', customerId: 'customer-2').toJson(),
    ]);
    final second = await LedgerImportService.preview(provider);

    expect(first.ready, hasLength(1));
    expect(second.ready, hasLength(2));
  });
}