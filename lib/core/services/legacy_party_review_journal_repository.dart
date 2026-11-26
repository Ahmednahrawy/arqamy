import 'dart:async';
import 'dart:convert';

import 'package:arqamy/core/database/app_database.dart';
import 'package:arqamy/core/services/legacy_invoice_party_resolution_planner.dart';
import 'package:arqamy/core/services/legacy_invoice_preflight_service.dart';
import 'package:arqamy/core/services/legacy_invoice_party_resolution_review.dart';
import 'package:arqamy/core/services/legacy_party_review_journal_models.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart' show SqliteException;
import 'package:uuid/uuid.dart';

class LegacyPartyReviewIdempotencyConflict implements Exception {
  const LegacyPartyReviewIdempotencyConflict(this.idempotencyKey);
  final String idempotencyKey;
  @override
  String toString() =>
      'Legacy party review idempotency key "$idempotencyKey" '
      'was reused with a different request.';
}

/// Persists only the D3.1 migration-run, occurrence, and decision journal.
/// It never creates parties, changes roles, links invoices, or writes finance data.
class LegacyPartyReviewJournalRepository {
  LegacyPartyReviewJournalRepository(
    this._database, {
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
  }) : _uuid = uuid,
       _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _clock;
  Future<void> _mutationQueue = Future<void>.value();

  Future<T> _serialize<T>(Future<T> Function() operation) async {
    final previous = _mutationQueue;
    final release = Completer<void>();
    _mutationQueue = release.future;
    await previous;
    try {
      return await operation();
    } finally {
      release.complete();
    }
  }

  Future<T> _transaction<T>(Future<T> Function() operation) async {
    const maxAttempts = 8;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await _database.transaction(operation);
      } on SqliteException catch (error) {
        final busy = error.resultCode == 5 || error.resultCode == 6;
        if (!busy || attempt == maxAttempts - 1) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 10 * (1 << attempt)));
      }
    }
    throw StateError('Transaction retry loop ended unexpectedly.');
  }

  Future<LegacyPartyReviewJournalRun> createRun({
    required String runId,
    required String snapshotManifestPath,
    required int migrationVersion,
    required int occurrenceIdentityVersion,
    required int preflightVersion,
    required String createdByActorId,
    required LegacyInvoicePreflightReport preflight,
    required LegacyPartyResolutionReport plan,
  }) {
    _validateText(runId, 'runId');
    _validateText(snapshotManifestPath, 'snapshotManifestPath');
    _validateText(createdByActorId, 'createdByActorId');
    _validatePositive(migrationVersion, 'migrationVersion');
    _validatePositive(occurrenceIdentityVersion, 'occurrenceIdentityVersion');
    _validatePositive(preflightVersion, 'preflightVersion');
    if (!preflight.sourceExists || !preflight.isComplete) {
      throw ArgumentError(
        'Only a complete, verified snapshot can be journaled.',
      );
    }
    if (!_isSha256(preflight.snapshotSha256) ||
        plan.snapshotSha256 != preflight.snapshotSha256) {
      throw ArgumentError(
        'Preflight and party plan must use the same SHA-256 snapshot.',
      );
    }
    if (plan.resolutions.length != preflight.occurrences.length) {
      throw ArgumentError(
        'The party plan must contain every preflight occurrence.',
      );
    }
    final byKey = {
      for (final item in preflight.occurrences)
        item.sourceOccurrenceIdentity.key: item,
    };
    if (byKey.length != preflight.occurrences.length) {
      throw ArgumentError('Preflight contains duplicate occurrence keys.');
    }
    for (final item in preflight.occurrences) {
      if (item.sourceOccurrenceIdentity.snapshotSha256 !=
          preflight.snapshotSha256) {
        throw ArgumentError(
          'Every occurrence identity must belong to the preflight snapshot.',
        );
      }
      if (item.sourceOccurrenceIdentity.version != occurrenceIdentityVersion) {
        throw ArgumentError(
          'Occurrence identity version does not match the run metadata.',
        );
      }
    }
    final planKeys = plan.resolutions
        .map((item) => item.sourceOccurrenceKey)
        .toSet();
    if (planKeys.length != plan.resolutions.length ||
        planKeys.length != byKey.length) {
      throw ArgumentError(
        'Party plan must contain each occurrence key exactly once.',
      );
    }
    for (final resolution in plan.resolutions) {
      final item = byKey[resolution.sourceOccurrenceKey];
      if (item == null || item.sourceIndex != resolution.sourceIndex) {
        throw ArgumentError(
          'Party plan keys and source indexes must match preflight.',
        );
      }
    }

    return _serialize(
      () => _transaction(() async {
        final existing = await _database
            .customSelect(
              'SELECT run_id FROM legacy_migration_runs WHERE run_id = ?',
              variables: [Variable.withString(runId)],
            )
            .getSingleOrNull();
        if (existing != null)
          throw StateError('Migration run "$runId" already exists.');

        await _database.customStatement(
          'INSERT INTO legacy_migration_runs (run_id, snapshot_sha256, '
          'snapshot_manifest_path, migration_version, occurrence_identity_version, '
          'preflight_version, created_at, created_by_actor_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          [
            runId,
            preflight.snapshotSha256,
            snapshotManifestPath,
            migrationVersion,
            occurrenceIdentityVersion,
            preflightVersion,
            _clock().toUtc().millisecondsSinceEpoch,
            createdByActorId,
          ],
        );

        final resolutions = {
          for (final item in plan.resolutions) item.sourceOccurrenceKey: item,
        };
        for (final item in preflight.occurrences) {
          final resolution = resolutions[item.sourceOccurrenceIdentity.key]!;
          final findings = jsonEncode({
            'issues': item.issues.map((issue) => issue.name).toList(),
            'malformedReasons': item.malformedReasons,
          });
          await _database.customStatement(
            'INSERT INTO legacy_migration_occurrences (run_id, source_occurrence_key, '
            'source_index, record_sha256, legacy_invoice_id, preflight_classification, '
            'resolution_status, expected_role, suggested_party_id, suggested_party_name, '
            'candidate_party_ids_json, findings_json) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              runId,
              item.sourceOccurrenceIdentity.key,
              item.sourceIndex,
              item.sourceOccurrenceIdentity.recordSha256,
              item.invoiceId,
              item.classification.name,
              resolution.status.name,
              _roleToDatabase(resolution.expectedRole),
              resolution.partyId,
              resolution.partyDisplayName,
              jsonEncode(resolution.candidatePartyIds),
              findings,
            ],
          );
        }
        return _readRun(runId);
      }),
    );
  }

  Future<LegacyPartyReviewJournalRun> getRun(String runId) {
    _validateText(runId, 'runId');
    return _readRun(runId);
  }

  Future<List<LegacyPartyReviewJournalDecision>> getDecisionHistory({
    required String runId,
    required String sourceOccurrenceKey,
  }) async {
    _validateText(runId, 'runId');
    _validateText(sourceOccurrenceKey, 'sourceOccurrenceKey');
    final rows = await _database
        .customSelect(
          'SELECT * FROM legacy_party_review_decisions WHERE run_id = ? '
          'AND source_occurrence_key = ? ORDER BY sequence ASC',
          variables: [
            Variable.withString(runId),
            Variable.withString(sourceOccurrenceKey),
          ],
        )
        .get();
    return List.unmodifiable(rows.map((row) => _decisionFromMap(row.data)));
  }

  Future<LegacyPartyReviewJournalSummary> getSummary(String runId) async {
    final run = await getRun(runId);
    var approved = 0;
    var held = 0;
    var stale = 0;
    var reviewed = 0;
    for (final occurrence in run.occurrences) {
      final latest = occurrence.latestDecision;
      if (latest == null) continue;
      reviewed++;
      if (latest.action == LegacyPartyReviewAction.keepHeld) {
        held++;
      } else if (await _partyHasRole(
        latest.resolvedPartyId,
        latest.resolvedPartyRole,
      )) {
        approved++;
      } else {
        stale++;
      }
    }
    final total = run.occurrences.length;
    return LegacyPartyReviewJournalSummary(
      totalOccurrences: total,
      approvedCount: approved,
      heldCount: held,
      staleCount: stale,
      reviewedCount: reviewed,
      unreviewedCount: total - reviewed,
    );
  }

  /// Records one decision. This is a convenience wrapper over the atomic batch API.
  Future<LegacyPartyReviewDecisionResult> recordDecision(
    RecordLegacyPartyReviewDecisionRequest request,
  ) async {
    final results = await recordDecisions([request]);
    return results.single;
  }

  /// Commits every decision in [requests] in one SQLite transaction.
  ///
  /// If any request is invalid or conflicts with an existing idempotency key,
  /// the entire batch is rolled back.
  Future<List<LegacyPartyReviewDecisionResult>> recordDecisions(
    Iterable<RecordLegacyPartyReviewDecisionRequest> requests,
  ) {
    final batch = requests.toList(growable: false);
    if (batch.isEmpty) {
      return Future<List<LegacyPartyReviewDecisionResult>>.value(const []);
    }
    return _serialize(
      () => _transaction(() async {
        final results = <LegacyPartyReviewDecisionResult>[];
        for (final request in batch) {
          results.add(await _recordDecisionInTransaction(request));
        }
        return List.unmodifiable(results);
      }),
    );
  }

  Future<LegacyPartyReviewDecisionResult> _recordDecisionInTransaction(
    RecordLegacyPartyReviewDecisionRequest request,
  ) async {
    _validateText(request.runId, 'runId');
    _validateText(request.idempotencyKey, 'idempotencyKey');
    final decision = request.decision;
    _validateText(decision.snapshotSha256, 'snapshotSha256');
    _validateText(decision.sourceOccurrenceKey, 'sourceOccurrenceKey');
    _validateText(decision.reviewerId, 'reviewerId');
    if (!decision.decidedAtUtc.isUtc) {
      throw ArgumentError('Decision timestamp must be UTC.');
    }
    final rawNote = request.reviewNote?.trim();
    final note = rawNote == null || rawNote.isEmpty ? null : rawNote;
    final fingerprint = _decisionFingerprint(request.runId, decision, note);

    // Idempotency is checked before mutable party state, so retries remain stable.
    final duplicate = await _database
        .customSelect(
          'SELECT decision_id, run_id, source_occurrence_key, sequence, request_fingerprint '
          'FROM legacy_party_review_decisions WHERE idempotency_key = ?',
          variables: [Variable.withString(request.idempotencyKey.trim())],
        )
        .getSingleOrNull();
    if (duplicate != null) {
      if (duplicate.read<String>('request_fingerprint') != fingerprint) {
        throw LegacyPartyReviewIdempotencyConflict(request.idempotencyKey);
      }
      return LegacyPartyReviewDecisionResult(
        runId: duplicate.read<String>('run_id'),
        sourceOccurrenceKey: duplicate.read<String>('source_occurrence_key'),
        decisionId: duplicate.read<String>('decision_id'),
        sequence: duplicate.read<int>('sequence'),
        wasIdempotentReplay: true,
      );
    }

    final run = await _database
        .customSelect(
          'SELECT snapshot_sha256 FROM legacy_migration_runs WHERE run_id = ?',
          variables: [Variable.withString(request.runId)],
        )
        .getSingleOrNull();
    if (run == null) throw StateError('Migration run does not exist.');
    if (run.read<String>('snapshot_sha256') != decision.snapshotSha256) {
      throw ArgumentError('Review decision belongs to a different snapshot.');
    }
    final occurrence = await _database
        .customSelect(
          'SELECT expected_role, suggested_party_id FROM legacy_migration_occurrences '
          'WHERE run_id = ? AND source_occurrence_key = ?',
          variables: [
            Variable.withString(request.runId),
            Variable.withString(decision.sourceOccurrenceKey),
          ],
        )
        .getSingleOrNull();
    if (occurrence == null) {
      throw ArgumentError('Review decision references an unknown occurrence.');
    }

    final expectedRoleValue = occurrence.data['expected_role'] as String?;
    final expectedRole = _roleFromDatabase(expectedRoleValue);
    String? partyId;
    String? partyName;
    String? partyRole;
    switch (decision.action) {
      case LegacyPartyReviewAction.keepHeld:
        if (decision.selectedPartyId != null) {
          throw ArgumentError('keepHeld must not select a party.');
        }
        break;
      case LegacyPartyReviewAction.acceptSuggestedMatch:
        if (decision.selectedPartyId != null) {
          throw ArgumentError(
            'acceptSuggestedMatch must not supply a party ID.',
          );
        }
        final suggestedId = occurrence.data['suggested_party_id'] as String?;
        if (suggestedId == null) {
          throw ArgumentError('There is no suggested party to accept.');
        }
        final party = await _findRoleCompatibleParty(suggestedId, expectedRole);
        partyId = party.id;
        partyName = party.name;
        partyRole = _roleToDatabase(expectedRole);
        break;
      case LegacyPartyReviewAction.selectParty:
        final selectedId = decision.selectedPartyId;
        if (selectedId == null || selectedId.trim().isEmpty) {
          throw ArgumentError('selectParty requires a party ID.');
        }
        final party = await _findRoleCompatibleParty(selectedId, expectedRole);
        partyId = party.id;
        partyName = party.name;
        partyRole = _roleToDatabase(expectedRole);
        break;
    }

    final previous = await _database
        .customSelect(
          'SELECT decision_id, sequence FROM legacy_party_review_decisions '
          'WHERE run_id = ? AND source_occurrence_key = ? '
          'ORDER BY sequence DESC LIMIT 1',
          variables: [
            Variable.withString(request.runId),
            Variable.withString(decision.sourceOccurrenceKey),
          ],
        )
        .getSingleOrNull();
    final sequence = previous == null ? 1 : previous.read<int>('sequence') + 1;
    final previousId = previous?.read<String>('decision_id');
    final decisionId = _uuid.v4();
    await _database.customStatement(
      'INSERT INTO legacy_party_review_decisions (decision_id, run_id, '
      'source_occurrence_key, sequence, previous_decision_id, action, expected_role, '
      'resolved_party_id, resolved_party_name, resolved_party_role, reviewer_id, '
      'decided_at, review_note, idempotency_key, request_fingerprint) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        decisionId,
        request.runId,
        decision.sourceOccurrenceKey,
        sequence,
        previousId,
        decision.action.name,
        expectedRoleValue,
        partyId,
        partyName,
        partyRole,
        decision.reviewerId.trim(),
        decision.decidedAtUtc.millisecondsSinceEpoch,
        note,
        request.idempotencyKey.trim(),
        fingerprint,
      ],
    );
    return LegacyPartyReviewDecisionResult(
      runId: request.runId,
      sourceOccurrenceKey: decision.sourceOccurrenceKey,
      decisionId: decisionId,
      sequence: sequence,
      wasIdempotentReplay: false,
    );
  }

  Future<LegacyPartyReviewJournalRun> _readRun(String runId) async {
    final run = await _database
        .customSelect(
          'SELECT * FROM legacy_migration_runs WHERE run_id = ?',
          variables: [Variable.withString(runId)],
        )
        .getSingleOrNull();
    if (run == null) throw StateError('Migration run "$runId" does not exist.');
    final occurrenceRows = await _database
        .customSelect(
          'SELECT * FROM legacy_migration_occurrences WHERE run_id = ? ORDER BY source_index',
          variables: [Variable.withString(runId)],
        )
        .get();
    final decisionRows = await _database
        .customSelect(
          'SELECT * FROM legacy_party_review_decisions WHERE run_id = ? '
          'ORDER BY source_occurrence_key, sequence',
          variables: [Variable.withString(runId)],
        )
        .get();
    final byKey = <String, List<LegacyPartyReviewJournalDecision>>{};
    for (final row in decisionRows) {
      final item = _decisionFromMap(row.data);
      (byKey[item.sourceOccurrenceKey] ??= []).add(item);
    }

    final occurrences = <LegacyPartyReviewJournalOccurrence>[];
    for (final row in occurrenceRows) {
      final data = row.data;
      final candidates = jsonDecode(
        data['candidate_party_ids_json']! as String,
      );
      final findings = jsonDecode(data['findings_json']! as String);
      if (candidates is! List ||
          candidates.any((item) => item is! String) ||
          findings is! Map) {
        throw StateError('Corrupt legacy party review journal JSON.');
      }
      final key = data['source_occurrence_key']! as String;
      occurrences.add(
        LegacyPartyReviewJournalOccurrence(
          runId: runId,
          sourceOccurrenceKey: key,
          sourceIndex: data['source_index']! as int,
          recordSha256: data['record_sha256']! as String,
          legacyInvoiceId: data['legacy_invoice_id'] as String?,
          preflightClassification: data['preflight_classification']! as String,
          resolutionStatus: data['resolution_status']! as String,
          expectedRole: _roleFromDatabase(data['expected_role'] as String?),
          suggestedPartyId: data['suggested_party_id'] as String?,
          suggestedPartyName: data['suggested_party_name'] as String?,
          candidatePartyIds: candidates.cast<String>(),
          findings: findings.cast<String, Object?>(),
          decisions: byKey[key] ?? const [],
        ),
      );
    }
    return LegacyPartyReviewJournalRun(
      runId: runId,
      snapshotSha256: run.read<String>('snapshot_sha256'),
      snapshotManifestPath: run.read<String>('snapshot_manifest_path'),
      migrationVersion: run.read<int>('migration_version'),
      occurrenceIdentityVersion: run.read<int>('occurrence_identity_version'),
      preflightVersion: run.read<int>('preflight_version'),
      createdAtUtc: DateTime.fromMillisecondsSinceEpoch(
        run.read<int>('created_at'),
        isUtc: true,
      ),
      createdByActorId: run.read<String>('created_by_actor_id'),
      occurrences: occurrences,
    );
  }

  Future<bool> _partyHasRole(String? partyId, LedgerPartyRole? role) async {
    if (partyId == null || role == null) return false;
    final row = await _database
        .customSelect(
          'SELECT 1 AS present FROM parties p '
          'JOIN party_roles pr ON pr.party_id = p.party_id '
          'WHERE p.party_id = ? AND pr.role = ?',
          variables: [
            Variable.withString(partyId),
            Variable.withString(_roleToDatabase(role)!),
          ],
        )
        .getSingleOrNull();
    return row != null;
  }

  Future<({String id, String name})> _findRoleCompatibleParty(
    String partyId,
    LedgerPartyRole? expectedRole,
  ) async {
    if (expectedRole == null) {
      throw ArgumentError(
        'This occurrence has no expected customer/supplier role.',
      );
    }
    final row = await _database
        .customSelect(
          'SELECT p.party_id, p.display_name FROM parties p '
          'JOIN party_roles pr ON pr.party_id = p.party_id '
          'WHERE p.party_id = ? AND pr.role = ?',
          variables: [
            Variable.withString(partyId),
            Variable.withString(_roleToDatabase(expectedRole)!),
          ],
        )
        .getSingleOrNull();
    if (row == null) {
      throw ArgumentError(
        'Party "$partyId" does not exist or lacks the required role.',
      );
    }
    return (
      id: row.read<String>('party_id'),
      name: row.read<String>('display_name'),
    );
  }

  LegacyPartyReviewJournalDecision _decisionFromMap(Map<String, Object?> data) {
    final actionName = data['action']! as String;
    final action = LegacyPartyReviewAction.values.firstWhere(
      (value) => value.name == actionName,
      orElse: () =>
          throw StateError('Unknown persisted review action: $actionName'),
    );
    return LegacyPartyReviewJournalDecision(
      decisionId: data['decision_id']! as String,
      runId: data['run_id']! as String,
      sourceOccurrenceKey: data['source_occurrence_key']! as String,
      sequence: data['sequence']! as int,
      previousDecisionId: data['previous_decision_id'] as String?,
      action: action,
      expectedRole: _roleFromDatabase(data['expected_role'] as String?),
      resolvedPartyId: data['resolved_party_id'] as String?,
      resolvedPartyName: data['resolved_party_name'] as String?,
      resolvedPartyRole: _roleFromDatabase(
        data['resolved_party_role'] as String?,
      ),
      reviewerId: data['reviewer_id']! as String,
      decidedAtUtc: DateTime.fromMillisecondsSinceEpoch(
        data['decided_at']! as int,
        isUtc: true,
      ),
      reviewNote: data['review_note'] as String?,
      idempotencyKey: data['idempotency_key']! as String,
      requestFingerprint: data['request_fingerprint']! as String,
    );
  }

  String _decisionFingerprint(
    String runId,
    LegacyPartyReviewDecision decision,
    String? reviewNote,
  ) {
    final payload = jsonEncode([
      runId,
      decision.snapshotSha256,
      decision.sourceOccurrenceKey,
      decision.action.name,
      decision.selectedPartyId,
      decision.reviewerId.trim(),
      decision.decidedAtUtc.toIso8601String(),
      reviewNote,
    ]);
    return sha256.convert(utf8.encode(payload)).toString();
  }

  static String? _roleToDatabase(LedgerPartyRole? role) => switch (role) {
    LedgerPartyRole.customer => 'customer',
    LedgerPartyRole.supplier => 'supplier',
    null => null,
  };

  static LedgerPartyRole? _roleFromDatabase(String? value) => switch (value) {
    'customer' => LedgerPartyRole.customer,
    'supplier' => LedgerPartyRole.supplier,
    null => null,
    _ => throw StateError('Unknown persisted party role: $value'),
  };

  static bool _isSha256(String value) =>
      RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(value);

  static void _validateText(String value, String name) {
    if (value.trim().isEmpty)
      throw ArgumentError.value(value, name, 'Must not be empty.');
  }

  static void _validatePositive(int value, String name) {
    if (value <= 0) throw ArgumentError.value(value, name, 'Must be positive.');
  }
}
