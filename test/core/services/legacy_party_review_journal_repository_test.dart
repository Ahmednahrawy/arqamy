import 'dart:io';

import 'package:arqamy/core/database/app_database.dart'
    hide LegacyPartyReviewDecision;
import 'package:arqamy/core/services/legacy_invoice_party_resolution_planner.dart';
import 'package:arqamy/core/services/legacy_invoice_preflight_service.dart';
import 'package:arqamy/core/services/legacy_invoice_party_resolution_review.dart';
import 'package:arqamy/core/services/legacy_invoice_source_occurrence_identity.dart';
import 'package:arqamy/core/services/legacy_party_review_journal_models.dart';
import 'package:arqamy/core/services/legacy_party_review_journal_repository.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:flutter_test/flutter_test.dart';

const _snapshotHash =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
final _decisionTime = DateTime.utc(2026, 11, 26, 10);

class _Fixture {
  const _Fixture(this.preflight, this.plan, this.keys);
  final LegacyInvoicePreflightReport preflight;
  final LegacyPartyResolutionReport plan;
  final List<String> keys;
}

_Fixture _fixture() {
  final rawRecords = [
    '{"id":"legacy-1"}',
    '{"id":"legacy-2"}',
    '{"id":"legacy-3"}',
  ];
  final identities = [
    for (var i = 0; i < rawRecords.length; i++)
      LegacyInvoiceSourceOccurrenceIdentity.create(
        snapshotSha256: _snapshotHash,
        sourceIndex: i,
        rawJson: rawRecords[i],
      ),
  ];
  final occurrences = [
    for (var i = 0; i < identities.length; i++)
      LegacyInvoicePreflightOccurrence(
        sourceIndex: i,
        sourceOccurrenceIdentity: identities[i],
        classification: LegacyInvoicePreflightClassification.ready,
        invoiceId: 'legacy-${i + 1}',
        serial: 'INV-${i + 1}',
        issues: const [],
        malformedReasons: const [],
        rawJson: rawRecords[i],
      ),
  ];
  final preflight = LegacyInvoicePreflightReport(
    snapshotSha256: _snapshotHash,
    sourceExists: true,
    occurrences: occurrences,
  );
  final plan = LegacyPartyResolutionReport(
    snapshotSha256: _snapshotHash,
    resolutions: [
      LegacyPartyOccurrenceResolution(
        sourceOccurrenceKey: identities[0].key,
        sourceIndex: 0,
        invoiceId: 'legacy-1',
        status: LegacyPartyResolutionStatus.resolvedByName,
        expectedRole: LedgerPartyRole.customer,
        partyId: 'customer-1',
        partyDisplayName: 'Customer One',
      ),
      LegacyPartyOccurrenceResolution(
        sourceOccurrenceKey: identities[1].key,
        sourceIndex: 1,
        invoiceId: 'legacy-2',
        status: LegacyPartyResolutionStatus.ambiguousName,
        expectedRole: LedgerPartyRole.supplier,
        candidatePartyIds: ['supplier-1', 'supplier-2'],
      ),
      LegacyPartyOccurrenceResolution(
        sourceOccurrenceKey: identities[2].key,
        sourceIndex: 2,
        invoiceId: 'legacy-3',
        status: LegacyPartyResolutionStatus.unknownAction,
      ),
    ],
  );
  return _Fixture(preflight, plan, identities.map((item) => item.key).toList());
}

void main() {
  late Directory directory;
  late AppDatabase database;
  late LegacyPartyReviewJournalRepository repository;
  late _Fixture fixture;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'party_review_repository_',
    );
    database = await AppDatabase.open(
      path: '${directory.path}${Platform.pathSeparator}journal.sqlite',
    );
    repository = LegacyPartyReviewJournalRepository(
      database,
      clock: () => DateTime.utc(2026, 11, 26, 9),
    );
    fixture = _fixture();
    await _insertParty(database, 'customer-1', 'Customer One', 'customer');
    await _insertParty(database, 'supplier-1', 'Supplier One', 'supplier');
    await _insertParty(database, 'supplier-2', 'Supplier Two', 'supplier');
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<LegacyPartyReviewJournalRun> createRun() => repository.createRun(
    runId: 'run-1',
    snapshotManifestPath: 'legacy/snapshots/run-1.json',
    migrationVersion: 1,
    occurrenceIdentityVersion: 1,
    preflightVersion: 1,
    createdByActorId: 'actor-1',
    preflight: fixture.preflight,
    plan: fixture.plan,
  );

  LegacyPartyReviewDecision decision(
    int index,
    LegacyPartyReviewAction action, {
    String? selectedPartyId,
    String reviewerId = 'reviewer-1',
  }) => LegacyPartyReviewDecision(
    snapshotSha256: _snapshotHash,
    sourceOccurrenceKey: fixture.keys[index],
    action: action,
    reviewerId: reviewerId,
    decidedAtUtc: _decisionTime,
    selectedPartyId: selectedPartyId,
  );

  test('persists and retrieves a complete immutable run and summary', () async {
    final run = await createRun();
    expect(run.runId, 'run-1');
    expect(run.snapshotSha256, _snapshotHash);
    expect(run.occurrences, hasLength(3));
    expect(
      run.occurrences.first.recordSha256,
      fixture.preflight.occurrences.first.sourceOccurrenceIdentity.recordSha256,
    );
    expect(run.occurrences[1].candidatePartyIds, ['supplier-1', 'supplier-2']);
    expect(run.occurrences[0].findings['issues'], isEmpty);

    final loaded = await repository.getRun('run-1');
    expect(loaded.occurrences.map((item) => item.sourceIndex), [0, 1, 2]);
    final summary = await repository.getSummary('run-1');
    expect(summary.totalOccurrences, 3);
    expect(summary.approvedCount, 0);
    expect(summary.heldCount, 0);
    expect(summary.staleCount, 0);
    expect(summary.reviewedCount, 0);
    expect(summary.unreviewedCount, 3);
  });

  test(
    'records all decision actions, appends superseding history, and replays idempotently',
    () async {
      await createRun();
      final accepted = await repository.recordDecision(
        RecordLegacyPartyReviewDecisionRequest(
          runId: 'run-1',
          decision: decision(0, LegacyPartyReviewAction.acceptSuggestedMatch),
          idempotencyKey: 'accept-occurrence-1',
        ),
      );
      expect(accepted.sequence, 1);
      expect(accepted.wasIdempotentReplay, isFalse);

      final replay = await repository.recordDecision(
        RecordLegacyPartyReviewDecisionRequest(
          runId: 'run-1',
          decision: decision(0, LegacyPartyReviewAction.acceptSuggestedMatch),
          idempotencyKey: 'accept-occurrence-1',
        ),
      );
      expect(replay.decisionId, accepted.decisionId);
      expect(replay.wasIdempotentReplay, isTrue);

      await expectLater(
        repository.recordDecision(
          RecordLegacyPartyReviewDecisionRequest(
            runId: 'run-1',
            decision: decision(0, LegacyPartyReviewAction.keepHeld),
            idempotencyKey: 'accept-occurrence-1',
          ),
        ),
        throwsA(isA<LegacyPartyReviewIdempotencyConflict>()),
      );

      final selected = await repository.recordDecision(
        RecordLegacyPartyReviewDecisionRequest(
          runId: 'run-1',
          decision: decision(
            1,
            LegacyPartyReviewAction.selectParty,
            selectedPartyId: 'supplier-2',
          ),
          idempotencyKey: 'select-occurrence-2',
          reviewNote: 'Selected after manual review',
        ),
      );
      final held = await repository.recordDecision(
        RecordLegacyPartyReviewDecisionRequest(
          runId: 'run-1',
          decision: decision(1, LegacyPartyReviewAction.keepHeld),
          idempotencyKey: 'hold-occurrence-2',
        ),
      );

      expect(held.sequence, 2);
      final history = await repository.getDecisionHistory(
        runId: 'run-1',
        sourceOccurrenceKey: fixture.keys[1],
      );
      expect(history, hasLength(2));
      expect(history.first.decisionId, selected.decisionId);
      expect(history.first.resolvedPartyName, 'Supplier Two');
      expect(history.last.previousDecisionId, selected.decisionId);
      expect(history.last.action, LegacyPartyReviewAction.keepHeld);
      expect(history.last.resolvedPartyId, isNull);

      final loaded = await repository.getRun('run-1');
      expect(loaded.occurrences[1].latestDecision!.decisionId, held.decisionId);
      final summary = await repository.getSummary('run-1');
      expect(summary.approvedCount, 1);
      expect(summary.heldCount, 1);
      expect(summary.staleCount, 0);
      expect(summary.reviewedCount, 2);
      expect(summary.unreviewedCount, 1);
    },
  );

  test(
    'rejects unresolved suggested matches and mismatched invoice identities',
    () async {
      final unresolvedPlan = LegacyPartyResolutionReport(
        snapshotSha256: _snapshotHash,
        resolutions: [
          fixture.plan.resolutions.first,
          LegacyPartyOccurrenceResolution(
            sourceOccurrenceKey: fixture.keys[1],
            sourceIndex: 1,
            invoiceId: 'legacy-2',
            status: LegacyPartyResolutionStatus.ambiguousName,
            expectedRole: LedgerPartyRole.supplier,
            partyId: 'supplier-1',
            partyDisplayName: 'Supplier One',
            candidatePartyIds: ['supplier-1', 'supplier-2'],
          ),
          fixture.plan.resolutions[2],
        ],
      );
      await expectLater(
        repository.createRun(
          runId: 'unresolved-run',
          snapshotManifestPath: 'legacy/snapshots/unresolved.json',
          migrationVersion: 1,
          occurrenceIdentityVersion: 1,
          preflightVersion: 1,
          createdByActorId: 'actor-1',
          preflight: fixture.preflight,
          plan: unresolvedPlan,
        ),
        throwsArgumentError,
      );

      final mismatchedInvoicePlan = LegacyPartyResolutionReport(
        snapshotSha256: _snapshotHash,
        resolutions: [
          LegacyPartyOccurrenceResolution(
            sourceOccurrenceKey: fixture.keys[0],
            sourceIndex: 0,
            invoiceId: 'different-invoice',
            status: LegacyPartyResolutionStatus.resolvedByName,
            expectedRole: LedgerPartyRole.customer,
            partyId: 'customer-1',
            partyDisplayName: 'Customer One',
          ),
          fixture.plan.resolutions[1],
          fixture.plan.resolutions[2],
        ],
      );
      await expectLater(
        repository.createRun(
          runId: 'mismatched-invoice-run',
          snapshotManifestPath: 'legacy/snapshots/mismatched.json',
          migrationVersion: 1,
          occurrenceIdentityVersion: 1,
          preflightVersion: 1,
          createdByActorId: 'actor-1',
          preflight: fixture.preflight,
          plan: mismatchedInvoicePlan,
        ),
        throwsArgumentError,
      );

      final persistedRuns = await database
          .customSelect(
            "SELECT COUNT(*) AS count FROM legacy_migration_runs "
            "WHERE run_id IN ('unresolved-run', 'mismatched-invoice-run')",
          )
          .getSingle();
      final persistedOccurrences = await database
          .customSelect(
            "SELECT COUNT(*) AS count FROM legacy_migration_occurrences "
            "WHERE run_id IN ('unresolved-run', 'mismatched-invoice-run')",
          )
          .getSingle();
      expect(persistedRuns.read<int>('count'), 0);
      expect(persistedOccurrences.read<int>('count'), 0);
    },
  );

  test(
    'rejects wrong-role, wrong-snapshot, and unknown occurrence decisions',
    () async {
      await createRun();
      await expectLater(
        repository.recordDecision(
          RecordLegacyPartyReviewDecisionRequest(
            runId: 'run-1',
            decision: decision(
              1,
              LegacyPartyReviewAction.selectParty,
              selectedPartyId: 'customer-1',
            ),
            idempotencyKey: 'wrong-role',
          ),
        ),
        throwsArgumentError,
      );
      await expectLater(
        repository.recordDecision(
          RecordLegacyPartyReviewDecisionRequest(
            runId: 'run-1',
            decision: LegacyPartyReviewDecision(
              snapshotSha256:
                  'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
              sourceOccurrenceKey: fixture.keys[0],
              action: LegacyPartyReviewAction.keepHeld,
              reviewerId: 'reviewer-1',
              decidedAtUtc: _decisionTime,
            ),
            idempotencyKey: 'wrong-snapshot',
          ),
        ),
        throwsArgumentError,
      );
      await expectLater(
        repository.recordDecision(
          RecordLegacyPartyReviewDecisionRequest(
            runId: 'run-1',
            decision: LegacyPartyReviewDecision(
              snapshotSha256: _snapshotHash,
              sourceOccurrenceKey: 'not-in-this-run',
              action: LegacyPartyReviewAction.keepHeld,
              reviewerId: 'reviewer-1',
              decidedAtUtc: _decisionTime,
            ),
            idempotencyKey: 'unknown-occurrence',
          ),
        ),
        throwsArgumentError,
      );
      expect(
        await repository.getDecisionHistory(
          runId: 'run-1',
          sourceOccurrenceKey: fixture.keys[1],
        ),
        isEmpty,
      );
    },
  );

  test(
    'rolls back every decision when one item in a batch is invalid',
    () async {
      await createRun();
      await expectLater(
        repository.recordDecisions([
          RecordLegacyPartyReviewDecisionRequest(
            runId: 'run-1',
            decision: decision(0, LegacyPartyReviewAction.acceptSuggestedMatch),
            idempotencyKey: 'batch-valid-first',
          ),
          RecordLegacyPartyReviewDecisionRequest(
            runId: 'run-1',
            decision: decision(
              1,
              LegacyPartyReviewAction.selectParty,
              selectedPartyId: 'customer-1',
            ),
            idempotencyKey: 'batch-invalid-second',
          ),
        ]),
        throwsArgumentError,
      );
      expect(
        await repository.getDecisionHistory(
          runId: 'run-1',
          sourceOccurrenceKey: fixture.keys[0],
        ),
        isEmpty,
      );
    },
  );

  test(
    'reports a previously approved decision as stale after its role is removed',
    () async {
      await createRun();
      await repository.recordDecision(
        RecordLegacyPartyReviewDecisionRequest(
          runId: 'run-1',
          decision: decision(0, LegacyPartyReviewAction.acceptSuggestedMatch),
          idempotencyKey: 'accept-before-role-change',
        ),
      );
      await database.customStatement(
        'DELETE FROM party_roles WHERE party_id = ? AND role = ?',
        ['customer-1', 'customer'],
      );

      final summary = await repository.getSummary('run-1');
      expect(summary.approvedCount, 0);
      expect(summary.heldCount, 0);
      expect(summary.staleCount, 1);
      expect(summary.reviewedCount, 1);
      expect(summary.unreviewedCount, 2);
      final history = await repository.getDecisionHistory(
        runId: 'run-1',
        sourceOccurrenceKey: fixture.keys[0],
      );
      expect(history, hasLength(1));
      expect(history.single.resolvedPartyName, 'Customer One');
    },
  );

  test(
    'rolls back the whole run when an occurrence cannot be inserted',
    () async {
      final invalidPlan = LegacyPartyResolutionReport(
        snapshotSha256: _snapshotHash,
        resolutions: [
          LegacyPartyOccurrenceResolution(
            sourceOccurrenceKey: fixture.keys[0],
            sourceIndex: 0,
            invoiceId: 'legacy-1',
            status: LegacyPartyResolutionStatus.resolvedByName,
            expectedRole: LedgerPartyRole.customer,
            partyId: 'missing-party',
            partyDisplayName: 'Missing Party',
          ),
          ...fixture.plan.resolutions.skip(1),
        ],
      );
      await expectLater(
        repository.createRun(
          runId: 'failed-run',
          snapshotManifestPath: 'legacy/snapshots/failed.json',
          migrationVersion: 1,
          occurrenceIdentityVersion: 1,
          preflightVersion: 1,
          createdByActorId: 'actor-1',
          preflight: fixture.preflight,
          plan: invalidPlan,
        ),
        throwsA(anything),
      );
      await expectLater(repository.getRun('failed-run'), throwsStateError);
    },
  );
}

Future<void> _insertParty(
  AppDatabase database,
  String id,
  String name,
  String role,
) async {
  await database.customStatement(
    'INSERT INTO parties (party_id, display_name, created_at, updated_at) VALUES (?, ?, ?, ?)',
    [id, name, 1, 1],
  );
  await database.customStatement(
    'INSERT INTO party_roles (party_id, role) VALUES (?, ?)',
    [id, role],
  );
}
