import 'package:arqamy/features/payment_ledger/data/allocation_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('allocation domain models', () {
    test(
      'keeps allocation and reversal amounts as positive integer minor units',
      () {
        final allocation = InvoiceAllocation(
          id: 'allocation-1',
          paymentId: 'payment-1',
          invoiceId: 'invoice-1',
          paymentFinancialAccountId: 'payment-account',
          invoiceFinancialAccountId: 'invoice-account',
          partyId: 'party-1',
          partyRole: 'customer',
          currencyCode: 'EGP',
          amountMinor: 12345,
          idempotencyKey: 'alloc-key',
          requestFingerprint: 'fingerprint',
          createdAt: DateTime.utc(2026),
        );
        final reversal = AllocationReversal(
          id: 'reversal-1',
          allocationId: allocation.id,
          amountMinor: 45,
          idempotencyKey: 'reverse-key',
          requestFingerprint: 'fingerprint',
          reason: 'correction',
          createdAt: DateTime.utc(2026),
        );

        expect(allocation.amountMinor, 12345);
        expect(allocation.amountMinor, isA<int>());
        expect(reversal.amountMinor, 45);
        expect(reversal.allocationId, allocation.id);
      },
    );

    test('rejects nonpositive allocation, reversal, and sequence values', () {
      expect(
        () => InvoiceAllocation(
          id: 'a',
          paymentId: 'p',
          invoiceId: 'i',
          paymentFinancialAccountId: 'pa',
          invoiceFinancialAccountId: 'ia',
          partyId: 'party',
          partyRole: 'customer',
          currencyCode: 'EGP',
          amountMinor: 0,
          idempotencyKey: 'key',
          requestFingerprint: 'fp',
          createdAt: DateTime.utc(2026),
        ),
        throwsArgumentError,
      );
      expect(
        () => AllocationReversal(
          id: 'r',
          allocationId: 'a',
          amountMinor: -1,
          idempotencyKey: 'key',
          requestFingerprint: 'fp',
          reason: 'reason',
          createdAt: DateTime.utc(2026),
        ),
        throwsArgumentError,
      );
      expect(
        () => AllocationStatusEvent(
          id: 'v',
          allocationId: 'a',
          sequence: 0,
          status: AllocationStatus.provisional,
          idempotencyKey: 'key',
          requestFingerprint: 'fp',
          recordedAt: DateTime.utc(2026),
        ),
        throwsArgumentError,
      );
      expect(
        () => CreateAllocationRequest(
          paymentId: 'p',
          invoiceId: 'i',
          paymentFinancialAccountId: 'pa',
          invoiceFinancialAccountId: 'ia',
          partyId: 'party',
          partyRole: 'customer',
          currencyCode: 'EGP',
          amountMinor: 0,
          idempotencyKey: 'key',
          requestFingerprint: 'fp',
        ),
        throwsArgumentError,
      );
      expect(
        () => ReverseAllocationRequest(
          allocationId: 'a',
          amountMinor: -1,
          reason: 'reason',
          idempotencyKey: 'key',
          requestFingerprint: 'fp',
        ),
        throwsArgumentError,
      );
    });

    test('exposes exactly the approved statuses and projections', () {
      expect(AllocationStatus.values, [
        AllocationStatus.provisional,
        AllocationStatus.serverConfirmed,
        AllocationStatus.rejected,
        AllocationStatus.conflictPending,
      ]);
      expect(AllocationStatus.values.map((status) => status.databaseValue), [
        'provisional',
        'server_confirmed',
        'rejected',
        'conflict_pending',
      ]);
      expect(AllocationProjection.values, [
        AllocationProjection.localEffective,
        AllocationProjection.globallyConfirmed,
      ]);
    });

    test(
      'requests retain integer amounts and status without transition rules',
      () {
        final create = CreateAllocationRequest(
          paymentId: 'p',
          invoiceId: 'i',
          paymentFinancialAccountId: 'pa',
          invoiceFinancialAccountId: 'ia',
          partyId: 'party',
          partyRole: 'customer',
          currencyCode: 'EGP',
          amountMinor: 100,
          idempotencyKey: 'create',
          requestFingerprint: 'fp',
        );
        final reverse = ReverseAllocationRequest(
          allocationId: 'a',
          amountMinor: 10,
          reason: 'reason',
          idempotencyKey: 'reverse',
          requestFingerprint: 'fp',
        );
        const change = ChangeAllocationStatusRequest(
          allocationId: 'a',
          expectedVersionId: 'v1',
          status: AllocationStatus.rejected,
          idempotencyKey: 'status',
          requestFingerprint: 'fp',
        );

        expect(create.amountMinor, isA<int>());
        expect(reverse.amountMinor, isA<int>());
        expect(change.status, AllocationStatus.rejected);
      },
    );
  });

  test('allocation errors carry their typed identifying values', () {
    const conflict = AllocationIdempotencyConflict('key-1');
    const stale = StaleAllocationStatus('allocation-1');

    expect(conflict.key, 'key-1');
    expect(conflict.toString(), contains('key-1'));
    expect(stale.allocationId, 'allocation-1');
    expect(stale.toString(), contains('allocation-1'));
  });
}
