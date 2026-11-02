import 'dart:io';

import 'package:arqamy/core/database/app_database.dart';
import 'package:arqamy/features/payment_ledger/data/cash_event_history.dart';
import 'package:arqamy/features/payment_ledger/data/cash_event_repository.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;
  AppDatabase? secondaryDatabase;
  late LedgerFoundationRepository foundation;
  late CashEventRepository repository;
  late String partyId;
  late String accountId;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'arqamy_cash_event_test_',
    );
    databasePath =
        '${temporaryDirectory.path}${Platform.pathSeparator}ledger.sqlite';
    database = await AppDatabase.open(path: databasePath);
    secondaryDatabase = null;
    foundation = LedgerFoundationRepository(database);
    repository = CashEventRepository(database);
    await foundation.addCurrency(
      const LedgerCurrency(
        code: 'EGP',
        minorUnitScale: 2,
        displayName: 'Egyptian pound',
      ),
    );
    final party = await foundation.createParty(displayName: 'Test party');
    partyId = party.id;
    await foundation.addPartyRole(
      partyId: partyId,
      role: LedgerPartyRole.customer,
    );
    final account = await foundation.createFinancialAccount(
      partyId: partyId,
      role: LedgerPartyRole.customer,
      currencyCode: 'EGP',
    );
    accountId = account.id;
  });

  tearDown(() async {
    await secondaryDatabase?.close();
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test(
    'Method A corrects 1,000 recorded to actual 800 without double counting',
    () async {
      final payment = await _record(
        repository,
        accountId: accountId,
        partyId: partyId,
        amount: 100000,
        physicalAmount: 80000,
        key: 'method-a-down',
      );

      final corrected = await repository.correctPayment(
        CorrectPaymentRequest(
          paymentId: payment.paymentId,
          expectedVersionId: payment.versionId,
          replacementAmountMinor: 80000,
          physicalAmountMinor: 80000,
          occurred: PhysicalOccurrence.yes,
          actorId: 'actor-1',
          reason: 'Correct recorded amount to verified cash',
          idempotencyKey: 'method-a-down-correction',
        ),
      );

      final transactions = await _transactionsFor(database, payment.paymentId);
      final versions = await _versionsFor(database, payment.cashEventId);
      final head = await _head(database, payment.cashEventId);
      expect(transactions.map((row) => row.transactionType), [
        'payment',
        'payment_reversal',
        'replacement',
      ]);
      expect(transactions.map((row) => row.amountMinor), [
        100000,
        100000,
        80000,
      ]);
      expect(transactions[1].direction, 'out');
      expect(versions, hasLength(2));
      expect(versions.last.effectiveRecognizedMinor, 80000);
      expect(versions.last.physicalAmountMinor, 80000);
      expect(head.versionId, corrected.versionId);
      expect(
        (await repository.getPhysicalCashReport()).single.cashInMinor,
        80000,
      );
      expect(
        (await repository.getEffectiveRecognitionReport()).single.amountMinor,
        80000,
      );
    },
  );

  test(
    'separate handles serialize competing event updates without forking history',
    () async {
      final payment = await _record(
        repository,
        accountId: accountId,
        partyId: partyId,
        amount: 10000,
        physicalAmount: 10000,
        key: 'separate-handle-event',
      );
      secondaryDatabase = await AppDatabase.open(path: databasePath);
      final secondRepository = CashEventRepository(secondaryDatabase!);
      final firstRequest = _correctionRequest(
        payment,
        amount: 9000,
        key: 'separate-handle-correction-a',
      );
      final secondRequest = _correctionRequest(
        payment,
        amount: 8000,
        key: 'separate-handle-correction-b',
      );
      final outcomes = await Future.wait<Object>([
        _captureOutcome(repository.correctPayment(firstRequest)),
        _captureOutcome(secondRepository.correctPayment(secondRequest)),
      ]);

      expect(
        outcomes.whereType<CashEventOperationResult>(),
        hasLength(1),
        reason: 'Outcomes: $outcomes',
      );
      final failures = outcomes.where(
        (outcome) => outcome is! CashEventOperationResult,
      );
      expect(failures, hasLength(1), reason: 'Outcomes: $outcomes');
      expect(
        failures.single,
        isA<StaleCashEventHead>(),
        reason: 'The retry must surface the stale expected head: $failures',
      );
      expect(await _versionsFor(database, payment.cashEventId), hasLength(2));
      final head = await _head(database, payment.cashEventId);
      final latestVersion = await (database.select(
        database.cashEventVersions,
      )..where((row) => row.id.equals(head.versionId))).getSingle();
      expect(latestVersion.sequence, 2);
      expect(head.revision, 2);
    },
  );

  test(
    'separate handles cannot resolve more suspense than remains available',
    () async {
      final payment = await _record(
        repository,
        accountId: accountId,
        partyId: partyId,
        amount: 10000,
        physicalAmount: 10000,
        key: 'separate-handle-suspense-payment',
      );
      final caseId = await repository.createSuspenseCase(
        SuspenseCaseRequest(
          paymentId: payment.paymentId,
          amountMinor: 10000,
          actorId: 'actor-1',
          reason: 'Concurrent resolution test',
          idempotencyKey: 'separate-handle-suspense-create',
        ),
      );
      secondaryDatabase = await AppDatabase.open(path: databasePath);
      final secondRepository = CashEventRepository(secondaryDatabase!);
      final outcomes = await Future.wait<Object>([
        _captureOutcome(
          repository.resolveSuspense(
            _resolutionRequest(caseId, amount: 7000, key: 'resolution-a'),
          ),
        ),
        _captureOutcome(
          secondRepository.resolveSuspense(
            _resolutionRequest(caseId, amount: 6000, key: 'resolution-b'),
          ),
        ),
      ]);

      final resolutions = await database
          .select(database.suspenseResolutions)
          .get();
      final resolvedTotal = resolutions.fold<int>(
        0,
        (total, row) => total + row.amountMinor,
      );
      final balance = await repository.getSuspenseBalance(caseId);
      expect(resolvedTotal, lessThanOrEqualTo(10000), reason: '$outcomes');
      expect(balance, greaterThanOrEqualTo(0), reason: '$outcomes');
      expect(resolvedTotal + balance, 10000);
      expect(outcomes.whereType<String>(), hasLength(resolutions.length));
      final failures = outcomes.where((outcome) => outcome is! String);
      expect(failures, hasLength(1), reason: 'Outcomes: $outcomes');
      expect(
        failures.single,
        isA<SuspenseLimitExceeded>(),
        reason: 'The retry must recheck the available suspense balance.',
      );
      expect(resolutions, isNotEmpty);
    },
  );

  test(
    'separate handles return one logical result for concurrent idempotent payment requests',
    () async {
      secondaryDatabase = await AppDatabase.open(path: databasePath);
      final secondRepository = CashEventRepository(secondaryDatabase!);
      final request = _paymentRequest(
        accountId: accountId,
        partyId: partyId,
        amount: 10000,
        physicalAmount: 10000,
        key: 'separate-handle-idempotent-payment',
      );
      final outcomes = await Future.wait<Object>([
        _captureOutcome(repository.recordPayment(request)),
        _captureOutcome(secondRepository.recordPayment(request)),
      ]);

      expect(
        outcomes.whereType<CashEventOperationResult>(),
        hasLength(2),
        reason: 'Concurrent retry outcomes: $outcomes',
      );
      final results = outcomes.whereType<CashEventOperationResult>().toList();
      expect(results[0].paymentId, results[1].paymentId);
      expect(results[0].cashEventId, results[1].cashEventId);
      expect(results[0].versionId, results[1].versionId);
      expect(
        await database.select(database.paymentIdentities).get(),
        hasLength(1),
      );
      expect(await database.select(database.cashEvents).get(), hasLength(1));
      expect(
        await database.select(database.cashEventVersions).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.financialTransactions).get(),
        hasLength(1),
      );
    },
  );

  test('Method A corrects 800 recorded to actual 1,000', () async {
    final payment = await _record(
      repository,
      accountId: accountId,
      partyId: partyId,
      amount: 80000,
      physicalAmount: 100000,
      key: 'method-a-up',
    );
    await repository.correctPayment(
      CorrectPaymentRequest(
        paymentId: payment.paymentId,
        expectedVersionId: payment.versionId,
        replacementAmountMinor: 100000,
        physicalAmountMinor: 100000,
        occurred: PhysicalOccurrence.yes,
        actorId: 'actor-1',
        reason: 'Correct to verified amount',
        idempotencyKey: 'method-a-up-correction',
      ),
    );

    expect(
      (await repository.getPhysicalCashReport()).single.cashInMinor,
      100000,
    );
    expect(
      (await repository.getEffectiveRecognitionReport()).single.amountMinor,
      100000,
    );
    expect(
      (await _transactionsFor(
        database,
        payment.paymentId,
      )).map((row) => row.amountMinor),
      [80000, 80000, 100000],
    );
  });

  test(
    'Method A correction to zero sends remaining physical cash to suspense',
    () async {
      final payment = await _record(
        repository,
        accountId: accountId,
        partyId: partyId,
        amount: 80000,
        physicalAmount: 80000,
        key: 'method-a-zero',
      );
      final corrected = await repository.correctPayment(
        CorrectPaymentRequest(
          paymentId: payment.paymentId,
          expectedVersionId: payment.versionId,
          replacementAmountMinor: 0,
          physicalAmountMinor: 80000,
          occurred: PhysicalOccurrence.yes,
          actorId: 'actor-1',
          reason: 'Remove recognition while cash remains',
          idempotencyKey: 'method-a-zero-correction',
        ),
      );

      expect(corrected.reconciliationCaseId, isA<String>());
      expect(
        await repository.getSuspenseBalance(corrected.reconciliationCaseId!),
        80000,
      );
      expect(
        (await repository.getPhysicalCashReport()).single.cashInMinor,
        80000,
      );
      expect(
        (await repository.getEffectiveRecognitionReport()).single.amountMinor,
        0,
      );
    },
  );

  test(
    'Method B reverses old recognition into suspense and records new event',
    () async {
      final oldPayment = await _record(
        repository,
        accountId: accountId,
        partyId: partyId,
        amount: 80000,
        physicalAmount: 80000,
        key: 'method-b-old-payment',
      );
      final reverse = ReversePaymentRequest(
        paymentId: oldPayment.paymentId,
        expectedVersionId: oldPayment.versionId,
        actorId: 'actor-1',
        reason: 'Old cash remains but recognition is replaced',
        idempotencyKey: 'method-b-old-reversal',
      );
      final newPayment = _paymentRequest(
        accountId: accountId,
        partyId: partyId,
        amount: 100000,
        physicalAmount: 100000,
        key: 'method-b-new-payment',
      );
      final result = await repository.recordIndependentPaymentAfterReversal(
        reversal: reverse,
        replacement: newPayment,
      );
      final retried = await repository.recordIndependentPaymentAfterReversal(
        reversal: reverse,
        replacement: newPayment,
      );

      expect(result.paymentId, isNot(oldPayment.paymentId));
      expect(result.cashEventId, isNot(oldPayment.cashEventId));
      expect(retried.paymentId, result.paymentId);
      expect(
        await _suspenseBalanceFor(database, repository, oldPayment.cashEventId),
        80000,
      );
      expect(
        (await repository.getPhysicalCashReport()).single.cashInMinor,
        180000,
      );
      expect(
        (await repository.getEffectiveRecognitionReport()).single.amountMinor,
        100000,
      );
      expect(
        await database.select(database.paymentIdentities).get(),
        hasLength(2),
      );
      expect(await database.select(database.cashEvents).get(), hasLength(2));
    },
  );

  test(
    'Method B rolls back both events when the replacement is invalid',
    () async {
      final oldPayment = await _record(
        repository,
        accountId: accountId,
        partyId: partyId,
        amount: 80000,
        physicalAmount: 80000,
        key: 'method-b-rollback-old',
      );
      final originalVersion = oldPayment.versionId;

      await expectLater(
        repository.recordIndependentPaymentAfterReversal(
          reversal: ReversePaymentRequest(
            paymentId: oldPayment.paymentId,
            expectedVersionId: originalVersion,
            actorId: 'actor-1',
            reason: 'Method B rollback test',
            idempotencyKey: 'method-b-rollback-reversal',
          ),
          replacement: _paymentRequest(
            accountId: accountId,
            partyId: 'missing-party',
            amount: 90000,
            physicalAmount: 90000,
            key: 'method-b-rollback-replacement',
          ),
        ),
        throwsA(anything),
      );

      expect(
        (await _head(database, oldPayment.cashEventId)).versionId,
        originalVersion,
      );
      expect(
        await _versionsFor(database, oldPayment.cashEventId),
        hasLength(1),
      );
      expect(
        await database.select(database.paymentIdentities).get(),
        hasLength(1),
      );
      expect(await database.select(database.cashEvents).get(), hasLength(1));
      expect(
        await database.select(database.financialTransactions).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.reconciliationCases).get(),
        isEmpty,
      );
    },
  );

  test(
    'never-occurred event keeps history and has a zero replacement',
    () async {
      final payment = await _record(
        repository,
        accountId: accountId,
        partyId: partyId,
        amount: 25000,
        physicalAmount: 0,
        occurred: PhysicalOccurrence.unknown,
        key: 'void-original',
      );
      final voided = await repository.voidNeverOccurred(
        VoidPaymentRequest(
          paymentId: payment.paymentId,
          expectedVersionId: payment.versionId,
          actorId: 'actor-1',
          reason: 'Confirmed no physical event occurred',
          idempotencyKey: 'void-event',
        ),
      );

      final transactions = await _transactionsFor(database, payment.paymentId);
      final versions = await _versionsFor(database, payment.cashEventId);
      expect(transactions.map((row) => row.transactionType), [
        'payment',
        'payment_reversal',
        'replacement',
      ]);
      expect(transactions.last.amountMinor, 0);
      expect(versions, hasLength(2));
      expect(versions.last.operation, 'void');
      expect(versions.last.occurred, 'no');
      expect(versions.last.effectiveRecognizedMinor, 0);
      expect((await repository.getPhysicalCashReport()).single.cashInMinor, 0);
      expect(
        (await repository.getEffectiveRecognitionReport()).single.amountMinor,
        0,
      );
      expect(
        (await _head(database, payment.cashEventId)).versionId,
        voided.versionId,
      );
    },
  );

  test('resolution cap, idempotency, and immutable suspense history', () async {
    final payment = await _record(
      repository,
      accountId: accountId,
      partyId: partyId,
      amount: 80000,
      physicalAmount: 80000,
      key: 'suspense-original',
    );
    final reversed = await repository.reverseWithoutCashReturn(
      ReversePaymentRequest(
        paymentId: payment.paymentId,
        expectedVersionId: payment.versionId,
        actorId: 'actor-1',
        reason: 'Financial recognition reversed, cash not returned',
        idempotencyKey: 'suspense-reversal',
      ),
    );
    final caseId = reversed.reconciliationCaseId!;
    expect(await repository.getSuspenseBalance(caseId), 80000);

    final tooLarge = ResolveSuspenseRequest(
      caseId: caseId,
      amountMinor: 80001,
      actorId: 'actor-1',
      authorizedByActorId: 'approver-1',
      authorizationReference: 'approval-1',
      reason: 'Resolve verified portion',
      idempotencyKey: 'resolution-too-large',
    );
    await expectLater(
      repository.resolveSuspense(tooLarge),
      throwsA(isA<SuspenseLimitExceeded>()),
    );
    expect(await repository.getSuspenseBalance(caseId), 80000);

    final partial = ResolveSuspenseRequest(
      caseId: caseId,
      amountMinor: 30000,
      actorId: 'actor-1',
      authorizedByActorId: 'approver-1',
      authorizationReference: 'approval-2',
      reason: 'Resolve verified portion',
      idempotencyKey: 'resolution-partial',
    );
    final resolutionId = await repository.resolveSuspense(partial);
    expect(await repository.resolveSuspense(partial), resolutionId);
    expect(await repository.getSuspenseBalance(caseId), 50000);
    expect(
      await database.select(database.suspenseResolutions).get(),
      hasLength(1),
    );
    expect(await database.select(database.suspenseEntries).get(), hasLength(2));

    await expectLater(
      database.customStatement(
        'UPDATE suspense_resolutions SET reason = ? WHERE resolution_id = ?',
        ['changed', resolutionId],
      ),
      throwsA(anything),
    );
    await expectLater(
      database.customStatement(
        'DELETE FROM suspense_entries WHERE case_id = ?',
        [caseId],
      ),
      throwsA(anything),
    );
  });

  test(
    'suspense increases and decreases are append-only and bounded',
    () async {
      final payment = await _record(
        repository,
        accountId: accountId,
        partyId: partyId,
        amount: 50000,
        physicalAmount: 50000,
        key: 'manual-suspense',
      );
      final caseId = await repository.createSuspenseCase(
        SuspenseCaseRequest(
          paymentId: payment.paymentId,
          amountMinor: 10000,
          actorId: 'actor-1',
          reason: 'Initial unidentified cash',
          idempotencyKey: 'manual-suspense-create',
        ),
      );
      await repository.increaseSuspense(
        SuspenseMovementRequest(
          caseId: caseId,
          amountMinor: 5000,
          actorId: 'actor-1',
          reason: 'Additional unidentified cash',
          idempotencyKey: 'manual-suspense-increase',
        ),
      );
      expect(await repository.getSuspenseBalance(caseId), 15000);

      await repository.decreaseSuspense(
        SuspenseMovementRequest(
          caseId: caseId,
          amountMinor: 4000,
          actorId: 'actor-1',
          reason: 'Cash verified',
          idempotencyKey: 'manual-suspense-decrease',
        ),
      );
      expect(await repository.getSuspenseBalance(caseId), 11000);
      await expectLater(
        repository.decreaseSuspense(
          SuspenseMovementRequest(
            caseId: caseId,
            amountMinor: 11001,
            actorId: 'actor-1',
            reason: 'Exceeds remaining balance',
            idempotencyKey: 'manual-suspense-over-decrease',
          ),
        ),
        throwsA(isA<SuspenseLimitExceeded>()),
      );
      expect(await repository.getSuspenseBalance(caseId), 11000);
      expect(
        await database.select(database.suspenseEntries).get(),
        hasLength(3),
      );
    },
  );

  test('full reversal reuses the event suspense case', () async {
    final payment = await _record(
      repository,
      accountId: accountId,
      partyId: partyId,
      amount: 80000,
      physicalAmount: 80000,
      key: 'existing-event-suspense',
    );
    final existingCaseId = await repository.createSuspenseCase(
      SuspenseCaseRequest(
        paymentId: payment.paymentId,
        amountMinor: 10000,
        actorId: 'actor-1',
        reason: 'Existing reconciliation issue',
        idempotencyKey: 'existing-event-suspense-case',
      ),
    );

    final reversed = await repository.reverseWithoutCashReturn(
      ReversePaymentRequest(
        paymentId: payment.paymentId,
        expectedVersionId: payment.versionId,
        actorId: 'actor-1',
        reason: 'Reverse while cash remains',
        idempotencyKey: 'existing-event-suspense-reversal',
      ),
    );

    expect(reversed.reconciliationCaseId, existingCaseId);
    expect(await repository.getSuspenseBalance(existingCaseId), 80000);
    expect(
      await database.select(database.reconciliationCases).get(),
      hasLength(1),
    );
  });

  test(
    'unknown physical movement is pending until resolved, then counted once',
    () async {
      final payment = await _record(
        repository,
        accountId: accountId,
        partyId: partyId,
        amount: 40000,
        physicalAmount: 40000,
        occurred: PhysicalOccurrence.unknown,
        key: 'unknown-payment',
      );
      final pending = (await repository.getPhysicalCashReport()).single;
      expect(pending.cashInMinor, 0);
      expect(pending.pendingUnknownMinor, 40000);
      expect(pending.pendingUnknownEvents, 1);

      final resolved = await repository.resolveUnknownPhysicalStatus(
        paymentId: payment.paymentId,
        expectedVersionId: payment.versionId,
        occurred: PhysicalOccurrence.yes,
        physicalAmountMinor: 40000,
        actorId: 'actor-1',
        reason: 'Receipt verified',
        idempotencyKey: 'unknown-resolved',
      );
      final report = (await repository.getPhysicalCashReport()).single;
      expect(report.cashInMinor, 40000);
      expect(report.pendingUnknownMinor, 0);
      expect(report.pendingUnknownEvents, 0);
      expect(await _versionsFor(database, payment.cashEventId), hasLength(2));
      expect(
        (await _head(database, payment.cashEventId)).versionId,
        resolved.versionId,
      );
      expect(await _transactionsFor(database, payment.paymentId), hasLength(1));
    },
  );

  test(
    'duplicate requests are idempotent and changed payloads conflict',
    () async {
      final request = _paymentRequest(
        accountId: accountId,
        partyId: partyId,
        amount: 10000,
        physicalAmount: 10000,
        key: 'same-payment-request',
      );
      final first = await repository.recordPayment(request);
      final repeated = await repository.recordPayment(request);
      expect(repeated.paymentId, first.paymentId);
      expect(
        await database.select(database.paymentIdentities).get(),
        hasLength(1),
      );

      final changed = _paymentRequest(
        accountId: accountId,
        partyId: partyId,
        amount: 10001,
        physicalAmount: 10000,
        key: 'same-payment-request',
      );
      await expectLater(
        repository.recordPayment(changed),
        throwsA(isA<IdempotencyConflict>()),
      );
      expect(
        await database.select(database.cashEventVersions).get(),
        hasLength(1),
      );
    },
  );

  test(
    'concurrent duplicate requests and stale head updates cannot fork history',
    () async {
      final request = _paymentRequest(
        accountId: accountId,
        partyId: partyId,
        amount: 10000,
        physicalAmount: 10000,
        key: 'concurrent-payment',
      );
      final created = await Future.wait([
        repository.recordPayment(request),
        repository.recordPayment(request),
      ]);
      expect(created[0].paymentId, created[1].paymentId);
      expect(
        await database.select(database.paymentIdentities).get(),
        hasLength(1),
      );

      final firstCorrection = CorrectPaymentRequest(
        paymentId: created.first.paymentId,
        expectedVersionId: created.first.versionId,
        replacementAmountMinor: 9000,
        physicalAmountMinor: 10000,
        occurred: PhysicalOccurrence.yes,
        actorId: 'actor-1',
        reason: 'Concurrent correction A',
        idempotencyKey: 'concurrent-correction-a',
      );
      final secondCorrection = CorrectPaymentRequest(
        paymentId: created.first.paymentId,
        expectedVersionId: created.first.versionId,
        replacementAmountMinor: 8000,
        physicalAmountMinor: 10000,
        occurred: PhysicalOccurrence.yes,
        actorId: 'actor-1',
        reason: 'Concurrent correction B',
        idempotencyKey: 'concurrent-correction-b',
      );
      final results = await Future.wait<Object>([
        _capture(repository.correctPayment(firstCorrection)),
        _capture(repository.correctPayment(secondCorrection)),
      ]);
      expect(results.whereType<CashEventOperationResult>(), hasLength(1));
      expect(results.whereType<StaleCashEventHead>(), hasLength(1));
      expect(
        await _versionsFor(database, created.first.cashEventId),
        hasLength(2),
      );
      expect((await _head(database, created.first.cashEventId)).revision, 2);
    },
  );

  test(
    'account and currency mismatch leaves no partial payment records',
    () async {
      final request = RecordPaymentRequest(
        financialAccountId: accountId,
        partyId: 'unrelated-party',
        partyRole: 'customer',
        currencyCode: 'EGP',
        financialDirection: LedgerDirection.incoming,
        cashDirection: LedgerDirection.incoming,
        transactionAmountMinor: 10000,
        physicalAmountMinor: 10000,
        occurred: PhysicalOccurrence.yes,
        actorId: 'actor-1',
        reason: 'Invalid account tuple test',
        idempotencyKey: 'invalid-account-tuple',
      );
      await expectLater(repository.recordPayment(request), throwsA(anything));
      expect(await database.select(database.paymentIdentities).get(), isEmpty);
      expect(await database.select(database.cashEvents).get(), isEmpty);
      expect(
        await database.select(database.financialTransactions).get(),
        isEmpty,
      );
      expect(await database.select(database.cashEventVersions).get(), isEmpty);
      expect(await database.select(database.cashEventHeads).get(), isEmpty);
    },
  );

  test('cash-event head cannot select another payment or version', () async {
    final payment = await _record(
      repository,
      accountId: accountId,
      partyId: partyId,
      amount: 10000,
      physicalAmount: 10000,
      key: 'head-composite-key',
    );

    await expectLater(
      database.customStatement(
        'UPDATE cash_event_heads SET payment_id = ? WHERE cash_event_id = ?',
        ['different-payment', payment.cashEventId],
      ),
      throwsA(anything),
    );
    await expectLater(
      database.customStatement(
        'UPDATE cash_event_heads SET version_id = ? WHERE cash_event_id = ?',
        ['different-version', payment.cashEventId],
      ),
      throwsA(anything),
    );
    expect(
      (await _head(database, payment.cashEventId)).versionId,
      payment.versionId,
    );
  });
}

Future<List<FinancialTransaction>> _transactionsFor(
  AppDatabase database,
  String paymentId,
) =>
    (database.select(database.financialTransactions)
          ..where((row) => row.paymentId.equals(paymentId))
          ..orderBy([(row) => OrderingTerm.asc(row.occurredAt)]))
        .get();

Future<List<CashEventVersion>> _versionsFor(
  AppDatabase database,
  String eventId,
) =>
    (database.select(database.cashEventVersions)
          ..where((row) => row.cashEventId.equals(eventId))
          ..orderBy([(row) => OrderingTerm.asc(row.sequence)]))
        .get();

Future<CashEventHead> _head(AppDatabase database, String eventId) =>
    (database.select(
      database.cashEventHeads,
    )..where((row) => row.cashEventId.equals(eventId))).getSingle();

Future<int> _suspenseBalanceFor(
  AppDatabase database,
  CashEventRepository repository,
  String eventId,
) async {
  final cases = await (database.select(
    database.reconciliationCases,
  )..where((row) => row.cashEventId.equals(eventId))).get();
  expect(cases, hasLength(1));
  return repository.getSuspenseBalance(cases.single.id);
}

RecordPaymentRequest _paymentRequest({
  required String accountId,
  required String partyId,
  required int amount,
  required int physicalAmount,
  required String key,
  PhysicalOccurrence occurred = PhysicalOccurrence.yes,
}) {
  return RecordPaymentRequest(
    financialAccountId: accountId,
    partyId: partyId,
    partyRole: 'customer',
    currencyCode: 'EGP',
    financialDirection: LedgerDirection.incoming,
    cashDirection: LedgerDirection.incoming,
    transactionAmountMinor: amount,
    physicalAmountMinor: physicalAmount,
    occurred: occurred,
    actorId: 'actor-1',
    reason: 'Test payment',
    idempotencyKey: key,
  );
}

Future<Object> _capture(Future<CashEventOperationResult> operation) async {
  try {
    return await operation;
  } on StaleCashEventHead catch (error) {
    return error;
  }
}

Future<CashEventOperationResult> _record(
  CashEventRepository repository, {
  required String accountId,
  required String partyId,
  required int amount,
  required int physicalAmount,
  required String key,
  PhysicalOccurrence occurred = PhysicalOccurrence.yes,
}) {
  return repository.recordPayment(
    _paymentRequest(
      accountId: accountId,
      partyId: partyId,
      amount: amount,
      physicalAmount: physicalAmount,
      key: key,
      occurred: occurred,
    ),
  );
}

CorrectPaymentRequest _correctionRequest(
  CashEventOperationResult payment, {
  required int amount,
  required String key,
}) {
  return CorrectPaymentRequest(
    paymentId: payment.paymentId,
    expectedVersionId: payment.versionId,
    replacementAmountMinor: amount,
    physicalAmountMinor: 10000,
    occurred: PhysicalOccurrence.yes,
    actorId: 'actor-1',
    reason: 'Separate-handle competing update',
    idempotencyKey: key,
  );
}

ResolveSuspenseRequest _resolutionRequest(
  String caseId, {
  required int amount,
  required String key,
}) {
  return ResolveSuspenseRequest(
    caseId: caseId,
    amountMinor: amount,
    actorId: 'actor-1',
    authorizedByActorId: 'actor-approver',
    authorizationReference: 'authorization-$key',
    reason: 'Separate-handle resolution',
    idempotencyKey: key,
  );
}

Future<Object> _captureOutcome<T>(Future<T> operation) async {
  try {
    return (await operation) as Object;
  } catch (error) {
    return error;
  }
}
