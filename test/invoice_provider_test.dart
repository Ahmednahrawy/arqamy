import 'dart:convert';

import 'package:arqamy/features/customerscreen/ui/widgets/edit_invoice_dialog.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Invoice _invoice({
  required String id,
  required String serial,
  String customerName = 'Customer',
  double paid = 0,
}) {
  return Invoice(
    id: id,
    customerName: customerName,
    products: [
      Product(
        name: 'Rice',
        weight: 2,
        packageWeight: 0,
        numberPackage: 0,
        price: 10,
      ),
    ],
    totalCost: 20,
    paid: paid,
    rest: 20 - paid,
    formattedDate: 'Oct 28, 2026',
    formattedTime: '12:34',
    invoiceSerial: serial,
  );
}

void main() {
  test('caches product summaries and invalidates them after changes', () {
    final provider = InvoiceProvider();
    final firstProduct = Product(
      name: 'Rice',
      weight: 10,
      packageWeight: 1,
      numberPackage: 1,
      price: 5,
    );

    expect(firstProduct.netWeight, 9);
    expect(firstProduct.totalPrice, 45);
    provider.addProduct(firstProduct);
    final productsView = provider.products;
    final groupedProducts = provider.groupedProducts;

    expect(provider.totalCost, 45);
    expect(provider.hasPackageProducts, isTrue);
    expect(identical(provider.products, productsView), isTrue);
    expect(identical(provider.groupedProducts, groupedProducts), isTrue);

    provider.addProduct(
      Product(
        name: 'Rice',
        weight: 5,
        packageWeight: 1,
        numberPackage: 1,
        price: 5,
      ),
    );

    expect(productsView, hasLength(1));
    expect(provider.products, hasLength(2));
    expect(provider.totalCost, 65);
    expect(provider.groupedProducts, hasLength(1));
    expect(identical(provider.groupedProducts, groupedProducts), isFalse);

    provider.updateProduct(
      1,
      Product(
        name: 'Beans',
        weight: 4,
        packageWeight: 0,
        numberPackage: 0,
        price: 10,
      ),
    );
    expect(provider.totalCost, 85);
    expect(provider.groupedProducts, hasLength(2));

    provider.removeProductAt(1);
    expect(provider.totalCost, 45);
    provider.clearInvoice();
    expect(provider.totalCost, 0);
    expect(provider.hasPackageProducts, isFalse);
    expect(provider.groupedProducts, isEmpty);
  });
  test('deleting an invoice removes it from persistent storage', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    final invoice = Invoice(
      id: 'invoice-1',
      customerName: 'Customer',
      products: [
        Product(
          name: 'Rice',
          weight: 2,
          packageWeight: 0,
          numberPackage: 0,
          price: 10,
        ),
      ],
      totalCost: 20,
      paid: 0,
      rest: 20,
      formattedDate: '2026-10-20',
      formattedTime: '08:00',
      invoiceSerial: '1001',
    );

    await provider.saveInvoice(invoice);
    await provider.deleteInvoice(invoice.id);

    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(reloadedProvider.invoices, isEmpty);
  });

  test('same-second invoices have unique IDs and survive save and reload',
      () async {
    SharedPreferences.setMockInitialValues({});
    const sameSecondSerial = '20261028123456';
    final provider = InvoiceProvider();
    provider.prepareDraft();
    final firstId = provider.draftInvoiceId;
    provider.setCustomerName('Customer');
    provider.setInvoiceAction('شراء');
    provider.addProduct(
      Product(
        name: 'Rice',
        weight: 2,
        packageWeight: 0,
        numberPackage: 0,
        price: 10,
      ),
    );
    expect(provider.draftInvoiceId, firstId);
    provider.prepareDraft();
    expect(provider.draftInvoiceId, firstId);
    final first = _invoice(id: firstId, serial: sameSecondSerial);
    provider.clearInvoice();
    final secondId = provider.draftInvoiceId;
    final second = _invoice(id: secondId, serial: sameSecondSerial);

    expect(first.id, isNot(second.id));
    expect(
      first.id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );

    await provider.saveInvoice(first);
    await provider.saveInvoice(second);

    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(reloadedProvider.invoices, hasLength(2));
    expect(
      reloadedProvider.invoices.map((invoice) => invoice.id).toSet(),
      {first.id, second.id},
    );
    expect(
      reloadedProvider.invoices.map((invoice) => invoice.invoiceSerial),
      [sameSecondSerial, sameSecondSerial],
    );
  });

  test('saving the same invoice repeatedly updates rather than duplicates',
      () async {
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    final draft = _invoice(id: provider.draftInvoiceId, serial: '1001');

    await provider.saveInvoice(draft);
    await provider.saveInvoice(draft);

    expect(provider.invoices, hasLength(1));
    expect(provider.invoices.single.id, draft.id);
    expect(provider.invoices.single.invoiceSerial, draft.invoiceSerial);
  });

  test('updating and deleting one invoice preserves the other', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    final first = _invoice(id: 'invoice-1', serial: '1001');
    final second = _invoice(id: 'invoice-2', serial: '1002');
    await provider.saveInvoice(first);
    await provider.saveInvoice(second);

    final editedFirst = _invoice(
      id: first.id,
      serial: first.invoiceSerial,
      customerName: 'Updated customer',
      paid: 5,
    );
    await provider.updateInvoice(editedFirst);
    expect(provider.invoices, hasLength(2));
    expect(provider.invoices.first.id, first.id);
    expect(provider.invoices.first.invoiceSerial, first.invoiceSerial);
    expect(provider.invoices.first.customerName, 'Updated customer');
    expect(provider.invoices.last.id, second.id);
    expect(provider.invoices.last.invoiceSerial, second.invoiceSerial);

    await provider.deleteInvoice(second.id);
    expect(provider.invoices, hasLength(1));
    expect(provider.invoices.single.id, editedFirst.id);
    expect(provider.invoices.single.invoiceSerial, editedFirst.invoiceSerial);

    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(reloadedProvider.invoices, hasLength(1));
    expect(reloadedProvider.invoices.single.id, editedFirst.id);
    expect(
      reloadedProvider.invoices.single.invoiceSerial,
      editedFirst.invoiceSerial,
    );
  });

  test('failed invoice update preserves memory and persisted contents',
      () async {
    var failWrites = false;
    var persistedJson = '';
    final provider = InvoiceProvider.withStorageWriter((json) async {
      if (failWrites) throw StateError('storage unavailable');
      persistedJson = json;
      return true;
    });
    final original = _invoice(id: 'legacy-id', serial: 'legacy-serial');
    await provider.saveInvoice(original);
    final originalPersistedJson = persistedJson;
    final replacement = _invoice(
      id: original.id,
      serial: original.invoiceSerial,
      customerName: 'Changed customer',
      paid: 10,
    );
    failWrites = true;

    await expectLater(
      provider.updateInvoice(replacement),
      throwsA(isA<StateError>()),
    );

    expect(provider.invoices, [original]);
    expect(persistedJson, originalPersistedJson);
    expect(json.decode(persistedJson).single['customerName'], 'Customer');
  });

  test('legacy invoice IDs and serials survive load and save', () async {
    const legacyId = 'INV_20261020_080000';
    const legacySerial = '20261020080000';
    final legacyInvoice = _invoice(id: legacyId, serial: legacySerial);
    SharedPreferences.setMockInitialValues({
      'saved_invoices': json.encode([legacyInvoice.toJson()]),
    });

    final provider = InvoiceProvider();
    await provider.loadInvoices();
    expect(provider.invoices.single.id, legacyId);
    expect(provider.invoices.single.invoiceSerial, legacySerial);

    await provider.updateInvoice(
      _invoice(
        id: legacyId,
        serial: legacySerial,
        customerName: 'Legacy customer edited',
      ),
    );
    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(reloadedProvider.invoices.single.id, legacyId);
    expect(reloadedProvider.invoices.single.invoiceSerial, legacySerial);
    expect(
      reloadedProvider.invoices.single.customerName,
      'Legacy customer edited',
    );
  });

  testWidgets('failed edit reports an error and keeps the original invoice',
      (tester) async {
    final original = _invoice(id: 'invoice-1', serial: '1001');
    var failWrites = false;
    final provider = InvoiceProvider.withStorageWriter((json) async {
      if (failWrites) throw StateError('storage unavailable');
      return true;
    });
    await provider.saveInvoice(original);
    failWrites = true;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => EditInvoiceDialog(invoice: original),
                ),
                child: const Text('Open edit'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ التغييرات'));
    await tester.pumpAndSettle();

    expect(provider.invoices, [original]);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.textContaining('تعذر حفظ تعديلات الفاتورة'), findsOneWidget);
  });

  test('customer balance subtracts sales from purchases', () {
    Invoice invoice({
      required String id,
      required String action,
      required double rest,
    }) {
      return Invoice(
        id: id,
        customerName: 'Customer',
        products: const [],
        totalCost: rest,
        paid: 0,
        rest: rest,
        formattedDate: '2026-10-20',
        formattedTime: '08:00',
        invoiceAction: action,
        invoiceSerial: id,
      );
    }

    final balance = InvoiceProvider.calculateCustomerBalance([
      invoice(id: 'buy-1', action: 'شراء', rest: 125),
      invoice(id: 'buy-2', action: 'شراء', rest: 550),
      invoice(id: 'sale-1', action: 'بـيع', rest: 375),
      invoice(id: 'storage-1', action: 'تخزين', rest: 900),
    ]);

    expect(balance, 300);
  });
}
