import 'dart:io';

import 'package:arqamy/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

const _d4Tables = [
  'legacy_invoice_import_attempts',
  'legacy_invoice_import_events',
  'legacy_invoice_import_occurrences',
  'legacy_invoice_import_runs',
  'legacy_invoice_occurrence_mappings',
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

<<<<<<< HEAD
=======
  test('creates the D4 journal on a fresh database', () async {
    expect(await _readD4Tables(database), _d4Tables);
    await _expectD4IndexesAndTriggers(database);
    await _expectDatabaseHealthy(database);
  });

>>>>>>> stage-d4-1-v8-schema
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

  test('enforces D4 immutable identity and append-only journal records', () async {
    await _insertRun(database);

    await expectLater(
      database.customStatement(
        "UPDATE legacy_invoice_import_runs "
        "SET snapshot_sha256 = '${List.filled(64, 'c').join()}' "
        "WHERE run_id = 'run-1'",
      ),
      throwsA(anything),
    );
    await database.customStatement(
      "UPDATE legacy_invoice_import_runs "
      "SET status = 'executing', updated_at = 2 WHERE run_id = 'run-1'",
    );

    await _insertOccurrence(
      database,
      runId: 'run-1',
      sourceOccurrenceKey: 'source-key-1',
      sourceIndex: 0,
    );
    await expectLater(
      database.customStatement(
        "UPDATE legacy_invoice_import_occurrences SET source_index = 9 "
        "WHERE run_id = 'run-1' AND source_occurrence_key = 'source-key-1'",
      ),
      throwsA(anything),
    );
    await database.customStatement(
      "UPDATE legacy_invoice_import_occurrences "
      "SET execution_status = 'held', updated_at = 2 "
      "WHERE run_id = 'run-1' AND source_occurrence_key = 'source-key-1'",
    );
    await expectLater(
      database.customStatement(
        "DELETE FROM legacy_invoice_import_occurrences "
        "WHERE run_id = 'run-1' AND source_occurrence_key = 'source-key-1'",
      ),
      throwsA(anything),
    );

    await _insertAttempt(
      database,
      attemptId: 'attempt-1',
      runId: 'run-1',
      sourceOccurrenceKey: 'source-key-1',
      outcome: 'retryable_failure',
    );
    await expectLater(
      database.customStatement(
        "UPDATE legacy_invoice_import_attempts "
        "SET outcome = 'imported' WHERE attempt_id = 'attempt-1'",
      ),
      throwsA(anything),
    );
    await expectLater(
      database.customStatement(
        "DELETE FROM legacy_invoice_import_attempts "
        "WHERE attempt_id = 'attempt-1'",
      ),
      throwsA(anything),
    );

    await _insertEvent(
      database,
      eventId: 'event-1',
      runId: 'run-1',
      sourceOccurrenceKey: 'source-key-1',
    );
    await expectLater(
      database.customStatement(
        "UPDATE legacy_invoice_import_events "
        "SET reason = 'changed' WHERE event_id = 'event-1'",
      ),
      throwsA(anything),
    );
    await expectLater(
      database.customStatement(
        "DELETE FROM legacy_invoice_import_events "
        "WHERE event_id = 'event-1'",
      ),
      throwsA(anything),
    );
    await _expectDatabaseHealthy(database);
  });

  test(
    'accepts only mappings backed by matching imported occurrence and attempt',
    () async {
      await _insertRun(database);
      await _insertInvoice(
        database,
        invoiceId: 'invoice-1',
        legacyRecordKey: 'source-key-1',
      );
      await _insertOccurrence(
        database,
        runId: 'run-1',
        sourceOccurrenceKey: 'source-key-1',
        sourceIndex: 0,
        executionStatus: 'imported',
        destinationInvoiceId: 'invoice-1',
      );
      await _insertAttempt(
        database,
        attemptId: 'attempt-1',
        runId: 'run-1',
        sourceOccurrenceKey: 'source-key-1',
        outcome: 'imported',
        destinationInvoiceId: 'invoice-1',
      );
      await _insertMapping(
        database,
        sourceOccurrenceKey: 'source-key-1',
        sourceIndex: 0,
        destinationInvoiceId: 'invoice-1',
      );

      expect(
        (await database
                .customSelect(
                  'SELECT COUNT(*) AS count '
                  'FROM legacy_invoice_occurrence_mappings',
                )
                .getSingle())
            .read<int>('count'),
        1,
      );
      await expectLater(
        database.customStatement(
          "UPDATE legacy_invoice_occurrence_mappings "
          "SET destination_fingerprint = 'changed' "
          "WHERE source_occurrence_key = 'source-key-1'",
        ),
        throwsA(anything),
      );
      await expectLater(
        database.customStatement(
          "DELETE FROM legacy_invoice_occurrence_mappings "
          "WHERE source_occurrence_key = 'source-key-1'",
        ),
        throwsA(anything),
      );

      await _insertInvoice(
        database,
        invoiceId: 'invoice-2',
        legacyRecordKey: 'not-source-key-2',
      );
      await _insertOccurrence(
        database,
        runId: 'run-1',
        sourceOccurrenceKey: 'source-key-2',
        sourceIndex: 1,
        executionStatus: 'imported',
        destinationInvoiceId: 'invoice-2',
      );
      await _insertAttempt(
        database,
        attemptId: 'attempt-2',
        runId: 'run-1',
        sourceOccurrenceKey: 'source-key-2',
        outcome: 'imported',
        destinationInvoiceId: 'invoice-2',
      );
      await expectLater(
        _insertMapping(
          database,
          sourceOccurrenceKey: 'source-key-2',
          sourceIndex: 1,
          destinationInvoiceId: 'invoice-2',
        ),
        throwsA(anything),
      );
      await _expectDatabaseHealthy(database);
    },
  );

}



Future<void> _insertRun(
  AppDatabase database, {
  String runId = 'run-1',
}) async {
  await database.customStatement(
    'INSERT INTO legacy_invoice_import_runs ('
    'run_id, parent_run_id, snapshot_sha256, snapshot_byte_length, '
    'snapshot_source_exists, snapshot_format_version, migration_version, '
    'occurrence_identity_version, preflight_version, mapping_contract_version, '
    'party_review_run_id, export_manifest_sha256, created_at, '
    'created_by_actor_id, created_by_actor_source, status, updated_at'
    ') VALUES (?, NULL, ?, 12, 1, 1, 1, 1, 1, 1, NULL, NULL, 1, NULL, '
    "'local_operator', 'prepared', 1)",
    [runId, List.filled(64, 'a').join()],
  );
}

Future<void> _insertOccurrence(
  AppDatabase database, {
  required String runId,
  required String sourceOccurrenceKey,
  required int sourceIndex,
  String executionStatus = 'ready',
  String? destinationInvoiceId,
}) async {
  await database.customStatement(
    'INSERT INTO legacy_invoice_import_occurrences ('
    'run_id, source_occurrence_key, source_index, record_sha256, '
    'preflight_classification, preflight_findings_json, execution_status, '
    'destination_invoice_id, current_attempt_number, updated_at'
    ') VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, 1)',
    [
      runId,
      sourceOccurrenceKey,
      sourceIndex,
      List.filled(64, 'b').join(),
      'valid',
      '[]',
      executionStatus,
      destinationInvoiceId,
    ],
  );
}

Future<void> _insertAttempt(
  AppDatabase database, {
  required String attemptId,
  required String runId,
  required String sourceOccurrenceKey,
  required String outcome,
  String? destinationInvoiceId,
}) async {
  await database.customStatement(
    'INSERT INTO legacy_invoice_import_attempts ('
    'attempt_id, run_id, source_occurrence_key, attempt_number, '
    'attempt_idempotency_key, claim_token_hash, worker_id, started_at, '
    'completed_at, outcome, destination_invoice_id'
    ') VALUES (?, ?, ?, 1, ?, ?, ?, 1, 2, ?, ?)',
    [
      attemptId,
      runId,
      sourceOccurrenceKey,
      'idempotency-$attemptId',
      'claim-hash-$attemptId',
      'test-worker',
      outcome,
      destinationInvoiceId,
    ],
  );
}

Future<void> _insertEvent(
  AppDatabase database, {
  required String eventId,
  required String runId,
  String? sourceOccurrenceKey,
}) async {
  await database.customStatement(
    'INSERT INTO legacy_invoice_import_events ('
    'event_id, run_id, source_occurrence_key, event_type, actor_id, '
    'actor_source, occurred_at, reason, details_json, request_idempotency_key'
    ") VALUES (?, ?, ?, 'hold', NULL, 'local_operator', 1, NULL, '{}', NULL)",
    [eventId, runId, sourceOccurrenceKey],
  );
}

Future<void> _insertInvoice(
  AppDatabase database, {
  required String invoiceId,
  required String legacyRecordKey,
}) async {
  await database.customStatement(
    'INSERT INTO invoices (invoice_id, invoice_serial, legacy_record_key, '
    "action, created_at, updated_at) VALUES (?, ?, ?, 'sale', 1, 1)",
    [invoiceId, 'serial-$invoiceId', legacyRecordKey],
  );
}

Future<void> _insertMapping(
  AppDatabase database, {
  required String sourceOccurrenceKey,
  required int sourceIndex,
  required String destinationInvoiceId,
}) async {
  await database.customStatement(
    'INSERT INTO legacy_invoice_occurrence_mappings ('
    'source_occurrence_key, source_snapshot_sha256, '
    'occurrence_identity_version, source_index, record_sha256, '
    'migration_version, mapping_contract_version, import_run_id, '
    'destination_invoice_id, destination_fingerprint, imported_at'
    ') VALUES (?, ?, 1, ?, ?, 1, 1, ?, ?, ?, 3)',
    [
      sourceOccurrenceKey,
      List.filled(64, 'a').join(),
      sourceIndex,
      List.filled(64, 'b').join(),
      'run-1',
      destinationInvoiceId,
      'destination-fingerprint-$destinationInvoiceId',
    ],
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
