import 'dart:io';

import 'package:arqamy/core/database/app_database.dart';
import 'package:arqamy/features/customerscreen/data/customer_registry.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase database;
  late LedgerFoundationRepository repository;
  late CustomerRegistry registry;
  var now = DateTime.utc(2026, 11, 24, 10);

  setUp(() async {
    now = DateTime.utc(2026, 11, 24, 10);
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'arqamy_customer_registry_test_',
    );
    database = await AppDatabase.open(
      path: '${temporaryDirectory.path}${Platform.pathSeparator}registry.sqlite',
    );
    repository = LedgerFoundationRepository(database, clock: () => now);
    registry = CustomerRegistry(
      database,
      repository: repository,
      clock: () => now,
    );
  });

  tearDown(() async {
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('creating a customer stores a cleaned name and the customer role',
      () async {
    final customer = await registry.createCustomer('  أحمد   علي ');

    expect(customer.id, isNotEmpty);
    expect(customer.displayName, 'أحمد علي');
    final listed = await registry.listCustomers();
    expect(listed.map((c) => c.id), [customer.id]);
    expect(listed.single.displayName, 'أحمد علي');
  });

  test('a blank name is rejected and creates nothing', () async {
    await expectLater(
      registry.createCustomer('   '),
      throwsA(isA<ArgumentError>()),
    );
    await expectLater(
      registry.createCustomer('\u0640\u200B'),
      throwsA(isA<ArgumentError>()),
    );
    expect(await registry.listCustomers(), isEmpty);
  });

  test('suppliers are not listed as customers', () async {
    final supplier = await repository.createParty(displayName: 'مورد');
    await repository.addPartyRole(
      partyId: supplier.id,
      role: LedgerPartyRole.supplier,
    );
    final customer = await registry.createCustomer('عميل');

    expect((await registry.listCustomers()).map((c) => c.id), [customer.id]);
    expect(await registry.findById(supplier.id), isNull);
  });

  test('customers are listed by name', () async {
    await registry.createCustomer('منى');
    await registry.createCustomer('علي');

    expect(
      (await registry.listCustomers()).map((c) => c.displayName),
      ['علي', 'منى'],
    );
  });

  test('renaming keeps the id and changes only the name and update time',
      () async {
    final customer = await registry.createCustomer('احمد');
    now = DateTime.utc(2026, 11, 24, 10, 5);

    await registry.rename(customer.id, '  أحمد علي ');

    expect((await registry.findById(customer.id))!.displayName, 'أحمد علي');
    final row = await database.select(database.parties).getSingle();
    expect(row.id, customer.id);
    expect(row.createdAt.isAtSameMomentAs(DateTime.utc(2026, 11, 24, 10)),
        isTrue);
    expect(row.updatedAt.isAtSameMomentAs(DateTime.utc(2026, 11, 24, 10, 5)),
        isTrue);
  });

  test('renaming to a blank name or an unknown customer fails', () async {
    final customer = await registry.createCustomer('منى');

    await expectLater(
      registry.rename(customer.id, '  '),
      throwsA(isA<ArgumentError>()),
    );
    await expectLater(
      registry.rename('missing-id', 'اسم'),
      throwsA(isA<StateError>()),
    );
    expect((await registry.findById(customer.id))!.displayName, 'منى');
  });

  test('findByName matches spelling variants and never invents a match',
      () async {
    final customer = await registry.createCustomer('أحمد علي');

    expect(
      (await registry.findByName('احمد  علي')).map((c) => c.id),
      [customer.id],
    );
    expect(await registry.findByName('منى'), isEmpty);
    expect(await registry.findByName('   '), isEmpty);
  });

  test('findOrCreateCustomer reuses the one matching customer', () async {
    final created = await registry.findOrCreateCustomer('منى');
    final again = await registry.findOrCreateCustomer(' منى ');

    expect(again.id, created.id);
    expect(await registry.listCustomers(), hasLength(1));
  });

  test('findOrCreateCustomer refuses to guess between several matches',
      () async {
    await registry.createCustomer('أحمد');
    await registry.createCustomer('احمد');

    await expectLater(
      registry.findOrCreateCustomer('أحمد'),
      throwsA(isA<AmbiguousCustomerNameException>()),
    );
    expect(await registry.listCustomers(), hasLength(2));
  });
}