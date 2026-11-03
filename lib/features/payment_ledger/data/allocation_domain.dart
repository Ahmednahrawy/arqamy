enum AllocationStatus {
  provisional('provisional'),
  serverConfirmed('server_confirmed'),
  rejected('rejected'),
  conflictPending('conflict_pending');

  const AllocationStatus(this.databaseValue);

  final String databaseValue;
}

enum AllocationProjection { localEffective, globallyConfirmed }

class InvoiceAllocation {
  InvoiceAllocation({
    required this.id,
    required this.paymentId,
    required this.invoiceId,
    required this.paymentFinancialAccountId,
    required this.invoiceFinancialAccountId,
    required this.partyId,
    required this.partyRole,
    required this.currencyCode,
    required this.amountMinor,
    required this.idempotencyKey,
    required this.requestFingerprint,
    required this.createdAt,
    this.originDeviceId,
    this.conflictGroupId,
    this.actorId,
    this.reason,
  }) {
    if (amountMinor <= 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'Must be positive.',
      );
    }
  }

  final String id;
  final String paymentId;
  final String invoiceId;
  final String paymentFinancialAccountId;
  final String invoiceFinancialAccountId;
  final String partyId;
  final String partyRole;
  final String currencyCode;
  final int amountMinor;
  final String idempotencyKey;
  final String requestFingerprint;
  final String? originDeviceId;
  final String? conflictGroupId;
  final String? actorId;
  final String? reason;
  final DateTime createdAt;
}

class AllocationReversal {
  AllocationReversal({
    required this.id,
    required this.allocationId,
    required this.amountMinor,
    required this.idempotencyKey,
    required this.requestFingerprint,
    required this.reason,
    required this.createdAt,
    this.actorId,
  }) {
    if (amountMinor <= 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'Must be positive.',
      );
    }
  }

  final String id;
  final String allocationId;
  final int amountMinor;
  final String idempotencyKey;
  final String requestFingerprint;
  final String? actorId;
  final String reason;
  final DateTime createdAt;
}

class AllocationStatusEvent {
  AllocationStatusEvent({
    required this.id,
    required this.allocationId,
    required this.sequence,
    required this.status,
    required this.idempotencyKey,
    required this.requestFingerprint,
    required this.recordedAt,
    this.previousVersionId,
    this.actorId,
    this.reason,
  }) {
    if (sequence <= 0) {
      throw ArgumentError.value(sequence, 'sequence', 'Must be positive.');
    }
  }

  final String id;
  final String allocationId;
  final int sequence;
  final AllocationStatus status;
  final String? previousVersionId;
  final String idempotencyKey;
  final String requestFingerprint;
  final String? actorId;
  final String? reason;
  final DateTime recordedAt;
}

class CreateAllocationRequest {
  CreateAllocationRequest({
    required this.paymentId,
    required this.invoiceId,
    required this.paymentFinancialAccountId,
    required this.invoiceFinancialAccountId,
    required this.partyId,
    required this.partyRole,
    required this.currencyCode,
    required this.amountMinor,
    required this.idempotencyKey,
    required this.requestFingerprint,
    this.originDeviceId,
    this.conflictGroupId,
    this.actorId,
    this.reason,
  }) {
    if (amountMinor <= 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'Must be positive.',
      );
    }
  }

  final String paymentId;
  final String invoiceId;
  final String paymentFinancialAccountId;
  final String invoiceFinancialAccountId;
  final String partyId;
  final String partyRole;
  final String currencyCode;
  final int amountMinor;
  final String idempotencyKey;
  final String requestFingerprint;
  final String? originDeviceId;
  final String? conflictGroupId;
  final String? actorId;
  final String? reason;
}

class ReverseAllocationRequest {
  ReverseAllocationRequest({
    required this.allocationId,
    required this.amountMinor,
    required this.reason,
    required this.idempotencyKey,
    required this.requestFingerprint,
    this.actorId,
  }) {
    if (amountMinor <= 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'Must be positive.',
      );
    }
  }

  final String allocationId;
  final int amountMinor;
  final String reason;
  final String idempotencyKey;
  final String requestFingerprint;
  final String? actorId;
}

class ChangeAllocationStatusRequest {
  const ChangeAllocationStatusRequest({
    required this.allocationId,
    required this.expectedVersionId,
    required this.status,
    required this.idempotencyKey,
    required this.requestFingerprint,
    this.actorId,
    this.reason,
  });

  final String allocationId;
  final String expectedVersionId;
  final AllocationStatus status;
  final String idempotencyKey;
  final String requestFingerprint;
  final String? actorId;
  final String? reason;
}

class AllocationOperationResult {
  const AllocationOperationResult({
    required this.allocationId,
    required this.operationId,
    required this.sequence,
  });

  final String allocationId;
  final String operationId;
  final int sequence;
}

class AllocationIdempotencyConflict implements Exception {
  const AllocationIdempotencyConflict(this.key);

  final String key;

  @override
  String toString() =>
      'Allocation idempotency key "$key" was reused with a different payload';
}

class StaleAllocationStatus implements Exception {
  const StaleAllocationStatus(this.allocationId);

  final String allocationId;

  @override
  String toString() =>
      'Allocation "$allocationId" status changed before the operation committed';
}
