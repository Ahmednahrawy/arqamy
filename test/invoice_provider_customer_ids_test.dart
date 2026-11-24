import 'dart:convert';

import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _invoice(String id, {String? customerId}) {
  return Invoice(
    id: id,
    customerName: 'أحمد',
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
    invoiceSerial: '1',
    customerId: customerId,
  );
}

void main() {
  String? stored;
  var failWrites = false;
  late InvoiceProvider provider;

  setUp(() {
    stored = null;
    failWrites = false;
    provider = InvoiceProvider.withStorageWriter((json) async {
      if (failWrites) return false;
      stored = json;
      return true;
    }, invoiceStorageReader: () async => stored);
  });

  test('withCustomerId changes only the customer ID', () {
    final original = _invoice('a');
    final linked = original.withCustomerId('customer-1');

    expect(linked.customerId, 'customer-1');
    expect(
      linked.toJson()..remove('customerId'),
      original.toJson(),
    );
  });

  test('links the listed invoices, saves them and notifies once', () async {
    await provider.saveInvoice(_invoice('a'));
    await provider.saveInvoice(_invoice('b'));
    var notifications = 0;
    provider.addListener(() => notifications++);

    final linked = await provider.assignCustomerIds({
      'a': 'customer-1',
      'missing': 'customer-2',
    });

    expect(linked, 1);
    expect(provider.invoices.map((i) => i.customerId), ['customer-1', null]);
    expect(notifications, 1);

    final reloaded = InvoiceProvider.withStorageWriter(
      (_) async => true,
      invoiceStorageReader: () async => stored,
    );
    await reloaded.loadInvoices();
    expect(reloaded.invoices.map((i) => i.customerId), ['customer-1', null]);
  });

  test('never overwrites an existing customer ID', () async {
    await provider.saveInvoice(_invoice('a', customerId: 'original'));

    final linked = await provider.assignCustomerIds({'a': 'other'});

    expect(linked, 0);
    expect(provider.invoices.single.customerId, 'original');
  });

  test('skips an id shared by several saved invoices', () async {
    stored = jsonEncode([
      _invoice('dup').toJson(),
      _invoice('dup').toJson(),
      _invoice('ok').toJson(),
    ]);
    await provider.loadInvoices();

    final linked = await provider.assignCustomerIds({
      'dup': 'customer-1',
      'ok': 'customer-2',
    });

    expect(linked, 1);
    expect(provider.invoices.map((i) => i.customerId), [
      null,
      null,
      'customer-2',
    ]);
  });

  test('an empty or unmatched request writes nothing', () async {
    await provider.saveInvoice(_invoice('a'));
    final before = stored;

    expect(await provider.assignCustomerIds({}), 0);
    expect(await provider.assignCustomerIds({'missing': 'customer-1'}), 0);
    expect(stored, before);
  });

  test('a blank customer ID is rejected', () async {
    await provider.saveInvoice(_invoice('a'));

    await expectLater(
      provider.assignCustomerIds({'a': '  '}),
      throwsA(isA<ArgumentError>()),
    );
    expect(provider.invoices.single.customerId, isNull);
  });

  test('a failed save leaves every invoice unchanged', () async {
    await provider.saveInvoice(_invoice('a'));
    await provider.saveInvoice(_invoice('b'));
    failWrites = true;

    await expectLater(
      provider.assignCustomerIds({'a': 'customer-1', 'b': 'customer-2'}),
      throwsA(isA<StateError>()),
    );

    expect(provider.invoices.map((i) => i.customerId), [null, null]);
  });
}