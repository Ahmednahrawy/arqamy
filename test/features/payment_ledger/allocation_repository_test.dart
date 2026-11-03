import 'dart:io';

import 'package:arqamy/core/database/app_database.dart';
import 'package:arqamy/features/payment_ledger/data/allocation_domain.dart'
    as domain;
import 'package:arqamy/features/payment_ledger/data/allocation_repository.dart';
import 'package:arqamy/features/payment_ledger/data/cash_event_history.dart';
import 'package:arqamy/features/payment_ledger/data/cash_event_repository.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temp;
  late String path;
  late AppDatabase database;
  late LedgerFoundationRepository foundation;
  late CashEventRepository cash;
  late AllocationRepository allocations;
  late String partyId;
  late String paymentAccountId;
  late String invoiceAccountId;
  late CashEventOperationResult payment;
  AppDatabase? secondDatabase;

  Future<void> addInvoice({
    String id = 'invoice-1',
    int totalMinor = 5000,
    String action = 'sale',
    String role = 'customer',
    String accountId = '',
    String invoicePartyId = '',
    String currency = 'EGP',
  }) async {
    final now = DateTime.utc(2026);
    await database
        .into(database.invoices)
        .insert(
          InvoicesCompanion.insert(
            id: id,
            serial: id,
            partyId: Value(invoicePartyId.isEmpty ? partyId : invoicePartyId),
            partyRole: Value(role),
            financialAccountId: Value(
              accountId.isEmpty ? invoiceAccountId : accountId,
            ),
            currencyCode: Value(currency),
            action: action,
            totalMinor: Value(totalMinor),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.invoiceLifecycleEvents)
        .insert(
          InvoiceLifecycleEventsCompanion.insert(
            id: '$id-lifecycle-1',
            invoiceId: id,
            sequence: 1,
            state: 'active',
            idempotencyKey: '$id-lifecycle-key-1',
            requestFingerprint: '$id-lifecycle-fingerprint-1',
            recordedAt: now,
          ),
        );
  }

  domain.CreateAllocationRequest createRequest({
    int amount = 1000,
    String key = 'allocation-key',
    String paymentId = '',
    String invoiceId = 'invoice-1',
    String paymentAccount = '',
    String invoiceAccountOverride = '',
    String party = '',
    String role = 'customer',
    String currency = 'EGP',
    String fingerprint = 'payload-fingerprint',
    String? conflictGroupId,
  }) => domain.CreateAllocationRequest(
    paymentId: paymentId.isEmpty ? payment.paymentId : paymentId,
    invoiceId: invoiceId,
    paymentFinancialAccountId: paymentAccount.isEmpty
        ? paymentAccountId
        : paymentAccount,
    invoiceFinancialAccountId: invoiceAccountOverride.isEmpty
        ? invoiceAccountId
        : invoiceAccountOverride,
    partyId: party.isEmpty ? partyId : party,
    partyRole: role,
    currencyCode: currency,
    amountMinor: amount,
    idempotencyKey: key,
    requestFingerprint: fingerprint,
    conflictGroupId: conflictGroupId,
  );

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('arqamy_allocation_test_');
    path = '${temp.path}${Platform.pathSeparator}ledger.sqlite';
    database = await AppDatabase.open(path: path);
    secondDatabase = null;
    foundation = LedgerFoundationRepository(database);
    cash = CashEventRepository(database);
    allocations = AllocationRepository(database);
    await foundation.addCurrency(
      const LedgerCurrency(
        code: 'EGP',
        minorUnitScale: 2,
        displayName: 'Egyptian pound',
      ),
    );
    final party = await foundation.createParty(displayName: 'Ledger party');
    partyId = party.id;
    await foundation.addPartyRole(
      partyId: partyId,
      role: LedgerPartyRole.customer,
    );
    paymentAccountId = (await foundation.createFinancialAccount(
      partyId: partyId,
      role: LedgerPartyRole.customer,
      currencyCode: 'EGP',
    )).id;
    invoiceAccountId = (await foundation.createFinancialAccount(
      partyId: partyId,
      role: LedgerPartyRole.customer,
      currencyCode: 'EGP',
    )).id;
    payment = await cash.recordPayment(
      RecordPaymentRequest(
        financialAccountId: paymentAccountId,
        partyId: partyId,
        partyRole: 'customer',
        currencyCode: 'EGP',
        financialDirection: LedgerDirection.incoming,
        cashDirection: LedgerDirection.incoming,
        transactionAmountMinor: 10000,
        physicalAmountMinor: 0,
        occurred: PhysicalOccurrence.unknown,
        actorId: 'actor',
        reason: 'test payment',
        idempotencyKey: 'test-payment',
      ),
    );
    await addInvoice();
  });

  tearDown(() async {
    await secondDatabase?.close();
    await database.close();
    await temp.delete(recursive: true);
  });

  test(
    'creates, retries idempotently, and rejects conflicting key reuse',
    () async {
      final request = createRequest(amount: 1200);
      final first = await allocations.createAllocation(request);
      final repeated = await allocations.createAllocation(request);

      expect(repeated.allocationId, first.allocationId);
      expect(
        await allocations.getPaymentAllocationTotal(payment.paymentId),
        1200,
      );
      expect(await allocations.getInvoiceAllocationTotal('invoice-1'), 1200);
      expect(
        (await allocations.getAllocationHistory(
          paymentId: payment.paymentId,
        )).single.invoiceFinancialAccountId,
        invoiceAccountId,
      );
      await expectLater(
        allocations.createAllocation(createRequest(amount: 1300)),
        throwsA(isA<domain.AllocationIdempotencyConflict>()),
      );
    },
  );

  test(
    'enforces available payment and invoice balances and identity matching',
    () async {
      await expectLater(
        allocations.createAllocation(createRequest(amount: 5001)),
        throwsA(isA<AllocationBalanceExceeded>()),
      );
      await allocations.createAllocation(createRequest(amount: 4000));
      await expectLater(
        allocations.createAllocation(
          createRequest(amount: 1500, key: 'over-invoice'),
        ),
        throwsA(isA<AllocationBalanceExceeded>()),
      );
      await expectLater(
        allocations.createAllocation(
          createRequest(key: 'wrong-account', paymentAccount: invoiceAccountId),
        ),
        throwsArgumentError,
      );
      expect(
        await database.select(database.invoiceAllocations).get(),
        hasLength(1),
      );
    },
  );

  test(
    'enforces payment availability independently of invoice capacity',
    () async {
      await addInvoice(id: 'payment-cap-invoice', totalMinor: 20000);
      await allocations.createAllocation(
        createRequest(
          amount: 9000,
          invoiceId: 'payment-cap-invoice',
          key: 'payment-cap-first',
        ),
      );

      await expectLater(
        allocations.createAllocation(
          createRequest(
            amount: 2000,
            invoiceId: 'payment-cap-invoice',
            key: 'payment-cap-second',
          ),
        ),
        throwsA(
          isA<AllocationBalanceExceeded>()
              .having((error) => error.entityId, 'entityId', payment.paymentId)
              .having((error) => error.availableMinor, 'availableMinor', 1000),
        ),
      );
    },
  );

  test('rejects storage and inactive invoices', () async {
    await addInvoice(id: 'storage-invoice', action: 'storage');
    await expectLater(
      allocations.createAllocation(
        createRequest(invoiceId: 'storage-invoice', key: 'storage'),
      ),
      throwsStateError,
    );
    await database
        .into(database.invoiceLifecycleEvents)
        .insert(
          InvoiceLifecycleEventsCompanion.insert(
            id: 'invoice-cancelled',
            invoiceId: 'invoice-1',
            sequence: 2,
            state: 'cancelled',
            previousEventId: const Value('invoice-1-lifecycle-1'),
            idempotencyKey: 'invoice-cancel-key',
            requestFingerprint: 'invoice-cancel-fingerprint',
            recordedAt: DateTime.utc(2026, 1, 2),
          ),
        );
    await expectLater(
      allocations.createAllocation(createRequest(key: 'cancelled')),
      throwsStateError,
    );
  });

  test(
    'reverses partially and fully with stable idempotency and projections',
    () async {
      final created = await allocations.createAllocation(
        createRequest(amount: 2000),
      );
      await allocations.changeStatus(
        domain.ChangeAllocationStatusRequest(
          allocationId: created.allocationId,
          expectedVersionId: created.operationId,
          status: domain.AllocationStatus.serverConfirmed,
          idempotencyKey: 'confirm-before-reversal',
          requestFingerprint: 'confirm-before-reversal-fingerprint',
        ),
      );
      final reversalRepository = AllocationRepository(
        database,
        clock: () => DateTime.utc(2026),
      );
      final partialRequest = domain.ReverseAllocationRequest(
        allocationId: created.allocationId,
        amountMinor: 500,
        reason: 'partial correction',
        idempotencyKey: 'partial-reversal',
        requestFingerprint: 'partial-fingerprint',
      );
      final partial = await reversalRepository.reverseAllocation(
        partialRequest,
      );
      expect(partial.sequence, 1);
      expect(
        await allocations.getPaymentAllocationTotal(payment.paymentId),
        1500,
      );
      expect(await allocations.getInvoiceAllocationTotal('invoice-1'), 1500);
      expect(
        await allocations.getPaymentAllocationTotal(
          payment.paymentId,
          projection: domain.AllocationProjection.globallyConfirmed,
        ),
        1500,
      );
      expect(
        await allocations.getInvoiceAllocationTotal(
          'invoice-1',
          projection: domain.AllocationProjection.globallyConfirmed,
        ),
        1500,
      );
      await expectLater(
        reversalRepository.reverseAllocation(
          domain.ReverseAllocationRequest(
            allocationId: created.allocationId,
            amountMinor: 400,
            reason: 'partial correction',
            idempotencyKey: 'partial-reversal',
            requestFingerprint: 'partial-fingerprint',
          ),
        ),
        throwsA(isA<domain.AllocationIdempotencyConflict>()),
      );
      await expectLater(
        reversalRepository.reverseAllocation(
          domain.ReverseAllocationRequest(
            allocationId: created.allocationId,
            amountMinor: 1600,
            reason: 'too much',
            idempotencyKey: 'over-reversal',
            requestFingerprint: 'over-fingerprint',
          ),
        ),
        throwsA(isA<AllocationReversalLimitExceeded>()),
      );
      final full = await reversalRepository.reverseAllocation(
        domain.ReverseAllocationRequest(
          allocationId: created.allocationId,
          amountMinor: 1500,
          reason: 'full reversal',
          idempotencyKey: 'full-reversal',
          requestFingerprint: 'full-fingerprint',
        ),
      );
      expect(full.sequence, 2);
      expect(await allocations.getPaymentAllocationTotal(payment.paymentId), 0);
      expect(await allocations.getInvoiceAllocationTotal('invoice-1'), 0);
      expect(
        await allocations.getPaymentAllocationTotal(
          payment.paymentId,
          projection: domain.AllocationProjection.globallyConfirmed,
        ),
        0,
      );
      expect(
        await allocations.getInvoiceAllocationTotal(
          'invoice-1',
          projection: domain.AllocationProjection.globallyConfirmed,
        ),
        0,
      );
      expect(
        await allocations.getReversalHistory(created.allocationId),
        hasLength(2),
      );
      final replay = await reversalRepository.reverseAllocation(partialRequest);
      expect(replay.allocationId, partial.allocationId);
      expect(replay.operationId, partial.operationId);
      expect(replay.sequence, partial.sequence);
    },
  );

  test(
    'preserves reversal insertion order when creation timestamps are equal',
    () async {
      final created = await allocations.createAllocation(
        createRequest(amount: 3000),
      );
      final recordedAt = DateTime.utc(2026, 3, 4, 5, 6, 7);
      final reversalRepository = AllocationRepository(
        database,
        clock: () => recordedAt,
      );

      Future<domain.AllocationOperationResult> reverse(
        String key,
        int amount,
      ) => reversalRepository.reverseAllocation(
        domain.ReverseAllocationRequest(
          allocationId: created.allocationId,
          amountMinor: amount,
          reason: 'same-time reversal',
          idempotencyKey: key,
          requestFingerprint: '$key-fingerprint',
        ),
      );

      final first = await reverse('same-time-first', 400);
      final second = await reverse('same-time-second', 500);
      final third = await reverse('same-time-third', 600);

      expect([first.sequence, second.sequence, third.sequence], [1, 2, 3]);
      final history = await allocations.getReversalHistory(
        created.allocationId,
      );
      expect(history.map((reversal) => reversal.id), [
        first.operationId,
        second.operationId,
        third.operationId,
      ]);
      expect(history.map((reversal) => reversal.sequence), [1, 2, 3]);
      expect(history.map((reversal) => reversal.createdAt), [
        recordedAt,
        recordedAt,
        recordedAt,
      ]);

      final replay = await reverse('same-time-first', 400);
      expect(replay.operationId, first.operationId);
      expect(replay.sequence, first.sequence);
      await expectLater(
        reverse('same-time-first', 401),
        throwsA(isA<domain.AllocationIdempotencyConflict>()),
      );
    },
  );

  test(
    'assigns reversal sequences independently for each allocation',
    () async {
      final firstAllocation = await allocations.createAllocation(
        createRequest(amount: 1000, key: 'sequence-allocation-1'),
      );
      final secondAllocation = await allocations.createAllocation(
        createRequest(amount: 1000, key: 'sequence-allocation-2'),
      );

      Future<domain.AllocationOperationResult> reverse(
        String allocationId,
        String key,
      ) => allocations.reverseAllocation(
        domain.ReverseAllocationRequest(
          allocationId: allocationId,
          amountMinor: 100,
          reason: 'sequence test',
          idempotencyKey: key,
          requestFingerprint: '$key-fingerprint',
        ),
      );

      final firstOne = await reverse(firstAllocation.allocationId, 'seq-1-a');
      final firstTwo = await reverse(firstAllocation.allocationId, 'seq-1-b');
      final secondOne = await reverse(secondAllocation.allocationId, 'seq-2-a');

      expect([firstOne.sequence, firstTwo.sequence], [1, 2]);
      expect(secondOne.sequence, 1);
    },
  );

  test('failed reversal transaction does not consume its sequence', () async {
    final created = await allocations.createAllocation(
      createRequest(amount: 1000, key: 'rollback-allocation'),
    );
    final first = await allocations.reverseAllocation(
      domain.ReverseAllocationRequest(
        allocationId: created.allocationId,
        amountMinor: 100,
        reason: 'first reversal',
        idempotencyKey: 'rollback-first',
        requestFingerprint: 'rollback-first-fingerprint',
      ),
    );
    expect(first.sequence, 1);

    await database.customStatement('''
      CREATE TRIGGER allocation_reversals_fail_test
      AFTER INSERT ON allocation_reversals
      WHEN NEW.idempotency_key = 'rollback-failure-key'
      BEGIN
        SELECT RAISE(ABORT, 'deliberate reversal transaction failure');
      END
    ''');
    final retryRequest = domain.ReverseAllocationRequest(
      allocationId: created.allocationId,
      amountMinor: 100,
      reason: 'retry reversal',
      idempotencyKey: 'rollback-failure-key',
      requestFingerprint: 'rollback-failure-fingerprint',
    );
    await expectLater(
      allocations.reverseAllocation(retryRequest),
      throwsA(anything),
    );
    await database.customStatement(
      'DROP TRIGGER allocation_reversals_fail_test',
    );

    final retry = await allocations.reverseAllocation(retryRequest);
    expect(retry.sequence, 2);
    expect(
      (await allocations.getReversalHistory(
        created.allocationId,
      )).map((reversal) => reversal.sequence),
      [1, 2],
    );
  });

  test(
    'VACUUM preserves persisted reversal sequences and history order',
    () async {
      final created = await allocations.createAllocation(
        createRequest(amount: 1000, key: 'vacuum-allocation'),
      );
      for (final key in ['vacuum-reversal-1', 'vacuum-reversal-2']) {
        await allocations.reverseAllocation(
          domain.ReverseAllocationRequest(
            allocationId: created.allocationId,
            amountMinor: 100,
            reason: 'vacuum test',
            idempotencyKey: key,
            requestFingerprint: '$key-fingerprint',
          ),
        );
      }
      final before = await allocations.getReversalHistory(created.allocationId);

      await database.customStatement('VACUUM');

      final after = await allocations.getReversalHistory(created.allocationId);
      expect(
        after.map((reversal) => reversal.id),
        before.map((reversal) => reversal.id),
      );
      expect(after.map((reversal) => reversal.sequence), [1, 2]);
    },
  );

  test('separate database handles assign unique reversal sequences', () async {
    final created = await allocations.createAllocation(
      createRequest(amount: 1000, key: 'concurrent-reversal-allocation'),
    );
    secondDatabase = await AppDatabase.open(path: path);
    final secondRepository = AllocationRepository(secondDatabase!);
    final outcomes = await Future.wait([
      allocations.reverseAllocation(
        domain.ReverseAllocationRequest(
          allocationId: created.allocationId,
          amountMinor: 100,
          reason: 'concurrent reversal',
          idempotencyKey: 'concurrent-reversal-1',
          requestFingerprint: 'concurrent-reversal-1-fingerprint',
        ),
      ),
      secondRepository.reverseAllocation(
        domain.ReverseAllocationRequest(
          allocationId: created.allocationId,
          amountMinor: 100,
          reason: 'concurrent reversal',
          idempotencyKey: 'concurrent-reversal-2',
          requestFingerprint: 'concurrent-reversal-2-fingerprint',
        ),
      ),
    ]);

    expect(outcomes.map((result) => result.sequence).toList()..sort(), [1, 2]);
    final history = await allocations.getReversalHistory(created.allocationId);
    expect(history.map((reversal) => reversal.sequence), [1, 2]);
    expect(history.map((reversal) => reversal.id).toSet(), {
      outcomes[0].operationId,
      outcomes[1].operationId,
    });
  });

  test('tracks all statuses in append-only history and projections', () async {
    final created = await allocations.createAllocation(
      createRequest(amount: 1000, conflictGroupId: 'group-1'),
    );
    expect(
      await allocations.getPaymentAllocationTotal(payment.paymentId),
      1000,
    );
    expect(
      await allocations.getPaymentAllocationTotal(
        payment.paymentId,
        projection: domain.AllocationProjection.globallyConfirmed,
      ),
      0,
    );
    expect(await allocations.getInvoiceAllocationTotal('invoice-1'), 1000);
    expect(
      await allocations.getInvoiceAllocationTotal(
        'invoice-1',
        projection: domain.AllocationProjection.globallyConfirmed,
      ),
      0,
    );
    expect(await allocations.getUnresolvedAllocations(), hasLength(1));

    var version = created.operationId;
    for (final (index, status) in [
      domain.AllocationStatus.serverConfirmed,
      domain.AllocationStatus.rejected,
      domain.AllocationStatus.conflictPending,
    ].indexed) {
      final result = await allocations.changeStatus(
        domain.ChangeAllocationStatusRequest(
          allocationId: created.allocationId,
          expectedVersionId: version,
          status: status,
          idempotencyKey: 'status-$index',
          requestFingerprint: 'status-fingerprint-$index',
        ),
      );
      version = result.operationId;
      final expectedLocal = status == domain.AllocationStatus.rejected
          ? 0
          : 1000;
      final expectedGlobal = status == domain.AllocationStatus.serverConfirmed
          ? 1000
          : 0;
      expect(
        await allocations.getPaymentAllocationTotal(payment.paymentId),
        expectedLocal,
      );
      expect(
        await allocations.getInvoiceAllocationTotal('invoice-1'),
        expectedLocal,
      );
      expect(
        await allocations.getPaymentAllocationTotal(
          payment.paymentId,
          projection: domain.AllocationProjection.globallyConfirmed,
        ),
        expectedGlobal,
      );
      expect(
        await allocations.getInvoiceAllocationTotal(
          'invoice-1',
          projection: domain.AllocationProjection.globallyConfirmed,
        ),
        expectedGlobal,
      );
    }
    expect(
      (await allocations.getStatusHistory(
        created.allocationId,
      )).map((e) => e.status),
      [
        domain.AllocationStatus.provisional,
        domain.AllocationStatus.serverConfirmed,
        domain.AllocationStatus.rejected,
        domain.AllocationStatus.conflictPending,
      ],
    );
    expect(
      await allocations.getPaymentAllocationTotal(payment.paymentId),
      1000,
    );
    expect(
      await allocations.getPaymentAllocationTotal(
        payment.paymentId,
        projection: domain.AllocationProjection.globallyConfirmed,
      ),
      0,
    );
    expect(await allocations.getConflictingAllocations(), hasLength(1));
    expect(
      await allocations.getConflictingAllocations(conflictGroupId: 'other'),
      isEmpty,
    );
  });

  test(
    'rejects stale status heads and revalidates a rejected allocation',
    () async {
      final first = await allocations.createAllocation(
        createRequest(amount: 3000),
      );
      await allocations.changeStatus(
        domain.ChangeAllocationStatusRequest(
          allocationId: first.allocationId,
          expectedVersionId: first.operationId,
          status: domain.AllocationStatus.rejected,
          idempotencyKey: 'reject-first',
          requestFingerprint: 'reject-first-fingerprint',
        ),
      );
      await allocations.createAllocation(
        createRequest(amount: 3000, key: 'second'),
      );
      await expectLater(
        allocations.changeStatus(
          domain.ChangeAllocationStatusRequest(
            allocationId: first.allocationId,
            expectedVersionId: first.operationId,
            status: domain.AllocationStatus.provisional,
            idempotencyKey: 'stale-status',
            requestFingerprint: 'stale-fingerprint',
          ),
        ),
        throwsA(isA<domain.StaleAllocationStatus>()),
      );
      final latest = (await allocations.getStatusHistory(
        first.allocationId,
      )).last;
      await expectLater(
        allocations.changeStatus(
          domain.ChangeAllocationStatusRequest(
            allocationId: first.allocationId,
            expectedVersionId: latest.id,
            status: domain.AllocationStatus.provisional,
            idempotencyKey: 'reactivate-first',
            requestFingerprint: 'reactivate-fingerprint',
          ),
        ),
        throwsA(isA<AllocationBalanceExceeded>()),
      );
      expect(
        (await allocations.getStatusHistory(first.allocationId)).last.status,
        domain.AllocationStatus.rejected,
      );
    },
  );

  test('separate database handles cannot over-allocate concurrently', () async {
    secondDatabase = await AppDatabase.open(path: path);
    final secondRepository = AllocationRepository(secondDatabase!);
    final outcomes = await Future.wait<Object>([
      _capture(
        allocations.createAllocation(
          createRequest(amount: 3000, key: 'concurrent-a'),
        ),
      ),
      _capture(
        secondRepository.createAllocation(
          createRequest(amount: 3000, key: 'concurrent-b'),
        ),
      ),
    ]);
    expect(
      outcomes.whereType<domain.AllocationOperationResult>(),
      hasLength(1),
      reason: '$outcomes',
    );
    expect(
      outcomes.whereType<AllocationBalanceExceeded>(),
      hasLength(1),
      reason: '$outcomes',
    );
    expect(
      await database.select(database.invoiceAllocations).get(),
      hasLength(1),
    );
  });

  test(
    'separate database handles cannot over-allocate payment availability',
    () async {
      await addInvoice(id: 'payment-race-invoice', totalMinor: 20000);
      secondDatabase = await AppDatabase.open(path: path);
      final secondRepository = AllocationRepository(secondDatabase!);
      final outcomes = await Future.wait<Object>([
        _capture(
          allocations.createAllocation(
            createRequest(
              amount: 6000,
              invoiceId: 'payment-race-invoice',
              key: 'payment-race-a',
            ),
          ),
        ),
        _capture(
          secondRepository.createAllocation(
            createRequest(
              amount: 6000,
              invoiceId: 'payment-race-invoice',
              key: 'payment-race-b',
            ),
          ),
        ),
      ]);
      expect(
        outcomes.whereType<domain.AllocationOperationResult>(),
        hasLength(1),
        reason: '$outcomes',
      );
      final failures = outcomes.whereType<AllocationBalanceExceeded>();
      expect(failures, hasLength(1), reason: '$outcomes');
      expect(failures.single.entityId, payment.paymentId);
      expect(
        await allocations.getPaymentAllocationTotal(payment.paymentId),
        6000,
      );
      expect(
        await allocations.getInvoiceAllocationTotal('payment-race-invoice'),
        6000,
      );
    },
  );

  test('validates supplier payments against purchase invoices', () async {
    final supplier = await foundation.createParty(
      displayName: 'Ledger supplier',
    );
    await foundation.addPartyRole(
      partyId: supplier.id,
      role: LedgerPartyRole.supplier,
    );
    final supplierPaymentAccount = await foundation.createFinancialAccount(
      partyId: supplier.id,
      role: LedgerPartyRole.supplier,
      currencyCode: 'EGP',
    );
    final supplierInvoiceAccount = await foundation.createFinancialAccount(
      partyId: supplier.id,
      role: LedgerPartyRole.supplier,
      currencyCode: 'EGP',
    );
    final supplierPayment = await cash.recordPayment(
      RecordPaymentRequest(
        financialAccountId: supplierPaymentAccount.id,
        partyId: supplier.id,
        partyRole: 'supplier',
        currencyCode: 'EGP',
        financialDirection: LedgerDirection.outgoing,
        cashDirection: LedgerDirection.outgoing,
        transactionAmountMinor: 3000,
        physicalAmountMinor: 3000,
        occurred: PhysicalOccurrence.yes,
        actorId: 'actor',
        reason: 'supplier payment',
        idempotencyKey: 'supplier-payment',
      ),
    );
    await addInvoice(
      id: 'supplier-purchase',
      totalMinor: 3000,
      action: 'purchase',
      role: 'supplier',
      accountId: supplierInvoiceAccount.id,
      invoicePartyId: supplier.id,
    );

    final result = await allocations.createAllocation(
      domain.CreateAllocationRequest(
        paymentId: supplierPayment.paymentId,
        invoiceId: 'supplier-purchase',
        paymentFinancialAccountId: supplierPaymentAccount.id,
        invoiceFinancialAccountId: supplierInvoiceAccount.id,
        partyId: supplier.id,
        partyRole: 'supplier',
        currencyCode: 'EGP',
        amountMinor: 2000,
        idempotencyKey: 'supplier-purchase-allocation',
        requestFingerprint: 'supplier-purchase-fingerprint',
      ),
    );
    expect(result.allocationId, isNotEmpty);
    expect(
      await allocations.getPaymentAllocationTotal(supplierPayment.paymentId),
      2000,
    );
    expect(
      await allocations.getInvoiceAllocationTotal('supplier-purchase'),
      2000,
    );

    await addInvoice(
      id: 'supplier-sale-invalid',
      totalMinor: 3000,
      action: 'sale',
      role: 'supplier',
      accountId: supplierInvoiceAccount.id,
      invoicePartyId: supplier.id,
    );
    await expectLater(
      allocations.createAllocation(
        domain.CreateAllocationRequest(
          paymentId: supplierPayment.paymentId,
          invoiceId: 'supplier-sale-invalid',
          paymentFinancialAccountId: supplierPaymentAccount.id,
          invoiceFinancialAccountId: supplierInvoiceAccount.id,
          partyId: supplier.id,
          partyRole: 'supplier',
          currencyCode: 'EGP',
          amountMinor: 1000,
          idempotencyKey: 'supplier-sale-invalid-allocation',
          requestFingerprint: 'supplier-sale-invalid-fingerprint',
        ),
      ),
      throwsArgumentError,
    );
  });

  test(
    'all Stage 3 recognition reductions enforce the local allocation floor',
    () async {
      final created = await allocations.createAllocation(
        createRequest(amount: 1000),
      );
      final request = ReversePaymentRequest(
        paymentId: payment.paymentId,
        expectedVersionId: payment.versionId,
        actorId: 'actor',
        reason: 'reduce payment recognition',
        idempotencyKey: 'reduce-recognition',
      );

      await expectLater(
        cash.correctPayment(
          CorrectPaymentRequest(
            paymentId: payment.paymentId,
            expectedVersionId: payment.versionId,
            replacementAmountMinor: 500,
            physicalAmountMinor: 500,
            occurred: PhysicalOccurrence.yes,
            actorId: 'actor',
            reason: 'lower amount',
            idempotencyKey: 'guard-correction',
          ),
        ),
        throwsA(isA<AllocationRecognitionLimitExceeded>()),
      );
      await expectLater(
        cash.reverseWithoutCashReturn(request),
        throwsA(isA<AllocationRecognitionLimitExceeded>()),
      );
      await expectLater(
        cash.voidNeverOccurred(
          VoidPaymentRequest(
            paymentId: payment.paymentId,
            expectedVersionId: payment.versionId,
            actorId: 'actor',
            reason: 'never occurred',
            idempotencyKey: 'guard-void',
          ),
        ),
        throwsA(isA<AllocationRecognitionLimitExceeded>()),
      );
      await expectLater(
        cash.resolveUnknownPhysicalStatus(
          paymentId: payment.paymentId,
          expectedVersionId: payment.versionId,
          occurred: PhysicalOccurrence.no,
          physicalAmountMinor: 0,
          actorId: 'actor',
          reason: 'cash did not occur',
          idempotencyKey: 'guard-resolve',
        ),
        throwsA(isA<AllocationRecognitionLimitExceeded>()),
      );
      await expectLater(
        cash.recordIndependentPaymentAfterReversal(
          reversal: ReversePaymentRequest(
            paymentId: payment.paymentId,
            expectedVersionId: payment.versionId,
            actorId: 'actor',
            reason: 'method B reversal',
            idempotencyKey: 'guard-method-b-reversal',
          ),
          replacement: RecordPaymentRequest(
            financialAccountId: paymentAccountId,
            partyId: partyId,
            partyRole: 'customer',
            currencyCode: 'EGP',
            financialDirection: LedgerDirection.incoming,
            cashDirection: LedgerDirection.incoming,
            transactionAmountMinor: 7000,
            physicalAmountMinor: 7000,
            occurred: PhysicalOccurrence.yes,
            actorId: 'actor',
            reason: 'method B replacement',
            idempotencyKey: 'guard-method-b-payment',
          ),
        ),
        throwsA(isA<AllocationRecognitionLimitExceeded>()),
      );
      expect(
        (await allocations.getStatusHistory(created.allocationId)).length,
        1,
      );
      expect(
        await database.select(database.paymentIdentities).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.cashEventHeads).get(),
        hasLength(1),
      );
    },
  );
}

Future<Object> _capture(Future<Object> operation) async {
  try {
    return await operation;
  } catch (error) {
    return error;
  }
}
