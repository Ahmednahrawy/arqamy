import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:arqamy/core/services/legacy_invoice_party_resolution_review.dart';

class LegacyPartyReviewJournalRun {
  LegacyPartyReviewJournalRun({
    required this.runId,
    required this.snapshotSha256,
    required this.snapshotManifestPath,
    required this.migrationVersion,
    required this.occurrenceIdentityVersion,
    required this.preflightVersion,
    required this.createdAtUtc,
    required this.createdByActorId,
    required List<LegacyPartyReviewJournalOccurrence> occurrences,
  }) : occurrences = List.unmodifiable(occurrences);

  final String runId;
  final String snapshotSha256;
  final String snapshotManifestPath;
  final int migrationVersion;
  final int occurrenceIdentityVersion;
  final int preflightVersion;
  final DateTime createdAtUtc;
  final String createdByActorId;
  final List<LegacyPartyReviewJournalOccurrence> occurrences;
}

class LegacyPartyReviewJournalOccurrence {
  LegacyPartyReviewJournalOccurrence({
    required this.runId,
    required this.sourceOccurrenceKey,
    required this.sourceIndex,
    required this.recordSha256,
    required this.preflightClassification,
    required this.resolutionStatus,
    required this.candidatePartyIds,
    required this.findings,
    required this.decisions,
    this.legacyInvoiceId,
    this.expectedRole,
    this.suggestedPartyId,
    this.suggestedPartyName,
  }) : candidatePartyIds = List.unmodifiable(candidatePartyIds),
       findings = Map.unmodifiable(findings),
       decisions = List.unmodifiable(decisions);

  final String runId;
  final String sourceOccurrenceKey;
  final int sourceIndex;
  final String recordSha256;
  final String? legacyInvoiceId;
  final String preflightClassification;
  final String resolutionStatus;
  final LedgerPartyRole? expectedRole;
  final String? suggestedPartyId;
  final String? suggestedPartyName;
  final List<String> candidatePartyIds;
  final Map<String, Object?> findings;
  final List<LegacyPartyReviewJournalDecision> decisions;

  LegacyPartyReviewJournalDecision? get latestDecision =>
      decisions.isEmpty ? null : decisions.last;
}

class LegacyPartyReviewJournalDecision {
  const LegacyPartyReviewJournalDecision({
    required this.decisionId,
    required this.runId,
    required this.sourceOccurrenceKey,
    required this.sequence,
    required this.action,
    required this.expectedRole,
    required this.reviewerId,
    required this.decidedAtUtc,
    required this.idempotencyKey,
    required this.requestFingerprint,
    this.previousDecisionId,
    this.resolvedPartyId,
    this.resolvedPartyName,
    this.resolvedPartyRole,
    this.reviewNote,
  });

  final String decisionId;
  final String runId;
  final String sourceOccurrenceKey;
  final int sequence;
  final String? previousDecisionId;
  final LegacyPartyReviewAction action;
  final LedgerPartyRole? expectedRole;
  final String? resolvedPartyId;
  final String? resolvedPartyName;
  final LedgerPartyRole? resolvedPartyRole;
  final String reviewerId;
  final DateTime decidedAtUtc;
  final String? reviewNote;
  final String idempotencyKey;
  final String requestFingerprint;
}

class RecordLegacyPartyReviewDecisionRequest {
  const RecordLegacyPartyReviewDecisionRequest({
    required this.runId,
    required this.decision,
    required this.idempotencyKey,
    this.reviewNote,
  });

  final String runId;
  final LegacyPartyReviewDecision decision;
  final String idempotencyKey;
  final String? reviewNote;
}

class LegacyPartyReviewDecisionResult {
  const LegacyPartyReviewDecisionResult({
    required this.runId,
    required this.sourceOccurrenceKey,
    required this.decisionId,
    required this.sequence,
    required this.wasIdempotentReplay,
  });

  final String runId;
  final String sourceOccurrenceKey;
  final String decisionId;
  final int sequence;
  final bool wasIdempotentReplay;
}

class LegacyPartyReviewJournalSummary {
  const LegacyPartyReviewJournalSummary({
    required this.totalOccurrences,
    required this.approvedCount,
    required this.heldCount,
    required this.reviewedCount,
    required this.unreviewedCount,
  });

  final int totalOccurrences;
  final int approvedCount;
  final int heldCount;
  final int reviewedCount;
  final int unreviewedCount;
}
