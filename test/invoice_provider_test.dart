import 'dart:async';
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

class _ControlledInvoiceStorage {
  bool _blockNextWrite = false;
  bool _failBlockedWrite = false;
  bool _returnFalseForNextWrite = false;
  bool _blockNextRead = false;
  bool _failNextRead = false;
  Completer<void>? _writeStarted;
  Completer<void>? _releaseWrite;
  Completer<void>? _readStarted;
  Completer<void>? _releaseRead;

  Completer<void> blockNextWrite({bool fail = false}) {
    _blockNextWrite = true;
    _failBlockedWrite = fail;
    _writeStarted = Completer<void>();
    _releaseWrite = Completer<void>();
    return _writeStarted!;
  }

  Completer<void> blockNextRead() {
    _blockNextRead = true;
    _readStarted = Completer<void>();
    _releaseRead = Completer<void>();
    return _readStarted!;
  }

  void returnFalseForNextWrite() => _returnFalseForNextWrite = true;
  void failNextRead() => _failNextRead = true;

  void releaseWrite() => _releaseWrite!.complete();
  void releaseRead() => _releaseRead!.complete();

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final invoicesJson = prefs.getString('saved_invoices');
    if (_blockNextRead) {
      _blockNextRead = false;
      _readStarted!.complete();
      await _releaseRead!.future;
    }
    if (_failNextRead) {
      _failNextRead = false;
      throw StateError('storage unavailable');
    }
    return invoicesJson;
  }

  Future<bool> write(String json) async {
    if (_blockNextWrite) {
      _blockNextWrite = false;
      _writeStarted!.complete();
      await _releaseWrite!.future;
      if (_failBlockedWrite) {
        throw StateError('storage unavailable');
      }
    }
    if (_returnFalseForNextWrite) {
      _returnFalseForNextWrite = false;
      return false;
    }

    return (await SharedPreferences.getInstance())
        .setString('saved_invoices', json);
  }
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

  test('concurrent saves both survive persistence and reload', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = _ControlledInvoiceStorage();
    final provider = InvoiceProvider.withStorageWriter(storage.write);
    final writeStarted = storage.blockNextWrite();

    final firstSave =
        provider.saveInvoice(_invoice(id: 'invoice-1', serial: '1'));
    final secondSave =
        provider.saveInvoice(_invoice(id: 'invoice-2', serial: '2'));
    await writeStarted.future;
    expect(provider.invoices, isEmpty);
    storage.releaseWrite();
    await Future.wait([firstSave, secondSave]);

    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(
      reloadedProvider.invoices.map((invoice) => invoice.id).toSet(),
      {'invoice-1', 'invoice-2'},
    );
  });

  test('load queued behind save reads and publishes the saved invoice',
      () async {
    SharedPreferences.setMockInitialValues({});
    final storage = _ControlledInvoiceStorage();
    final provider = InvoiceProvider.withStorageWriter(
      storage.write,
      invoiceStorageReader: storage.read,
    );
    final writeStarted = storage.blockNextWrite();
    final readStarted = storage.blockNextRead();
    final savedInvoice = _invoice(id: 'saved', serial: '1');

    final save = provider.saveInvoice(savedInvoice);
    await writeStarted.future;
    final load = provider.loadInvoices();
    storage.releaseWrite();
    await readStarted.future;
    expect(provider.invoices.single.id, savedInvoice.id);
    storage.releaseRead();
    await Future.wait([save, load]);

    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(
      provider.invoices.map((invoice) => invoice.toJson()).toList(),
      reloadedProvider.invoices.map((invoice) => invoice.toJson()).toList(),
    );
    expect(provider.invoices.single.id, savedInvoice.id);
  });

  test('load queued behind update does not restore stale invoice data',
      () async {
    SharedPreferences.setMockInitialValues({});
    final storage = _ControlledInvoiceStorage();
    final provider = InvoiceProvider.withStorageWriter(
      storage.write,
      invoiceStorageReader: storage.read,
    );
    final original = _invoice(id: 'invoice-1', serial: '1');
    await provider.saveInvoice(original);
    final writeStarted = storage.blockNextWrite();
    final readStarted = storage.blockNextRead();
    final updated = _invoice(
      id: original.id,
      serial: original.invoiceSerial,
      customerName: 'Updated customer',
    );

    final update = provider.updateInvoice(updated);
    await writeStarted.future;
    final load = provider.loadInvoices();
    storage.releaseWrite();
    await readStarted.future;
    expect(provider.invoices.single.customerName, updated.customerName);
    storage.releaseRead();
    await Future.wait([update, load]);

    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(
      provider.invoices.map((invoice) => invoice.toJson()).toList(),
      reloadedProvider.invoices.map((invoice) => invoice.toJson()).toList(),
    );
    expect(provider.invoices.single.customerName, updated.customerName);
  });

  test('load queued behind delete does not resurrect the invoice', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = _ControlledInvoiceStorage();
    final provider = InvoiceProvider.withStorageWriter(
      storage.write,
      invoiceStorageReader: storage.read,
    );
    final existing = _invoice(id: 'invoice-1', serial: '1');
    await provider.saveInvoice(existing);
    final writeStarted = storage.blockNextWrite();
    final readStarted = storage.blockNextRead();

    final delete = provider.deleteInvoice(existing.id);
    await writeStarted.future;
    final load = provider.loadInvoices();
    storage.releaseWrite();
    await readStarted.future;
    expect(provider.invoices, isEmpty);
    storage.releaseRead();
    await Future.wait([delete, load]);

    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(provider.invoices, isEmpty);
    expect(
      provider.invoices.map((invoice) => invoice.toJson()).toList(),
      reloadedProvider.invoices.map((invoice) => invoice.toJson()).toList(),
    );
  });

  test('failed load does not block a later mutation', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = _ControlledInvoiceStorage();
    final provider = InvoiceProvider.withStorageWriter(
      storage.write,
      invoiceStorageReader: storage.read,
    );
    final existing = _invoice(id: 'existing', serial: '1');
    await provider.saveInvoice(existing);
    storage.failNextRead();

    await expectLater(provider.loadInvoices(), throwsA(isA<StateError>()));
    expect(provider.invoices, [existing]);
    await provider.saveInvoice(_invoice(id: 'after-load-failure', serial: '2'));

    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(
      provider.invoices.map((invoice) => invoice.toJson()).toList(),
      reloadedProvider.invoices.map((invoice) => invoice.toJson()).toList(),
    );
    expect(
      provider.invoices.map((invoice) => invoice.id).toSet(),
      {'existing', 'after-load-failure'},
    );
  });

  test('false write preserves state and does not block later mutations',
      () async {
    SharedPreferences.setMockInitialValues({});
    final storage = _ControlledInvoiceStorage();
    final provider = InvoiceProvider.withStorageWriter(storage.write);
    final original = _invoice(id: 'original', serial: '1');
    await provider.saveInvoice(original);
    final prefs = await SharedPreferences.getInstance();
    final originalJson = prefs.getString('saved_invoices');
    storage.returnFalseForNextWrite();

    await expectLater(
      provider.saveInvoice(_invoice(id: 'rejected', serial: '2')),
      throwsA(isA<StateError>()),
    );
    expect(provider.invoices, [original]);
    expect(prefs.getString('saved_invoices'), originalJson);

    await provider.saveInvoice(_invoice(id: 'later', serial: '3'));
    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(
      provider.invoices.map((invoice) => invoice.toJson()).toList(),
      reloadedProvider.invoices.map((invoice) => invoice.toJson()).toList(),
    );
    expect(
      provider.invoices.map((invoice) => invoice.id).toSet(),
      {'original', 'later'},
    );
  });

  test('concurrent updates preserve both changes', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = _ControlledInvoiceStorage();
    final provider = InvoiceProvider.withStorageWriter(storage.write);
    final first = _invoice(id: 'invoice-1', serial: '1');
    final second = _invoice(id: 'invoice-2', serial: '2');
    await provider.saveInvoice(first);
    await provider.saveInvoice(second);
    final writeStarted = storage.blockNextWrite();

    final firstUpdate = provider.updateInvoice(
      _invoice(
          id: first.id,
          serial: first.invoiceSerial,
          customerName: 'First updated'),
    );
    final secondUpdate = provider.updateInvoice(
      _invoice(
          id: second.id,
          serial: second.invoiceSerial,
          customerName: 'Second updated'),
    );
    await writeStarted.future;
    storage.releaseWrite();
    await Future.wait([firstUpdate, secondUpdate]);

    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(
      reloadedProvider.invoices.map((invoice) => invoice.customerName).toSet(),
      {'First updated', 'Second updated'},
    );
  });

  test('concurrent save and delete preserve both successful changes', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = _ControlledInvoiceStorage();
    final provider = InvoiceProvider.withStorageWriter(storage.write);
    final existing = _invoice(id: 'existing', serial: '1');
    final added = _invoice(id: 'added', serial: '2');
    await provider.saveInvoice(existing);
    final writeStarted = storage.blockNextWrite();

    final save = provider.saveInvoice(added);
    final delete = provider.deleteInvoice(existing.id);
    await writeStarted.future;
    storage.releaseWrite();
    await Future.wait([save, delete]);

    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(reloadedProvider.invoices.map((invoice) => invoice.id), ['added']);
  });

  test('failed mutation does not block a later successful mutation', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = _ControlledInvoiceStorage();
    final provider = InvoiceProvider.withStorageWriter(storage.write);
    final original = _invoice(id: 'original', serial: '1');
    await provider.saveInvoice(original);
    final writeStarted = storage.blockNextWrite(fail: true);

    final failedUpdate = provider.updateInvoice(
      _invoice(
        id: original.id,
        serial: original.invoiceSerial,
        customerName: 'Failed update',
      ),
    );
    final laterSave = provider.saveInvoice(_invoice(id: 'later', serial: '2'));
    await writeStarted.future;
    storage.releaseWrite();

    await expectLater(failedUpdate, throwsA(isA<StateError>()));
    await laterSave;

    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(
      reloadedProvider.invoices.map((invoice) => invoice.id).toSet(),
      {'original', 'later'},
    );
    expect(
      reloadedProvider.invoices
          .firstWhere((invoice) => invoice.id == original.id)
          .customerName,
      original.customerName,
    );
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
