import 'package:arqamy/core/helpers/invoice_backup.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _invoice(String id, {String customer = 'أحمد'}) {
  return Invoice(
    id: id,
    customerName: customer,
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
  );
}

String _backupOf(List<Invoice> invoices) =>
    InvoiceBackup.encode(invoices, exportedAt: DateTime.utc(2026, 11, 21));

// The first change loads storage, so the reader is given explicitly instead
// of touching the real SharedPreferences.
InvoiceProvider _provider({bool Function()? failWrites}) =>
    InvoiceProvider.withStorageWriter(
      (_) async => !(failWrites?.call() ?? false),
      invoiceStorageReader: () async => null,
    );
void main() {
  test('an exported backup restores into an empty provider', () async {
    final source = _provider();
    await source.saveInvoice(_invoice('a'));
    await source.saveInvoice(_invoice('b'));
    final backup = source.exportBackup(now: DateTime.utc(2026, 11, 21));

    final target = _provider();
    final result = await target.restoreBackup(backup);

    expect(result.added, 2);
    expect(result.replaced, 0);
    expect(
      target.invoices.map((invoice) => invoice.toJson()),
      source.invoices.map((invoice) => invoice.toJson()),
    );
  });

  test('exporting with no invoices gives an empty valid backup', () {
    final backup = _provider().exportBackup(now: DateTime.utc(2026, 11, 21));

    expect(InvoiceBackup.decode(backup), isEmpty);
  });

  test(
    'restore replaces matching ids and keeps other saved invoices',
    () async {
      final provider = _provider();
      await provider.saveInvoice(_invoice('a', customer: 'Old'));
      await provider.saveInvoice(_invoice('keep'));

      final result = await provider.restoreBackup(
        _backupOf([_invoice('a', customer: 'New'), _invoice('c')]),
      );

      expect(result.added, 1);
      expect(result.replaced, 1);
      expect(result.total, 2);
      expect(provider.invoices.map((invoice) => invoice.id), [
        'a',
        'keep',
        'c',
      ]);
      expect(provider.invoices.first.customerName, 'New');
    },
  );

  test('restore notifies listeners once', () async {
    final provider = _provider();
    // The first change loads storage, which notifies once by itself.
    await provider.loadInvoices();
    var notifications = 0;
    provider.addListener(() => notifications++);

    await provider.restoreBackup(_backupOf([_invoice('a')]));
    expect(notifications, 1);
  });

  test('an invalid backup changes nothing and writes nothing', () async {
    var writes = 0;
    final provider = InvoiceProvider.withStorageWriter((_) async {
      writes++;
      return true;
    }, invoiceStorageReader: () async => null);
    await provider.saveInvoice(_invoice('a'));
    writes = 0;

    await expectLater(
      provider.restoreBackup('not json'),
      throwsA(isA<InvoiceBackupFormatException>()),
    );

    expect(writes, 0);
    expect(provider.invoices.map((invoice) => invoice.id), ['a']);
  });

  test('a failed storage write leaves the saved invoices unchanged', () async {
    var failing = false;
    final provider = _provider(failWrites: () => failing);
    await provider.saveInvoice(_invoice('a'));
    failing = true;

    await expectLater(
      provider.restoreBackup(_backupOf([_invoice('b')])),
      throwsA(isA<StateError>()),
    );

    expect(provider.invoices.map((invoice) => invoice.id), ['a']);
  });

  test(
    'previewRestore counts what a restore would change without changing it',
    () async {
      final provider = _provider();
      await provider.saveInvoice(_invoice('a'));
      await provider.saveInvoice(_invoice('keep'));
      final backup = _backupOf([
        _invoice('a', customer: 'New'),
        _invoice('c'),
        _invoice('d'),
      ]);

      final preview = provider.previewRestore(backup);

      expect(preview.added, 2);
      expect(preview.replaced, 1);
      expect(provider.invoices.map((invoice) => invoice.id), ['a', 'keep']);
      expect(provider.invoices.first.customerName, 'أحمد');
    },
  );

  test('previewRestore rejects an invalid backup', () {
    expect(
      () => _provider().previewRestore('not json'),
      throwsA(isA<InvoiceBackupFormatException>()),
    );
  });
}
