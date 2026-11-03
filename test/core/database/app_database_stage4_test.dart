import 'dart:io';

import 'package:arqamy/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _Version3FixtureDatabase extends GeneratedDatabase {
  _Version3FixtureDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  Iterable<TableInfo> get allTables => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (_) async {});
}

class _Version4FixtureDatabase extends GeneratedDatabase {
  _Version4FixtureDatabase(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  Iterable<TableInfo> get allTables => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (_) async {});
}

void main() {
  late Directory temporaryDirectory;
  late String databasePath;
  AppDatabase? database;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'arqamy_stage4_schema_',
    );
    databasePath =
        '${temporaryDirectory.path}${Platform.pathSeparator}ledger.sqlite';
  });

  tearDown(() async {
    await database?.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test(
    'migrates a populated committed v3 schema and preserves all rows',
    () async {
      final fixture = _Version3FixtureDatabase(
        NativeDatabase(
          File(databasePath),
          setup: (connection) => connection.execute('PRAGMA foreign_keys = ON'),
        ),
      );
      await fixture.customStatement('PRAGMA user_version = 3');
      await _createVersion3Schema(fixture);
      await _insertVersion3Rows(fixture);
      final before = await _snapshotVersion3Tables(fixture);
      await fixture.close();

      database = await AppDatabase.open(path: databasePath);

      expect(await database!.storedSchemaVersion, 5);
      expect(await _snapshotVersion3Tables(database!), before);
      expect(
        await database!
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' "
              "AND name NOT LIKE 'sqlite_%' ORDER BY name",
            )
            .map((row) => row.read<String>('name'))
            .get(),
        [
          'allocation_reversals',
          'allocation_status_history',
          'cash_event_heads',
          'cash_event_versions',
          'cash_events',
          'currencies',
          'financial_accounts',
          'financial_transactions',
          'invoice_allocations',
          'invoice_lifecycle_events',
          'invoice_lines',
          'invoices',
          'parties',
          'party_roles',
          'payment_identities',
          'payment_refunds',
          'reconciliation_cases',
          'refund_allocation_reversals',
          'refund_financial_transactions',
          'suspense_entries',
          'suspense_resolutions',
        ],
      );

      await _verifyStage4Constraints(database!);
      await _verifyStage4HistoryAndRelationships(database!);

      expect(
        await database!.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
      expect(
        (await database!.customSelect('PRAGMA integrity_check').getSingle())
            .read<String>('integrity_check'),
        'ok',
      );

      final beforeReopen = await _snapshotVersion3Tables(database!);
      await database!.close();
      database = await AppDatabase.open(path: databasePath);
      expect(await database!.storedSchemaVersion, 5);
      expect(await _snapshotVersion3Tables(database!), beforeReopen);
    },
  );

  test(
    'rolls back the complete v3 migration when schema creation fails',
    () async {
      final fixture = _Version3FixtureDatabase(
        NativeDatabase(
          File(databasePath),
          setup: (connection) => connection.execute('PRAGMA foreign_keys = ON'),
        ),
      );
      await fixture.customStatement('PRAGMA user_version = 3');
      await _createVersion3Schema(fixture);
      await _insertVersion3Rows(fixture);
      final before = await _snapshotVersion3Tables(fixture);
      await fixture.customStatement(
        'CREATE TABLE invoice_allocations (unexpected TEXT)',
      );
      await fixture.close();

      await expectLater(
        AppDatabase.open(path: databasePath),
        throwsA(anything),
      );

      final afterFailure = _Version3FixtureDatabase(
        NativeDatabase(
          File(databasePath),
          setup: (connection) => connection.execute('PRAGMA foreign_keys = ON'),
        ),
      );
      expect(
        (await afterFailure.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        3,
      );
      expect(await _snapshotVersion3Tables(afterFailure), before);
      expect(
        (await afterFailure
                .customSelect(
                  "SELECT sql FROM sqlite_master WHERE type = 'table' "
                  "AND name = 'invoice_allocations'",
                )
                .getSingle())
            .read<String>('sql'),
        'CREATE TABLE invoice_allocations (unexpected TEXT)',
      );
      await afterFailure.close();
    },
  );

  test(
    'migrates populated v4 reversals to durable per-allocation sequences',
    () async {
      await _createPopulatedV4Fixture(databasePath);
      final fixture = _openVersion4Fixture(databasePath);
      final legacyRows = await fixture
          .customSelect(
            'SELECT rowid AS migration_rowid, * FROM allocation_reversals '
            'ORDER BY allocation_id, rowid',
          )
          .get();
      final refundLinksBefore = await fixture
          .customSelect(
            'SELECT * FROM refund_allocation_reversals ORDER BY rowid',
          )
          .get();
      final childTriggerBefore =
          (await fixture
                  .customSelect(
                    "SELECT sql FROM sqlite_master WHERE type = 'trigger' "
                    "AND name = 'refund_allocation_reversals_validate_insert'",
                  )
                  .getSingle())
              .read<String>('sql');
      await fixture.close();

      database = await AppDatabase.open(path: databasePath);

      expect(await database!.storedSchemaVersion, 5);
      final migratedRows = await database!
          .customSelect(
            'SELECT * FROM allocation_reversals '
            'ORDER BY allocation_id, sequence',
          )
          .get();
      expect(migratedRows, hasLength(legacyRows.length));
      final expectedSequences = <String, int>{};
      for (var index = 0; index < legacyRows.length; index++) {
        final legacy = Map<String, Object?>.from(legacyRows[index].data)
          ..remove('migration_rowid');
        final allocationId = legacy['allocation_id']! as String;
        final sequence = (expectedSequences[allocationId] ?? 0) + 1;
        expectedSequences[allocationId] = sequence;
        expect(migratedRows[index].data, {...legacy, 'sequence': sequence});
      }
      expect(expectedSequences.values, contains(3));
      expect(expectedSequences.values, contains(2));
      expect(
        migratedRows
            .where(
              (row) => row.read<String>('allocation_id') == 'allocation-v4',
            )
            .map((row) => row.read<int>('sequence')),
        [1, 2, 3],
      );
      expect(
        await database!
            .customSelect(
              'SELECT * FROM refund_allocation_reversals ORDER BY rowid',
            )
            .get()
            .then((rows) => rows.map((row) => row.data).toList()),
        refundLinksBefore.map((row) => row.data).toList(),
      );
      expect(
        (await database!
                .customSelect(
                  "SELECT sql FROM sqlite_master WHERE type = 'trigger' "
                  "AND name = 'refund_allocation_reversals_validate_insert'",
                )
                .getSingle())
            .read<String>('sql'),
        childTriggerBefore,
      );

      for (final name in [
        'allocation_reversals_allocation',
        'refund_allocation_reversals_refund',
        'allocation_reversals_immutable_update',
        'allocation_reversals_immutable_delete',
        'refund_allocation_reversals_immutable_update',
        'refund_allocation_reversals_immutable_delete',
        'refund_allocation_reversals_validate_insert',
      ]) {
        final object = await database!
            .customSelect(
              "SELECT COUNT(*) AS count FROM sqlite_master "
              "WHERE name = ?",
              variables: [Variable.withString(name)],
            )
            .getSingle();
        expect(object.read<int>('count'), 1, reason: 'Missing $name');
      }
      await expectLater(
        database!.customStatement(
          'UPDATE allocation_reversals SET sequence = sequence',
        ),
        throwsA(anything),
      );
      await expectLater(
        database!.customStatement(
          'DELETE FROM allocation_reversals WHERE allocation_reversal_id = ?',
          ['allocation-reversal-v4'],
        ),
        throwsA(anything),
      );
      await expectLater(
        database!.customStatement(
          'INSERT INTO allocation_reversals ('
          'allocation_reversal_id, allocation_id, amount_minor, '
          'idempotency_key, request_fingerprint, actor_id, reason, created_at, '
          'sequence) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            'invalid-sequence',
            'allocation-v4',
            1,
            'invalid-sequence-key',
            'invalid-sequence-fingerprint',
            null,
            'invalid sequence',
            1710000002000,
            0,
          ],
        ),
        throwsA(anything),
      );
      await expectLater(
        database!.customStatement(
          'INSERT INTO allocation_reversals ('
          'allocation_reversal_id, allocation_id, amount_minor, '
          'idempotency_key, request_fingerprint, actor_id, reason, created_at, '
          'sequence) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            'duplicate-sequence',
            'allocation-v4',
            1,
            'duplicate-sequence-key',
            'duplicate-sequence-fingerprint',
            null,
            'duplicate sequence',
            1710000002000,
            1,
          ],
        ),
        throwsA(anything),
      );
      await expectLater(
        database!.customStatement(
          'INSERT INTO allocation_reversals ('
          'allocation_reversal_id, allocation_id, amount_minor, '
          'idempotency_key, request_fingerprint, actor_id, reason, created_at, '
          'sequence) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            'invalid-amount',
            'allocation-v4',
            0,
            'invalid-amount-key',
            'invalid-amount-fingerprint',
            null,
            'invalid amount',
            1710000002000,
            4,
          ],
        ),
        throwsA(anything),
      );
      await expectLater(
        database!.customStatement(
          'INSERT INTO allocation_reversals ('
          'allocation_reversal_id, allocation_id, amount_minor, '
          'idempotency_key, request_fingerprint, actor_id, reason, created_at, '
          'sequence) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            'duplicate-idempotency-key',
            'allocation-v4',
            1,
            'allocation-reversal-v4-key',
            'duplicate-idempotency-fingerprint',
            null,
            'duplicate idempotency key',
            1710000002000,
            4,
          ],
        ),
        throwsA(anything),
      );
      expect(
        await database!.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
      expect(
        (await database!.customSelect('PRAGMA integrity_check').getSingle())
            .read<String>('integrity_check'),
        'ok',
      );
    },
  );

  test('rolls back a failed v4 to v5 reversal migration completely', () async {
    await _createPopulatedV4Fixture(databasePath);
    final fixture = _openVersion4Fixture(databasePath);
    await fixture.customStatement('PRAGMA foreign_keys = OFF');
    final validatorSql =
        (await fixture
                .customSelect(
                  "SELECT sql FROM sqlite_master WHERE type = 'trigger' "
                  "AND name = 'refund_allocation_reversals_validate_insert'",
                )
                .getSingle())
            .read<String>('sql');
    await fixture.customStatement(
      'DROP TRIGGER refund_allocation_reversals_validate_insert',
    );
    await fixture.customStatement(
      'INSERT INTO refund_allocation_reversals ('
      'refund_allocation_reversal_id, refund_id, original_payment_id, '
      'invoice_id, allocation_id, allocation_reversal_id, idempotency_key, '
      'request_fingerprint, actor_id, reason, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'dangling-refund-link',
        'missing-refund',
        'payment-v4',
        'invoice-v3',
        'allocation-v4',
        'allocation-v4-reversal-2',
        'dangling-refund-link-key',
        'dangling-refund-link-fingerprint',
        null,
        'intentional migration failure fixture',
        1710000003000,
      ],
    );
    await fixture.customStatement(validatorSql);
    await fixture.customStatement('PRAGMA foreign_keys = ON');
    final reversalsBefore = await fixture
        .customSelect(
          'SELECT rowid AS migration_rowid, * FROM allocation_reversals '
          'ORDER BY rowid',
        )
        .get();
    final linksBefore = await fixture
        .customSelect(
          'SELECT * FROM refund_allocation_reversals ORDER BY rowid',
        )
        .get();
    final tableSqlBefore =
        (await fixture
                .customSelect(
                  "SELECT sql FROM sqlite_master WHERE type = 'table' "
                  "AND name = 'allocation_reversals'",
                )
                .getSingle())
            .read<String>('sql');
    await fixture.close();

    await expectLater(AppDatabase.open(path: databasePath), throwsA(anything));

    final afterFailure = _openVersion4Fixture(databasePath);
    expect(
      (await afterFailure.customSelect('PRAGMA user_version').getSingle())
          .read<int>('user_version'),
      4,
    );
    expect(
      (await afterFailure
              .customSelect(
                "SELECT sql FROM sqlite_master WHERE type = 'table' "
                "AND name = 'allocation_reversals'",
              )
              .getSingle())
          .read<String>('sql'),
      tableSqlBefore,
    );
    expect(
      await afterFailure
          .customSelect(
            'SELECT rowid AS migration_rowid, * FROM allocation_reversals '
            'ORDER BY rowid',
          )
          .get()
          .then((rows) => rows.map((row) => row.data).toList()),
      reversalsBefore.map((row) => row.data).toList(),
    );
    expect(
      await afterFailure
          .customSelect(
            'SELECT * FROM refund_allocation_reversals ORDER BY rowid',
          )
          .get()
          .then((rows) => rows.map((row) => row.data).toList()),
      linksBefore.map((row) => row.data).toList(),
    );
    expect(
      await afterFailure
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'trigger' "
            "AND name LIKE 'allocation_reversals_immutable_%' ORDER BY name",
          )
          .map((row) => row.read<String>('name'))
          .get(),
      [
        'allocation_reversals_immutable_delete',
        'allocation_reversals_immutable_update',
      ],
    );
    await afterFailure.close();
  });
}

_Version4FixtureDatabase _openVersion4Fixture(String path) =>
    _Version4FixtureDatabase(
      NativeDatabase(
        File(path),
        setup: (connection) => connection.execute('PRAGMA foreign_keys = ON'),
      ),
    );

Future<void> _createPopulatedV4Fixture(String path) async {
  final version3 = _Version3FixtureDatabase(
    NativeDatabase(
      File(path),
      setup: (connection) => connection.execute('PRAGMA foreign_keys = ON'),
    ),
  );
  await version3.customStatement('PRAGMA user_version = 3');
  await _createVersion3Schema(version3);
  await _insertVersion3Rows(version3);
  await version3.close();

  final database = await AppDatabase.open(path: path);
  await _verifyStage4HistoryAndRelationships(database);
  await _insertAdditionalReversalMigrationRows(database);
  await _convertAllocationReversalsToV4(database);
  await database.close();
}

Future<void> _insertAdditionalReversalMigrationRows(
  AppDatabase database,
) async {
  const now = 1710000001000;
  await database.customStatement(
    'INSERT INTO invoices (invoice_id, invoice_serial, party_id, party_role, '
    'financial_account_id, currency_code, action, created_at, updated_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'migration-invoice-2',
      'MIGRATION-005',
      'party-v3',
      'customer',
      'account-v3',
      'EGP',
      'sale',
      now + 30,
      now + 30,
    ],
  );
  await database.customStatement(
    'INSERT INTO invoice_lifecycle_events VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'migration-invoice-2-active',
      'migration-invoice-2',
      1,
      'active',
      null,
      'migration-invoice-2-active-key',
      'migration-invoice-2-active-fingerprint',
      'migration-actor',
      'active',
      now + 31,
    ],
  );
  await database.customStatement(
    'INSERT INTO invoice_allocations VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'migration-allocation-2',
      'payment-v4',
      'migration-invoice-2',
      'payment-account-v4',
      'account-v3',
      'party-v3',
      'customer',
      'EGP',
      200,
      'migration-allocation-2-key',
      'migration-allocation-2-fingerprint',
      null,
      null,
      'migration-actor',
      'second allocation',
      now + 32,
    ],
  );

  for (final reversal in [
    (
      id: 'allocation-v4-reversal-2',
      allocationId: 'allocation-v4',
      amount: 50,
      key: 'allocation-v4-reversal-2-key',
      timestamp: now + 40,
      sequence: 2,
    ),
    (
      id: 'allocation-v4-reversal-3',
      allocationId: 'allocation-v4',
      amount: 75,
      key: 'allocation-v4-reversal-3-key',
      timestamp: now + 40,
      sequence: 3,
    ),
    (
      id: 'allocation-2-reversal-1',
      allocationId: 'migration-allocation-2',
      amount: 60,
      key: 'allocation-2-reversal-1-key',
      timestamp: now + 41,
      sequence: 1,
    ),
    (
      id: 'allocation-2-reversal-2',
      allocationId: 'migration-allocation-2',
      amount: 40,
      key: 'allocation-2-reversal-2-key',
      timestamp: now + 41,
      sequence: 2,
    ),
  ]) {
    await database.customStatement(
      'INSERT INTO allocation_reversals ('
      'allocation_reversal_id, allocation_id, amount_minor, idempotency_key, '
      'request_fingerprint, actor_id, reason, created_at, sequence) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        reversal.id,
        reversal.allocationId,
        reversal.amount,
        reversal.key,
        '${reversal.key}-fingerprint',
        'migration-actor',
        'migration fixture reversal',
        reversal.timestamp,
        reversal.sequence,
      ],
    );
  }
}

Future<void> _convertAllocationReversalsToV4(AppDatabase database) async {
  await database.customStatement('PRAGMA foreign_keys = OFF');
  try {
    await database.transaction(() async {
      final refundAllocationTrigger = await database
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE type = 'trigger' "
            "AND name = 'refund_allocation_reversals_validate_insert'",
          )
          .getSingleOrNull();
      await database.customStatement('''
        CREATE TABLE allocation_reversals_v4 (
          allocation_reversal_id TEXT NOT NULL PRIMARY KEY,
          allocation_id TEXT NOT NULL,
          amount_minor INTEGER NOT NULL,
          idempotency_key TEXT NOT NULL,
          request_fingerprint TEXT NOT NULL,
          actor_id TEXT,
          reason TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          UNIQUE (allocation_reversal_id, allocation_id),
          UNIQUE (idempotency_key),
          CHECK (amount_minor > 0),
          CHECK (length(trim(idempotency_key)) > 0),
          CHECK (length(trim(request_fingerprint)) > 0),
          FOREIGN KEY (allocation_id)
            REFERENCES invoice_allocations (allocation_id)
        )
      ''');
      await database.customStatement(
        'INSERT INTO allocation_reversals_v4 ('
        'allocation_reversal_id, allocation_id, amount_minor, idempotency_key, '
        'request_fingerprint, actor_id, reason, created_at) '
        'SELECT allocation_reversal_id, allocation_id, amount_minor, '
        'idempotency_key, request_fingerprint, actor_id, reason, created_at '
        'FROM allocation_reversals ORDER BY allocation_id, sequence',
      );
      if (refundAllocationTrigger != null) {
        await database.customStatement(
          'DROP TRIGGER refund_allocation_reversals_validate_insert',
        );
      }
      await database.customStatement('DROP TABLE allocation_reversals');
      await database.customStatement(
        'ALTER TABLE allocation_reversals_v4 RENAME TO allocation_reversals',
      );
      if (refundAllocationTrigger != null) {
        await database.customStatement(
          refundAllocationTrigger.read<String>('sql'),
        );
      }
      await database.customStatement(
        'CREATE INDEX allocation_reversals_allocation '
        'ON allocation_reversals (allocation_id, created_at)',
      );
      await database.customStatement('''
        CREATE TRIGGER allocation_reversals_immutable_update
        BEFORE UPDATE ON allocation_reversals BEGIN
          SELECT RAISE(ABORT, 'allocation_reversals is append-only');
        END
      ''');
      await database.customStatement('''
        CREATE TRIGGER allocation_reversals_immutable_delete
        BEFORE DELETE ON allocation_reversals BEGIN
          SELECT RAISE(ABORT, 'allocation_reversals is append-only');
        END
      ''');
      await database.customStatement('PRAGMA user_version = 4');
    });
  } finally {
    await database.customStatement('PRAGMA foreign_keys = ON');
  }
}

Future<void> _createVersion3Schema(_Version3FixtureDatabase database) async {
  const statements = [
    '''
    CREATE TABLE currencies (
      currency_code TEXT NOT NULL PRIMARY KEY,
      minor_unit_scale INTEGER NOT NULL,
      display_name TEXT NOT NULL,
      CHECK (minor_unit_scale BETWEEN 0 AND 6)
    )
    ''',
    '''
    CREATE TABLE parties (
      party_id TEXT NOT NULL PRIMARY KEY,
      display_name TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''',
    '''
    CREATE TABLE party_roles (
      party_id TEXT NOT NULL,
      role TEXT NOT NULL,
      PRIMARY KEY (party_id, role),
      FOREIGN KEY (party_id) REFERENCES parties (party_id),
      CHECK (role IN ('customer', 'supplier'))
    )
    ''',
    '''
    CREATE TABLE financial_accounts (
      account_id TEXT NOT NULL PRIMARY KEY,
      party_id TEXT NOT NULL,
      role TEXT NOT NULL,
      currency_code TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      UNIQUE (account_id, party_id, role, currency_code),
      FOREIGN KEY (party_id, role) REFERENCES party_roles (party_id, role),
      FOREIGN KEY (currency_code) REFERENCES currencies (currency_code)
    )
    ''',
    '''
    CREATE TABLE invoices (
      invoice_id TEXT NOT NULL PRIMARY KEY,
      invoice_serial TEXT NOT NULL,
      legacy_record_key TEXT UNIQUE,
      legacy_invoice_id TEXT,
      source_json TEXT,
      party_id TEXT,
      party_role TEXT,
      financial_account_id TEXT,
      currency_code TEXT,
      action TEXT NOT NULL,
      legacy_action TEXT,
      total_minor INTEGER,
      legacy_total_value TEXT,
      legacy_paid_value TEXT,
      legacy_remaining_value TEXT,
      issued_at INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      UNIQUE (invoice_id, currency_code),
      CHECK (total_minor IS NULL OR total_minor >= 0),
      CHECK ((financial_account_id IS NULL AND party_id IS NULL
          AND party_role IS NULL) OR
        (financial_account_id IS NOT NULL AND party_id IS NOT NULL
          AND party_role IS NOT NULL AND currency_code IS NOT NULL)),
      CHECK (action IN ('sale', 'purchase', 'storage', 'unknown')),
      FOREIGN KEY (party_id, party_role) REFERENCES party_roles (party_id, role),
      FOREIGN KEY (financial_account_id, party_id, party_role, currency_code)
        REFERENCES financial_accounts (account_id, party_id, role, currency_code),
      FOREIGN KEY (currency_code) REFERENCES currencies (currency_code)
    )
    ''',
    '''
    CREATE TABLE invoice_lines (
      invoice_line_id TEXT NOT NULL PRIMARY KEY,
      invoice_id TEXT NOT NULL,
      line_index INTEGER NOT NULL,
      product_name TEXT NOT NULL,
      quantity_decimal TEXT,
      package_weight_decimal TEXT,
      package_count INTEGER,
      unit_price_decimal TEXT,
      line_total_minor INTEGER,
      currency_code TEXT,
      source_json TEXT,
      UNIQUE (invoice_id, line_index),
      CHECK (line_index >= 0),
      CHECK (package_count IS NULL OR package_count >= 0),
      CHECK (line_total_minor IS NULL OR line_total_minor >= 0),
      FOREIGN KEY (invoice_id) REFERENCES invoices (invoice_id),
      FOREIGN KEY (invoice_id, currency_code)
        REFERENCES invoices (invoice_id, currency_code),
      FOREIGN KEY (currency_code) REFERENCES currencies (currency_code)
    )
    ''',
    '''
    CREATE TABLE payment_identities (
      payment_id TEXT NOT NULL PRIMARY KEY,
      financial_account_id TEXT NOT NULL,
      party_id TEXT NOT NULL,
      party_role TEXT NOT NULL,
      currency_code TEXT NOT NULL,
      financial_direction TEXT NOT NULL,
      created_by_actor_id TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      UNIQUE (payment_id, financial_account_id, party_id, party_role, currency_code),
      CHECK (financial_direction IN ('in', 'out')),
      FOREIGN KEY (financial_account_id, party_id, party_role, currency_code)
        REFERENCES financial_accounts (account_id, party_id, role, currency_code)
    )
    ''',
    '''
    CREATE TABLE cash_events (
      cash_event_id TEXT NOT NULL PRIMARY KEY,
      payment_id TEXT NOT NULL UNIQUE,
      created_by_actor_id TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      UNIQUE (cash_event_id, payment_id),
      FOREIGN KEY (payment_id) REFERENCES payment_identities (payment_id)
    )
    ''',
    '''
    CREATE TABLE financial_transactions (
      transaction_id TEXT NOT NULL PRIMARY KEY,
      cash_event_id TEXT NOT NULL,
      payment_id TEXT NOT NULL,
      financial_account_id TEXT NOT NULL,
      party_id TEXT NOT NULL,
      party_role TEXT NOT NULL,
      currency_code TEXT NOT NULL,
      transaction_type TEXT NOT NULL,
      direction TEXT NOT NULL,
      amount_minor INTEGER NOT NULL,
      related_transaction_id TEXT,
      actor_id TEXT NOT NULL,
      reason TEXT NOT NULL,
      idempotency_key TEXT UNIQUE,
      occurred_at INTEGER NOT NULL,
      UNIQUE (transaction_id, cash_event_id, payment_id),
      CHECK (transaction_type IN ('payment', 'payment_reversal', 'replacement')),
      CHECK (direction IN ('in', 'out')),
      CHECK (amount_minor >= 0),
      CHECK (transaction_type = 'replacement' OR amount_minor > 0),
      FOREIGN KEY (cash_event_id, payment_id)
        REFERENCES cash_events (cash_event_id, payment_id),
      FOREIGN KEY (payment_id, financial_account_id, party_id, party_role, currency_code)
        REFERENCES payment_identities
          (payment_id, financial_account_id, party_id, party_role, currency_code),
      FOREIGN KEY (related_transaction_id, cash_event_id, payment_id)
        REFERENCES financial_transactions
          (transaction_id, cash_event_id, payment_id)
    )
    ''',
    '''
    CREATE TABLE cash_event_versions (
      version_id TEXT NOT NULL PRIMARY KEY,
      cash_event_id TEXT NOT NULL,
      payment_id TEXT NOT NULL,
      sequence INTEGER NOT NULL,
      operation TEXT NOT NULL,
      occurred TEXT NOT NULL,
      cash_direction TEXT NOT NULL,
      physical_amount_minor INTEGER NOT NULL,
      effective_recognized_minor INTEGER NOT NULL,
      transaction_id TEXT,
      previous_version_id TEXT,
      idempotency_key TEXT NOT NULL UNIQUE,
      request_payload TEXT NOT NULL,
      actor_id TEXT NOT NULL,
      reason TEXT NOT NULL,
      recorded_at INTEGER NOT NULL,
      UNIQUE (cash_event_id, sequence),
      UNIQUE (version_id, cash_event_id, payment_id),
      CHECK (operation IN ('original', 'correction', 'reversal', 'replacement', 'void')),
      CHECK (occurred IN ('yes', 'no', 'unknown')),
      CHECK (cash_direction IN ('in', 'out')),
      CHECK (sequence > 0),
      CHECK (physical_amount_minor >= 0),
      CHECK (effective_recognized_minor >= 0),
      CHECK (occurred != 'no' OR physical_amount_minor = 0),
      FOREIGN KEY (cash_event_id, payment_id)
        REFERENCES cash_events (cash_event_id, payment_id),
      FOREIGN KEY (transaction_id, cash_event_id, payment_id)
        REFERENCES financial_transactions
          (transaction_id, cash_event_id, payment_id),
      FOREIGN KEY (previous_version_id, cash_event_id, payment_id)
        REFERENCES cash_event_versions
          (version_id, cash_event_id, payment_id)
    )
    ''',
    '''
    CREATE TABLE cash_event_heads (
      cash_event_id TEXT NOT NULL PRIMARY KEY,
      payment_id TEXT NOT NULL,
      version_id TEXT NOT NULL,
      revision INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      UNIQUE (cash_event_id, payment_id),
      CHECK (revision > 0),
      FOREIGN KEY (cash_event_id, payment_id)
        REFERENCES cash_events (cash_event_id, payment_id),
      FOREIGN KEY (version_id, cash_event_id, payment_id)
        REFERENCES cash_event_versions (version_id, cash_event_id, payment_id)
    )
    ''',
    '''
    CREATE TABLE reconciliation_cases (
      case_id TEXT NOT NULL PRIMARY KEY,
      cash_event_id TEXT NOT NULL,
      payment_id TEXT NOT NULL,
      financial_account_id TEXT NOT NULL,
      party_id TEXT NOT NULL,
      party_role TEXT NOT NULL,
      currency_code TEXT NOT NULL,
      reason TEXT NOT NULL,
      created_by_actor_id TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      UNIQUE (case_id, cash_event_id, payment_id, financial_account_id,
        party_id, party_role, currency_code),
      FOREIGN KEY (cash_event_id, payment_id)
        REFERENCES cash_events (cash_event_id, payment_id),
      FOREIGN KEY (payment_id, financial_account_id, party_id, party_role, currency_code)
        REFERENCES payment_identities
          (payment_id, financial_account_id, party_id, party_role, currency_code)
    )
    ''',
    '''
    CREATE TABLE suspense_resolutions (
      resolution_id TEXT NOT NULL PRIMARY KEY,
      case_id TEXT NOT NULL,
      cash_event_id TEXT NOT NULL,
      payment_id TEXT NOT NULL,
      financial_account_id TEXT NOT NULL,
      party_id TEXT NOT NULL,
      party_role TEXT NOT NULL,
      currency_code TEXT NOT NULL,
      amount_minor INTEGER NOT NULL,
      actor_id TEXT NOT NULL,
      authorized_by_actor_id TEXT NOT NULL,
      authorization_reference TEXT NOT NULL,
      reason TEXT NOT NULL,
      idempotency_key TEXT NOT NULL UNIQUE,
      request_payload TEXT NOT NULL,
      resolved_at INTEGER NOT NULL,
      UNIQUE (resolution_id, case_id, cash_event_id, payment_id,
        financial_account_id, party_id, party_role, currency_code),
      CHECK (amount_minor > 0),
      FOREIGN KEY (case_id, cash_event_id, payment_id, financial_account_id,
        party_id, party_role, currency_code)
        REFERENCES reconciliation_cases
          (case_id, cash_event_id, payment_id, financial_account_id,
           party_id, party_role, currency_code)
    )
    ''',
    '''
    CREATE TABLE suspense_entries (
      suspense_entry_id TEXT NOT NULL PRIMARY KEY,
      case_id TEXT NOT NULL,
      cash_event_id TEXT NOT NULL,
      payment_id TEXT NOT NULL,
      financial_account_id TEXT NOT NULL,
      party_id TEXT NOT NULL,
      party_role TEXT NOT NULL,
      currency_code TEXT NOT NULL,
      movement_type TEXT NOT NULL,
      amount_minor INTEGER NOT NULL,
      resolution_id TEXT,
      actor_id TEXT NOT NULL,
      reason TEXT NOT NULL,
      idempotency_key TEXT NOT NULL UNIQUE,
      request_payload TEXT NOT NULL,
      recorded_at INTEGER NOT NULL,
      CHECK (movement_type IN ('creation', 'increase', 'decrease', 'resolution')),
      CHECK (amount_minor > 0),
      CHECK ((movement_type = 'resolution' AND resolution_id IS NOT NULL) OR
        (movement_type != 'resolution' AND resolution_id IS NULL)),
      FOREIGN KEY (case_id, cash_event_id, payment_id, financial_account_id,
        party_id, party_role, currency_code)
        REFERENCES reconciliation_cases
          (case_id, cash_event_id, payment_id, financial_account_id,
           party_id, party_role, currency_code),
      FOREIGN KEY (resolution_id, case_id, cash_event_id, payment_id,
        financial_account_id, party_id, party_role, currency_code)
        REFERENCES suspense_resolutions
          (resolution_id, case_id, cash_event_id, payment_id,
           financial_account_id, party_id, party_role, currency_code)
    )
    ''',
    'CREATE INDEX financial_transactions_event_time ON financial_transactions (cash_event_id, occurred_at)',
    'CREATE INDEX financial_transactions_account_time ON financial_transactions (financial_account_id, currency_code, occurred_at)',
    'CREATE INDEX cash_event_versions_event_sequence ON cash_event_versions (cash_event_id, sequence)',
    'CREATE INDEX suspense_entries_case_time ON suspense_entries (case_id, recorded_at)',
    'CREATE INDEX suspense_entries_account_currency ON suspense_entries (financial_account_id, currency_code)',
  ];

  for (final statement in statements) {
    await database.customStatement(statement);
  }
  for (final table in [
    'payment_identities',
    'cash_events',
    'financial_transactions',
    'cash_event_versions',
    'reconciliation_cases',
    'suspense_resolutions',
    'suspense_entries',
  ]) {
    await database.customStatement(
      'CREATE TRIGGER ${table}_immutable_update BEFORE UPDATE ON $table '
      "BEGIN SELECT RAISE(ABORT, '$table is append-only'); END",
    );
    await database.customStatement(
      'CREATE TRIGGER ${table}_immutable_delete BEFORE DELETE ON $table '
      "BEGIN SELECT RAISE(ABORT, '$table is append-only'); END",
    );
  }
}

Future<void> _insertVersion3Rows(_Version3FixtureDatabase database) async {
  const now = 1710000000000;
  await database.customStatement('INSERT INTO currencies VALUES (?, ?, ?)', [
    'EGP',
    2,
    'Egyptian pound',
  ]);
  await database.customStatement('INSERT INTO parties VALUES (?, ?, ?, ?)', [
    'party-v3',
    'Version 3 party',
    now,
    now + 1,
  ]);
  await database.customStatement('INSERT INTO party_roles VALUES (?, ?)', [
    'party-v3',
    'customer',
  ]);
  await database.customStatement(
    'INSERT INTO financial_accounts VALUES (?, ?, ?, ?, ?)',
    ['account-v3', 'party-v3', 'customer', 'EGP', now + 2],
  );
  await database.customStatement(
    'INSERT INTO invoices VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'invoice-v3',
      'SERIAL-003',
      'source-v3',
      'legacy-v3',
      '{"evidence":"v3"}',
      'party-v3',
      'customer',
      'account-v3',
      'EGP',
      'sale',
      'بيع',
      12000,
      '120.00',
      '20.00',
      '100.00',
      now + 3,
      now + 4,
      now + 5,
    ],
  );
  await database.customStatement(
    'INSERT INTO invoice_lines VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'line-v3',
      'invoice-v3',
      0,
      'Ledger item',
      '2.5',
      '1.0',
      1,
      '48',
      12000,
      'EGP',
      '{"evidence":"line-v3"}',
    ],
  );
  await database.customStatement(
    'INSERT INTO payment_identities VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'payment-v3',
      'account-v3',
      'party-v3',
      'customer',
      'EGP',
      'in',
      'actor-v3',
      now + 6,
    ],
  );
  await database.customStatement(
    'INSERT INTO cash_events VALUES (?, ?, ?, ?)',
    ['event-v3', 'payment-v3', 'actor-v3', now + 7],
  );
  await database.customStatement(
    'INSERT INTO financial_transactions VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'transaction-v3',
      'event-v3',
      'payment-v3',
      'account-v3',
      'party-v3',
      'customer',
      'EGP',
      'payment',
      'in',
      2000,
      null,
      'actor-v3',
      'v3 fixture',
      'transaction-v3-key',
      now + 8,
    ],
  );
  await database.customStatement(
    'INSERT INTO cash_event_versions VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'version-v3',
      'event-v3',
      'payment-v3',
      1,
      'original',
      'yes',
      'in',
      2000,
      2000,
      'transaction-v3',
      null,
      'version-v3-key',
      '{"evidence":"version-v3"}',
      'actor-v3',
      'v3 fixture',
      now + 9,
    ],
  );
  await database.customStatement(
    'INSERT INTO cash_event_heads VALUES (?, ?, ?, ?, ?)',
    ['event-v3', 'payment-v3', 'version-v3', 1, now + 10],
  );
  await database.customStatement(
    'INSERT INTO reconciliation_cases VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'case-v3',
      'event-v3',
      'payment-v3',
      'account-v3',
      'party-v3',
      'customer',
      'EGP',
      'v3 fixture',
      'actor-v3',
      now + 11,
    ],
  );
  await database.customStatement(
    'INSERT INTO suspense_resolutions VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'resolution-v3',
      'case-v3',
      'event-v3',
      'payment-v3',
      'account-v3',
      'party-v3',
      'customer',
      'EGP',
      100,
      'actor-v3',
      'approver-v3',
      'approval-v3',
      'v3 resolution',
      'resolution-v3-key',
      '{"evidence":"resolution-v3"}',
      now + 12,
    ],
  );
  await database.customStatement(
    'INSERT INTO suspense_entries VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'entry-v3',
      'case-v3',
      'event-v3',
      'payment-v3',
      'account-v3',
      'party-v3',
      'customer',
      'EGP',
      'resolution',
      100,
      'resolution-v3',
      'actor-v3',
      'v3 resolution',
      'entry-v3-key',
      '{"evidence":"entry-v3"}',
      now + 13,
    ],
  );
}

Future<Map<String, List<Map<String, Object?>>>> _snapshotVersion3Tables(
  GeneratedDatabase database,
) async {
  const tables = [
    'currencies',
    'parties',
    'party_roles',
    'financial_accounts',
    'invoices',
    'invoice_lines',
    'payment_identities',
    'cash_events',
    'financial_transactions',
    'cash_event_versions',
    'cash_event_heads',
    'reconciliation_cases',
    'suspense_resolutions',
    'suspense_entries',
  ];
  return {
    for (final table in tables)
      table: [
        for (final row
            in await database
                .customSelect('SELECT * FROM $table ORDER BY rowid')
                .get())
          row.data,
      ],
  };
}

Future<void> _verifyStage4Constraints(AppDatabase database) async {
  const indexes = [
    'financial_transactions_event_time',
    'financial_transactions_account_time',
    'cash_event_versions_event_sequence',
    'suspense_entries_case_time',
    'suspense_entries_account_currency',
    'invoices_identity_for_allocations',
    'invoice_allocations_payment',
    'invoice_allocations_invoice',
    'allocation_reversals_allocation',
    'allocation_status_history_allocation',
    'payment_refunds_original',
    'payment_refunds_invoice',
    'invoice_lifecycle_events_invoice',
    'refund_allocation_reversals_refund',
  ];
  for (final index in indexes) {
    final row = await database
        .customSelect(
          "SELECT COUNT(*) AS count FROM sqlite_master "
          "WHERE type = 'index' AND name = ?",
          variables: [Variable.withString(index)],
        )
        .getSingle();
    expect(row.read<int>('count'), 1, reason: 'Missing index $index');
  }

  for (final table in [
    'invoice_allocations',
    'allocation_reversals',
    'allocation_status_history',
    'payment_refunds',
    'refund_allocation_reversals',
    'invoice_lifecycle_events',
  ]) {
    expect(
      await database.customSelect('PRAGMA foreign_key_list($table)').get(),
      isNotEmpty,
      reason: 'Missing foreign keys in $table',
    );
  }

  final transactionDefinition =
      (await database
              .customSelect(
                "SELECT sql FROM sqlite_master WHERE type = 'table' "
                "AND name = 'financial_transactions'",
              )
              .getSingle())
          .read<String>('sql');
  expect(transactionDefinition, contains("'refund'"));

  for (final table in [
    'payment_identities',
    'cash_events',
    'financial_transactions',
    'cash_event_versions',
    'reconciliation_cases',
    'suspense_resolutions',
    'suspense_entries',
  ]) {
    final triggers = await database
        .customSelect(
          "SELECT COUNT(*) AS count FROM sqlite_master "
          "WHERE type = 'trigger' AND name = ?",
          variables: [Variable.withString('${table}_immutable_update')],
        )
        .getSingle();
    expect(triggers.read<int>('count'), 1);
  }
}

Future<void> _verifyStage4HistoryAndRelationships(AppDatabase database) async {
  const now = 1710000001000;
  await database.customStatement(
    'INSERT INTO financial_accounts VALUES (?, ?, ?, ?, ?)',
    ['payment-account-v4', 'party-v3', 'customer', 'EGP', now],
  );
  await database.customStatement(
    'INSERT INTO payment_identities VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'payment-v4',
      'payment-account-v4',
      'party-v3',
      'customer',
      'EGP',
      'in',
      'actor-v4',
      now,
    ],
  );
  await database.customStatement(
    'INSERT INTO cash_events VALUES (?, ?, ?, ?)',
    ['event-v4', 'payment-v4', 'actor-v4', now],
  );
  await database.customStatement(
    'INSERT INTO invoice_lifecycle_events VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'lifecycle-v3-1',
      'invoice-v3',
      1,
      'active',
      null,
      'lifecycle-v3-1-key',
      'fingerprint-1',
      'actor-v4',
      'initial state',
      now,
    ],
  );

  await database.customStatement(
    'INSERT INTO invoice_allocations VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'allocation-v4',
      'payment-v4',
      'invoice-v3',
      'payment-account-v4',
      'account-v3',
      'party-v3',
      'customer',
      'EGP',
      500,
      'allocation-v4-key',
      'allocation-fingerprint',
      'device-a',
      'conflict-group-a',
      'actor-v4',
      'initial allocation',
      now,
    ],
  );

  String? previousId;
  for (final (index, status) in [
    'provisional',
    'server_confirmed',
    'conflict_pending',
    'rejected',
  ].indexed) {
    final id = 'status-v4-$index';
    await database.customStatement(
      'INSERT INTO allocation_status_history VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        'allocation-v4',
        index + 1,
        status,
        previousId,
        '$id-key',
        'fingerprint-$index',
        'actor-v4',
        'status update',
        now + index,
      ],
    );
    previousId = id;
  }
  expect(
    await database
        .customSelect(
          'SELECT status FROM allocation_status_history '
          'WHERE allocation_id = ? ORDER BY sequence',
          variables: [Variable.withString('allocation-v4')],
        )
        .map((row) => row.read<String>('status'))
        .get(),
    ['provisional', 'server_confirmed', 'conflict_pending', 'rejected'],
  );
  await expectLater(
    database.customStatement(
      'INSERT INTO allocation_status_history VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'status-invalid',
        'allocation-v4',
        5,
        'globally_confirmed',
        previousId,
        'invalid-status-key',
        'fingerprint-invalid',
        'actor-v4',
        'invalid state',
        now + 10,
      ],
    ),
    throwsA(anything),
  );

  await database.customStatement(
    'INSERT INTO allocation_reversals VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'allocation-reversal-v4',
      'allocation-v4',
      200,
      'allocation-reversal-v4-key',
      'reversal-fingerprint',
      'actor-v4',
      'partial reversal',
      now + 11,
      1,
    ],
  );

  await database.customStatement(
    'INSERT INTO payment_identities VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'refund-payment-v4',
      'account-v3',
      'party-v3',
      'customer',
      'EGP',
      'out',
      'actor-v4',
      now + 12,
    ],
  );
  await database.customStatement(
    'INSERT INTO cash_events VALUES (?, ?, ?, ?)',
    ['refund-event-v4', 'refund-payment-v4', 'actor-v4', now + 13],
  );
  await database.customStatement(
    'INSERT INTO financial_transactions VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'refund-transaction-v4',
      'refund-event-v4',
      'refund-payment-v4',
      'account-v3',
      'party-v3',
      'customer',
      'EGP',
      'refund',
      'out',
      200,
      null,
      'actor-v4',
      'invoice refund',
      'refund-transaction-v4-key',
      now + 14,
    ],
  );
  await database.customStatement(
    'INSERT INTO payment_refunds VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'refund-v4',
      'payment-v4',
      'event-v4',
      'refund-payment-v4',
      'refund-event-v4',
      'invoice-v3',
      'payment-account-v4',
      'account-v3',
      'account-v3',
      'party-v3',
      'customer',
      'EGP',
      200,
      'refund-v4-key',
      'refund-fingerprint',
      'actor-v4',
      'invoice-linked refund',
      now + 15,
    ],
  );
  await database.customStatement(
    'INSERT INTO refund_allocation_reversals VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'refund-allocation-link-v4',
      'refund-v4',
      'payment-v4',
      'invoice-v3',
      'allocation-v4',
      'allocation-reversal-v4',
      'refund-allocation-link-v4-key',
      'refund-allocation-link-fingerprint',
      'actor-v4',
      'link reversed allocation to refund',
      now + 16,
    ],
  );

  await database.customStatement(
    'INSERT INTO invoice_lifecycle_events VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'lifecycle-v3-2',
      'invoice-v3',
      2,
      'cancelled',
      'lifecycle-v3-1',
      'lifecycle-v3-2-key',
      'fingerprint-2',
      'actor-v4',
      'cancelled',
      now + 17,
    ],
  );
  await expectLater(
    database.customStatement(
      'INSERT INTO invoice_allocations VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'allocation-cancelled',
        'payment-v4',
        'invoice-v3',
        'payment-account-v4',
        'account-v3',
        'party-v3',
        'customer',
        'EGP',
        1,
        'allocation-cancelled-key',
        'fingerprint-cancelled',
        null,
        null,
        'actor-v4',
        'must be rejected',
        now + 18,
      ],
    ),
    throwsA(anything),
  );

  await expectLater(
    database.customStatement(
      'INSERT INTO invoice_allocations VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'allocation-duplicate-key',
        'payment-v4',
        'invoice-v3',
        'payment-account-v4',
        'account-v3',
        'party-v3',
        'customer',
        'EGP',
        1,
        'allocation-v4-key',
        'fingerprint-duplicate',
        'device-b',
        'conflict-group-a',
        'actor-v4',
        'duplicate idempotency key',
        now + 19,
      ],
    ),
    throwsA(anything),
  );

  await database.customStatement(
    'INSERT INTO invoices (invoice_id, invoice_serial, party_id, party_role, '
    'financial_account_id, currency_code, action, created_at, updated_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'storage-invoice-v4',
      'STORAGE-004',
      'party-v3',
      'customer',
      'account-v3',
      'EGP',
      'storage',
      now + 20,
      now + 20,
    ],
  );
  await database.customStatement(
    'INSERT INTO invoice_lifecycle_events VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'storage-lifecycle-v4',
      'storage-invoice-v4',
      1,
      'active',
      null,
      'storage-lifecycle-v4-key',
      'storage-fingerprint',
      'actor-v4',
      'initial state',
      now + 21,
    ],
  );
  await expectLater(
    database.customStatement(
      'INSERT INTO invoice_allocations VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'allocation-storage',
        'payment-v4',
        'storage-invoice-v4',
        'payment-account-v4',
        'account-v3',
        'party-v3',
        'customer',
        'EGP',
        1,
        'allocation-storage-key',
        'storage-fingerprint',
        null,
        null,
        'actor-v4',
        'storage must be ineligible',
        now + 22,
      ],
    ),
    throwsA(anything),
  );

  final storedStatus = await database
      .customSelect(
        'SELECT status FROM allocation_status_history '
        'WHERE allocation_id = ? ORDER BY sequence DESC LIMIT 1',
        variables: [Variable.withString('allocation-v4')],
      )
      .getSingle();
  expect(storedStatus.read<String>('status'), 'rejected');

  for (final table in [
    'invoice_allocations',
    'allocation_reversals',
    'allocation_status_history',
    'payment_refunds',
    'refund_allocation_reversals',
    'invoice_lifecycle_events',
  ]) {
    await expectLater(
      database.customStatement(
        'UPDATE $table SET rowid = rowid '
        'WHERE rowid = (SELECT rowid FROM $table LIMIT 1)',
      ),
      throwsA(anything),
      reason: '$table update trigger must protect history',
    );
    await expectLater(
      database.customStatement(
        'DELETE FROM $table WHERE rowid = (SELECT rowid FROM $table LIMIT 1)',
      ),
      throwsA(anything),
      reason: '$table delete trigger must protect history',
    );
  }
}
