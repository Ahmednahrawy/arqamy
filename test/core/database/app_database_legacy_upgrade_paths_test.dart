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
      'arqamy_legacy_upgrade_paths_',
    );
    databasePath =
        '${temporaryDirectory.path}${Platform.pathSeparator}ledger.sqlite';
    database = await AppDatabase.open(path: databasePath);
  });

  tearDown(() async {
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test(
    'upgrades a v5 journal-free database atomically and retries after collision',
    () async {
      await database.customStatement(
        "INSERT INTO currencies VALUES ('EGP', 2, 'Egyptian pound')",
      );
      await _removePartyReviewJournal(database);
      await database.customStatement('PRAGMA user_version = 5');
      await database.customStatement(
        'CREATE TABLE legacy_migration_runs (unexpected TEXT)',
      );

      final schemaBeforeFailure = await _snapshotSchemaObjects(database);
      final currenciesBeforeFailure = await _readCurrencies(database);

      await expectLater(
        _runProductionUpgrade(database, from: 5, to: 7),
        throwsA(anything),
      );

      expect(await _readUserVersion(database), 5);
      expect(await _snapshotSchemaObjects(database), schemaBeforeFailure);
      expect(await _readCurrencies(database), currenciesBeforeFailure);
      await _expectDatabaseHealthy(database);

      await database.customStatement('DROP TABLE legacy_migration_runs');
      await _runProductionUpgrade(database, from: 5, to: 7);

      expect(await _readUserVersion(database), 7);
      expect(await _readCurrencies(database), currenciesBeforeFailure);
      await _expectPartyReviewJournalExists(database);
      await _expectDatabaseHealthy(database);
    },
  );

  test('runs the v6 to v7 validation-trigger replacement path', () async {
    await database.customStatement(
      "INSERT INTO currencies VALUES ('EGP', 2, 'Egyptian pound')",
    );
    final currenciesBefore = await _readCurrencies(database);
    await database.customStatement('PRAGMA user_version = 6');

    await _runProductionUpgrade(database, from: 6, to: 7);

    expect(await _readUserVersion(database), 7);
    expect(await _readCurrencies(database), currenciesBefore);
    await _expectPartyReviewJournalExists(database);

    final validationTrigger = await database
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE type = 'trigger' "
          "AND name = 'legacy_party_review_decisions_validate_insert'",
        )
        .getSingle();
    expect(
      validationTrigger.read<String>('sql'),
      contains('legacy_party_review_decisions_validate_insert'),
    );
    await _expectDatabaseHealthy(database);
  });

  test(
    'preserves the v7 schema and data on the current v7 no-op path',
    () async {
      await database.customStatement(
        "INSERT INTO currencies VALUES ('EGP', 2, 'Egyptian pound')",
      );
      final schemaBefore = await _snapshotSchemaObjects(database);
      final currenciesBefore = await _readCurrencies(database);
      await database.customStatement('PRAGMA user_version = 7');

      await _runProductionUpgrade(database, from: 7, to: 7);

      expect(await _readUserVersion(database), 7);
      expect(await _snapshotSchemaObjects(database), schemaBefore);
      expect(await _readCurrencies(database), currenciesBefore);
      await _expectDatabaseHealthy(database);
    },
  );
}

Future<void> _removePartyReviewJournal(AppDatabase database) async {
  final triggers = await database
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'trigger' "
        "AND tbl_name IN ('legacy_party_review_decisions', "
        "'legacy_migration_occurrences', 'legacy_migration_runs')",
      )
      .map((row) => row.read<String>('name'))
      .get();

  for (final trigger in triggers) {
    await database.customStatement('DROP TRIGGER "$trigger"');
  }

  await database.customStatement('DROP TABLE legacy_party_review_decisions');
  await database.customStatement('DROP TABLE legacy_migration_occurrences');
  await database.customStatement('DROP TABLE legacy_migration_runs');
}

Future<void> _runProductionUpgrade(
  AppDatabase database, {
  required int from,
  required int to,
}) async {
  await database.transaction(() async {
    await database.customStatement('PRAGMA defer_foreign_keys = ON');
    await database.migration.onUpgrade(Migrator(database), from, to);

    final foreignKeyViolations = await database
        .customSelect('PRAGMA foreign_key_check')
        .get();
    if (foreignKeyViolations.isNotEmpty) {
      throw StateError(
        'Migration left foreign-key violations: $foreignKeyViolations',
      );
    }

    final integrityResults = await database
        .customSelect('PRAGMA integrity_check')
        .get();
    final integrityMessages = integrityResults
        .map((row) => row.read<String>('integrity_check'))
        .toList(growable: false);
    if (integrityMessages.length != 1 || integrityMessages.single != 'ok') {
      throw StateError(
        'SQLite integrity check failed after migration: $integrityMessages',
      );
    }

    await database.customStatement('PRAGMA defer_foreign_keys = OFF');
    final foreignKeysEnabled =
        (await database.customSelect('PRAGMA foreign_keys').getSingle())
            .read<int>('foreign_keys');
    if (foreignKeysEnabled != 1) {
      throw StateError('Foreign-key enforcement was unexpectedly disabled.');
    }

    await database.customStatement('PRAGMA user_version = $to');
  });
}

Future<void> _expectPartyReviewJournalExists(AppDatabase database) async {
  final tables = await database
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name IN ('legacy_migration_runs', "
        "'legacy_migration_occurrences', 'legacy_party_review_decisions') "
        'ORDER BY name',
      )
      .map((row) => row.read<String>('name'))
      .get();

  expect(tables, [
    'legacy_migration_occurrences',
    'legacy_migration_runs',
    'legacy_party_review_decisions',
  ]);

  final triggers = await database
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'trigger' "
        "AND name IN ('legacy_migration_runs_immutable_update', "
        "'legacy_migration_runs_immutable_delete', "
        "'legacy_migration_occurrences_immutable_update', "
        "'legacy_migration_occurrences_immutable_delete', "
        "'legacy_party_review_decisions_immutable_update', "
        "'legacy_party_review_decisions_immutable_delete') "
        'ORDER BY name',
      )
      .map((row) => row.read<String>('name'))
      .get();

  expect(triggers, [
    'legacy_migration_occurrences_immutable_delete',
    'legacy_migration_occurrences_immutable_update',
    'legacy_migration_runs_immutable_delete',
    'legacy_migration_runs_immutable_update',
    'legacy_party_review_decisions_immutable_delete',
    'legacy_party_review_decisions_immutable_update',
  ]);
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

Future<List<Map<String, Object?>>> _readCurrencies(AppDatabase database) async {
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
