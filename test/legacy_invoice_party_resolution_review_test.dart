import 'package:arqamy/core/services/legacy_invoice_party_resolution_planner.dart';
import 'package:arqamy/core/services/legacy_invoice_party_resolution_review.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:flutter_test/flutter_test.dart';

const _snapshotHash =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
final _decidedAt = DateTime.utc(2026, 11, 25, 20);

LegacyPartyCandidate _party(
  String id,
  String name,
  Set<LedgerPartyRole> roles,
) =>
    LegacyPartyCandidate(
      party: LedgerParty(id: id, displayName: name),
      roles: roles,
    );

LegacyPartyResolutionReport _plan() => const LegacyPartyResolutionReport(
      snapshotSha256: _snapshotHash,
      resolutions: [
        LegacyPartyOccurrenceResolution(
          sourceOccurrenceKey: 'occurrence-1',
          sourceIndex: 0,
          invoiceId: 'legacy-1',
          status: LegacyPartyResolutionStatus.resolvedByName,
          expectedRole: LedgerPartyRole.customer,
          partyId: 'customer-1',
          partyDisplayName: 'Customer One',
        ),
        LegacyPartyOccurrenceResolution(
          sourceOccurrenceKey: 'occurrence-2',
          sourceIndex: 1,
          invoiceId: 'legacy-2',
          status: LegacyPartyResolutionStatus.ambiguousName,
          expectedRole: LedgerPartyRole.supplier,
          candidatePartyIds: ['supplier-1', 'supplier-2'],
        ),
        LegacyPartyOccurrenceResolution(
          sourceOccurrenceKey: 'occurrence-3',
          sourceIndex: 2,
          invoiceId: 'legacy-3',
          status: LegacyPartyResolutionStatus.unknownAction,
        ),
      ],
    );

LegacyPartyReviewDecision _decision(
  String key,
  LegacyPartyReviewAction action, {
  String? selectedPartyId,
  String snapshotSha256 = _snapshotHash,
  String reviewerId = 'reviewer-1',
  DateTime? decidedAtUtc,
}) =>
    LegacyPartyReviewDecision(
      snapshotSha256: snapshotSha256,
      sourceOccurrenceKey: key,
      action: action,
      reviewerId: reviewerId,
      decidedAtUtc: decidedAtUtc ?? _decidedAt,
      selectedPartyId: selectedPartyId,
    );

void main() {
  const review = LegacyInvoicePartyResolutionReview();

  final parties = [
    _party('customer-1', 'Customer One', {LedgerPartyRole.customer}),
    _party('supplier-1', 'Supplier One', {LedgerPartyRole.supplier}),
    _party('supplier-2', 'Supplier Two', {LedgerPartyRole.supplier}),
    _party('wrong-role', 'Customer Only', {LedgerPartyRole.customer}),
  ];

  test('accepts a suggested match for the exact source occurrence', () {
    final report = review.review(
      plan: _plan(),
      decisions: [
        _decision('occurrence-1', LegacyPartyReviewAction.acceptSuggestedMatch),
      ],
      parties: parties,
    );

    expect(report.approvedCount, 1);
    expect(report.heldCount, 2);
    expect(report.reviewedCount, 1);
    expect(report.occurrences.first.partyId, 'customer-1');
    expect(report.occurrences.first.partyRole, LedgerPartyRole.customer);
    expect(report.occurrences.first.decision!.reviewerId, 'reviewer-1');
    expect(report.occurrences.first.decision!.decidedAtUtc, _decidedAt);
  });

  test('allows an explicit role-compatible party selection', () {
    final report = review.review(
      plan: _plan(),
      decisions: [
        _decision(
          'occurrence-2',
          LegacyPartyReviewAction.selectParty,
          selectedPartyId: 'supplier-2',
        ),
      ],
      parties: parties,
    );

    final result = report.occurrences[1];
    expect(result.isApproved, isTrue);
    expect(result.partyId, 'supplier-2');
    expect(result.partyDisplayName, 'Supplier Two');
    expect(result.partyRole, LedgerPartyRole.supplier);
  });

  test('keeps a reviewed occurrence held without selecting a party', () {
    final report = review.review(
      plan: _plan(),
      decisions: [
        _decision('occurrence-2', LegacyPartyReviewAction.keepHeld),
      ],
      parties: parties,
    );

    expect(report.occurrences[1].isApproved, isFalse);
    expect(report.occurrences[1].partyId, isNull);
    expect(report.reviewedCount, 1);
  });

  test('unreviewed occurrences remain held', () {
    final report = review.review(
      plan: _plan(),
      decisions: const [],
      parties: parties,
    );

    expect(report.approvedCount, 0);
    expect(report.heldCount, 3);
    expect(report.reviewedCount, 0);
  });

  test('rejects a decision from a different snapshot', () {
    expect(
      () => review.review(
        plan: _plan(),
        decisions: [
          _decision(
            'occurrence-1',
            LegacyPartyReviewAction.acceptSuggestedMatch,
            snapshotSha256: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          ),
        ],
        parties: parties,
      ),
      throwsArgumentError,
    );
  });

  test('rejects duplicate decisions for one occurrence', () {
    expect(
      () => review.review(
        plan: _plan(),
        decisions: [
          _decision('occurrence-1', LegacyPartyReviewAction.keepHeld),
          _decision('occurrence-1', LegacyPartyReviewAction.keepHeld),
        ],
        parties: parties,
      ),
      throwsArgumentError,
    );
  });

  test('rejects an unknown source occurrence key', () {
    expect(
      () => review.review(
        plan: _plan(),
        decisions: [
          _decision('not-in-plan', LegacyPartyReviewAction.keepHeld),
        ],
        parties: parties,
      ),
      throwsArgumentError,
    );
  });

  test('rejects a selected party that does not have the required role', () {
    expect(
      () => review.review(
        plan: _plan(),
        decisions: [
          _decision(
            'occurrence-2',
            LegacyPartyReviewAction.selectParty,
            selectedPartyId: 'wrong-role',
          ),
        ],
        parties: parties,
      ),
      throwsArgumentError,
    );
  });

  test('does not allow an unknown action to be approved by party selection',
      () {
    expect(
      () => review.review(
        plan: _plan(),
        decisions: [
          _decision(
            'occurrence-3',
            LegacyPartyReviewAction.selectParty,
            selectedPartyId: 'customer-1',
          ),
        ],
        parties: parties,
      ),
      throwsArgumentError,
    );
  });

  test('requires reviewer identity and UTC decision time', () {
    expect(
      () => review.review(
        plan: _plan(),
        decisions: [
          _decision(
            'occurrence-1',
            LegacyPartyReviewAction.acceptSuggestedMatch,
            reviewerId: '  ',
          ),
        ],
        parties: parties,
      ),
      throwsArgumentError,
    );

    expect(
      () => review.review(
        plan: _plan(),
        decisions: [
          _decision(
            'occurrence-1',
            LegacyPartyReviewAction.acceptSuggestedMatch,
            decidedAtUtc: DateTime(2026, 11, 25, 20),
          ),
        ],
        parties: parties,
      ),
      throwsArgumentError,
    );
  });

  test('rejects an accept action when the plan has no suggested match', () {
    expect(
      () => review.review(
        plan: _plan(),
        decisions: [
          _decision('occurrence-2', LegacyPartyReviewAction.acceptSuggestedMatch),
        ],
        parties: parties,
      ),
      throwsArgumentError,
    );
  });
}
