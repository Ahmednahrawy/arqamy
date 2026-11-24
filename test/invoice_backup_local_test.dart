import 'dart:io';

import 'package:arqamy/core/helpers/invoice_backup.dart';
import 'package:arqamy/core/services/invoice_backup_service.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _invoice(String id) {
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
    invoiceSerial: id,
  );
}

void main() {
  late Directory temporaryDirectory;
  String? stored;
  late InvoiceProvider provider;

  setUp(() async {
    stored = null;
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'arqamy_local_backup_test_',
    );
    provider = InvoiceProvider.withStorageWriter((json) async {
      stored = json;
      return true;
    }, invoiceStorageReader: () async => stored);
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  test('writes a readable backup of every saved invoice', () async {
    await provider.saveInvoice(_invoice('a'));
    await provider.saveInvoice(_invoice('b'));
    final folder = Directory('${temporaryDirectory.path}/nested/backups');

    final file = await InvoiceBackupService.saveLocalBackup(
      provider,
      now: DateTime(2026, 11, 24, 10, 5),
      directory: folder,
    );

    expect(file.path, endsWith('auto-arqamy-backup-20261124-1005.json'));
    final restored = InvoiceBackup.decode(await file.readAsString());
    expect(restored.map((invoice) => invoice.id), ['a', 'b']);
  });

  test('backs up invoices that were saved earlier but not loaded yet',
      () async {
    final other = InvoiceProvider.withStorageWriter((json) async {
      stored = json;
      return true;
    });
    await other.saveInvoice(_invoice('saved-earlier'));

    final file = await InvoiceBackupService.saveLocalBackup(
      provider,
      directory: temporaryDirectory,
    );

    final restored = InvoiceBackup.decode(await file.readAsString());
    expect(restored.map((invoice) => invoice.id), ['saved-earlier']);
  });
}