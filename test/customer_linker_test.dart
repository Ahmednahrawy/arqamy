import 'dart:convert';
import 'dart:io';

import 'package:arqamy/core/database/app_database.dart' hide Invoice;
import 'package:arqamy/features/customerscreen/data/customer_linker.dart';
import 'package:arqamy/features/customerscreen/data/customer_registry.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _invoice(String id, String name, {String? customerId}) {
  return Invoice(
    id: id,
    customerName: name,
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
    paid: 0,
    rest: 50,
    formattedDate: 'Nov 21, 2026',
    formattedTime: '10:30',
    invoiceAction: 'بيع',
    invoiceSerial: id,
    customerId: customerId,
  );
}

void main() {
  late Directory temporaryDirectory;
  late AppDatabase database;
  late CustomerRegistry registry;
  late InvoiceProvider provider;
  String? stored;
  var failWrites = false;
  var backupCalls = 0;
  var backupFails = false;
  var customerIdsAtBackup = <String?>[];

  setUp(() async {
    stored = null;
    failWrites = false;
    backupCalls = 0;
    backupFails = false;
    customerIdsAtBackup = [];
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'arqamy_customer_linker_test_',
    );
    database = await AppDatabase.open(
      path: '${temporaryDirectory.path}${Platform.pathSeparator}linker.sqlite',
    );
    registry = CustomerRegistry(database);
    provider = InvoiceProvider.withStorageWriter((json) async {
      if (failWrites) return false;
      stored = json;
      return true;
    }, invoiceStorageReader: () async => stored);
  });

  tearDown(() async {
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  CustomerLinker linker() => CustomerLinker(
    provider: provider,
    registry: registry,
    backup: () async {
      backupCalls++;
      customerIdsAtBackup = provider.invoices
          .map((invoice) => invoice.customerId)
          .toList();
      if (backupFails) throw StateError('disk full');
    },
  );

  Future<void> seed(List<Invoice> invoices) async {
    for (final invoice in invoices) {
      await provider.saveInvoice(invoice);
    }
  }

  Map<String, String?> customerIds() => {
    for (final invoice in provider.invoices) invoice.id: invoice.customerId,
  };

  test('links single-spelling customers after taking a backup', () async {
    await seed([
      _invoice('a1', 'أحمد علي'),
      _invoice('a2', 'أحمد علي'),
      _invoice('m1', 'منى'),
    ]);

    final result = await linker().linkAutomaticMatches();

    expect(backupCalls, 1);
    expect(customerIdsAtBackup, [null, null, null]);
    expect(result.customersCreated, 2);
    expect(result.customersReused, 0);
    expect(result.invoicesLinked, 3);
    expect(result.groupsNeedingConfirmation, 0);
    final ids = customerIds();
    expect(ids.values, everyElement(isNotNull));
    expect(ids['a1'], ids['a2']);
    expect(ids['a1'], isNot(ids['m1']));
    final customers = await registry.listCustomers();
    expect(customers.map((c) => c.id).toSet(), ids.values.toSet());
    expect(stored, contains(ids['m1']!));
  });

  test('leaves groups with several spellings for the owner', () async {
    await seed([
      _invoice('a1', 'أحمد'),
      _invoice('a2', 'احمد'),
      _invoice('m1', 'منى'),
    ]);

    final result = await linker().linkAutomaticMatches();

    expect(result.groupsNeedingConfirmation, 1);
    expect(result.invoicesLinked, 1);
    final ids = customerIds();
    expect(ids['a1'], isNull);
    expect(ids['a2'], isNull);
    expect(ids['m1'], isNotNull);
    expect(await registry.listCustomers(), hasLength(1));
  });

  test('reuses a registered customer whose name matches', () async {
    final existing = await registry.createCustomer('أحمد علي');
    await seed([_invoice('a1', 'احمد علي')]);

    final result = await linker().linkAutomaticMatches();

    expect(result.customersReused, 1);
    expect(result.customersCreated, 0);
    expect(provider.invoices.single.customerId, existing.id);
    expect(await registry.listCustomers(), hasLength(1));
  });

  test('does not guess when the registry itself is ambiguous', () async {
    await registry.createCustomer('أحمد');
    await registry.createCustomer('احمد');
    await seed([_invoice('a1', 'أحمد')]);

    final result = await linker().linkAutomaticMatches();

    expect(result.invoicesLinked, 0);
    expect(result.groupsNeedingConfirmation, 1);
    expect(provider.invoices.single.customerId, isNull);
  });

  test('a failed backup stops everything before any change', () async {
    await seed([_invoice('a1', 'منى')]);
    backupFails = true;

    await expectLater(
      linker().linkAutomaticMatches(),
      throwsA(isA<StateError>()),
    );

    expect(provider.invoices.single.customerId, isNull);
    expect(await registry.listCustomers(), isEmpty);
  });

  test('nothing to link means no backup and no change', () async {
    await seed([
      _invoice('a1', 'منى', customerId: 'customer-1'),
      _invoice('b1', '   '),
    ]);

    final result = await linker().linkAutomaticMatches();

    expect(backupCalls, 0);
    expect(result.invoicesLinked, 0);
    expect(result.unnamedInvoices, 1);
    expect(provider.invoices.first.customerId, 'customer-1');
    expect(provider.invoices.last.customerId, isNull);
  });

  test(
    'a failed save changes no invoice and a retry reuses the customer',
    () async {
      await seed([_invoice('a1', 'منى')]);
      failWrites = true;

      await expectLater(
        linker().linkAutomaticMatches(),
        throwsA(isA<StateError>()),
      );

      expect(provider.invoices.single.customerId, isNull);
      final afterFailure = await registry.listCustomers();
      expect(afterFailure, hasLength(1));

      failWrites = false;
      final result = await linker().linkAutomaticMatches();

      expect(result.customersReused, 1);
      expect(result.customersCreated, 0);
      expect(provider.invoices.single.customerId, afterFailure.single.id);
      expect(await registry.listCustomers(), hasLength(1));
    },
  );

  test('invoices sharing one id are left unlinked', () async {
    stored = jsonEncode([
      _invoice('dup', 'منى').toJson(),
      _invoice('dup', 'سمير').toJson(),
      _invoice('ok', 'علي').toJson(),
    ]);

    final result = await linker().linkAutomaticMatches();

    expect(result.invoicesLinked, 1);
    expect(
      provider.invoices
          .where((invoice) => invoice.customerId != null)
          .map((invoice) => invoice.id),
      ['ok'],
    );
  });
}
