import 'dart:async';
import 'dart:convert';

import 'package:arqamy/core/database/app_database.dart';
import 'package:arqamy/features/payment_ledger/data/allocation_domain.dart'
    as domain;
import 'package:drift/drift.dart';
import 'package:drift/native.dart' show SqliteException;
import 'package:uuid/uuid.dart';

class AllocationBalanceExceeded implements Exception {
  const AllocationBalanceExceeded({
    required this.entityId,
    required this.requestedMinor,
    required this.availableMinor,
  });

  final String entityId;
  final int requestedMinor;
  final int availableMinor;

  @override
  String toString() =>
      'Allocation amount $requestedMinor exceeds available balance '
      '$availableMinor for "$entityId"';
}

class AllocationReversalLimitExceeded implements Exception {
  const AllocationReversalLimitExceeded({
    required this.allocationId,
    required this.requestedMinor,
    required this.availableMinor,
  });

  final String allocationId;
  final int requestedMinor;
  final int availableMinor;

  @override
  String toString() =>
      'Reversal amount $requestedMinor exceeds remaining allocation '
      '$availableMinor for "$allocationId"';
}

class AllocationRecognitionLimitExceeded implements Exception {
  const AllocationRecognitionLimitExceeded({
    required this.paymentId,
    required this.recognizedMinor,
    required this.allocatedMinor,
  });

  final String paymentId;
  final int recognizedMinor;
  final int allocatedMinor;

  @override
  String toString() =>
      'Payment "$paymentId" cannot be recognized at $recognizedMinor minor '
      'units while $allocatedMinor minor units remain allocated';
}

class AllocationRepository {
  AllocationRepository(
    this._database, {
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
  }) : _uuid = uuid,
       _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _clock;
  Future<void> _mutationQueue = Future<void>.value();

  /// Checks the Stage 3 recognition floor while its write transaction is open.
  static Future<void> ensureRecognitionCoversLocalAllocations({
    required AppDatabase database,
    required String paymentId,
    required int recognizedMinor,
  }) async {
    final row = await database
        .customSelect(
          '''
      SELECT COALESCE(SUM(a.amount_minor - COALESCE((
        SELECT SUM(r.amount_minor) FROM allocation_reversals r
        WHERE r.allocation_id = a.allocation_id
      ), 0)), 0) AS allocated_minor
      FROM invoice_allocations a
      JOIN allocation_status_history h ON h.allocation_id = a.allocation_id
      WHERE a.payment_id = ? AND h.sequence = (
        SELECT MAX(h2.sequence) FROM allocation_status_history h2
        WHERE h2.allocation_id = a.allocation_id
      ) AND h.status IN ('provisional', 'server_confirmed', 'conflict_pending')
      ''',
          variables: [Variable.withString(paymentId)],
          readsFrom: {
            database.invoiceAllocations,
            database.allocationReversals,
            database.allocationStatusHistory,
          },
        )
        .getSingle();
    final allocatedMinor = row.read<int>('allocated_minor');
    if (recognizedMinor < allocatedMinor) {
      throw AllocationRecognitionLimitExceeded(
        paymentId: paymentId,
        recognizedMinor: recognizedMinor,
        allocatedMinor: allocatedMinor,
      );
    }
  }

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

  Future<domain.AllocationOperationResult> createAllocation(
    domain.CreateAllocationRequest request,
  ) {
    _validateCreateRequest(request);
    final fingerprint = _createFingerprint(request);
    return _serialize(
      () => _transaction(() => _createAllocation(request, fingerprint)),
    );
  }

  Future<domain.AllocationOperationResult> reverseAllocation(
    domain.ReverseAllocationRequest request,
  ) {
    _validateText(request.allocationId, 'allocationId');
    _validateText(request.reason, 'reason');
    _validateText(request.idempotencyKey, 'idempotencyKey');
    _validateText(request.requestFingerprint, 'requestFingerprint');
    _validateText(request.actorId, 'actorId', optional: true);
    _validatePositive(request.amountMinor, 'amountMinor');
    final fingerprint = jsonEncode([
      'allocation_reversal',
      request.allocationId,
      request.amountMinor,
      request.actorId,
      request.reason,
      request.requestFingerprint,
    ]);
    return _serialize(
      () => _transaction(() => _reverseAllocation(request, fingerprint)),
    );
  }

  Future<domain.AllocationOperationResult> changeStatus(
    domain.ChangeAllocationStatusRequest request,
  ) {
    _validateText(request.allocationId, 'allocationId');
    _validateText(request.expectedVersionId, 'expectedVersionId');
    _validateText(request.idempotencyKey, 'idempotencyKey');
    _validateText(request.requestFingerprint, 'requestFingerprint');
    _validateText(request.actorId, 'actorId', optional: true);
    _validateText(request.reason, 'reason', optional: true);
    final fingerprint = jsonEncode([
      'allocation_status',
      request.allocationId,
      request.expectedVersionId,
      request.status.databaseValue,
      request.actorId,
      request.reason,
      request.requestFingerprint,
    ]);
    return _serialize(
      () => _transaction(() => _changeStatus(request, fingerprint)),
    );
  }

  Future<List<domain.InvoiceAllocation>> getAllocationHistory({
    String? paymentId,
    String? invoiceId,
  }) async {
    final rows =
        await (_database.select(_database.invoiceAllocations)..orderBy([
              (row) => OrderingTerm.asc(row.createdAt),
              (row) => OrderingTerm.asc(row.id),
            ]))
            .get();
    final filtered = rows.where(
      (row) =>
          (paymentId == null || row.paymentId == paymentId) &&
          (invoiceId == null || row.invoiceId == invoiceId),
    );
    return filtered.map(_allocationFromRow).toList(growable: false);
  }

  Future<List<domain.AllocationReversal>> getReversalHistory(
    String allocationId,
  ) async {
    final rows = await _database
        .customSelect(
          'SELECT * FROM allocation_reversals '
          'WHERE allocation_id = ? ORDER BY rowid ASC',
          variables: [Variable.withString(allocationId)],
          readsFrom: {_database.allocationReversals},
        )
        .get();
    return rows
        .map((row) => _reversalFromMap(row.data))
        .toList(growable: false);
  }

  Future<List<domain.AllocationStatusEvent>> getStatusHistory(
    String allocationId,
  ) async {
    final rows =
        await (_database.select(_database.allocationStatusHistory)
              ..where((row) => row.allocationId.equals(allocationId))
              ..orderBy([(row) => OrderingTerm.asc(row.sequence)]))
            .get();
    return rows.map(_statusFromRow).toList(growable: false);
  }

  Future<int> getPaymentAllocationTotal(
    String paymentId, {
    domain.AllocationProjection projection =
        domain.AllocationProjection.localEffective,
  }) => _allocationTotal('payment_id', paymentId, projection);

  Future<int> getInvoiceAllocationTotal(
    String invoiceId, {
    domain.AllocationProjection projection =
        domain.AllocationProjection.localEffective,
  }) => _allocationTotal('invoice_id', invoiceId, projection);

  Future<List<domain.InvoiceAllocation>> getUnresolvedAllocations({
    String? paymentId,
    String? invoiceId,
  }) => _allocationsWithStatuses(
    const ['provisional', 'conflict_pending'],
    paymentId: paymentId,
    invoiceId: invoiceId,
  );

  Future<List<domain.InvoiceAllocation>> getConflictingAllocations({
    String? paymentId,
    String? invoiceId,
    String? conflictGroupId,
  }) async {
    final candidates = await _allocationsWithStatuses(
      const ['conflict_pending'],
      paymentId: paymentId,
      invoiceId: invoiceId,
    );
    if (conflictGroupId == null) return candidates;
    return candidates
        .where((allocation) => allocation.conflictGroupId == conflictGroupId)
        .toList(growable: false);
  }

  Future<domain.AllocationOperationResult> _createAllocation(
    domain.CreateAllocationRequest request,
    String fingerprint,
  ) async {
    final duplicate = await _findIdempotencyKey(request.idempotencyKey);
    if (duplicate != null) {
      _checkFingerprint(
        duplicate.fingerprint,
        fingerprint,
        request.idempotencyKey,
      );
      if (duplicate.allocationId == null) {
        throw domain.AllocationIdempotencyConflict(request.idempotencyKey);
      }
      final initial =
          await (_database.select(_database.allocationStatusHistory)
                ..where(
                  (row) => row.allocationId.equals(duplicate.allocationId!),
                )
                ..orderBy([(row) => OrderingTerm.asc(row.sequence)])
                ..limit(1))
              .getSingle();
      return domain.AllocationOperationResult(
        allocationId: duplicate.allocationId!,
        operationId: initial.id,
        sequence: initial.sequence,
      );
    }

    final payment = await (_database.select(
      _database.paymentIdentities,
    )..where((row) => row.id.equals(request.paymentId))).getSingleOrNull();
    final invoice = await (_database.select(
      _database.invoices,
    )..where((row) => row.id.equals(request.invoiceId))).getSingleOrNull();
    if (payment == null || invoice == null) {
      throw StateError('Allocation payment or invoice does not exist.');
    }
    final lifecycle = await _latestLifecycleState(invoice.id);
    if (invoice.action == 'storage' ||
        invoice.action == 'unknown' ||
        lifecycle != 'active') {
      throw StateError(
        'Only active sale or purchase invoices can be allocated.',
      );
    }
    _validateIdentityMatch(request, payment, invoice);

    final allocation = await _allocationTotalsForIdentity(
      paymentId: request.paymentId,
      invoiceId: request.invoiceId,
    );
    final availableInvoice =
        (invoice.totalMinor ?? 0) - allocation.invoiceLocal;
    if (request.amountMinor > availableInvoice) {
      throw AllocationBalanceExceeded(
        entityId: invoice.id,
        requestedMinor: request.amountMinor,
        availableMinor: availableInvoice,
      );
    }
    final recognized = await _recognizedPaymentAmount(request.paymentId);
    final availablePayment = recognized - allocation.paymentLocal;
    if (request.amountMinor > availablePayment) {
      throw AllocationBalanceExceeded(
        entityId: payment.id,
        requestedMinor: request.amountMinor,
        availableMinor: availablePayment,
      );
    }

    final now = _clock();
    final allocationId = _uuid.v4();
    await _database
        .into(_database.invoiceAllocations)
        .insert(
          InvoiceAllocationsCompanion.insert(
            id: allocationId,
            paymentId: request.paymentId,
            invoiceId: request.invoiceId,
            paymentFinancialAccountId: request.paymentFinancialAccountId,
            invoiceFinancialAccountId: request.invoiceFinancialAccountId,
            partyId: request.partyId,
            partyRole: request.partyRole,
            currencyCode: request.currencyCode,
            amountMinor: request.amountMinor,
            idempotencyKey: request.idempotencyKey,
            requestFingerprint: fingerprint,
            originDeviceId: Value(request.originDeviceId),
            conflictGroupId: Value(request.conflictGroupId),
            actorId: Value(request.actorId),
            reason: Value(request.reason),
            createdAt: now,
          ),
        );
    final statusId = _uuid.v4();
    await _database
        .into(_database.allocationStatusHistory)
        .insert(
          AllocationStatusHistoryCompanion.insert(
            id: statusId,
            allocationId: allocationId,
            sequence: 1,
            status: domain.AllocationStatus.provisional.databaseValue,
            previousVersionId: const Value(null),
            idempotencyKey: '${request.idempotencyKey}:initial-status',
            requestFingerprint: jsonEncode(['initial_status', allocationId]),
            actorId: Value(request.actorId),
            reason: Value(request.reason),
            recordedAt: now,
          ),
        );
    return domain.AllocationOperationResult(
      allocationId: allocationId,
      operationId: statusId,
      sequence: 1,
    );
  }

  Future<domain.AllocationOperationResult> _reverseAllocation(
    domain.ReverseAllocationRequest request,
    String fingerprint,
  ) async {
    final duplicate = await _findIdempotencyKey(request.idempotencyKey);
    if (duplicate != null) {
      _checkFingerprint(
        duplicate.fingerprint,
        fingerprint,
        request.idempotencyKey,
      );
      if (duplicate.reversalId == null) {
        throw domain.AllocationIdempotencyConflict(request.idempotencyKey);
      }
      return domain.AllocationOperationResult(
        allocationId: duplicate.allocationId!,
        operationId: duplicate.reversalId!,
        sequence: duplicate.sequence,
      );
    }
    final allocation = await (_database.select(
      _database.invoiceAllocations,
    )..where((row) => row.id.equals(request.allocationId))).getSingleOrNull();
    if (allocation == null) throw StateError('Allocation does not exist.');
    final prior = await _reversedAmount(request.allocationId);
    final remaining = allocation.amountMinor - prior;
    if (request.amountMinor > remaining) {
      throw AllocationReversalLimitExceeded(
        allocationId: allocation.id,
        requestedMinor: request.amountMinor,
        availableMinor: remaining,
      );
    }
    final reversalId = _uuid.v4();
    final createdAt = _clock();
    await _database
        .into(_database.allocationReversals)
        .insert(
          AllocationReversalsCompanion.insert(
            id: reversalId,
            allocationId: allocation.id,
            amountMinor: request.amountMinor,
            idempotencyKey: request.idempotencyKey,
            requestFingerprint: fingerprint,
            actorId: Value(request.actorId),
            reason: request.reason,
            createdAt: createdAt,
          ),
        );
    return domain.AllocationOperationResult(
      allocationId: allocation.id,
      operationId: reversalId,
      sequence: await _reversalSequence(allocation.id, reversalId),
    );
  }

  Future<domain.AllocationOperationResult> _changeStatus(
    domain.ChangeAllocationStatusRequest request,
    String fingerprint,
  ) async {
    final duplicate = await _findIdempotencyKey(request.idempotencyKey);
    if (duplicate != null) {
      _checkFingerprint(
        duplicate.fingerprint,
        fingerprint,
        request.idempotencyKey,
      );
      if (duplicate.statusEventId == null) {
        throw domain.AllocationIdempotencyConflict(request.idempotencyKey);
      }
      return domain.AllocationOperationResult(
        allocationId: duplicate.allocationId!,
        operationId: duplicate.statusEventId!,
        sequence: duplicate.sequence,
      );
    }
    final current =
        await (_database.select(_database.allocationStatusHistory)
              ..where((row) => row.allocationId.equals(request.allocationId))
              ..orderBy([(row) => OrderingTerm.desc(row.sequence)])
              ..limit(1))
            .getSingleOrNull();
    if (current == null || current.id != request.expectedVersionId) {
      throw domain.StaleAllocationStatus(request.allocationId);
    }
    final allocation = await (_database.select(
      _database.invoiceAllocations,
    )..where((row) => row.id.equals(request.allocationId))).getSingle();
    if (_isLocalEffective(request.status)) {
      await _validateEffectiveAllocation(
        _allocationFromRow(allocation),
        wasEffective: _isLocalEffective(
          domain.AllocationStatus.values.firstWhere(
            (status) => status.databaseValue == current.status,
          ),
        ),
      );
    }
    final sequence = current.sequence + 1;
    final eventId = _uuid.v4();
    await _database
        .into(_database.allocationStatusHistory)
        .insert(
          AllocationStatusHistoryCompanion.insert(
            id: eventId,
            allocationId: allocation.id,
            sequence: sequence,
            status: request.status.databaseValue,
            previousVersionId: Value(current.id),
            idempotencyKey: request.idempotencyKey,
            requestFingerprint: fingerprint,
            actorId: Value(request.actorId),
            reason: Value(request.reason),
            recordedAt: _clock(),
          ),
        );
    return domain.AllocationOperationResult(
      allocationId: allocation.id,
      operationId: eventId,
      sequence: sequence,
    );
  }

  Future<void> _validateEffectiveAllocation(
    domain.InvoiceAllocation allocation, {
    required bool wasEffective,
  }) async {
    final payment = await (_database.select(
      _database.paymentIdentities,
    )..where((row) => row.id.equals(allocation.paymentId))).getSingle();
    final invoice = await (_database.select(
      _database.invoices,
    )..where((row) => row.id.equals(allocation.invoiceId))).getSingle();
    final lifecycle = await _latestLifecycleState(invoice.id);
    if (lifecycle != 'active' ||
        invoice.action == 'storage' ||
        invoice.action == 'unknown') {
      throw StateError(
        'Only active sale or purchase invoices can be allocated.',
      );
    }
    final totals = await _allocationTotalsForIdentity(
      paymentId: allocation.paymentId,
      invoiceId: allocation.invoiceId,
    );
    final reversed = await _reversedAmount(allocation.id);
    final effectiveAmount = allocation.amountMinor - reversed;
    final invoicePrior =
        totals.invoiceLocal - (wasEffective ? effectiveAmount : 0);
    final paymentPrior =
        totals.paymentLocal - (wasEffective ? effectiveAmount : 0);
    final invoiceAvailable = (invoice.totalMinor ?? 0) - invoicePrior;
    final paymentAvailable =
        await _recognizedPaymentAmount(payment.id) - paymentPrior;
    if (effectiveAmount > invoiceAvailable) {
      throw AllocationBalanceExceeded(
        entityId: invoice.id,
        requestedMinor: effectiveAmount,
        availableMinor: invoiceAvailable,
      );
    }
    if (effectiveAmount > paymentAvailable) {
      throw AllocationBalanceExceeded(
        entityId: payment.id,
        requestedMinor: effectiveAmount,
        availableMinor: paymentAvailable,
      );
    }
  }

  Future<List<domain.InvoiceAllocation>> _allocationsWithStatuses(
    List<String> statuses, {
    String? paymentId,
    String? invoiceId,
  }) async {
    final vars = <Variable<Object>>[];
    final statusPlaceholders = List.filled(statuses.length, '?').join(', ');
    final conditions = <String>[
      'h.sequence = (SELECT MAX(h2.sequence) '
          'FROM allocation_status_history h2 WHERE h2.allocation_id = a.allocation_id)',
      'h.status IN ($statusPlaceholders)',
    ];
    vars.addAll(statuses.map(Variable.withString));
    if (paymentId != null) {
      conditions.add('a.payment_id = ?');
      vars.add(Variable.withString(paymentId));
    }
    if (invoiceId != null) {
      conditions.add('a.invoice_id = ?');
      vars.add(Variable.withString(invoiceId));
    }
    final rows = await _database
        .customSelect(
          'SELECT a.* FROM invoice_allocations a JOIN allocation_status_history h '
          'ON h.allocation_id = a.allocation_id WHERE ${conditions.join(' AND ')} '
          'ORDER BY a.created_at',
          variables: vars,
          readsFrom: {
            _database.invoiceAllocations,
            _database.allocationStatusHistory,
          },
        )
        .get();
    return rows
        .map((row) => _allocationFromMap(row.data))
        .toList(growable: false);
  }

  Future<int> _allocationTotal(
    String keyColumn,
    String value,
    domain.AllocationProjection projection,
  ) async {
    final confirmed =
        projection == domain.AllocationProjection.globallyConfirmed;
    final statuses = confirmed
        ? "'server_confirmed'"
        : "'provisional', 'server_confirmed', 'conflict_pending'";
    final row = await _database
        .customSelect(
          '''
      SELECT COALESCE(SUM(a.amount_minor - COALESCE((
        SELECT SUM(r.amount_minor) FROM allocation_reversals r
        WHERE r.allocation_id = a.allocation_id
      ), 0)), 0) AS total_minor
      FROM invoice_allocations a
      JOIN allocation_status_history h ON h.allocation_id = a.allocation_id
      WHERE a.$keyColumn = ? AND h.sequence = (
        SELECT MAX(h2.sequence) FROM allocation_status_history h2
        WHERE h2.allocation_id = a.allocation_id
      ) AND h.status IN ($statuses)
      ''',
          variables: [Variable.withString(value)],
          readsFrom: {
            _database.invoiceAllocations,
            _database.allocationReversals,
            _database.allocationStatusHistory,
          },
        )
        .getSingle();
    return row.read<int>('total_minor');
  }

  Future<({int paymentLocal, int invoiceLocal})> _allocationTotalsForIdentity({
    required String paymentId,
    required String invoiceId,
  }) async => (
    paymentLocal: await getPaymentAllocationTotal(paymentId),
    invoiceLocal: await getInvoiceAllocationTotal(invoiceId),
  );

  Future<int> _recognizedPaymentAmount(String paymentId) async {
    final row = await _database
        .customSelect(
          '''
      SELECT v.effective_recognized_minor FROM cash_event_heads h
      JOIN cash_event_versions v ON v.version_id = h.version_id
        AND v.payment_id = h.payment_id AND v.cash_event_id = h.cash_event_id
      WHERE h.payment_id = ?
      ''',
          variables: [Variable.withString(paymentId)],
          readsFrom: {_database.cashEventHeads, _database.cashEventVersions},
        )
        .getSingleOrNull();
    if (row == null) {
      throw StateError('Payment has no current cash-event head.');
    }
    return row.read<int>('effective_recognized_minor');
  }

  Future<int> _reversedAmount(String allocationId) async {
    final row = await _database
        .customSelect(
          'SELECT COALESCE(SUM(amount_minor), 0) AS total_minor '
          'FROM allocation_reversals WHERE allocation_id = ?',
          variables: [Variable.withString(allocationId)],
          readsFrom: {_database.allocationReversals},
        )
        .getSingle();
    return row.read<int>('total_minor');
  }

  Future<int> _reversalSequence(String allocationId, String reversalId) async {
    final rows = await _database
        .customSelect(
          'SELECT allocation_reversal_id FROM allocation_reversals '
          'WHERE allocation_id = ? ORDER BY rowid ASC',
          variables: [Variable.withString(allocationId)],
          readsFrom: {_database.allocationReversals},
        )
        .get();
    final index = rows.indexWhere(
      (row) => row.read<String>('allocation_reversal_id') == reversalId,
    );
    if (index < 0) {
      throw StateError('Allocation reversal was not found after insertion.');
    }
    return index + 1;
  }

  Future<String?> _latestLifecycleState(String invoiceId) async {
    final row =
        await (_database.select(_database.invoiceLifecycleEvents)
              ..where((event) => event.invoiceId.equals(invoiceId))
              ..orderBy([(event) => OrderingTerm.desc(event.sequence)])
              ..limit(1))
            .getSingleOrNull();
    return row?.state;
  }

  Future<_IdempotencyRecord?> _findIdempotencyKey(String key) async {
    final allocation = await (_database.select(
      _database.invoiceAllocations,
    )..where((row) => row.idempotencyKey.equals(key))).getSingleOrNull();
    if (allocation != null) {
      return _IdempotencyRecord(
        allocation.requestFingerprint,
        allocationId: allocation.id,
      );
    }
    final reversal = await (_database.select(
      _database.allocationReversals,
    )..where((row) => row.idempotencyKey.equals(key))).getSingleOrNull();
    if (reversal != null) {
      return _IdempotencyRecord(
        reversal.requestFingerprint,
        allocationId: reversal.allocationId,
        reversalId: reversal.id,
        sequence: await _reversalSequence(reversal.allocationId, reversal.id),
      );
    }
    final status = await (_database.select(
      _database.allocationStatusHistory,
    )..where((row) => row.idempotencyKey.equals(key))).getSingleOrNull();
    if (status != null) {
      return _IdempotencyRecord(
        status.requestFingerprint,
        allocationId: status.allocationId,
        statusEventId: status.id,
        sequence: status.sequence,
      );
    }
    return null;
  }

  void _validateCreateRequest(domain.CreateAllocationRequest request) {
    for (final (value, field) in <(String, String)>[
      (request.paymentId, 'paymentId'),
      (request.invoiceId, 'invoiceId'),
      (request.paymentFinancialAccountId, 'paymentFinancialAccountId'),
      (request.invoiceFinancialAccountId, 'invoiceFinancialAccountId'),
      (request.partyId, 'partyId'),
      (request.partyRole, 'partyRole'),
      (request.currencyCode, 'currencyCode'),
      (request.idempotencyKey, 'idempotencyKey'),
      (request.requestFingerprint, 'requestFingerprint'),
    ]) {
      _validateText(value, field);
    }
    _validateText(request.actorId, 'actorId', optional: true);
    _validateText(request.reason, 'reason', optional: true);
    _validateText(request.originDeviceId, 'originDeviceId', optional: true);
    _validateText(request.conflictGroupId, 'conflictGroupId', optional: true);
    _validatePositive(request.amountMinor, 'amountMinor');
  }

  void _validateIdentityMatch(
    domain.CreateAllocationRequest request,
    PaymentIdentity payment,
    Invoice invoice,
  ) {
    if (request.paymentFinancialAccountId != payment.financialAccountId ||
        request.invoiceFinancialAccountId != invoice.financialAccountId ||
        request.partyId != payment.partyId ||
        request.partyId != invoice.partyId ||
        request.partyRole != payment.partyRole ||
        request.partyRole != invoice.partyRole ||
        request.currencyCode != payment.currencyCode ||
        request.currencyCode != invoice.currencyCode) {
      throw ArgumentError(
        'Allocation payment and invoice identities do not match.',
      );
    }
    final compatible =
        (request.partyRole == 'customer' &&
            payment.financialDirection == 'in' &&
            invoice.action == 'sale') ||
        (request.partyRole == 'supplier' &&
            payment.financialDirection == 'out' &&
            invoice.action == 'purchase');
    if (!compatible) {
      throw ArgumentError(
        'Allocation party role, payment direction, and invoice action are incompatible.',
      );
    }
  }

  String _createFingerprint(domain.CreateAllocationRequest request) =>
      jsonEncode([
        'invoice_allocation',
        request.paymentId,
        request.invoiceId,
        request.paymentFinancialAccountId,
        request.invoiceFinancialAccountId,
        request.partyId,
        request.partyRole,
        request.currencyCode,
        request.amountMinor,
        request.originDeviceId,
        request.conflictGroupId,
        request.actorId,
        request.reason,
        request.requestFingerprint,
      ]);

  bool _isLocalEffective(domain.AllocationStatus status) =>
      status != domain.AllocationStatus.rejected;

  void _checkFingerprint(String existing, String requested, String key) {
    if (existing != requested) throw domain.AllocationIdempotencyConflict(key);
  }

  void _validateText(String? value, String field, {bool optional = false}) {
    if (value == null && optional) return;
    if (value == null || value.trim().isEmpty) {
      throw ArgumentError.value(value, field, 'Must not be empty.');
    }
  }

  void _validatePositive(int value, String field) {
    if (value <= 0) {
      throw ArgumentError.value(value, field, 'Must be positive.');
    }
  }

  domain.InvoiceAllocation _allocationFromRow(InvoiceAllocation row) =>
      domain.InvoiceAllocation(
        id: row.id,
        paymentId: row.paymentId,
        invoiceId: row.invoiceId,
        paymentFinancialAccountId: row.paymentFinancialAccountId,
        invoiceFinancialAccountId: row.invoiceFinancialAccountId,
        partyId: row.partyId,
        partyRole: row.partyRole,
        currencyCode: row.currencyCode,
        amountMinor: row.amountMinor,
        idempotencyKey: row.idempotencyKey,
        requestFingerprint: row.requestFingerprint,
        originDeviceId: row.originDeviceId,
        conflictGroupId: row.conflictGroupId,
        actorId: row.actorId,
        reason: row.reason,
        createdAt: row.createdAt,
      );

  domain.AllocationReversal _reversalFromMap(Map<String, Object?> row) =>
      domain.AllocationReversal(
        id: row['allocation_reversal_id']! as String,
        allocationId: row['allocation_id']! as String,
        amountMinor: row['amount_minor']! as int,
        idempotencyKey: row['idempotency_key']! as String,
        requestFingerprint: row['request_fingerprint']! as String,
        actorId: row['actor_id'] as String?,
        reason: row['reason']! as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (row['created_at']! as int) * 1000,
          isUtc: true,
        ),
      );

  domain.AllocationStatusEvent _statusFromRow(
    AllocationStatusHistoryData row,
  ) => domain.AllocationStatusEvent(
    id: row.id,
    allocationId: row.allocationId,
    sequence: row.sequence,
    status: domain.AllocationStatus.values.firstWhere(
      (status) => status.databaseValue == row.status,
    ),
    previousVersionId: row.previousVersionId,
    idempotencyKey: row.idempotencyKey,
    requestFingerprint: row.requestFingerprint,
    actorId: row.actorId,
    reason: row.reason,
    recordedAt: row.recordedAt,
  );

  domain.InvoiceAllocation _allocationFromMap(
    Map<String, Object?> row,
  ) => domain.InvoiceAllocation(
    id: row['allocation_id']! as String,
    paymentId: row['payment_id']! as String,
    invoiceId: row['invoice_id']! as String,
    paymentFinancialAccountId: row['payment_financial_account_id']! as String,
    invoiceFinancialAccountId: row['invoice_financial_account_id']! as String,
    partyId: row['party_id']! as String,
    partyRole: row['party_role']! as String,
    currencyCode: row['currency_code']! as String,
    amountMinor: row['amount_minor']! as int,
    idempotencyKey: row['idempotency_key']! as String,
    requestFingerprint: row['request_fingerprint']! as String,
    originDeviceId: row['origin_device_id'] as String?,
    conflictGroupId: row['conflict_group_id'] as String?,
    actorId: row['actor_id'] as String?,
    reason: row['reason'] as String?,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (row['created_at']! as int) * 1000,
      isUtc: true,
    ),
  );
}

class _IdempotencyRecord {
  const _IdempotencyRecord(
    this.fingerprint, {
    this.allocationId,
    this.reversalId,
    this.statusEventId,
    this.sequence = 1,
  });

  final String fingerprint;
  final String? allocationId;
  final String? reversalId;
  final String? statusEventId;
  final int sequence;
}
