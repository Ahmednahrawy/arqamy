enum LedgerDirection {
  incoming('in'),
  outgoing('out');

  const LedgerDirection(this.databaseValue);

  final String databaseValue;

  LedgerDirection get opposite => switch (this) {
    incoming => outgoing,
    outgoing => incoming,
  };
}

enum PhysicalOccurrence {
  yes('yes'),
  no('no'),
  unknown('unknown');

  const PhysicalOccurrence(this.databaseValue);

  final String databaseValue;
}

enum CashEventOperation {
  original('original'),
  correction('correction'),
  reversal('reversal'),
  replacement('replacement'),
  voidEvent('void');

  const CashEventOperation(this.databaseValue);

  final String databaseValue;
}

class RecordPaymentRequest {
  const RecordPaymentRequest({
    required this.financialAccountId,
    required this.partyId,
    required this.partyRole,
    required this.currencyCode,
    required this.financialDirection,
    required this.cashDirection,
    required this.transactionAmountMinor,
    required this.physicalAmountMinor,
    required this.occurred,
    required this.actorId,
    required this.reason,
    required this.idempotencyKey,
  });

  final String financialAccountId;
  final String partyId;
  final String partyRole;
  final String currencyCode;
  final LedgerDirection financialDirection;
  final LedgerDirection cashDirection;
  final int transactionAmountMinor;
  final int physicalAmountMinor;
  final PhysicalOccurrence occurred;
  final String actorId;
  final String reason;
  final String idempotencyKey;
}

class CashEventOperationResult {
  const CashEventOperationResult({
    required this.paymentId,
    required this.cashEventId,
    required this.versionId,
    required this.sequence,
    this.reconciliationCaseId,
  });

  final String paymentId;
  final String cashEventId;
  final String versionId;
  final int sequence;
  final String? reconciliationCaseId;
}

class CorrectPaymentRequest {
  const CorrectPaymentRequest({
    required this.paymentId,
    required this.expectedVersionId,
    required this.replacementAmountMinor,
    required this.physicalAmountMinor,
    required this.occurred,
    required this.actorId,
    required this.reason,
    required this.idempotencyKey,
  });

  final String paymentId;
  final String expectedVersionId;
  final int replacementAmountMinor;
  final int physicalAmountMinor;
  final PhysicalOccurrence occurred;
  final String actorId;
  final String reason;
  final String idempotencyKey;
}

class ReversePaymentRequest {
  const ReversePaymentRequest({
    required this.paymentId,
    required this.expectedVersionId,
    required this.actorId,
    required this.reason,
    required this.idempotencyKey,
  });

  final String paymentId;
  final String expectedVersionId;
  final String actorId;
  final String reason;
  final String idempotencyKey;
}

class VoidPaymentRequest {
  const VoidPaymentRequest({
    required this.paymentId,
    required this.expectedVersionId,
    required this.actorId,
    required this.reason,
    required this.idempotencyKey,
  });

  final String paymentId;
  final String expectedVersionId;
  final String actorId;
  final String reason;
  final String idempotencyKey;
}

class SuspenseCaseRequest {
  const SuspenseCaseRequest({
    required this.paymentId,
    required this.amountMinor,
    required this.actorId,
    required this.reason,
    required this.idempotencyKey,
  });

  final String paymentId;
  final int amountMinor;
  final String actorId;
  final String reason;
  final String idempotencyKey;
}

class SuspenseMovementRequest {
  const SuspenseMovementRequest({
    required this.caseId,
    required this.amountMinor,
    required this.actorId,
    required this.reason,
    required this.idempotencyKey,
  });

  final String caseId;
  final int amountMinor;
  final String actorId;
  final String reason;
  final String idempotencyKey;
}

class ResolveSuspenseRequest extends SuspenseMovementRequest {
  const ResolveSuspenseRequest({
    required super.caseId,
    required super.amountMinor,
    required super.actorId,
    required super.reason,
    required super.idempotencyKey,
    required this.authorizedByActorId,
    required this.authorizationReference,
  });

  final String authorizedByActorId;
  final String authorizationReference;
}

class CashReportTotal {
  const CashReportTotal({
    required this.financialAccountId,
    required this.partyId,
    required this.partyRole,
    required this.currencyCode,
    required this.cashInMinor,
    required this.cashOutMinor,
    required this.pendingUnknownMinor,
    required this.pendingUnknownEvents,
  });

  final String financialAccountId;
  final String partyId;
  final String partyRole;
  final String currencyCode;
  final int cashInMinor;
  final int cashOutMinor;
  final int pendingUnknownMinor;
  final int pendingUnknownEvents;
}

class EffectiveRecognitionTotal {
  const EffectiveRecognitionTotal({
    required this.financialAccountId,
    required this.partyId,
    required this.partyRole,
    required this.currencyCode,
    required this.direction,
    required this.amountMinor,
  });

  final String financialAccountId;
  final String partyId;
  final String partyRole;
  final String currencyCode;
  final LedgerDirection direction;
  final int amountMinor;
}

class IdempotencyConflict implements Exception {
  const IdempotencyConflict(this.key);

  final String key;

  @override
  String toString() =>
      'Idempotency key "$key" was reused with a different payload';
}

class StaleCashEventHead implements Exception {
  const StaleCashEventHead(this.eventId);

  final String eventId;

  @override
  String toString() =>
      'Cash event "$eventId" changed before the operation committed';
}

class SuspenseLimitExceeded implements Exception {
  const SuspenseLimitExceeded({
    required this.requestedMinor,
    required this.availableMinor,
  });

  final int requestedMinor;
  final int availableMinor;

  @override
  String toString() =>
      'Suspense movement $requestedMinor exceeds available balance $availableMinor';
}
