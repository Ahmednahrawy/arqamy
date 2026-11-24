import 'dart:io';

import 'package:arqamy/core/database/app_database.dart' hide Invoice;
import 'package:arqamy/features/customerscreen/data/customer_registry.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart' as legacy;
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation_repository.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_import_executor.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_import_planner.dart';
import 'package:flutter_test/flutter_test.dart';

const _egp = LedgerCurrency(
  code: 'EGP',
  minorUnitScale: 2,
  displayName: 'Egyptian pound',
);

legacy.Invoice _invoice(String id, String? customerId, {String action = 'بيع'}) {
  return legacy.Invoice(
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
    invoiceAction: action,
    invoiceSerial: 'S-$id',
    customerId: customerId,
  );
}

void main() {
  late Directory temporaryDirectory;
  late AppDatabase database;
  late CustomerRegistry registry;
  late LedgerFoundationRepository repository;
  var backupCalls = 0;
  var backupFails = false;
  var currencyRowsAtBackup = -1;

  setUp(() async {
    backupCalls = 0;
    backupFails = false;
    currencyRowsAtBackup = -1;
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'arqamy_ledger_import_test_',
    );
    database = await AppDatabase.open(
      path: '${temporaryDirectory.path}${Platform.pathSeparator}import.sqlite',
    );
    registry = CustomerRegistry(database);
    repository = LedgerFoundationRepository(database);
  });

  tearDown(() async {
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  LedgerImportExecutor executor() => LedgerImportExecutor(
    database,
    repository: repository,
    backup: () async {
      backupCalls++;
      currencyRowsAtBackup = (await database.select(
        database.currencies,
      ).get()).length;
      if (backupFails) throw StateError('disk full');
    },
  );

  LedgerImportPlan planFor(List<legacy.Invoice> invoices) =>
      LedgerImportPlanner(currency: _egp).plan(invoices);

  test('imports ready invoices with currency, roles and accounts', () async {
    final customer = await registry.createCustomer('منى');
    final plan = planFor([
      _invoice('a', customer.id),
      _invoice('b', customer.id, action: 'شراء'),
    ]);

    final result = await executor().execute(plan);

    expect(backupCalls, 1);
    expect(currencyRowsAtBackup, 0);
    expect(result.currencyAdded, isTrue);
    expect(result.rolesAdded, 1);
    expect(result.accountsCreated, 2);
    expect(result.invoicesImported, 2);
    expect(result.held, 0);

    final invoices = await database.select(database.invoices).get();
    expect(invoices, hasLength(2));
    expect(invoices.every((row) => row.financialAccountId != null), isTrue);
    expect(
      invoices.map((row) => row.partyRole).toSet(),
      {'customer', 'supplier'},
    );
    expect(invoices.every((row) => row.currencyCode == 'EGP'), isTrue);
    expect(invoices.every((row) => row.totalMinor == 5000), isTrue);
    expect(await database.select(database.invoiceLines).get(), hasLength(2));
    expect(await database.select(database.currencies).get(), hasLength(1));
    expect(
      await database.select(database.financialAccounts).get(),
      hasLength(2),
    );
  });

  test('a storage invoice is imported for the customer role', () async {
    final customer = await registry.createCustomer('منى');

    final result = await executor().execute(
      planFor([_invoice('a', customer.id, action: 'تخزين')]),
    );

    expect(result.invoicesImported, 1);
    final row = (await database.select(database.invoices).get()).single;
    expect(row.action, 'storage');
    expect(row.partyRole, 'customer');
  });

  test('running it again adds nothing', () async {
    final customer = await registry.createCustomer('منى');
    final invoices = [
      _invoice('a', customer.id),
      _invoice('b', customer.id, action: 'شراء'),
    ];
    await executor().execute(planFor(invoices));

    final second = await executor().execute(planFor(invoices));

    expect(second.currencyAdded, isFalse);
    expect(second.rolesAdded, 0);
    expect(second.accountsCreated, 0);
    expect(second.invoicesImported, 0);
    expect(second.invoicesAlreadyImported, 2);
    expect(await database.select(database.invoices).get(), hasLength(2));
    expect(
      await database.select(database.financialAccounts).get(),
      hasLength(2),
    );
  });

  test('invoices of the same party and role share one account', () async {
    final customer = await registry.createCustomer('منى');

    final result = await executor().execute(
      planFor([_invoice('a', customer.id), _invoice('b', customer.id)]),
    );

    expect(result.accountsCreated, 1);
    expect(result.invoicesImported, 2);
  });

  test('an unknown customer ID is skipped, never invented', () async {
    final result = await executor().execute(
      planFor([_invoice('a', 'no-such-party')]),
    );

    expect(result.skippedMissingParty, 1);
    expect(result.invoicesImported, 0);
    expect(await database.select(database.invoices).get(), isEmpty);
    expect(await database.select(database.financialAccounts).get(), isEmpty);
    expect(await database.select(database.parties).get(), isEmpty);
  });

  test('held invoices are never imported and need no backup', () async {
    final result = await executor().execute(planFor([_invoice('a', null)]));

    expect(result.held, 1);
    expect(backupCalls, 0);
    expect(await database.select(database.invoices).get(), isEmpty);
    expect(await database.select(database.currencies).get(), isEmpty);
  });

  test('a failed backup stops everything before any write', () async {
    final customer = await registry.createCustomer('منى');
    backupFails = true;

    await expectLater(
      executor().execute(planFor([_invoice('a', customer.id)])),
      throwsA(isA<StateError>()),
    );

    expect(await database.select(database.currencies).get(), isEmpty);
    expect(await database.select(database.invoices).get(), isEmpty);
  });

  test('a currency stored with other decimals stops the import', () async {
    final customer = await registry.createCustomer('منى');
    await repository.addCurrency(
      const LedgerCurrency(
        code: 'EGP',
        minorUnitScale: 3,
        displayName: 'Egyptian pound',
      ),
    );

    await expectLater(
      executor().execute(planFor([_invoice('a', customer.id)])),
      throwsA(isA<StateError>()),
    );

    expect(await database.select(database.invoices).get(), isEmpty);
    expect(await database.select(database.financialAccounts).get(), isEmpty);
  });
}