import 'dart:io';

import 'package:arqamy/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'arqamy_stage_d3_schema_',
    );
    databasePath =
        '${temporaryDirectory.path}${Platform.pathSeparator}ledger.sqlite';
    database = await AppDatabase.open(path: databasePath);
  });

  tearDown(() async {
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('creates the three persistent journal tables on a fresh database', () async {
    expect(database.schemaVersion, 6);
    expect(await database.storedSchemaVersion, 6);

    final tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name LIKE 'legacy_%' ORDER BY name",
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
          "AND name LIKE 'legacy_%' ORDER BY name",
        )
        .map((row) => row.read<String>('name'))
        .get();

    expect(
      triggers,
      containsAll([
        'legacy_migration_runs_immutable_update',
        'legacy_migration_runs_immutable_delete',
        'legacy_migration_occurrences_immutable_update',
        'legacy_migration_occurrences_immutable_delete',
        'legacy_party_review_decisions_immutable_update',
        'legacy_party_review_decisions_immutable_delete',
        'legacy_migration_occurrences_validate_insert',
        'legacy_party_review_decisions_validate_insert',
      ]),
    );
  });

  test('enforces journal constraints, decision sequencing, and immutability', () async {
    await expectLater(
      _insertRun(database, runId: 'bad-run', digest: 'not-a-sha'),
      throwsA(anything),
    );

    await _insertRun(database);
    await _insertParty(database, 'party-customer', 'Customer One', 'customer');
    await _insertParty(database, 'party-supplier', 'Supplier One', 'supplier');

    await expectLater(
      _insertOccurrence(
        database,
        key: 'bad-json',
        candidateJson: '{invalid',
      ),
      throwsA(anything),
    );

    await expectLater(
      _insertOccurrence(
        database,
        key: 'bad-role',
        expectedRole: 'employee',
      ),
      throwsA(anything),
    );

    await _insertOccurrence(
      database,
      key: 'occurrence-1',
      expectedRole: 'customer',
    );
    await _insertOccurrence(
      database,
      key: 'occurrence-2',
      expectedRole: 'customer',
      suggestedPartyId: 'party-customer',
      suggestedPartyName: 'Customer One',
      sourceIndex: 1,
    );

    await expectLater(
      _insertOccurrence(
        database,
        key: 'missing-suggestion',
        expectedRole: 'customer',
        suggestedPartyId: 'party-does-not-exist',
        suggestedPartyName: 'Missing',
        sourceIndex: 2,
      ),
      throwsA(anything),
    );

    await _insertDecision(
      database,
      decisionId: 'decision-1',
      occurrenceKey: 'occurrence-1',
      sequence: 1,
      action: 'selectParty',
      expectedRole: 'customer',
      partyId: 'party-customer',
      partyName: 'Customer One',
      partyRole: 'customer',
    );

    await _insertDecision(
      database,
      decisionId: 'decision-2',
      occurrenceKey: 'occurrence-1',
      sequence: 2,
      previousDecisionId: 'decision-1',
      action: 'keepHeld',
      expectedRole: 'customer',
    );

    await expectLater(
      _insertDecision(
        database,
        decisionId: 'decision-gap',
        occurrenceKey: 'occurrence-1',
        sequence: 4,
        previousDecisionId: 'decision-2',
        action: 'keepHeld',
        expectedRole: 'customer',
      ),
      throwsA(anything),
    );

    await expectLater(
      _insertDecision(
        database,
        decisionId: 'decision-wrong-role',
        occurrenceKey: 'occurrence-1',
        sequence: 3,
        previousDecisionId: 'decision-2',
        action: 'selectParty',
        expectedRole: 'supplier',
        partyId: 'party-supplier',
        partyName: 'Supplier One',
        partyRole: 'supplier',
      ),
      throwsA(anything),
    );

    await _insertDecision(
      database,
      decisionId: 'decision-3',
      occurrenceKey: 'occurrence-2',
      sequence: 1,
      action: 'acceptSuggestedMatch',
      expectedRole: 'customer',
      partyId: 'party-customer',
      partyName: 'Customer One',
      partyRole: 'customer',
      idempotencyKey: 'decision-3-key',
    );

    for (final table in [
      'legacy_migration_runs',
      'legacy_migration_occurrences',
      'legacy_party_review_decisions',
    ]) {
      await expectLater(
        database.customStatement(
          'UPDATE $table SET rowid = rowid '
          'WHERE rowid = (SELECT rowid FROM $table LIMIT 1)',
        ),
        throwsA(anything),
        reason: '$table must reject updates',
      );
      await expectLater(
        database.customStatement(
          'DELETE FROM $table WHERE rowid = (SELECT rowid FROM $table LIMIT 1)',
        ),
        throwsA(anything),
        reason: '$table must reject deletes',
      );
    }

    await expectLater(
      _insertOccurrence(
        database,
        key: 'late-occurrence',
        expectedRole: 'customer',
        sourceIndex: 3,
      ),
      throwsA(anything),
      reason: 'occurrence planner output is frozen after review begins',
    );

    expect(
      await database.customSelect('PRAGMA foreign_key_check').get(),
      isEmpty,
    );
  });

  test('upgrades a version 5 database and preserves existing business data', () async {
    await database.customStatement(
      'INSERT INTO currencies (currency_code, minor_unit_scale, display_name) '
      'VALUES (?, ?, ?)',
      ['EGP', 2, 'Egyptian Pound'],
    );
    await database.customStatement(
      'INSERT INTO parties (party_id, display_name, created_at, updated_at) '
      'VALUES (?, ?, ?, ?)',
      ['party-preserved', 'Preserved Party', 100, 200],
    );
    await database.customStatement(
      'INSERT INTO party_roles (party_id, role) VALUES (?, ?)',
      ['party-preserved', 'customer'],
    );

    // Remove only the v6 additions to form the actual v5 table layout.
    await database.customStatement('DROP TABLE legacy_party_review_decisions');
    await database.customStatement('DROP TABLE legacy_migration_occurrences');
    await database.customStatement('DROP TABLE legacy_migration_runs');
    await database.customStatement('PRAGMA user_version = 5');
    await database.close();

    database = await AppDatabase.open(path: databasePath);

    expect(await database.storedSchemaVersion, 6);
    expect(
      await database
          .customSelect('SELECT display_name FROM parties WHERE party_id = ?', variables: [
            const Variable<String>('party-preserved'),
          ])
          .map((row) => row.read<String>('display_name'))
          .getSingle(),
      'Preserved Party',
    );
    expect(
      await database
          .customSelect('SELECT role FROM party_roles WHERE party_id = ?', variables: [
            const Variable<String>('party-preserved'),
          ])
          .map((row) => row.read<String>('role'))
          .getSingle(),
      'customer',
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
  });
}

Future<void> _insertRun(
  AppDatabase database, {
  String runId = 'run-1',
  String digest = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
}) {
  return database.customStatement(
    'INSERT INTO legacy_migration_runs (run_id, snapshot_sha256, '
    'snapshot_manifest_path, migration_version, occurrence_identity_version, '
    'preflight_version, created_at, created_by_actor_id) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    [runId, digest, 'legacy/snapshots/run-1.json', 1, 1, 1, 1700000000000, 'actor-1'],
  );
}

Future<void> _insertOccurrence(
  AppDatabase database, {
  required String key,
  String? expectedRole,
  String? suggestedPartyId,
  String? suggestedPartyName,
  int sourceIndex = 0,
  String candidateJson = '[]',
}) {
  return database.customStatement(
    'INSERT INTO legacy_migration_occurrences (run_id, source_occurrence_key, '
    'source_index, record_sha256, legacy_invoice_id, preflight_classification, '
    'resolution_status, expected_role, suggested_party_id, suggested_party_name, '
    'candidate_party_ids_json, findings_json) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      'run-1',
      key,
      sourceIndex,
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      null,
      'unclassified',
      'pending',
      expectedRole,
      suggestedPartyId,
      suggestedPartyName,
      candidateJson,
      '[]',
    ],
  );
}

Future<void> _insertParty(
  AppDatabase database,
  String id,
  String name,
  String role,
) async {
  await database.customStatement(
    'INSERT INTO parties (party_id, display_name, created_at, updated_at) '
    'VALUES (?, ?, ?, ?)',
    [id, name, 1, 1],
  );
  await database.customStatement(
    'INSERT INTO party_roles (party_id, role) VALUES (?, ?)',
    [id, role],
  );
}

Future<void> _insertDecision(
  AppDatabase database, {
  required String decisionId,
  required String occurrenceKey,
  required int sequence,
  required String action,
  String? previousDecisionId,
  String? expectedRole,
  String? partyId,
  String? partyName,
  String? partyRole,
  String? idempotencyKey,
}) {
  return database.customStatement(
    'INSERT INTO legacy_party_review_decisions (decision_id, run_id, '
    'source_occurrence_key, sequence, previous_decision_id, action, '
    'expected_role, resolved_party_id, resolved_party_name, resolved_party_role, '
    'reviewer_id, decided_at, review_note, idempotency_key, request_fingerprint) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      decisionId,
      'run-1',
      occurrenceKey,
      sequence,
      previousDecisionId,
      action,
      expectedRole,
      partyId,
      partyName,
      partyRole,
      'reviewer-1',
      1700000000000 + sequence,
      null,
      idempotencyKey ?? '$decisionId-key',
      'fingerprint-$decisionId',
    ],
  );
}
