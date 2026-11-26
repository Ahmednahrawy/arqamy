import 'dart:io';

import 'package:arqamy/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

const _d4Tables = [
  'legacy_invoice_import_attempts',
  'legacy_invoice_import_events',
  'legacy_invoice_occurrence_mappings',
  'legacy_invoice_import_occurrences',
  'legacy_invoice_import_runs',
];

void main() {
  late Directory temporaryDirectory;
  late AppDatabase database;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'arqamy_d4_v7_v8_migration_',
    );
    final databasePath =
        '${temporaryDirectory.path}${Platform.pathSeparator}ledger.sqlite';
    database = await AppDatabase.open(path: databasePath);
  });

  tearDown(() async {
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('creates all five D4 tables when upgrading v7 to v8', () async {
    await _dropD4Schema(database);
    await database.customStatement(
      "INSERT INTO currencies VALUES ('EGP', 2, 'Egyptian pound')",
    );
    await database.customStatement('PRAGMA user_version = 7');

    await _runV7ToV8Upgrade(database);

    expect(await _readUserVersion(database), 8);
    expect(await _readD4Tables(database), _d4Tables);
    await _expectD4IndexesAndTriggers(database);
    expect(
      await _readCurrencies(database),
      [
        {
          'currency_code': 'EGP',
          'minor_unit_scale': 2,
          'display_name': 'Egyptian pound',
        },
      ],
    );
    await _expectDatabaseHealthy(database);
  });

  test(
    'rolls back a v7 to v8 table collision and succeeds on a clean retry',
    () async {
      await _dropD4Schema(database);
      await database.customStatement(
        "INSERT INTO currencies VALUES ('EGP', 2, 'Egyptian pound')",
      );
      await database.customStatement('PRAGMA user_version = 7');
      await database.customStatement(
        'CREATE TABLE legacy_invoice_import_runs (unexpected TEXT)',
      );

      final schemaBeforeFailure = await _snapshotSchemaObjects(database);
      final currenciesBeforeFailure = await _readCurrencies(database);

      await expectLater(
        _runV7ToV8Upgrade(database),
        throwsA(anything),
      );

      expect(await _readUserVersion(database), 7);
      expect(await _snapshotSchemaObjects(database), schemaBeforeFailure);
      expect(await _readCurrencies(database), currenciesBeforeFailure);
      expect(await _readD4Tables(database), ['legacy_invoice_import_runs']);
      await _expectDatabaseHealthy(database);

      await database.customStatement(
        'DROP TABLE legacy_invoice_import_runs',
      );
      await _runV7ToV8Upgrade(database);

      expect(await _readUserVersion(database), 8);
      expect(await _readD4Tables(database), _d4Tables);
      await _expectD4IndexesAndTriggers(database);
      expect(await _readCurrencies(database), currenciesBeforeFailure);
      await _expectDatabaseHealthy(database);
    },
  );
}


Future<void> _dropD4Schema(AppDatabase database) async {
  final triggers = await database
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'trigger' "
        "AND tbl_name IN (${_d4Tables.map((name) => "'$name'").join(', ')})",
      )
      .map((row) => row.read<String>('name'))
      .get();
  for (final trigger in triggers) {
    await database.customStatement('DROP TRIGGER "$trigger"');
  }

  for (final table in [
    'legacy_invoice_occurrence_mappings',
    'legacy_invoice_import_events',
    'legacy_invoice_import_attempts',
    'legacy_invoice_import_occurrences',
    'legacy_invoice_import_runs',
  ]) {
    await database.customStatement('DROP TABLE "$table"');
  }
}

Future<void> _expectD4IndexesAndTriggers(AppDatabase database) async {
  final indexes = await database
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index' "
        "AND name LIKE 'legacy_invoice_%' ORDER BY name",
      )
      .map((row) => row.read<String>('name'))
      .get();
  expect(
    indexes,
    [
      'legacy_invoice_import_events_run_time_index',
      'legacy_invoice_import_occurrences_claim_expiry_index',
      'legacy_invoice_import_occurrences_run_status_index',
      'legacy_invoice_occurrence_mappings_run_index',
    ],
  );

  final triggers = await database
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'trigger' "
        "AND tbl_name IN (${_d4Tables.map((name) => "'$name'").join(', ')}) "
        "ORDER BY name",
      )
      .map((row) => row.read<String>('name'))
      .get();
  expect(
    triggers,
    [
      'legacy_invoice_import_attempts_immutable_delete',
      'legacy_invoice_import_attempts_immutable_update',
      'legacy_invoice_import_events_immutable_delete',
      'legacy_invoice_import_events_immutable_update',
      'legacy_invoice_import_occurrences_immutable_identity',
      'legacy_invoice_import_occurrences_prevent_delete',
      'legacy_invoice_import_runs_immutable_identity',
      'legacy_invoice_import_runs_prevent_delete',
      'legacy_invoice_occurrence_mappings_immutable_delete',
      'legacy_invoice_occurrence_mappings_immutable_update',
      'legacy_invoice_occurrence_mappings_validate_insert',
    ],
  );
}

Future<void> _runV7ToV8Upgrade(AppDatabase database) async {
  await database.transaction(() async {
    await database.migration.onUpgrade(Migrator(database), 7, 8);
    await database.customStatement('PRAGMA user_version = 8');
  });
}

Future<List<String>> _readD4Tables(AppDatabase database) async {
  return database
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name IN (${_d4Tables.map((name) => "'$name'").join(', ')}) "
        'ORDER BY name',
      )
      .map((row) => row.read<String>('name'))
      .get();
}

Future<List<Map<String, Object?>>> _snapshotSchemaObjects(
  AppDatabase database,
) async {
  final rows = await database
      .customSelect(
        "SELECT type, name, tbl_name, sql FROM sqlite_master "
        "WHERE name NOT LIKE 'sqlite_%' ORDER BY type, name",
      )
      .get();
  return rows.map((row) => row.data).toList();
}

Future<List<Map<String, Object?>>> _readCurrencies(
  AppDatabase database,
) async {
  final rows = await database
      .customSelect('SELECT * FROM currencies ORDER BY currency_code')
      .get();
  return rows.map((row) => row.data).toList();
}

Future<int> _readUserVersion(AppDatabase database) async =>
    (await database.customSelect('PRAGMA user_version').getSingle()).read<int>(
      'user_version',
    );

Future<void> _expectDatabaseHealthy(AppDatabase database) async {
  expect(
    (await database.customSelect('PRAGMA foreign_keys').getSingle()).read<int>(
      'foreign_keys',
    ),
    1,
  );
  expect(
    await database.customSelect('PRAGMA foreign_key_check').get(),
    isEmpty,
  );
  expect(
    (await database.customSelect('PRAGMA integrity_check').getSingle())
        .read<String>('integrity_check'),
    'ok',
  );
}
