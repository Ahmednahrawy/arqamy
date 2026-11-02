import 'dart:io';

import 'package:arqamy/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'arqamy_database_test_',
    );
    databasePath =
        '${temporaryDirectory.path}${Platform.pathSeparator}ledger.sqlite';
    database = await AppDatabase.open(path: databasePath);
  });

  tearDown(() async {
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('initializes the ledger schema with version 3', () async {
    expect(database.schemaVersion, 3);
    expect(await database.storedSchemaVersion, 3);

    final tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%' ORDER BY name",
        )
        .map((row) => row.read<String>('name'))
        .get();
    expect(tables, [
      'cash_event_heads',
      'cash_event_versions',
      'cash_events',
      'currencies',
      'financial_accounts',
      'financial_transactions',
      'invoice_lines',
      'invoices',
      'parties',
      'party_roles',
      'payment_identities',
      'reconciliation_cases',
      'suspense_entries',
      'suspense_resolutions',
    ]);

    final foreignKeys = await database
        .customSelect('PRAGMA foreign_keys')
        .getSingle();
    expect(foreignKeys.read<bool>('foreign_keys'), isTrue);
  });

  test(
    'enforces party-role and currency-specific account relationships',
    () async {
      await _insertCurrency(database, 'EGP');
      await _insertParty(database, 'party-1');
      await database.customStatement(
        'INSERT INTO party_roles (party_id, role) VALUES (?, ?)',
        ['party-1', 'customer'],
      );
      await database.customStatement(
        'INSERT INTO financial_accounts '
        '(account_id, party_id, role, currency_code, created_at) '
        'VALUES (?, ?, ?, ?, ?)',
        ['account-egp', 'party-1', 'customer', 'EGP', 1],
      );

      await expectLater(
        database.customStatement(
          'INSERT INTO financial_accounts '
          '(account_id, party_id, role, currency_code, created_at) '
          'VALUES (?, ?, ?, ?, ?)',
          ['invalid-role', 'party-1', 'supplier', 'EGP', 1],
        ),
        throwsA(anything),
      );
      await expectLater(
        database.customStatement(
          'INSERT INTO financial_accounts '
          '(account_id, party_id, role, currency_code, created_at) '
          'VALUES (?, ?, ?, ?, ?)',
          ['invalid-currency', 'party-1', 'customer', 'USD', 1],
        ),
        throwsA(anything),
      );
    },
  );

  test(
    'supports storage invoices and enforces account and line currencies',
    () async {
      await _insertCurrency(database, 'EGP');
      await _insertCurrency(database, 'USD');
      await _insertParty(database, 'party-1');
      await database.customStatement(
        'INSERT INTO party_roles (party_id, role) VALUES (?, ?)',
        ['party-1', 'customer'],
      );
      await database.customStatement(
        'INSERT INTO financial_accounts '
        '(account_id, party_id, role, currency_code, created_at) '
        'VALUES (?, ?, ?, ?, ?)',
        ['account-egp', 'party-1', 'customer', 'EGP', 1],
      );
      await _insertInvoice(
        database,
        id: 'invoice-storage',
        serial: 'S-1',
        action: 'storage',
        partyId: 'party-1',
        role: 'customer',
        accountId: 'account-egp',
        currencyCode: 'EGP',
      );

      final action = await database
          .customSelect(
            'SELECT action FROM invoices WHERE invoice_id = ?',
            variables: [Variable.withString('invoice-storage')],
          )
          .getSingle();
      expect(action.read<String>('action'), 'storage');

      await database.customStatement(
        'INSERT INTO invoice_lines '
        '(invoice_line_id, invoice_id, line_index, product_name, currency_code) '
        'VALUES (?, ?, ?, ?, ?)',
        ['line-egp', 'invoice-storage', 0, 'Storage item', 'EGP'],
      );

      await expectLater(
        _insertInvoice(
          database,
          id: 'invoice-mismatch',
          serial: 'S-2',
          action: 'sale',
          partyId: 'party-1',
          role: 'customer',
          accountId: 'account-egp',
          currencyCode: 'USD',
        ),
        throwsA(anything),
      );
      await expectLater(
        database.customStatement(
          'INSERT INTO invoice_lines '
          '(invoice_line_id, invoice_id, line_index, product_name, currency_code) '
          'VALUES (?, ?, ?, ?, ?)',
          ['line-usd', 'invoice-storage', 1, 'Wrong currency', 'USD'],
        ),
        throwsA(anything),
      );
      await expectLater(
        database.customStatement(
          'INSERT INTO invoices '
          '(invoice_id, invoice_serial, action, created_at, updated_at) '
          'VALUES (?, ?, ?, ?, ?)',
          ['invalid-action', 'S-3', 'storage-sale', 1, 1],
        ),
        throwsA(anything),
      );
    },
  );

  test('upgrades a version 1 database without application tables', () async {
    await database.customStatement('PRAGMA foreign_keys = OFF');
    for (final table in [
      'suspense_entries',
      'suspense_resolutions',
      'reconciliation_cases',
      'cash_event_heads',
      'cash_event_versions',
      'financial_transactions',
      'cash_events',
      'payment_identities',
      'invoice_lines',
      'invoices',
      'financial_accounts',
      'party_roles',
      'parties',
      'currencies',
    ]) {
      await database.customStatement('DROP TABLE $table');
    }
    await database.customStatement('PRAGMA user_version = 1');
    await database.close();

    database = await AppDatabase.open(path: databasePath);

    expect(await database.storedSchemaVersion, 3);
    final tables = await database
        .customSelect(
          "SELECT COUNT(*) AS count FROM sqlite_master "
          "WHERE type = 'table' AND name IN "
          "('currencies', 'parties', 'party_roles', 'financial_accounts', "
          "'invoices', 'invoice_lines', 'payment_identities', 'cash_events', "
          "'financial_transactions', 'cash_event_versions', 'cash_event_heads', "
          "'reconciliation_cases', 'suspense_resolutions', 'suspense_entries')",
        )
        .getSingle();
    expect(tables.read<int>('count'), 14);
  });

  test('upgrades schema version 2 with Stage 3 tables and indexes', () async {
    await database.customStatement('PRAGMA foreign_keys = OFF');
    for (final table in [
      'suspense_entries',
      'suspense_resolutions',
      'reconciliation_cases',
      'cash_event_heads',
      'cash_event_versions',
      'financial_transactions',
      'cash_events',
      'payment_identities',
    ]) {
      await database.customStatement('DROP TABLE $table');
    }
    await database.customStatement('PRAGMA user_version = 2');
    await database.close();

    database = await AppDatabase.open(path: databasePath);

    expect(await database.storedSchemaVersion, 3);
    final stage3Tables = await database
        .customSelect(
          "SELECT COUNT(*) AS count FROM sqlite_master "
          "WHERE type = 'table' AND name IN "
          "('payment_identities', 'cash_events', 'financial_transactions', "
          "'cash_event_versions', 'cash_event_heads', "
          "'reconciliation_cases', 'suspense_resolutions', 'suspense_entries')",
        )
        .getSingle();
    expect(stage3Tables.read<int>('count'), 8);
    final trigger = await database
        .customSelect(
          "SELECT COUNT(*) AS count FROM sqlite_master WHERE type = 'trigger' "
          "AND name = 'financial_transactions_immutable_update'",
        )
        .getSingle();
    expect(trigger.read<int>('count'), 1);
  });

  test('commits and rolls back Drift transactions', () async {
    await database.customStatement(
      'CREATE TABLE transaction_probe (value TEXT NOT NULL)',
    );

    await database.transaction(() async {
      await database.customStatement(
        'INSERT INTO transaction_probe (value) VALUES (?)',
        ['committed'],
      );
    });

    expect(
      await database
          .customSelect('SELECT value FROM transaction_probe')
          .map((row) => row.read<String>('value'))
          .get(),
      ['committed'],
    );

    await expectLater(
      database.transaction(() async {
        await database.customStatement(
          'INSERT INTO transaction_probe (value) VALUES (?)',
          ['rolled back'],
        );
        throw StateError('Force transaction rollback');
      }),
      throwsA(isA<StateError>()),
    );

    expect(
      await database
          .customSelect('SELECT value FROM transaction_probe')
          .map((row) => row.read<String>('value'))
          .get(),
      ['committed'],
    );
  });

  test(
    'persists committed values after closing and reopening SQLite',
    () async {
      await database.customStatement(
        'CREATE TABLE transaction_probe (value TEXT NOT NULL)',
      );

      await database.transaction(() async {
        await database.customStatement(
          'INSERT INTO transaction_probe (value) VALUES (?)',
          ['persisted across reopen'],
        );
      });

      await database.close();
      database = await AppDatabase.open(path: databasePath);

      expect(
        await database
            .customSelect('SELECT value FROM transaction_probe')
            .map((row) => row.read<String>('value'))
            .get(),
        ['persisted across reopen'],
      );
    },
  );
}

Future<void> _insertCurrency(AppDatabase database, String code) {
  return database.customStatement(
    'INSERT INTO currencies (currency_code, minor_unit_scale, display_name) '
    'VALUES (?, ?, ?)',
    [code, 2, code],
  );
}

Future<void> _insertParty(AppDatabase database, String id) {
  return database.customStatement(
    'INSERT INTO parties (party_id, display_name, created_at, updated_at) '
    'VALUES (?, ?, ?, ?)',
    [id, id, 1, 1],
  );
}

Future<void> _insertInvoice(
  AppDatabase database, {
  required String id,
  required String serial,
  required String action,
  required String partyId,
  required String role,
  required String accountId,
  required String currencyCode,
}) {
  return database.customStatement(
    'INSERT INTO invoices '
    '(invoice_id, invoice_serial, action, party_id, party_role, '
    'financial_account_id, currency_code, created_at, updated_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [id, serial, action, partyId, role, accountId, currencyCode, 1, 1],
  );
}
