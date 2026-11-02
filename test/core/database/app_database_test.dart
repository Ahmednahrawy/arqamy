import 'dart:io';

import 'package:arqamy/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

part 'app_database_test.g.dart';

@DriftDatabase(
  tables: [
    Currencies,
    Parties,
    PartyRoles,
    FinancialAccounts,
    Invoices,
    InvoiceLines,
  ],
)
class Stage2Database extends _$Stage2Database {
  Stage2Database(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createAll();
    },
  );
}

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

  test('migrates a genuine Stage 2 database without losing records', () async {
    await database.close();
    await File(databasePath).delete();
    final stage2 = Stage2Database(
      NativeDatabase(
        File(databasePath),
        setup: (database) => database.execute('PRAGMA foreign_keys = ON'),
      ),
    );
    expect(
      (await stage2.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      2,
    );

    await stage2.customStatement('INSERT INTO currencies VALUES (?, ?, ?)', [
      'EGP',
      2,
      'Egyptian pound',
    ]);
    await stage2.customStatement('INSERT INTO parties VALUES (?, ?, ?, ?)', [
      'party-v2',
      'Stage 2 party',
      1710000000000,
      1710000001000,
    ]);
    await stage2.customStatement('INSERT INTO party_roles VALUES (?, ?)', [
      'party-v2',
      'customer',
    ]);
    await stage2.customStatement(
      'INSERT INTO financial_accounts VALUES (?, ?, ?, ?, ?)',
      ['account-v2', 'party-v2', 'customer', 'EGP', 1710000002000],
    );
    await stage2.customStatement(
      'INSERT INTO invoices ('
      'invoice_id, invoice_serial, legacy_record_key, legacy_invoice_id, '
      'source_json, party_id, party_role, financial_account_id, currency_code, '
      'action, legacy_action, total_minor, legacy_total_value, legacy_paid_value, '
      'legacy_remaining_value, issued_at, created_at, updated_at'
      ') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'invoice-v2',
        'SERIAL-002',
        'source-occurrence-002',
        'legacy-002',
        '{"evidence":"preserve"}',
        'party-v2',
        'customer',
        'account-v2',
        'EGP',
        'sale',
        'sale',
        123456,
        '1234.56',
        '100.00',
        '1134.56',
        1710000003000,
        1710000004000,
        1710000005000,
      ],
    );
    await stage2.customStatement(
      'INSERT INTO invoice_lines ('
      'invoice_line_id, invoice_id, line_index, product_name, '
      'quantity_decimal, package_weight_decimal, package_count, '
      'unit_price_decimal, line_total_minor, currency_code, source_json'
      ') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'line-v2',
        'invoice-v2',
        0,
        'Preserved item',
        '2.500',
        '1.250',
        2,
        '49.3824',
        123456,
        'EGP',
        '{"line":"original"}',
      ],
    );
    await stage2.close();

    database = await AppDatabase.open(path: databasePath);

    expect(await database.storedSchemaVersion, 3);
    expect(
      await database
          .customSelect('SELECT * FROM currencies')
          .get()
          .then((rows) => rows.single.data),
      {
        'currency_code': 'EGP',
        'minor_unit_scale': 2,
        'display_name': 'Egyptian pound',
      },
    );
    expect(
      await database
          .customSelect('SELECT * FROM parties')
          .get()
          .then((rows) => rows.single.data),
      {
        'party_id': 'party-v2',
        'display_name': 'Stage 2 party',
        'created_at': 1710000000000,
        'updated_at': 1710000001000,
      },
    );
    expect(
      await database
          .customSelect('SELECT * FROM party_roles')
          .get()
          .then((rows) => rows.single.data),
      {'party_id': 'party-v2', 'role': 'customer'},
    );
    expect(
      await database
          .customSelect('SELECT * FROM financial_accounts')
          .get()
          .then((rows) => rows.single.data),
      {
        'account_id': 'account-v2',
        'party_id': 'party-v2',
        'role': 'customer',
        'currency_code': 'EGP',
        'created_at': 1710000002000,
      },
    );
    final invoice = await database
        .customSelect(
          'SELECT * FROM invoices WHERE invoice_id = ?',
          variables: [Variable.withString('invoice-v2')],
        )
        .getSingle();
    expect(invoice.data, {
      'invoice_id': 'invoice-v2',
      'invoice_serial': 'SERIAL-002',
      'legacy_record_key': 'source-occurrence-002',
      'legacy_invoice_id': 'legacy-002',
      'source_json': '{"evidence":"preserve"}',
      'party_id': 'party-v2',
      'party_role': 'customer',
      'financial_account_id': 'account-v2',
      'currency_code': 'EGP',
      'action': 'sale',
      'legacy_action': 'sale',
      'total_minor': 123456,
      'legacy_total_value': '1234.56',
      'legacy_paid_value': '100.00',
      'legacy_remaining_value': '1134.56',
      'issued_at': 1710000003000,
      'created_at': 1710000004000,
      'updated_at': 1710000005000,
    });
    final line = await database
        .customSelect(
          'SELECT * FROM invoice_lines WHERE invoice_line_id = ?',
          variables: [Variable.withString('line-v2')],
        )
        .getSingle();
    expect(line.data, {
      'invoice_line_id': 'line-v2',
      'invoice_id': 'invoice-v2',
      'line_index': 0,
      'product_name': 'Preserved item',
      'quantity_decimal': '2.500',
      'package_weight_decimal': '1.250',
      'package_count': 2,
      'unit_price_decimal': '49.3824',
      'line_total_minor': 123456,
      'currency_code': 'EGP',
      'source_json': '{"line":"original"}',
    });

    const stage3Tables = [
      'payment_identities',
      'cash_events',
      'financial_transactions',
      'cash_event_versions',
      'cash_event_heads',
      'reconciliation_cases',
      'suspense_resolutions',
      'suspense_entries',
    ];
    for (final table in stage3Tables) {
      final found = await database
          .customSelect(
            "SELECT COUNT(*) AS count FROM sqlite_master "
            "WHERE type = 'table' AND name = ?",
            variables: [Variable.withString(table)],
          )
          .getSingle();
      expect(found.read<int>('count'), 1, reason: 'Missing table $table');
    }

    const stage3Indexes = [
      'financial_transactions_event_time',
      'financial_transactions_account_time',
      'cash_event_versions_event_sequence',
      'suspense_entries_case_time',
      'suspense_entries_account_currency',
    ];
    for (final index in stage3Indexes) {
      final found = await database
          .customSelect(
            "SELECT COUNT(*) AS count FROM sqlite_master "
            "WHERE type = 'index' AND name = ?",
            variables: [Variable.withString(index)],
          )
          .getSingle();
      expect(found.read<int>('count'), 1, reason: 'Missing index $index');
    }

    for (final table in stage3Tables) {
      final foreignKeys = await database
          .customSelect('PRAGMA foreign_key_list($table)')
          .get();
      expect(foreignKeys, isNotEmpty, reason: 'Missing foreign keys in $table');
    }
    final triggers = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'trigger' "
          "AND name LIKE '%_immutable_%' ORDER BY name",
        )
        .map((row) => row.read<String>('name'))
        .get();
    expect(
      triggers,
      unorderedEquals([
        for (final table in [
          'cash_events',
          'cash_event_versions',
          'financial_transactions',
          'payment_identities',
          'reconciliation_cases',
          'suspense_entries',
          'suspense_resolutions',
        ]) ...['${table}_immutable_delete', '${table}_immutable_update'],
      ]),
    );

    await _insertStage3MigrationRows(database);
    for (final table in [
      'payment_identities',
      'cash_events',
      'financial_transactions',
      'cash_event_versions',
      'reconciliation_cases',
      'suspense_resolutions',
      'suspense_entries',
    ]) {
      await expectLater(
        database.customStatement('UPDATE $table SET rowid = rowid'),
        throwsA(anything),
        reason: '$table update trigger must protect migrated history',
      );
      await expectLater(
        database.customStatement('DELETE FROM $table'),
        throwsA(anything),
        reason: '$table delete trigger must protect migrated history',
      );
    }

    final foreignKeyViolations = await database
        .customSelect('PRAGMA foreign_key_check')
        .get();
    expect(foreignKeyViolations, isEmpty);
    final integrity = await database
        .customSelect('PRAGMA integrity_check')
        .getSingle();
    expect(integrity.read<String>('integrity_check'), 'ok');
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

Future<void> _insertStage3MigrationRows(AppDatabase database) async {
  const timestamp = 1710000006000;
  await database.customStatement(
    'INSERT INTO payment_identities VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'payment-migration',
      'account-v2',
      'party-v2',
      'customer',
      'EGP',
      'in',
      'migration-test',
      timestamp,
    ],
  );
  await database.customStatement(
    'INSERT INTO cash_events VALUES (?, ?, ?, ?)',
    ['event-migration', 'payment-migration', 'migration-test', timestamp],
  );
  await database.customStatement(
    'INSERT INTO financial_transactions VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'transaction-migration',
      'event-migration',
      'payment-migration',
      'account-v2',
      'party-v2',
      'customer',
      'EGP',
      'payment',
      'in',
      1000,
      null,
      'migration-test',
      'migration seed',
      'transaction-migration-key',
      timestamp,
    ],
  );
  await database.customStatement(
    'INSERT INTO cash_event_versions VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'version-migration',
      'event-migration',
      'payment-migration',
      1,
      'original',
      'yes',
      'in',
      1000,
      1000,
      'transaction-migration',
      null,
      'version-migration-key',
      '{"source":"migration test"}',
      'migration-test',
      'migration seed',
      timestamp,
    ],
  );
  await database.customStatement(
    'INSERT INTO cash_event_heads VALUES (?, ?, ?, ?, ?)',
    ['event-migration', 'payment-migration', 'version-migration', 1, timestamp],
  );
  await database.customStatement(
    'INSERT INTO reconciliation_cases VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'case-migration',
      'event-migration',
      'payment-migration',
      'account-v2',
      'party-v2',
      'customer',
      'EGP',
      'migration test case',
      'migration-test',
      timestamp,
    ],
  );
  await database.customStatement(
    'INSERT INTO suspense_resolutions VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'resolution-migration',
      'case-migration',
      'event-migration',
      'payment-migration',
      'account-v2',
      'party-v2',
      'customer',
      'EGP',
      100,
      'migration-test',
      'approver-test',
      'approval-migration',
      'migration resolution',
      'resolution-migration-key',
      '{"source":"migration test"}',
      timestamp,
    ],
  );
  await database.customStatement(
    'INSERT INTO suspense_entries VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'entry-migration',
      'case-migration',
      'event-migration',
      'payment-migration',
      'account-v2',
      'party-v2',
      'customer',
      'EGP',
      'resolution',
      100,
      'resolution-migration',
      'migration-test',
      'migration resolution',
      'entry-migration-key',
      '{"source":"migration test"}',
      timestamp,
    ],
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
