import 'dart:io';

import 'package:arqamy/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _Version5InspectorDatabase extends GeneratedDatabase {
  _Version5InspectorDatabase(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  Iterable<TableInfo> get allTables => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (_) async {});
}

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

  test(
    'creates the three persistent journal tables on a fresh database',
    () async {
      expect(database.schemaVersion, 8);
      expect(await database.storedSchemaVersion, 8);

      final tables = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name IN ('legacy_migration_occurrences', 'legacy_migration_runs', "
            "'legacy_party_review_decisions') ORDER BY name",
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
    },
  );

  test(
    'enforces journal constraints, decision sequencing, and immutability',
    () async {
      await expectLater(
        _insertRun(database, runId: 'bad-run', digest: 'not-a-sha'),
        throwsA(anything),
      );

      await _insertRun(database);
      await _insertParty(
        database,
        'party-customer',
        'Customer One',
        'customer',
      );
      await _insertParty(
        database,
        'party-supplier',
        'Supplier One',
        'supplier',
      );

      await expectLater(
        _insertOccurrence(database, key: 'bad-json', candidateJson: '{invalid'),
        throwsA(anything),
      );

      await expectLater(
        _insertOccurrence(database, key: 'bad-role', expectedRole: 'employee'),
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
        resolutionStatus: 'resolvedByName',
        sourceIndex: 1,
      );

      await _insertOccurrence(
        database,
        key: 'unresolved-suggestion',
        expectedRole: 'customer',
        suggestedPartyId: 'party-customer',
        suggestedPartyName: 'Customer One',
        resolutionStatus: 'ambiguousName',
        sourceIndex: 2,
      );

      await expectLater(
        _insertDecision(
          database,
          decisionId: 'decision-unresolved-suggestion',
          occurrenceKey: 'unresolved-suggestion',
          sequence: 1,
          action: 'acceptSuggestedMatch',
          expectedRole: 'customer',
          partyId: 'party-customer',
          partyName: 'Customer One',
          partyRole: 'customer',
        ),
        throwsA(anything),
        reason:
            'an ambiguous occurrence must never be approved as a suggestion',
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

      await expectLater(
        _insertDecision(
          database,
          decisionId: 'decision-wrong-party-role',
          occurrenceKey: 'occurrence-1',
          sequence: 3,
          previousDecisionId: 'decision-2',
          action: 'selectParty',
          expectedRole: 'customer',
          partyId: 'party-supplier',
          partyName: 'Supplier One',
          partyRole: 'customer',
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
    },
  );

  test(
    'atomically upgrades v6 review validation and preserves journal history',
    () async {
      await _insertRun(database);
      await _insertParty(
        database,
        'party-v7-customer',
        'Customer V7',
        'customer',
      );
      await _insertOccurrence(
        database,
        key: 'resolved-before-upgrade',
        expectedRole: 'customer',
        suggestedPartyId: 'party-v7-customer',
        suggestedPartyName: 'Customer V7',
        resolutionStatus: 'resolvedByName',
      );
      await _insertOccurrence(
        database,
        key: 'ambiguous-before-upgrade',
        expectedRole: 'customer',
        suggestedPartyId: 'party-v7-customer',
        suggestedPartyName: 'Customer V7',
        resolutionStatus: 'ambiguousName',
        sourceIndex: 1,
      );
      await _insertOccurrence(
        database,
        key: 'resolved-existing-id-before-upgrade',
        expectedRole: 'customer',
        suggestedPartyId: 'party-v7-customer',
        suggestedPartyName: 'Customer V7',
        resolutionStatus: 'resolvedByExistingId',
        sourceIndex: 2,
      );
      await _insertDecision(
        database,
        decisionId: 'decision-before-upgrade',
        occurrenceKey: 'resolved-before-upgrade',
        sequence: 1,
        action: 'keepHeld',
        expectedRole: 'customer',
      );

      await database.customStatement(
        'DROP TRIGGER legacy_party_review_decisions_validate_insert',
      );
      await _createV6PartyReviewDecisionTrigger(database);
      await database.customStatement('PRAGMA user_version = 6');
      await database.close();

      database = await AppDatabase.open(path: databasePath);

      expect(database.schemaVersion, 8);
      expect(await database.storedSchemaVersion, 8);
      final preserved = await database
          .customSelect(
            'SELECT COUNT(*) AS count FROM legacy_party_review_decisions '
            'WHERE decision_id = ?',
            variables: [Variable.withString('decision-before-upgrade')],
          )
          .getSingle();
      expect(preserved.read<int>('count'), 1);

      await expectLater(
        _insertDecision(
          database,
          decisionId: 'decision-invalid-after-upgrade',
          occurrenceKey: 'ambiguous-before-upgrade',
          sequence: 1,
          action: 'acceptSuggestedMatch',
          expectedRole: 'customer',
          partyId: 'party-v7-customer',
          partyName: 'Customer V7',
          partyRole: 'customer',
        ),
        throwsA(anything),
        reason:
            'the v7 trigger must reject approval of an ambiguous resolution',
      );

      await _insertDecision(
        database,
        decisionId: 'decision-valid-after-upgrade',
        occurrenceKey: 'resolved-before-upgrade',
        sequence: 2,
        previousDecisionId: 'decision-before-upgrade',
        action: 'acceptSuggestedMatch',
        expectedRole: 'customer',
        partyId: 'party-v7-customer',
        partyName: 'Customer V7',
        partyRole: 'customer',
      );

      await _insertDecision(
        database,
        decisionId: 'decision-existing-id-after-upgrade',
        occurrenceKey: 'resolved-existing-id-before-upgrade',
        sequence: 1,
        action: 'acceptSuggestedMatch',
        expectedRole: 'customer',
        partyId: 'party-v7-customer',
        partyName: 'Customer V7',
        partyRole: 'customer',
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
    },
  );

  test('rolls back a failed v5-to-v8 journal migration', () async {
    await database.customStatement(
      'INSERT INTO parties (party_id, display_name, created_at, updated_at) '
      'VALUES (?, ?, ?, ?)',
      ['party-rollback', 'Rollback Party', 100, 200],
    );
    await database.customStatement('DROP TABLE legacy_invoice_occurrence_mappings');
    await database.customStatement('DROP TABLE legacy_invoice_import_attempts');
    await database.customStatement('DROP TABLE legacy_invoice_import_events');
    await database.customStatement('DROP TABLE legacy_invoice_import_occurrences');
    await database.customStatement('DROP TABLE legacy_invoice_import_runs');
    await database.customStatement('DROP TABLE legacy_party_review_decisions');
    await database.customStatement('DROP TABLE legacy_migration_occurrences');
    await database.customStatement('DROP TABLE legacy_migration_runs');
    // A view with the target table name cannot be silently accepted by
    // CREATE TABLE IF NOT EXISTS, so this forces the v5-to-v8 DDL to fail
    // after legacy_migration_runs has been created inside the migration.
    await database.customStatement(
      'CREATE VIEW legacy_migration_occurrences AS SELECT 1 AS sentinel',
    );
    await database.customStatement('PRAGMA user_version = 5');
    await database.close();

    var migrationFailed = false;
    try {
      database = await AppDatabase.open(path: databasePath);
    } catch (_) {
      migrationFailed = true;
    }
    expect(
      migrationFailed,
      isTrue,
      reason: 'the injected DDL collision must fail migration',
    );

    final inspector = _Version5InspectorDatabase(
      NativeDatabase(File(databasePath)),
    );
    expect(
      (await inspector.customSelect('PRAGMA user_version').getSingle())
          .read<int>('user_version'),
      5,
    );
    final createdRunTable = await inspector
        .customSelect(
          "SELECT COUNT(*) AS count FROM sqlite_master "
          "WHERE type = 'table' AND name = 'legacy_migration_runs'",
        )
        .getSingle();
    expect(createdRunTable.read<int>('count'), 0);
    final preservedParty = await inspector
        .customSelect(
          'SELECT display_name FROM parties WHERE party_id = ?',
          variables: [Variable.withString('party-rollback')],
        )
        .getSingle();
    expect(preservedParty.read<String>('display_name'), 'Rollback Party');
    await inspector.customStatement('DROP VIEW legacy_migration_occurrences');
    await inspector.close();

    database = await AppDatabase.open(path: databasePath);
    expect(await database.storedSchemaVersion, 8);
  });

  test(
    'upgrades a version 5 database and preserves existing business data',
    () async {
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
      await database.customStatement('DROP TABLE legacy_invoice_occurrence_mappings');
      await database.customStatement('DROP TABLE legacy_invoice_import_attempts');
      await database.customStatement('DROP TABLE legacy_invoice_import_events');
      await database.customStatement('DROP TABLE legacy_invoice_import_occurrences');
      await database.customStatement('DROP TABLE legacy_invoice_import_runs');
      await database.customStatement(
        'DROP TABLE legacy_party_review_decisions',
      );
      await database.customStatement('DROP TABLE legacy_migration_occurrences');
      await database.customStatement('DROP TABLE legacy_migration_runs');
      await database.customStatement('PRAGMA user_version = 5');
      await database.close();

      database = await AppDatabase.open(path: databasePath);

      expect(await database.storedSchemaVersion, 8);
      expect(
        await database
            .customSelect(
              'SELECT display_name FROM parties WHERE party_id = ?',
              variables: [Variable.withString('party-preserved')],
            )
            .map((row) => row.read<String>('display_name'))
            .getSingle(),
        'Preserved Party',
      );
      expect(
        await database
            .customSelect(
              'SELECT role FROM party_roles WHERE party_id = ?',
              variables: [Variable.withString('party-preserved')],
            )
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
    },
  );
}

Future<void> _createV6PartyReviewDecisionTrigger(AppDatabase database) {
  return database.customStatement('''
    CREATE TRIGGER legacy_party_review_decisions_validate_insert
    BEFORE INSERT ON legacy_party_review_decisions
    WHEN NOT EXISTS (
      SELECT 1
      FROM legacy_migration_occurrences o
      WHERE o.run_id = NEW.run_id
        AND o.source_occurrence_key = NEW.source_occurrence_key
        AND o.expected_role IS NEW.expected_role
    )
    OR (NEW.sequence = 1 AND NEW.previous_decision_id IS NOT NULL)
    OR (NEW.sequence > 1 AND NOT EXISTS (
      SELECT 1
      FROM legacy_party_review_decisions previous
      WHERE previous.decision_id = NEW.previous_decision_id
        AND previous.run_id = NEW.run_id
        AND previous.source_occurrence_key = NEW.source_occurrence_key
        AND previous.sequence = NEW.sequence - 1
    ))
    OR NEW.sequence != (
      SELECT COALESCE(MAX(existing.sequence), 0) + 1
      FROM legacy_party_review_decisions existing
      WHERE existing.run_id = NEW.run_id
        AND existing.source_occurrence_key = NEW.source_occurrence_key
    )
    OR (NEW.action = 'acceptSuggestedMatch' AND NOT EXISTS (
      SELECT 1
      FROM legacy_migration_occurrences o
      JOIN parties p ON p.party_id = o.suggested_party_id
      JOIN party_roles pr ON pr.party_id = p.party_id
      WHERE o.run_id = NEW.run_id
        AND o.source_occurrence_key = NEW.source_occurrence_key
        AND o.suggested_party_id = NEW.resolved_party_id
        AND pr.role = NEW.expected_role
        AND NEW.resolved_party_role = NEW.expected_role
    ))
    OR (NEW.action = 'selectParty' AND NOT EXISTS (
      SELECT 1
      FROM parties p
      JOIN party_roles pr ON pr.party_id = p.party_id
      WHERE p.party_id = NEW.resolved_party_id
        AND p.display_name = NEW.resolved_party_name
        AND pr.role = NEW.expected_role
        AND NEW.resolved_party_role = NEW.expected_role
    ))
    BEGIN
      SELECT RAISE(ABORT, 'Invalid legacy party review decision');
    END
  ''');
}

Future<void> _insertRun(
  AppDatabase database, {
  String runId = 'run-1',
  String digest =
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
}) {
  return database.customStatement(
    'INSERT INTO legacy_migration_runs (run_id, snapshot_sha256, '
    'snapshot_manifest_path, migration_version, occurrence_identity_version, '
    'preflight_version, created_at, created_by_actor_id) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    [
      runId,
      digest,
      'legacy/snapshots/run-1.json',
      1,
      1,
      1,
      1700000000000,
      'actor-1',
    ],
  );
}

Future<void> _insertOccurrence(
  AppDatabase database, {
  required String key,
  String? expectedRole,
  String? suggestedPartyId,
  String? suggestedPartyName,
  String resolutionStatus = 'pending',
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
      resolutionStatus,
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
