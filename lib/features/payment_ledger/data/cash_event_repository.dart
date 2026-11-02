import 'dart:async';
import 'dart:convert';

import 'package:arqamy/core/database/app_database.dart';
import 'package:arqamy/features/payment_ledger/data/cash_event_history.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart' show SqliteException;
import 'package:uuid/uuid.dart';

class CashEventRepository {
  CashEventRepository(
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
        final isBusy = error.resultCode == 5 || error.resultCode == 6;
        if (!isBusy || attempt == maxAttempts - 1) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 10 * (1 << attempt)));
      }
    }
    throw StateError('Transaction retry loop ended unexpectedly.');
  }

  Future<CashEventOperationResult> recordPayment(RecordPaymentRequest request) {
    _validatePaymentRequest(request);
    final payload = _paymentPayload(request);
    return _serialize(
      () => _transaction(() => _recordPayment(request, payload)),
    );
  }

  Future<CashEventOperationResult> correctPayment(
    CorrectPaymentRequest request,
  ) {
    _validateText(request.actorId, 'actorId');
    _validateText(request.reason, 'reason');
    _validateText(request.idempotencyKey, 'idempotencyKey');
    _validateNonNegative(
      request.replacementAmountMinor,
      'replacementAmountMinor',
    );
    _validateNonNegative(request.physicalAmountMinor, 'physicalAmountMinor');
    if (request.occurred == PhysicalOccurrence.no &&
        (request.physicalAmountMinor != 0 ||
            request.replacementAmountMinor != 0)) {
      throw ArgumentError(
        'An event confirmed not to have occurred must have zero physical and recognized amounts.',
      );
    }

    final payload = jsonEncode([
      'correction',
      request.paymentId,
      request.expectedVersionId,
      request.replacementAmountMinor,
      request.physicalAmountMinor,
      request.occurred.databaseValue,
      request.actorId,
      request.reason,
    ]);
    return _serialize(
      () => _transaction(() => _correctPayment(request, payload)),
    );
  }

  Future<CashEventOperationResult> reverseWithoutCashReturn(
    ReversePaymentRequest request,
  ) {
    _validateText(request.actorId, 'actorId');
    _validateText(request.reason, 'reason');
    _validateText(request.idempotencyKey, 'idempotencyKey');
    final payload = jsonEncode([
      'reverse_without_cash_return',
      request.paymentId,
      request.expectedVersionId,
      request.actorId,
      request.reason,
    ]);
    return _serialize(
      () => _transaction(() => _reverseWithoutCashReturn(request, payload)),
    );
  }

  Future<CashEventOperationResult> voidNeverOccurred(
    VoidPaymentRequest request,
  ) {
    _validateText(request.actorId, 'actorId');
    _validateText(request.reason, 'reason');
    _validateText(request.idempotencyKey, 'idempotencyKey');
    final payload = jsonEncode([
      'void_never_occurred',
      request.paymentId,
      request.expectedVersionId,
      request.actorId,
      request.reason,
    ]);
    return _serialize(
      () => _transaction(() => _voidNeverOccurred(request, payload)),
    );
  }

  Future<CashEventOperationResult> resolveUnknownPhysicalStatus({
    required String paymentId,
    required String expectedVersionId,
    required PhysicalOccurrence occurred,
    required int physicalAmountMinor,
    required String actorId,
    required String reason,
    required String idempotencyKey,
  }) {
    if (occurred == PhysicalOccurrence.unknown) {
      throw ArgumentError.value(
        occurred,
        'occurred',
        'Must resolve to yes or no.',
      );
    }
    _validateText(actorId, 'actorId');
    _validateText(reason, 'reason');
    _validateText(idempotencyKey, 'idempotencyKey');
    _validateNonNegative(physicalAmountMinor, 'physicalAmountMinor');
    if (occurred == PhysicalOccurrence.no && physicalAmountMinor != 0) {
      throw ArgumentError.value(
        physicalAmountMinor,
        'physicalAmountMinor',
        'Must be zero when physical movement did not occur.',
      );
    }

    final payload = jsonEncode([
      'resolve_unknown_physical_status',
      paymentId,
      expectedVersionId,
      occurred.databaseValue,
      physicalAmountMinor,
      actorId,
      reason,
    ]);
    return _serialize(
      () => _transaction(() async {
        final duplicate = await _findVersionByKey(idempotencyKey, payload);
        if (duplicate != null) return _resultFromVersion(duplicate);
        final current = await _loadCurrent(paymentId, expectedVersionId);
        if (current.version.occurred !=
            PhysicalOccurrence.unknown.databaseValue) {
          throw StateError('Only an unknown physical status can be resolved.');
        }
        if (occurred == PhysicalOccurrence.no) {
          final request = CorrectPaymentRequest(
            paymentId: paymentId,
            expectedVersionId: expectedVersionId,
            replacementAmountMinor: 0,
            physicalAmountMinor: 0,
            occurred: PhysicalOccurrence.no,
            actorId: actorId,
            reason: reason,
            idempotencyKey: idempotencyKey,
          );
          return _correctPayment(request, payload);
        }

        final now = _clock();
        final versionId = _uuid.v4();
        final sequence = current.version.sequence + 1;
        await _insertVersion(
          id: versionId,
          cashEventId: current.head.cashEventId,
          paymentId: paymentId,
          sequence: sequence,
          operation: CashEventOperation.correction,
          occurred: occurred,
          cashDirection: _direction(current.version.cashDirection),
          physicalAmountMinor: physicalAmountMinor,
          effectiveRecognizedMinor: current.version.effectiveRecognizedMinor,
          transactionId: current.version.transactionId,
          previousVersionId: current.version.id,
          idempotencyKey: idempotencyKey,
          requestPayload: payload,
          actorId: actorId,
          reason: reason,
          recordedAt: now,
        );
        await _advanceHead(current.head, versionId, sequence, now);
        return CashEventOperationResult(
          paymentId: paymentId,
          cashEventId: current.head.cashEventId,
          versionId: versionId,
          sequence: sequence,
        );
      }),
    );
  }

  Future<CashEventOperationResult> recordIndependentPaymentAfterReversal({
    required ReversePaymentRequest reversal,
    required RecordPaymentRequest replacement,
  }) {
    _validatePaymentRequest(replacement);
    _validateText(reversal.actorId, 'actorId');
    _validateText(reversal.reason, 'reason');
    _validateText(reversal.idempotencyKey, 'idempotencyKey');
    if (reversal.idempotencyKey == replacement.idempotencyKey) {
      throw ArgumentError(
        'The two physical events require distinct idempotency keys.',
      );
    }
    final reversalPayload = jsonEncode([
      'method_b_old_event_reversal',
      reversal.paymentId,
      reversal.expectedVersionId,
      reversal.actorId,
      reversal.reason,
      replacement.idempotencyKey,
    ]);
    final paymentPayload = _paymentPayload(replacement);

    return _serialize(
      () => _transaction(() async {
        await _reverseWithoutCashReturn(reversal, reversalPayload);
        final result = await _recordPayment(replacement, paymentPayload);
        return result;
      }),
    );
  }

  Future<String> createSuspenseCase(SuspenseCaseRequest request) {
    _validateText(request.actorId, 'actorId');
    _validateText(request.reason, 'reason');
    _validateText(request.idempotencyKey, 'idempotencyKey');
    _validatePositive(request.amountMinor, 'amountMinor');
    final payload = jsonEncode([
      'suspense_creation',
      request.paymentId,
      request.amountMinor,
      request.actorId,
      request.reason,
    ]);
    return _serialize(
      () => _transaction(() async {
        final existing = await _findSuspenseEntry(request.idempotencyKey);
        if (existing != null) {
          _checkPayload(
            existing.requestPayload,
            payload,
            request.idempotencyKey,
          );
          return existing.caseId;
        }

        final identity = await _loadIdentity(request.paymentId);
        final event = await (_database.select(
          _database.cashEvents,
        )..where((row) => row.paymentId.equals(request.paymentId))).getSingle();
        final caseId = _uuid.v4();
        final now = _clock();
        await _database
            .into(_database.reconciliationCases)
            .insert(
              ReconciliationCasesCompanion.insert(
                id: caseId,
                cashEventId: event.id,
                paymentId: request.paymentId,
                financialAccountId: identity.financialAccountId,
                partyId: identity.partyId,
                partyRole: identity.partyRole,
                currencyCode: identity.currencyCode,
                reason: request.reason,
                createdByActorId: request.actorId,
                createdAt: now,
              ),
            );
        await _insertSuspenseEntry(
          caseId: caseId,
          identity: identity,
          eventId: event.id,
          movementType: 'creation',
          amountMinor: request.amountMinor,
          resolutionId: null,
          actorId: request.actorId,
          reason: request.reason,
          idempotencyKey: request.idempotencyKey,
          requestPayload: payload,
          recordedAt: now,
        );
        return caseId;
      }),
    );
  }

  Future<void> increaseSuspense(SuspenseMovementRequest request) =>
      _appendSuspenseMovement(
        request,
        'increase',
        requireAvailableBalance: false,
      );

  Future<void> decreaseSuspense(SuspenseMovementRequest request) =>
      _appendSuspenseMovement(
        request,
        'decrease',
        requireAvailableBalance: true,
      );

  Future<String> resolveSuspense(ResolveSuspenseRequest request) {
    _validateSuspenseMovement(request);
    _validateText(request.authorizedByActorId, 'authorizedByActorId');
    _validateText(request.authorizationReference, 'authorizationReference');
    final payload = jsonEncode([
      'resolution',
      request.caseId,
      request.amountMinor,
      request.actorId,
      request.authorizedByActorId,
      request.authorizationReference,
      request.reason,
    ]);
    return _serialize(
      () => _transaction(() async {
        final prior =
            await (_database.select(_database.suspenseResolutions)..where(
                  (row) => row.idempotencyKey.equals(request.idempotencyKey),
                ))
                .getSingleOrNull();
        if (prior != null) {
          _checkPayload(prior.requestPayload, payload, request.idempotencyKey);
          return prior.id;
        }

        final reconciliationCase = await _loadCase(request.caseId);
        final balance = await _suspenseBalance(request.caseId);
        if (request.amountMinor > balance) {
          throw SuspenseLimitExceeded(
            requestedMinor: request.amountMinor,
            availableMinor: balance,
          );
        }
        final now = _clock();
        final resolutionId = _uuid.v4();
        await _database
            .into(_database.suspenseResolutions)
            .insert(
              SuspenseResolutionsCompanion.insert(
                id: resolutionId,
                caseId: reconciliationCase.id,
                cashEventId: reconciliationCase.cashEventId,
                paymentId: reconciliationCase.paymentId,
                financialAccountId: reconciliationCase.financialAccountId,
                partyId: reconciliationCase.partyId,
                partyRole: reconciliationCase.partyRole,
                currencyCode: reconciliationCase.currencyCode,
                amountMinor: request.amountMinor,
                actorId: request.actorId,
                authorizedByActorId: request.authorizedByActorId,
                authorizationReference: request.authorizationReference,
                reason: request.reason,
                idempotencyKey: request.idempotencyKey,
                requestPayload: payload,
                resolvedAt: now,
              ),
            );
        final identity = await _loadIdentity(reconciliationCase.paymentId);
        await _insertSuspenseEntry(
          caseId: reconciliationCase.id,
          identity: identity,
          eventId: reconciliationCase.cashEventId,
          movementType: 'resolution',
          amountMinor: request.amountMinor,
          resolutionId: resolutionId,
          actorId: request.actorId,
          reason: request.reason,
          idempotencyKey: request.idempotencyKey,
          requestPayload: payload,
          recordedAt: now,
        );
        return resolutionId;
      }),
    );
  }

  Future<int> getSuspenseBalance(String caseId) async {
    await _loadCase(caseId);
    return _suspenseBalance(caseId);
  }

  Future<List<CashReportTotal>> getPhysicalCashReport() async {
    final rows = await _database.customSelect('''
      SELECT p.financial_account_id, p.party_id, p.party_role, p.currency_code,
        SUM(CASE WHEN v.occurred = 'yes' AND v.cash_direction = 'in'
          THEN v.physical_amount_minor ELSE 0 END) AS cash_in_minor,
        SUM(CASE WHEN v.occurred = 'yes' AND v.cash_direction = 'out'
          THEN v.physical_amount_minor ELSE 0 END) AS cash_out_minor,
        SUM(CASE WHEN v.occurred = 'unknown'
          THEN v.physical_amount_minor ELSE 0 END) AS pending_unknown_minor,
        SUM(CASE WHEN v.occurred = 'unknown' THEN 1 ELSE 0 END)
          AS pending_unknown_events
      FROM cash_event_heads h
      JOIN cash_event_versions v
        ON v.version_id = h.version_id
        AND v.cash_event_id = h.cash_event_id
        AND v.payment_id = h.payment_id
      JOIN payment_identities p ON p.payment_id = h.payment_id
      GROUP BY p.financial_account_id, p.party_id, p.party_role, p.currency_code
      ORDER BY p.financial_account_id, p.currency_code
    ''').get();
    return [
      for (final row in rows)
        CashReportTotal(
          financialAccountId: row.read<String>('financial_account_id'),
          partyId: row.read<String>('party_id'),
          partyRole: row.read<String>('party_role'),
          currencyCode: row.read<String>('currency_code'),
          cashInMinor: row.read<int>('cash_in_minor'),
          cashOutMinor: row.read<int>('cash_out_minor'),
          pendingUnknownMinor: row.read<int>('pending_unknown_minor'),
          pendingUnknownEvents: row.read<int>('pending_unknown_events'),
        ),
    ];
  }

  Future<List<EffectiveRecognitionTotal>>
  getEffectiveRecognitionReport() async {
    final rows = await _database.customSelect('''
      SELECT p.financial_account_id, p.party_id, p.party_role, p.currency_code,
        p.financial_direction,
        SUM(v.effective_recognized_minor) AS recognized_minor
      FROM cash_event_heads h
      JOIN cash_event_versions v
        ON v.version_id = h.version_id
        AND v.cash_event_id = h.cash_event_id
        AND v.payment_id = h.payment_id
      JOIN payment_identities p ON p.payment_id = h.payment_id
      GROUP BY p.financial_account_id, p.party_id, p.party_role,
        p.currency_code, p.financial_direction
      ORDER BY p.financial_account_id, p.currency_code, p.financial_direction
    ''').get();
    return [
      for (final row in rows)
        EffectiveRecognitionTotal(
          financialAccountId: row.read<String>('financial_account_id'),
          partyId: row.read<String>('party_id'),
          partyRole: row.read<String>('party_role'),
          currencyCode: row.read<String>('currency_code'),
          direction: row.read<String>('financial_direction') == 'in'
              ? LedgerDirection.incoming
              : LedgerDirection.outgoing,
          amountMinor: row.read<int>('recognized_minor'),
        ),
    ];
  }

  Future<CashEventOperationResult> _recordPayment(
    RecordPaymentRequest request,
    String payload,
  ) async {
    final duplicate = await _findVersionByKey(request.idempotencyKey, payload);
    if (duplicate != null) return _resultFromVersion(duplicate);

    final identityId = _uuid.v4();
    final eventId = _uuid.v4();
    final transactionId = _uuid.v4();
    final versionId = _uuid.v4();
    final now = _clock();
    await _database
        .into(_database.paymentIdentities)
        .insert(
          PaymentIdentitiesCompanion.insert(
            id: identityId,
            financialAccountId: request.financialAccountId,
            partyId: request.partyId,
            partyRole: request.partyRole,
            currencyCode: request.currencyCode,
            financialDirection: request.financialDirection.databaseValue,
            createdByActorId: request.actorId,
            createdAt: now,
          ),
        );
    await _database
        .into(_database.cashEvents)
        .insert(
          CashEventsCompanion.insert(
            id: eventId,
            paymentId: identityId,
            createdByActorId: request.actorId,
            createdAt: now,
          ),
        );
    await _insertTransaction(
      id: transactionId,
      identityId: identityId,
      eventId: eventId,
      accountId: request.financialAccountId,
      partyId: request.partyId,
      partyRole: request.partyRole,
      currencyCode: request.currencyCode,
      type: 'payment',
      direction: request.financialDirection,
      amountMinor: request.transactionAmountMinor,
      relatedTransactionId: null,
      actorId: request.actorId,
      reason: request.reason,
      idempotencyKey: '${request.idempotencyKey}:payment',
      occurredAt: now,
    );
    await _insertVersion(
      id: versionId,
      cashEventId: eventId,
      paymentId: identityId,
      sequence: 1,
      operation: CashEventOperation.original,
      occurred: request.occurred,
      cashDirection: request.cashDirection,
      physicalAmountMinor: request.physicalAmountMinor,
      effectiveRecognizedMinor: request.transactionAmountMinor,
      transactionId: transactionId,
      previousVersionId: null,
      idempotencyKey: request.idempotencyKey,
      requestPayload: payload,
      actorId: request.actorId,
      reason: request.reason,
      recordedAt: now,
    );
    await _database
        .into(_database.cashEventHeads)
        .insert(
          CashEventHeadsCompanion.insert(
            cashEventId: eventId,
            paymentId: identityId,
            versionId: versionId,
            revision: 1,
            updatedAt: now,
          ),
        );
    return CashEventOperationResult(
      paymentId: identityId,
      cashEventId: eventId,
      versionId: versionId,
      sequence: 1,
    );
  }

  Future<CashEventOperationResult> _correctPayment(
    CorrectPaymentRequest request,
    String payload,
  ) async {
    final duplicate = await _findVersionByKey(request.idempotencyKey, payload);
    if (duplicate != null) return _resultFromVersion(duplicate);
    final current = await _loadCurrent(
      request.paymentId,
      request.expectedVersionId,
    );
    final identity = await _loadIdentity(request.paymentId);
    final reversalId = current.version.effectiveRecognizedMinor == 0
        ? null
        : _uuid.v4();
    if (reversalId != null) {
      await _insertTransaction(
        id: reversalId,
        identityId: request.paymentId,
        eventId: current.head.cashEventId,
        accountId: identity.financialAccountId,
        partyId: identity.partyId,
        partyRole: identity.partyRole,
        currencyCode: identity.currencyCode,
        type: 'payment_reversal',
        direction: _direction(identity.financialDirection).opposite,
        amountMinor: current.version.effectiveRecognizedMinor,
        relatedTransactionId: current.version.transactionId,
        actorId: request.actorId,
        reason: request.reason,
        idempotencyKey: '${request.idempotencyKey}:reversal',
        occurredAt: _clock(),
      );
    }
    final replacementId = _uuid.v4();
    final now = _clock();
    await _insertTransaction(
      id: replacementId,
      identityId: request.paymentId,
      eventId: current.head.cashEventId,
      accountId: identity.financialAccountId,
      partyId: identity.partyId,
      partyRole: identity.partyRole,
      currencyCode: identity.currencyCode,
      type: 'replacement',
      direction: _direction(identity.financialDirection),
      amountMinor: request.replacementAmountMinor,
      relatedTransactionId: reversalId ?? current.version.transactionId,
      actorId: request.actorId,
      reason: request.reason,
      idempotencyKey: '${request.idempotencyKey}:replacement',
      occurredAt: now,
    );
    final versionId = _uuid.v4();
    final sequence = current.version.sequence + 1;
    await _insertVersion(
      id: versionId,
      cashEventId: current.head.cashEventId,
      paymentId: request.paymentId,
      sequence: sequence,
      operation: request.occurred == PhysicalOccurrence.no
          ? CashEventOperation.voidEvent
          : CashEventOperation.correction,
      occurred: request.occurred,
      cashDirection: _direction(current.version.cashDirection),
      physicalAmountMinor: request.physicalAmountMinor,
      effectiveRecognizedMinor: request.replacementAmountMinor,
      transactionId: replacementId,
      previousVersionId: current.version.id,
      idempotencyKey: request.idempotencyKey,
      requestPayload: payload,
      actorId: request.actorId,
      reason: request.reason,
      recordedAt: now,
    );
    await _advanceHead(current.head, versionId, sequence, now);
    String? caseId;
    if (request.occurred == PhysicalOccurrence.yes &&
        request.replacementAmountMinor == 0 &&
        request.physicalAmountMinor > 0) {
      caseId = await _synchronizeEventSuspense(
        identity: identity,
        eventId: current.head.cashEventId,
        targetAmountMinor: request.physicalAmountMinor,
        actorId: request.actorId,
        reason: request.reason,
        idempotencyKey: '${request.idempotencyKey}:suspense',
        requestPayload: payload,
        recordedAt: now,
      );
    }
    return CashEventOperationResult(
      paymentId: request.paymentId,
      cashEventId: current.head.cashEventId,
      versionId: versionId,
      sequence: sequence,
      reconciliationCaseId: caseId,
    );
  }

  Future<CashEventOperationResult> _reverseWithoutCashReturn(
    ReversePaymentRequest request,
    String payload,
  ) async {
    final duplicate = await _findVersionByKey(request.idempotencyKey, payload);
    if (duplicate != null) return _resultFromVersion(duplicate);
    final current = await _loadCurrent(
      request.paymentId,
      request.expectedVersionId,
    );
    if (current.version.effectiveRecognizedMinor <= 0 ||
        current.version.transactionId == null) {
      throw StateError('There is no recognized transaction to reverse.');
    }
    final identity = await _loadIdentity(request.paymentId);
    final now = _clock();
    final reversalId = _uuid.v4();
    await _insertTransaction(
      id: reversalId,
      identityId: request.paymentId,
      eventId: current.head.cashEventId,
      accountId: identity.financialAccountId,
      partyId: identity.partyId,
      partyRole: identity.partyRole,
      currencyCode: identity.currencyCode,
      type: 'payment_reversal',
      direction: _direction(identity.financialDirection).opposite,
      amountMinor: current.version.effectiveRecognizedMinor,
      relatedTransactionId: current.version.transactionId,
      actorId: request.actorId,
      reason: request.reason,
      idempotencyKey: '${request.idempotencyKey}:reversal',
      occurredAt: now,
    );
    final versionId = _uuid.v4();
    final sequence = current.version.sequence + 1;
    await _insertVersion(
      id: versionId,
      cashEventId: current.head.cashEventId,
      paymentId: request.paymentId,
      sequence: sequence,
      operation: CashEventOperation.reversal,
      occurred: _occurrence(current.version.occurred),
      cashDirection: _direction(current.version.cashDirection),
      physicalAmountMinor: current.version.physicalAmountMinor,
      effectiveRecognizedMinor: 0,
      transactionId: reversalId,
      previousVersionId: current.version.id,
      idempotencyKey: request.idempotencyKey,
      requestPayload: payload,
      actorId: request.actorId,
      reason: request.reason,
      recordedAt: now,
    );
    await _advanceHead(current.head, versionId, sequence, now);

    String? caseId;
    if (current.version.occurred == PhysicalOccurrence.yes.databaseValue &&
        current.version.physicalAmountMinor > 0) {
      caseId = await _synchronizeEventSuspense(
        identity: identity,
        eventId: current.head.cashEventId,
        targetAmountMinor: current.version.physicalAmountMinor,
        actorId: request.actorId,
        reason: request.reason,
        idempotencyKey: '${request.idempotencyKey}:suspense',
        requestPayload: payload,
        recordedAt: now,
      );
    }
    return CashEventOperationResult(
      paymentId: request.paymentId,
      cashEventId: current.head.cashEventId,
      versionId: versionId,
      sequence: sequence,
      reconciliationCaseId: caseId,
    );
  }

  Future<CashEventOperationResult> _voidNeverOccurred(
    VoidPaymentRequest request,
    String payload,
  ) async {
    final duplicate = await _findVersionByKey(request.idempotencyKey, payload);
    if (duplicate != null) return _resultFromVersion(duplicate);
    final current = await _loadCurrent(
      request.paymentId,
      request.expectedVersionId,
    );
    if (current.version.effectiveRecognizedMinor <= 0 ||
        current.version.transactionId == null) {
      throw StateError('There is no recognized transaction to reverse.');
    }
    final identity = await _loadIdentity(request.paymentId);
    final now = _clock();
    final reversalId = _uuid.v4();
    await _insertTransaction(
      id: reversalId,
      identityId: request.paymentId,
      eventId: current.head.cashEventId,
      accountId: identity.financialAccountId,
      partyId: identity.partyId,
      partyRole: identity.partyRole,
      currencyCode: identity.currencyCode,
      type: 'payment_reversal',
      direction: _direction(identity.financialDirection).opposite,
      amountMinor: current.version.effectiveRecognizedMinor,
      relatedTransactionId: current.version.transactionId,
      actorId: request.actorId,
      reason: request.reason,
      idempotencyKey: '${request.idempotencyKey}:reversal',
      occurredAt: now,
    );
    final replacementId = _uuid.v4();
    await _insertTransaction(
      id: replacementId,
      identityId: request.paymentId,
      eventId: current.head.cashEventId,
      accountId: identity.financialAccountId,
      partyId: identity.partyId,
      partyRole: identity.partyRole,
      currencyCode: identity.currencyCode,
      type: 'replacement',
      direction: _direction(identity.financialDirection),
      amountMinor: 0,
      relatedTransactionId: reversalId,
      actorId: request.actorId,
      reason: request.reason,
      idempotencyKey: '${request.idempotencyKey}:replacement',
      occurredAt: now,
    );
    final versionId = _uuid.v4();
    final sequence = current.version.sequence + 1;
    await _insertVersion(
      id: versionId,
      cashEventId: current.head.cashEventId,
      paymentId: request.paymentId,
      sequence: sequence,
      operation: CashEventOperation.voidEvent,
      occurred: PhysicalOccurrence.no,
      cashDirection: _direction(current.version.cashDirection),
      physicalAmountMinor: 0,
      effectiveRecognizedMinor: 0,
      transactionId: replacementId,
      previousVersionId: current.version.id,
      idempotencyKey: request.idempotencyKey,
      requestPayload: payload,
      actorId: request.actorId,
      reason: request.reason,
      recordedAt: now,
    );
    await _advanceHead(current.head, versionId, sequence, now);
    return CashEventOperationResult(
      paymentId: request.paymentId,
      cashEventId: current.head.cashEventId,
      versionId: versionId,
      sequence: sequence,
    );
  }

  Future<String?> _synchronizeEventSuspense({
    required PaymentIdentity identity,
    required String eventId,
    required int targetAmountMinor,
    required String actorId,
    required String reason,
    required String idempotencyKey,
    required String requestPayload,
    required DateTime recordedAt,
  }) async {
    final target = targetAmountMinor > 0 ? targetAmountMinor : 0;
    final cases = await (_database.select(
      _database.reconciliationCases,
    )..where((row) => row.cashEventId.equals(eventId))).get();
    if (cases.isEmpty && target == 0) return null;

    final caseId = cases.isEmpty ? _uuid.v4() : cases.first.id;
    if (cases.isEmpty) {
      await _database
          .into(_database.reconciliationCases)
          .insert(
            ReconciliationCasesCompanion.insert(
              id: caseId,
              cashEventId: eventId,
              paymentId: identity.id,
              financialAccountId: identity.financialAccountId,
              partyId: identity.partyId,
              partyRole: identity.partyRole,
              currencyCode: identity.currencyCode,
              reason: reason,
              createdByActorId: actorId,
              createdAt: recordedAt,
            ),
          );
    }

    final balance = await _suspenseBalance(caseId);
    if (balance == target) return caseId;
    final movementType = target > balance ? 'increase' : 'decrease';
    final amount = (target - balance).abs();
    final movementKey = '$idempotencyKey:$movementType';
    final movementPayload = jsonEncode([
      'event_suspense_balance',
      caseId,
      target,
      actorId,
      reason,
      requestPayload,
    ]);
    await _insertSuspenseEntry(
      caseId: caseId,
      identity: identity,
      eventId: eventId,
      movementType: movementType,
      amountMinor: amount,
      resolutionId: null,
      actorId: actorId,
      reason: reason,
      idempotencyKey: movementKey,
      requestPayload: movementPayload,
      recordedAt: recordedAt,
    );
    return caseId;
  }

  Future<void> _appendSuspenseMovement(
    SuspenseMovementRequest request,
    String movementType, {
    required bool requireAvailableBalance,
  }) {
    _validateSuspenseMovement(request);
    final payload = jsonEncode([
      movementType,
      request.caseId,
      request.amountMinor,
      request.actorId,
      request.reason,
    ]);
    return _serialize(
      () => _transaction(() async {
        final existing = await _findSuspenseEntry(request.idempotencyKey);
        if (existing != null) {
          _checkPayload(
            existing.requestPayload,
            payload,
            request.idempotencyKey,
          );
          return;
        }
        final reconciliationCase = await _loadCase(request.caseId);
        final balance = await _suspenseBalance(request.caseId);
        if (requireAvailableBalance && request.amountMinor > balance) {
          throw SuspenseLimitExceeded(
            requestedMinor: request.amountMinor,
            availableMinor: balance,
          );
        }
        final identity = await _loadIdentity(reconciliationCase.paymentId);
        await _insertSuspenseEntry(
          caseId: reconciliationCase.id,
          identity: identity,
          eventId: reconciliationCase.cashEventId,
          movementType: movementType,
          amountMinor: request.amountMinor,
          resolutionId: null,
          actorId: request.actorId,
          reason: request.reason,
          idempotencyKey: request.idempotencyKey,
          requestPayload: payload,
          recordedAt: _clock(),
        );
      }),
    );
  }

  Future<void> _insertSuspenseEntry({
    required String caseId,
    required PaymentIdentity identity,
    required String eventId,
    required String movementType,
    required int amountMinor,
    required String? resolutionId,
    required String actorId,
    required String reason,
    required String idempotencyKey,
    required String requestPayload,
    required DateTime recordedAt,
  }) async {
    await _database
        .into(_database.suspenseEntries)
        .insert(
          SuspenseEntriesCompanion.insert(
            id: _uuid.v4(),
            caseId: caseId,
            cashEventId: eventId,
            paymentId: identity.id,
            financialAccountId: identity.financialAccountId,
            partyId: identity.partyId,
            partyRole: identity.partyRole,
            currencyCode: identity.currencyCode,
            movementType: movementType,
            amountMinor: amountMinor,
            resolutionId: Value(resolutionId),
            actorId: actorId,
            reason: reason,
            idempotencyKey: idempotencyKey,
            requestPayload: requestPayload,
            recordedAt: recordedAt,
          ),
        );
  }

  Future<void> _insertTransaction({
    required String id,
    required String identityId,
    required String eventId,
    required String accountId,
    required String partyId,
    required String partyRole,
    required String currencyCode,
    required String type,
    required LedgerDirection direction,
    required int amountMinor,
    required String? relatedTransactionId,
    required String actorId,
    required String reason,
    required String? idempotencyKey,
    required DateTime occurredAt,
  }) async {
    await _database
        .into(_database.financialTransactions)
        .insert(
          FinancialTransactionsCompanion.insert(
            id: id,
            cashEventId: eventId,
            paymentId: identityId,
            financialAccountId: accountId,
            partyId: partyId,
            partyRole: partyRole,
            currencyCode: currencyCode,
            transactionType: type,
            direction: direction.databaseValue,
            amountMinor: amountMinor,
            relatedTransactionId: Value(relatedTransactionId),
            actorId: actorId,
            reason: reason,
            idempotencyKey: Value(idempotencyKey),
            occurredAt: occurredAt,
          ),
        );
  }

  Future<void> _insertVersion({
    required String id,
    required String cashEventId,
    required String paymentId,
    required int sequence,
    required CashEventOperation operation,
    required PhysicalOccurrence occurred,
    required LedgerDirection cashDirection,
    required int physicalAmountMinor,
    required int effectiveRecognizedMinor,
    required String? transactionId,
    required String? previousVersionId,
    required String idempotencyKey,
    required String requestPayload,
    required String actorId,
    required String reason,
    required DateTime recordedAt,
  }) async {
    await _database
        .into(_database.cashEventVersions)
        .insert(
          CashEventVersionsCompanion.insert(
            id: id,
            cashEventId: cashEventId,
            paymentId: paymentId,
            sequence: sequence,
            operation: operation.databaseValue,
            occurred: occurred.databaseValue,
            cashDirection: cashDirection.databaseValue,
            physicalAmountMinor: physicalAmountMinor,
            effectiveRecognizedMinor: effectiveRecognizedMinor,
            transactionId: Value(transactionId),
            previousVersionId: Value(previousVersionId),
            idempotencyKey: idempotencyKey,
            requestPayload: requestPayload,
            actorId: actorId,
            reason: reason,
            recordedAt: recordedAt,
          ),
        );
  }

  Future<void> _advanceHead(
    CashEventHead head,
    String newVersionId,
    int newRevision,
    DateTime updatedAt,
  ) async {
    final updated =
        await (_database.update(_database.cashEventHeads)..where(
              (row) =>
                  row.cashEventId.equals(head.cashEventId) &
                  row.paymentId.equals(head.paymentId) &
                  row.versionId.equals(head.versionId) &
                  row.revision.equals(head.revision),
            ))
            .write(
              CashEventHeadsCompanion(
                versionId: Value(newVersionId),
                revision: Value(newRevision),
                updatedAt: Value(updatedAt),
              ),
            );
    if (updated != 1) throw StaleCashEventHead(head.cashEventId);
  }

  Future<_CurrentEvent> _loadCurrent(
    String paymentId,
    String expectedVersionId,
  ) async {
    final head = await (_database.select(
      _database.cashEventHeads,
    )..where((row) => row.paymentId.equals(paymentId))).getSingleOrNull();
    if (head == null || head.versionId != expectedVersionId) {
      final eventId = head?.cashEventId ?? paymentId;
      throw StaleCashEventHead(eventId);
    }
    final version =
        await (_database.select(_database.cashEventVersions)..where(
              (row) =>
                  row.id.equals(head.versionId) &
                  row.cashEventId.equals(head.cashEventId) &
                  row.paymentId.equals(head.paymentId),
            ))
            .getSingle();
    return _CurrentEvent(head, version);
  }

  Future<PaymentIdentity> _loadIdentity(String paymentId) {
    return (_database.select(
      _database.paymentIdentities,
    )..where((row) => row.id.equals(paymentId))).getSingle();
  }

  Future<ReconciliationCase> _loadCase(String caseId) {
    return (_database.select(
      _database.reconciliationCases,
    )..where((row) => row.id.equals(caseId))).getSingle();
  }

  Future<int> _suspenseBalance(String caseId) async {
    final row = await _database
        .customSelect(
          '''
          SELECT COALESCE(SUM(
            CASE WHEN movement_type IN ('creation', 'increase') THEN amount_minor
              ELSE -amount_minor END
          ), 0) AS balance_minor
          FROM suspense_entries WHERE case_id = ?
          ''',
          variables: [Variable.withString(caseId)],
        )
        .getSingle();
    return row.read<int>('balance_minor');
  }

  Future<CashEventVersion?> _findVersionByKey(
    String idempotencyKey,
    String requestPayload,
  ) async {
    final version =
        await (_database.select(_database.cashEventVersions)
              ..where((row) => row.idempotencyKey.equals(idempotencyKey)))
            .getSingleOrNull();
    if (version != null) {
      _checkPayload(version.requestPayload, requestPayload, idempotencyKey);
    }
    return version;
  }

  Future<SuspenseEntry?> _findSuspenseEntry(String idempotencyKey) {
    return (_database.select(_database.suspenseEntries)
          ..where((row) => row.idempotencyKey.equals(idempotencyKey)))
        .getSingleOrNull();
  }

  Future<CashEventOperationResult> _resultFromVersion(
    CashEventVersion version,
  ) async {
    final caseRow =
        await (_database.select(_database.reconciliationCases)
              ..where((row) => row.cashEventId.equals(version.cashEventId)))
            .getSingleOrNull();
    return CashEventOperationResult(
      paymentId: version.paymentId,
      cashEventId: version.cashEventId,
      versionId: version.id,
      sequence: version.sequence,
      reconciliationCaseId: caseRow?.id,
    );
  }

  void _validatePaymentRequest(RecordPaymentRequest request) {
    _validateText(request.financialAccountId, 'financialAccountId');
    _validateText(request.partyId, 'partyId');
    _validateText(request.partyRole, 'partyRole');
    _validateText(request.currencyCode, 'currencyCode');
    _validateText(request.actorId, 'actorId');
    _validateText(request.reason, 'reason');
    _validateText(request.idempotencyKey, 'idempotencyKey');
    _validatePositive(request.transactionAmountMinor, 'transactionAmountMinor');
    _validateNonNegative(request.physicalAmountMinor, 'physicalAmountMinor');
    if (request.occurred == PhysicalOccurrence.no &&
        request.physicalAmountMinor != 0) {
      throw ArgumentError(
        'An event confirmed not to have occurred must have zero physical amount.',
      );
    }
  }

  void _validateSuspenseMovement(SuspenseMovementRequest request) {
    _validateText(request.caseId, 'caseId');
    _validateText(request.actorId, 'actorId');
    _validateText(request.reason, 'reason');
    _validateText(request.idempotencyKey, 'idempotencyKey');
    _validatePositive(request.amountMinor, 'amountMinor');
  }

  String _paymentPayload(RecordPaymentRequest request) => jsonEncode([
    'payment',
    request.financialAccountId,
    request.partyId,
    request.partyRole,
    request.currencyCode,
    request.financialDirection.databaseValue,
    request.cashDirection.databaseValue,
    request.transactionAmountMinor,
    request.physicalAmountMinor,
    request.occurred.databaseValue,
    request.actorId,
    request.reason,
  ]);

  void _checkPayload(String existing, String requested, String key) {
    if (existing != requested) throw IdempotencyConflict(key);
  }

  void _validateText(String value, String field) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, field, 'Must not be empty.');
    }
  }

  void _validatePositive(int value, String field) {
    if (value <= 0) {
      throw ArgumentError.value(value, field, 'Must be positive.');
    }
  }

  void _validateNonNegative(int value, String field) {
    if (value < 0) {
      throw ArgumentError.value(value, field, 'Must not be negative.');
    }
  }

  LedgerDirection _direction(String value) =>
      value == 'in' ? LedgerDirection.incoming : LedgerDirection.outgoing;

  PhysicalOccurrence _occurrence(String value) => switch (value) {
    'yes' => PhysicalOccurrence.yes,
    'no' => PhysicalOccurrence.no,
    _ => PhysicalOccurrence.unknown,
  };
}

class _CurrentEvent {
  const _CurrentEvent(this.head, this.version);

  final CashEventHead head;
  final CashEventVersion version;
}
