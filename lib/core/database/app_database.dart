import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'app_database.g.dart';

class Currencies extends Table {
  @override
  String get tableName => 'currencies';

  TextColumn get code => text().named('currency_code')();
  IntColumn get minorUnitScale => integer().named('minor_unit_scale')();
  TextColumn get displayName => text().named('display_name')();

  @override
  Set<Column> get primaryKey => {code};

  @override
  List<String> get customConstraints => [
    'CHECK (minor_unit_scale BETWEEN 0 AND 6)',
  ];
}

class Parties extends Table {
  @override
  String get tableName => 'parties';

  TextColumn get id => text().named('party_id')();
  TextColumn get displayName => text().named('display_name')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class PartyRoles extends Table {
  @override
  String get tableName => 'party_roles';

  TextColumn get partyId => text().named('party_id')();
  TextColumn get role => text().named('role')();

  @override
  Set<Column> get primaryKey => {partyId, role};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (party_id) REFERENCES parties (party_id)',
    "CHECK (role IN ('customer', 'supplier'))",
  ];
}

class FinancialAccounts extends Table {
  @override
  String get tableName => 'financial_accounts';

  TextColumn get id => text().named('account_id')();
  TextColumn get partyId => text().named('party_id')();
  TextColumn get role => text().named('role')();
  TextColumn get currencyCode => text().named('currency_code')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {id, partyId, role, currencyCode},
  ];

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (party_id, role) REFERENCES party_roles (party_id, role)',
    'FOREIGN KEY (currency_code) REFERENCES currencies (currency_code)',
  ];
}

class Invoices extends Table {
  @override
  String get tableName => 'invoices';

  TextColumn get id => text().named('invoice_id')();
  TextColumn get serial => text().named('invoice_serial')();
  TextColumn get legacyRecordKey =>
      text().named('legacy_record_key').nullable()();
  TextColumn get legacyInvoiceId =>
      text().named('legacy_invoice_id').nullable()();
  TextColumn get sourceJson => text().named('source_json').nullable()();
  TextColumn get partyId => text().named('party_id').nullable()();
  TextColumn get partyRole => text().named('party_role').nullable()();
  TextColumn get financialAccountId =>
      text().named('financial_account_id').nullable()();
  TextColumn get currencyCode => text().named('currency_code').nullable()();
  TextColumn get action => text()
      .named('action')
      .customConstraint(
        'NOT NULL CHECK ("action" IN (\'sale\', \'purchase\', \'storage\', \'unknown\'))',
      )();
  TextColumn get legacyAction => text().named('legacy_action').nullable()();
  IntColumn get totalMinor => integer().named('total_minor').nullable()();
  TextColumn get legacyTotalValue =>
      text().named('legacy_total_value').nullable()();
  TextColumn get legacyPaidValue =>
      text().named('legacy_paid_value').nullable()();
  TextColumn get legacyRemainingValue =>
      text().named('legacy_remaining_value').nullable()();
  DateTimeColumn get issuedAt => dateTime().named('issued_at').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {legacyRecordKey},
    {id, currencyCode},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (total_minor IS NULL OR total_minor >= 0)',
    'CHECK ((financial_account_id IS NULL AND party_id IS NULL AND party_role IS NULL) OR '
        '(financial_account_id IS NOT NULL AND party_id IS NOT NULL AND party_role IS NOT NULL AND currency_code IS NOT NULL))',
    'FOREIGN KEY (party_id, party_role) REFERENCES party_roles (party_id, role)',
    'FOREIGN KEY (financial_account_id, party_id, party_role, currency_code) '
        'REFERENCES financial_accounts (account_id, party_id, role, currency_code)',
    'FOREIGN KEY (currency_code) REFERENCES currencies (currency_code)',
  ];
}

class InvoiceLines extends Table {
  @override
  String get tableName => 'invoice_lines';

  TextColumn get id => text().named('invoice_line_id')();
  TextColumn get invoiceId => text().named('invoice_id')();
  IntColumn get lineIndex => integer().named('line_index')();
  TextColumn get productName => text().named('product_name')();
  TextColumn get quantityDecimal =>
      text().named('quantity_decimal').nullable()();
  TextColumn get packageWeightDecimal =>
      text().named('package_weight_decimal').nullable()();
  IntColumn get packageCount => integer().named('package_count').nullable()();
  TextColumn get unitPriceDecimal =>
      text().named('unit_price_decimal').nullable()();
  IntColumn get lineTotalMinor =>
      integer().named('line_total_minor').nullable()();
  TextColumn get currencyCode => text().named('currency_code').nullable()();
  TextColumn get sourceJson => text().named('source_json').nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {invoiceId, lineIndex},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (line_index >= 0)',
    'CHECK (package_count IS NULL OR package_count >= 0)',
    'CHECK (line_total_minor IS NULL OR line_total_minor >= 0)',
    'FOREIGN KEY (invoice_id) REFERENCES invoices (invoice_id)',
    'FOREIGN KEY (invoice_id, currency_code) REFERENCES invoices (invoice_id, currency_code)',
    'FOREIGN KEY (currency_code) REFERENCES currencies (currency_code)',
  ];
}

class PaymentIdentities extends Table {
  @override
  String get tableName => 'payment_identities';

  TextColumn get id => text().named('payment_id')();
  TextColumn get financialAccountId => text().named('financial_account_id')();
  TextColumn get partyId => text().named('party_id')();
  TextColumn get partyRole => text().named('party_role')();
  TextColumn get currencyCode => text().named('currency_code')();
  TextColumn get financialDirection => text().named('financial_direction')();
  TextColumn get createdByActorId => text().named('created_by_actor_id')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {id, financialAccountId, partyId, partyRole, currencyCode},
  ];

  @override
  List<String> get customConstraints => [
    "CHECK (financial_direction IN ('in', 'out'))",
    'FOREIGN KEY (financial_account_id, party_id, party_role, currency_code) '
        'REFERENCES financial_accounts (account_id, party_id, role, currency_code)',
  ];
}

class CashEvents extends Table {
  @override
  String get tableName => 'cash_events';

  TextColumn get id => text().named('cash_event_id')();
  TextColumn get paymentId => text().named('payment_id')();
  TextColumn get createdByActorId => text().named('created_by_actor_id')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {paymentId},
    {id, paymentId},
  ];

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (payment_id) REFERENCES payment_identities (payment_id)',
  ];
}

class FinancialTransactions extends Table {
  @override
  String get tableName => 'financial_transactions';

  TextColumn get id => text().named('transaction_id')();
  TextColumn get cashEventId => text().named('cash_event_id')();
  TextColumn get paymentId => text().named('payment_id')();
  TextColumn get financialAccountId => text().named('financial_account_id')();
  TextColumn get partyId => text().named('party_id')();
  TextColumn get partyRole => text().named('party_role')();
  TextColumn get currencyCode => text().named('currency_code')();
  TextColumn get transactionType => text().named('transaction_type')();
  TextColumn get direction => text().named('direction')();
  IntColumn get amountMinor => integer().named('amount_minor')();
  TextColumn get relatedTransactionId =>
      text().named('related_transaction_id').nullable()();
  TextColumn get actorId => text().named('actor_id')();
  TextColumn get reason => text().named('reason')();
  TextColumn get idempotencyKey => text().named('idempotency_key').nullable()();
  DateTimeColumn get occurredAt => dateTime().named('occurred_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {id, cashEventId, paymentId},
    {idempotencyKey},
  ];

  @override
  List<String> get customConstraints => [
    "CHECK (transaction_type IN ('payment', 'payment_reversal', 'replacement', 'refund'))",
    "CHECK (direction IN ('in', 'out'))",
    'CHECK (amount_minor >= 0)',
    "CHECK (transaction_type = 'replacement' OR amount_minor > 0)",
    'FOREIGN KEY (cash_event_id, payment_id) '
        'REFERENCES cash_events (cash_event_id, payment_id)',
    'FOREIGN KEY (payment_id, financial_account_id, party_id, party_role, currency_code) '
        'REFERENCES payment_identities '
        '(payment_id, financial_account_id, party_id, party_role, currency_code)',
    'FOREIGN KEY (related_transaction_id, cash_event_id, payment_id) '
        'REFERENCES financial_transactions '
        '(transaction_id, cash_event_id, payment_id)',
  ];
}

class CashEventVersions extends Table {
  @override
  String get tableName => 'cash_event_versions';

  TextColumn get id => text().named('version_id')();
  TextColumn get cashEventId => text().named('cash_event_id')();
  TextColumn get paymentId => text().named('payment_id')();
  IntColumn get sequence => integer().named('sequence')();
  TextColumn get operation => text().named('operation')();
  TextColumn get occurred => text().named('occurred')();
  TextColumn get cashDirection => text().named('cash_direction')();
  IntColumn get physicalAmountMinor =>
      integer().named('physical_amount_minor')();
  IntColumn get effectiveRecognizedMinor =>
      integer().named('effective_recognized_minor')();
  TextColumn get transactionId => text().named('transaction_id').nullable()();
  TextColumn get previousVersionId =>
      text().named('previous_version_id').nullable()();
  TextColumn get idempotencyKey => text().named('idempotency_key')();
  TextColumn get requestPayload => text().named('request_payload')();
  TextColumn get actorId => text().named('actor_id')();
  TextColumn get reason => text().named('reason')();
  DateTimeColumn get recordedAt => dateTime().named('recorded_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {cashEventId, sequence},
    {id, cashEventId, paymentId},
    {idempotencyKey},
  ];

  @override
  List<String> get customConstraints => [
    "CHECK (operation IN ('original', 'correction', 'reversal', 'replacement', 'void'))",
    "CHECK (occurred IN ('yes', 'no', 'unknown'))",
    "CHECK (cash_direction IN ('in', 'out'))",
    'CHECK (sequence > 0)',
    'CHECK (physical_amount_minor >= 0)',
    'CHECK (effective_recognized_minor >= 0)',
    "CHECK (occurred != 'no' OR physical_amount_minor = 0)",
    'FOREIGN KEY (cash_event_id, payment_id) '
        'REFERENCES cash_events (cash_event_id, payment_id)',
    'FOREIGN KEY (transaction_id, cash_event_id, payment_id) '
        'REFERENCES financial_transactions '
        '(transaction_id, cash_event_id, payment_id)',
    'FOREIGN KEY (previous_version_id, cash_event_id, payment_id) '
        'REFERENCES cash_event_versions '
        '(version_id, cash_event_id, payment_id)',
  ];
}

class CashEventHeads extends Table {
  @override
  String get tableName => 'cash_event_heads';

  TextColumn get cashEventId => text().named('cash_event_id')();
  TextColumn get paymentId => text().named('payment_id')();
  TextColumn get versionId => text().named('version_id')();
  IntColumn get revision => integer().named('revision')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {cashEventId};

  @override
  List<Set<Column>> get uniqueKeys => [
    {cashEventId, paymentId},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (revision > 0)',
    'FOREIGN KEY (cash_event_id, payment_id) '
        'REFERENCES cash_events (cash_event_id, payment_id)',
    'FOREIGN KEY (version_id, cash_event_id, payment_id) '
        'REFERENCES cash_event_versions '
        '(version_id, cash_event_id, payment_id)',
  ];
}

class ReconciliationCases extends Table {
  @override
  String get tableName => 'reconciliation_cases';

  TextColumn get id => text().named('case_id')();
  TextColumn get cashEventId => text().named('cash_event_id')();
  TextColumn get paymentId => text().named('payment_id')();
  TextColumn get financialAccountId => text().named('financial_account_id')();
  TextColumn get partyId => text().named('party_id')();
  TextColumn get partyRole => text().named('party_role')();
  TextColumn get currencyCode => text().named('currency_code')();
  TextColumn get reason => text().named('reason')();
  TextColumn get createdByActorId => text().named('created_by_actor_id')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {
      id,
      cashEventId,
      paymentId,
      financialAccountId,
      partyId,
      partyRole,
      currencyCode,
    },
  ];

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (cash_event_id, payment_id) '
        'REFERENCES cash_events (cash_event_id, payment_id)',
    'FOREIGN KEY (payment_id, financial_account_id, party_id, party_role, currency_code) '
        'REFERENCES payment_identities '
        '(payment_id, financial_account_id, party_id, party_role, currency_code)',
  ];
}

class SuspenseResolutions extends Table {
  @override
  String get tableName => 'suspense_resolutions';

  TextColumn get id => text().named('resolution_id')();
  TextColumn get caseId => text().named('case_id')();
  TextColumn get cashEventId => text().named('cash_event_id')();
  TextColumn get paymentId => text().named('payment_id')();
  TextColumn get financialAccountId => text().named('financial_account_id')();
  TextColumn get partyId => text().named('party_id')();
  TextColumn get partyRole => text().named('party_role')();
  TextColumn get currencyCode => text().named('currency_code')();
  IntColumn get amountMinor => integer().named('amount_minor')();
  TextColumn get actorId => text().named('actor_id')();
  TextColumn get authorizedByActorId =>
      text().named('authorized_by_actor_id')();
  TextColumn get authorizationReference =>
      text().named('authorization_reference')();
  TextColumn get reason => text().named('reason')();
  TextColumn get idempotencyKey => text().named('idempotency_key')();
  TextColumn get requestPayload => text().named('request_payload')();
  DateTimeColumn get resolvedAt => dateTime().named('resolved_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {
      id,
      caseId,
      cashEventId,
      paymentId,
      financialAccountId,
      partyId,
      partyRole,
      currencyCode,
    },
    {idempotencyKey},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (amount_minor > 0)',
    'FOREIGN KEY (case_id, cash_event_id, payment_id, financial_account_id, party_id, party_role, currency_code) '
        'REFERENCES reconciliation_cases '
        '(case_id, cash_event_id, payment_id, financial_account_id, party_id, party_role, currency_code)',
  ];
}

class SuspenseEntries extends Table {
  @override
  String get tableName => 'suspense_entries';

  TextColumn get id => text().named('suspense_entry_id')();
  TextColumn get caseId => text().named('case_id')();
  TextColumn get cashEventId => text().named('cash_event_id')();
  TextColumn get paymentId => text().named('payment_id')();
  TextColumn get financialAccountId => text().named('financial_account_id')();
  TextColumn get partyId => text().named('party_id')();
  TextColumn get partyRole => text().named('party_role')();
  TextColumn get currencyCode => text().named('currency_code')();
  TextColumn get movementType => text().named('movement_type')();
  IntColumn get amountMinor => integer().named('amount_minor')();
  TextColumn get resolutionId => text().named('resolution_id').nullable()();
  TextColumn get actorId => text().named('actor_id')();
  TextColumn get reason => text().named('reason')();
  TextColumn get idempotencyKey => text().named('idempotency_key')();
  TextColumn get requestPayload => text().named('request_payload')();
  DateTimeColumn get recordedAt => dateTime().named('recorded_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {idempotencyKey},
  ];

  @override
  List<String> get customConstraints => [
    "CHECK (movement_type IN ('creation', 'increase', 'decrease', 'resolution'))",
    'CHECK (amount_minor > 0)',
    "CHECK ((movement_type = 'resolution' AND resolution_id IS NOT NULL) OR "
        "(movement_type != 'resolution' AND resolution_id IS NULL))",
    'FOREIGN KEY (case_id, cash_event_id, payment_id, financial_account_id, party_id, party_role, currency_code) '
        'REFERENCES reconciliation_cases '
        '(case_id, cash_event_id, payment_id, financial_account_id, party_id, party_role, currency_code)',
    'FOREIGN KEY (resolution_id, case_id, cash_event_id, payment_id, financial_account_id, party_id, party_role, currency_code) '
        'REFERENCES suspense_resolutions '
        '(resolution_id, case_id, cash_event_id, payment_id, financial_account_id, party_id, party_role, currency_code)',
  ];
}

class InvoiceAllocations extends Table {
  @override
  String get tableName => 'invoice_allocations';

  TextColumn get id => text().named('allocation_id')();
  TextColumn get paymentId => text().named('payment_id')();
  TextColumn get invoiceId => text().named('invoice_id')();
  TextColumn get paymentFinancialAccountId =>
      text().named('payment_financial_account_id')();
  TextColumn get invoiceFinancialAccountId =>
      text().named('invoice_financial_account_id')();
  TextColumn get partyId => text().named('party_id')();
  TextColumn get partyRole => text().named('party_role')();
  TextColumn get currencyCode => text().named('currency_code')();
  IntColumn get amountMinor => integer().named('amount_minor')();
  TextColumn get idempotencyKey => text().named('idempotency_key')();
  TextColumn get requestFingerprint => text().named('request_fingerprint')();
  TextColumn get originDeviceId =>
      text().named('origin_device_id').nullable()();
  TextColumn get conflictGroupId =>
      text().named('conflict_group_id').nullable()();
  TextColumn get actorId => text().named('actor_id').nullable()();
  TextColumn get reason => text().named('reason').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {id, paymentId, invoiceId},
    {idempotencyKey},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (amount_minor > 0)',
    'CHECK (length(trim(idempotency_key)) > 0)',
    'CHECK (length(trim(request_fingerprint)) > 0)',
    'FOREIGN KEY (payment_id, payment_financial_account_id, party_id, party_role, currency_code) '
        'REFERENCES payment_identities '
        '(payment_id, financial_account_id, party_id, party_role, currency_code)',
    'FOREIGN KEY (invoice_id, invoice_financial_account_id, party_id, party_role, currency_code) '
        'REFERENCES invoices '
        '(invoice_id, financial_account_id, party_id, party_role, currency_code)',
  ];
}

class AllocationReversals extends Table {
  @override
  String get tableName => 'allocation_reversals';

  TextColumn get id => text().named('allocation_reversal_id')();
  TextColumn get allocationId => text().named('allocation_id')();
  IntColumn get amountMinor => integer().named('amount_minor')();
  TextColumn get idempotencyKey => text().named('idempotency_key')();
  TextColumn get requestFingerprint => text().named('request_fingerprint')();
  TextColumn get actorId => text().named('actor_id').nullable()();
  TextColumn get reason => text().named('reason')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  IntColumn get sequence => integer().named('sequence')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {id, allocationId},
    {allocationId, sequence},
    {idempotencyKey},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (amount_minor > 0)',
    'CHECK (sequence > 0)',
    'CHECK (length(trim(idempotency_key)) > 0)',
    'CHECK (length(trim(request_fingerprint)) > 0)',
    'FOREIGN KEY (allocation_id) REFERENCES invoice_allocations (allocation_id)',
  ];
}

class AllocationStatusHistory extends Table {
  @override
  String get tableName => 'allocation_status_history';

  TextColumn get id => text().named('status_version_id')();
  TextColumn get allocationId => text().named('allocation_id')();
  IntColumn get sequence => integer().named('sequence')();
  TextColumn get status => text().named('status')();
  TextColumn get previousVersionId =>
      text().named('previous_version_id').nullable()();
  TextColumn get idempotencyKey => text().named('idempotency_key')();
  TextColumn get requestFingerprint => text().named('request_fingerprint')();
  TextColumn get actorId => text().named('actor_id').nullable()();
  TextColumn get reason => text().named('reason').nullable()();
  DateTimeColumn get recordedAt => dateTime().named('recorded_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {allocationId, sequence},
    {id, allocationId},
    {idempotencyKey},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (sequence > 0)',
    "CHECK (status IN ('provisional', 'server_confirmed', 'rejected', 'conflict_pending'))",
    "CHECK ((sequence = 1 AND previous_version_id IS NULL) OR "
        '(sequence > 1 AND previous_version_id IS NOT NULL))',
    'FOREIGN KEY (allocation_id) REFERENCES invoice_allocations (allocation_id)',
    'FOREIGN KEY (previous_version_id, allocation_id) '
        'REFERENCES allocation_status_history '
        '(status_version_id, allocation_id)',
  ];
}

class Refunds extends Table {
  @override
  String get tableName => 'payment_refunds';

  TextColumn get id => text().named('refund_id')();
  TextColumn get originalPaymentId => text().named('original_payment_id')();
  TextColumn get originalCashEventId =>
      text().named('original_cash_event_id')();
  TextColumn get refundPaymentId => text().named('refund_payment_id')();
  TextColumn get refundCashEventId => text().named('refund_cash_event_id')();
  TextColumn get invoiceId => text().named('invoice_id').nullable()();
  TextColumn get originalFinancialAccountId =>
      text().named('original_financial_account_id')();
  TextColumn get refundFinancialAccountId =>
      text().named('refund_financial_account_id')();
  TextColumn get invoiceFinancialAccountId =>
      text().named('invoice_financial_account_id').nullable()();
  TextColumn get partyId => text().named('party_id')();
  TextColumn get partyRole => text().named('party_role')();
  TextColumn get currencyCode => text().named('currency_code')();
  IntColumn get amountMinor => integer().named('amount_minor')();
  TextColumn get idempotencyKey => text().named('idempotency_key')();
  TextColumn get requestFingerprint => text().named('request_fingerprint')();
  TextColumn get actorId => text().named('actor_id').nullable()();
  TextColumn get reason => text().named('reason')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {id, originalPaymentId, invoiceId},
    {id, originalPaymentId, refundPaymentId},
    {id, refundPaymentId, refundCashEventId},
    {refundPaymentId},
    {idempotencyKey},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (original_payment_id != refund_payment_id)',
    'CHECK (amount_minor > 0)',
    'CHECK (length(trim(idempotency_key)) > 0)',
    'CHECK (length(trim(request_fingerprint)) > 0)',
    'CHECK ((invoice_id IS NULL AND invoice_financial_account_id IS NULL) OR '
        '(invoice_id IS NOT NULL AND invoice_financial_account_id IS NOT NULL))',
    'FOREIGN KEY (original_cash_event_id, original_payment_id) '
        'REFERENCES cash_events (cash_event_id, payment_id)',
    'FOREIGN KEY (refund_cash_event_id, refund_payment_id) '
        'REFERENCES cash_events (cash_event_id, payment_id)',
    'FOREIGN KEY (original_payment_id, original_financial_account_id, party_id, party_role, currency_code) '
        'REFERENCES payment_identities '
        '(payment_id, financial_account_id, party_id, party_role, currency_code)',
    'FOREIGN KEY (refund_payment_id, refund_financial_account_id, party_id, party_role, currency_code) '
        'REFERENCES payment_identities '
        '(payment_id, financial_account_id, party_id, party_role, currency_code)',
    'FOREIGN KEY (invoice_id, invoice_financial_account_id, party_id, party_role, currency_code) '
        'REFERENCES invoices '
        '(invoice_id, financial_account_id, party_id, party_role, currency_code)',
  ];
}

class RefundFinancialTransactions extends Table {
  @override
  String get tableName => 'refund_financial_transactions';

  TextColumn get refundId => text().named('refund_id')();
  TextColumn get transactionId => text().named('transaction_id')();
  TextColumn get cashEventId => text().named('cash_event_id')();
  TextColumn get paymentId => text().named('payment_id')();

  @override
  Set<Column> get primaryKey => {refundId};

  @override
  List<Set<Column>> get uniqueKeys => [
    {transactionId},
  ];

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (refund_id, payment_id, cash_event_id) '
        'REFERENCES payment_refunds '
        '(refund_id, refund_payment_id, refund_cash_event_id)',
    'FOREIGN KEY (transaction_id, cash_event_id, payment_id) '
        'REFERENCES financial_transactions '
        '(transaction_id, cash_event_id, payment_id)',
  ];
}

class RefundAllocationReversals extends Table {
  @override
  String get tableName => 'refund_allocation_reversals';

  TextColumn get id => text().named('refund_allocation_reversal_id')();
  TextColumn get refundId => text().named('refund_id')();
  TextColumn get originalPaymentId => text().named('original_payment_id')();
  TextColumn get invoiceId => text().named('invoice_id')();
  TextColumn get allocationId => text().named('allocation_id')();
  TextColumn get allocationReversalId =>
      text().named('allocation_reversal_id')();
  TextColumn get idempotencyKey => text().named('idempotency_key')();
  TextColumn get requestFingerprint => text().named('request_fingerprint')();
  TextColumn get actorId => text().named('actor_id').nullable()();
  TextColumn get reason => text().named('reason').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {id, refundId},
    {allocationReversalId},
    {idempotencyKey},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (length(trim(idempotency_key)) > 0)',
    'CHECK (length(trim(request_fingerprint)) > 0)',
    'FOREIGN KEY (refund_id, original_payment_id, invoice_id) '
        'REFERENCES payment_refunds (refund_id, original_payment_id, invoice_id)',
    'FOREIGN KEY (allocation_id, original_payment_id, invoice_id) '
        'REFERENCES invoice_allocations (allocation_id, payment_id, invoice_id)',
    'FOREIGN KEY (allocation_reversal_id, allocation_id) '
        'REFERENCES allocation_reversals '
        '(allocation_reversal_id, allocation_id)',
  ];
}

class InvoiceLifecycleEvents extends Table {
  @override
  String get tableName => 'invoice_lifecycle_events';

  TextColumn get id => text().named('lifecycle_event_id')();
  TextColumn get invoiceId => text().named('invoice_id')();
  IntColumn get sequence => integer().named('sequence')();
  TextColumn get state => text().named('state')();
  TextColumn get previousEventId =>
      text().named('previous_event_id').nullable()();
  TextColumn get idempotencyKey => text().named('idempotency_key')();
  TextColumn get requestFingerprint => text().named('request_fingerprint')();
  TextColumn get actorId => text().named('actor_id').nullable()();
  TextColumn get reason => text().named('reason').nullable()();
  DateTimeColumn get recordedAt => dateTime().named('recorded_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {invoiceId, sequence},
    {id, invoiceId},
    {idempotencyKey},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (sequence > 0)',
    "CHECK (state IN ('active', 'cancelled', 'deleted'))",
    "CHECK ((sequence = 1 AND previous_event_id IS NULL) OR "
        '(sequence > 1 AND previous_event_id IS NOT NULL))',
    'FOREIGN KEY (invoice_id) REFERENCES invoices (invoice_id)',
    'FOREIGN KEY (previous_event_id, invoice_id) '
        'REFERENCES invoice_lifecycle_events '
        '(lifecycle_event_id, invoice_id)',
  ];
}

@DriftDatabase(
  tables: [
    Currencies,
    Parties,
    PartyRoles,
    FinancialAccounts,
    Invoices,
    InvoiceLines,
    PaymentIdentities,
    CashEvents,
    FinancialTransactions,
    CashEventVersions,
    CashEventHeads,
    ReconciliationCases,
    SuspenseResolutions,
    SuspenseEntries,
    InvoiceAllocations,
    AllocationReversals,
    AllocationStatusHistory,
    Refunds,
    RefundFinancialTransactions,
    RefundAllocationReversals,
    InvoiceLifecycleEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createCashEventIndexesAndTriggers();
      await _createStage4IndexesAndTriggers();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createAll();
        await _createCashEventIndexesAndTriggers();
        await _createStage4IndexesAndTriggers();
      } else if (from < 3) {
        await m.createTable(paymentIdentities);
        await m.createTable(cashEvents);
        await m.createTable(financialTransactions);
        await m.createTable(cashEventVersions);
        await m.createTable(cashEventHeads);
        await m.createTable(reconciliationCases);
        await m.createTable(suspenseResolutions);
        await m.createTable(suspenseEntries);
        await _createCashEventIndexesAndTriggers();
        await _migrateV3ToV4(m);
      } else if (from < 4) {
        await _migrateV3ToV4(m);
      } else if (from < 5) {
        await _migrateV4ToV5();
      }
    },
  );

  Future<void> _migrateV4ToV5() async {
    // SQLite requires foreign-key enforcement to be disabled before the
    // transaction that rebuilds a referenced parent table.
    await customStatement('PRAGMA foreign_keys = OFF');
    try {
      await transaction(() async {
        final legacyRows = await customSelect(
          'SELECT rowid AS migration_rowid, * FROM allocation_reversals '
          'ORDER BY rowid ASC',
        ).get();
        final refundAllocationTrigger = await customSelect(
          "SELECT sql FROM sqlite_master WHERE type = 'trigger' "
          "AND name = 'refund_allocation_reversals_validate_insert'",
        ).getSingleOrNull();

        await customStatement('''
          CREATE TABLE allocation_reversals_v5 (
            allocation_reversal_id TEXT NOT NULL PRIMARY KEY,
            allocation_id TEXT NOT NULL,
            amount_minor INTEGER NOT NULL,
            idempotency_key TEXT NOT NULL,
            request_fingerprint TEXT NOT NULL,
            actor_id TEXT,
            reason TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            sequence INTEGER NOT NULL,
            UNIQUE (allocation_reversal_id, allocation_id),
            UNIQUE (allocation_id, sequence),
            UNIQUE (idempotency_key),
            CHECK (amount_minor > 0),
            CHECK (sequence > 0),
            CHECK (length(trim(idempotency_key)) > 0),
            CHECK (length(trim(request_fingerprint)) > 0),
            FOREIGN KEY (allocation_id)
              REFERENCES invoice_allocations (allocation_id)
          )
        ''');

        final sequencesByAllocation = <String, int>{};
        for (final row in legacyRows) {
          final data = row.data;
          final allocationId = data['allocation_id']! as String;
          final sequence = (sequencesByAllocation[allocationId] ?? 0) + 1;
          sequencesByAllocation[allocationId] = sequence;
          await customStatement(
            'INSERT INTO allocation_reversals_v5 ('
            'allocation_reversal_id, allocation_id, amount_minor, '
            'idempotency_key, request_fingerprint, actor_id, reason, '
            'created_at, sequence) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              data['allocation_reversal_id'],
              allocationId,
              data['amount_minor'],
              data['idempotency_key'],
              data['request_fingerprint'],
              data['actor_id'],
              data['reason'],
              data['created_at'],
              sequence,
            ],
          );
        }

        if (refundAllocationTrigger != null) {
          await customStatement(
            'DROP TRIGGER refund_allocation_reversals_validate_insert',
          );
        }
        await customStatement('DROP TABLE allocation_reversals');
        await customStatement(
          'ALTER TABLE allocation_reversals_v5 '
          'RENAME TO allocation_reversals',
        );
        if (refundAllocationTrigger != null) {
          await customStatement(refundAllocationTrigger.read<String>('sql'));
        }
        await customStatement(
          'CREATE INDEX allocation_reversals_allocation '
          'ON allocation_reversals (allocation_id, created_at)',
        );
        await customStatement('''
          CREATE TRIGGER allocation_reversals_immutable_update
          BEFORE UPDATE ON allocation_reversals BEGIN
            SELECT RAISE(ABORT, 'allocation_reversals is append-only');
          END
        ''');
        await customStatement('''
          CREATE TRIGGER allocation_reversals_immutable_delete
          BEFORE DELETE ON allocation_reversals BEGIN
            SELECT RAISE(ABORT, 'allocation_reversals is append-only');
          END
        ''');

        final migratedCount = (await customSelect(
          'SELECT COUNT(*) AS count FROM allocation_reversals',
        ).getSingle()).read<int>('count');
        if (migratedCount != legacyRows.length) {
          throw StateError(
            'The v4 to v5 migration changed the allocation reversal row count.',
          );
        }

        final violations = await customSelect('PRAGMA foreign_key_check').get();
        if (violations.isNotEmpty) {
          throw StateError(
            'Foreign-key violations found during the v4 to v5 migration.',
          );
        }
        final integrity = (await customSelect(
          'PRAGMA integrity_check',
        ).getSingle()).read<String>('integrity_check');
        if (integrity != 'ok') {
          throw StateError(
            'SQLite integrity check failed during the v4 to v5 migration: '
            '$integrity',
          );
        }
      });
    } finally {
      await customStatement('PRAGMA foreign_keys = ON');
    }
  }

  Future<void> _migrateV3ToV4(Migrator m) async {
    await customStatement('PRAGMA foreign_keys = OFF');
    try {
      await transaction(() async {
        final transactions = await _readMigrationRows('financial_transactions');
        final versions = await _readMigrationRows('cash_event_versions');
        final heads = await _readMigrationRows('cash_event_heads');

        await customStatement('DROP TABLE cash_event_heads');
        await customStatement('DROP TABLE cash_event_versions');
        await customStatement('DROP TABLE financial_transactions');

        await m.createTable(financialTransactions);
        await _restoreMigrationRows('financial_transactions', transactions);
        await m.createTable(cashEventVersions);
        await _restoreMigrationRows('cash_event_versions', versions);
        await m.createTable(cashEventHeads);
        await _restoreMigrationRows('cash_event_heads', heads);

        await m.createTable(invoiceAllocations);
        await m.createTable(allocationReversals);
        await m.createTable(allocationStatusHistory);
        await m.createTable(refunds);
        await m.createTable(refundFinancialTransactions);
        await m.createTable(refundAllocationReversals);
        await m.createTable(invoiceLifecycleEvents);
        await _createCashEventIndexesAndTriggers();
        await _createStage4IndexesAndTriggers();

        final violations = await customSelect('PRAGMA foreign_key_check').get();
        if (violations.isNotEmpty) {
          throw StateError(
            'Foreign-key violations found during the v3 to v4 migration.',
          );
        }
      });
    } finally {
      await customStatement('PRAGMA foreign_keys = ON');
    }
  }

  Future<List<Map<String, Object?>>> _readMigrationRows(
    String tableName,
  ) async {
    final rows = await customSelect(
      'SELECT * FROM $tableName ORDER BY rowid',
    ).get();
    return [for (final row in rows) row.data];
  }

  Future<void> _restoreMigrationRows(
    String tableName,
    List<Map<String, Object?>> rows,
  ) async {
    if (rows.isEmpty) return;
    final columns = rows.first.keys.toList();
    final columnList = columns.map((column) => '"$column"').join(', ');
    final placeholders = List.filled(columns.length, '?').join(', ');
    for (final row in rows) {
      await customStatement(
        'INSERT INTO $tableName ($columnList) VALUES ($placeholders)',
        [for (final column in columns) row[column]],
      );
    }
  }

  Future<void> _createCashEventIndexesAndTriggers() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS financial_transactions_event_time '
      'ON financial_transactions (cash_event_id, occurred_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS financial_transactions_account_time '
      'ON financial_transactions '
      '(financial_account_id, currency_code, occurred_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS cash_event_versions_event_sequence '
      'ON cash_event_versions (cash_event_id, sequence)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS suspense_entries_case_time '
      'ON suspense_entries (case_id, recorded_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS suspense_entries_account_currency '
      'ON suspense_entries (financial_account_id, currency_code)',
    );

    for (final table in [
      'payment_identities',
      'cash_events',
      'financial_transactions',
      'cash_event_versions',
      'reconciliation_cases',
      'suspense_resolutions',
      'suspense_entries',
    ]) {
      await customStatement(
        'CREATE TRIGGER IF NOT EXISTS ${table}_immutable_update '
        'BEFORE UPDATE ON $table BEGIN '
        "SELECT RAISE(ABORT, '$table is append-only'); END",
      );
      await customStatement(
        'CREATE TRIGGER IF NOT EXISTS ${table}_immutable_delete '
        'BEFORE DELETE ON $table BEGIN '
        "SELECT RAISE(ABORT, '$table is append-only'); END",
      );
    }
  }

  Future<void> _createStage4IndexesAndTriggers() async {
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS invoices_identity_for_allocations '
      'ON invoices (invoice_id, financial_account_id, party_id, party_role, currency_code)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS invoice_allocations_payment '
      'ON invoice_allocations (payment_id, created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS invoice_allocations_invoice '
      'ON invoice_allocations (invoice_id, created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS allocation_reversals_allocation '
      'ON allocation_reversals (allocation_id, created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS allocation_status_history_allocation '
      'ON allocation_status_history (allocation_id, sequence)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS payment_refunds_original '
      'ON payment_refunds (original_payment_id, created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS payment_refunds_invoice '
      'ON payment_refunds (invoice_id, created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS invoice_lifecycle_events_invoice '
      'ON invoice_lifecycle_events (invoice_id, sequence)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS refund_allocation_reversals_refund '
      'ON refund_allocation_reversals (refund_id, created_at)',
    );
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS refund_financial_transactions_validate_insert
      BEFORE INSERT ON refund_financial_transactions
      WHEN NOT EXISTS (
        SELECT 1
        FROM payment_refunds r
        JOIN financial_transactions t
          ON t.transaction_id = NEW.transaction_id
          AND t.cash_event_id = NEW.cash_event_id
          AND t.payment_id = NEW.payment_id
        JOIN payment_identities p ON p.payment_id = NEW.payment_id
        WHERE r.refund_id = NEW.refund_id
          AND r.refund_payment_id = NEW.payment_id
          AND r.refund_cash_event_id = NEW.cash_event_id
          AND t.transaction_type = 'refund'
          AND t.amount_minor = r.amount_minor
          AND t.direction = p.financial_direction
      )
      BEGIN
        SELECT RAISE(ABORT, 'Refund transaction does not match its refund record');
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS invoice_allocations_validate_insert
      BEFORE INSERT ON invoice_allocations
      WHEN NOT EXISTS (
        SELECT 1
        FROM payment_identities p
        JOIN invoices i ON i.invoice_id = NEW.invoice_id
        JOIN invoice_lifecycle_events l ON l.invoice_id = i.invoice_id
        WHERE p.payment_id = NEW.payment_id
          AND p.financial_account_id = NEW.payment_financial_account_id
          AND p.party_id = NEW.party_id
          AND p.party_role = NEW.party_role
          AND p.currency_code = NEW.currency_code
          AND i.financial_account_id = NEW.invoice_financial_account_id
          AND i.party_id = NEW.party_id
          AND i.party_role = NEW.party_role
          AND i.currency_code = NEW.currency_code
          AND ((p.party_role = 'customer' AND p.financial_direction = 'in'
                AND i.action = 'sale')
            OR (p.party_role = 'supplier' AND p.financial_direction = 'out'
                AND i.action = 'purchase'))
          AND l.sequence = (
            SELECT MAX(latest.sequence)
            FROM invoice_lifecycle_events latest
            WHERE latest.invoice_id = i.invoice_id
          )
          AND l.state = 'active'
      )
      BEGIN
        SELECT RAISE(ABORT, 'Invoice allocation identity or eligibility mismatch');
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS allocation_status_history_sequence
      BEFORE INSERT ON allocation_status_history
      WHEN (NEW.sequence = 1 AND NEW.previous_version_id IS NOT NULL)
        OR (NEW.sequence > 1 AND NOT EXISTS (
          SELECT 1 FROM allocation_status_history previous
          WHERE previous.status_version_id = NEW.previous_version_id
            AND previous.allocation_id = NEW.allocation_id
            AND previous.sequence = NEW.sequence - 1
        ))
      BEGIN
        SELECT RAISE(ABORT, 'Invalid allocation status history sequence');
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS invoice_lifecycle_events_sequence
      BEFORE INSERT ON invoice_lifecycle_events
      WHEN (NEW.sequence = 1 AND NEW.previous_event_id IS NOT NULL)
        OR (NEW.sequence > 1 AND NOT EXISTS (
          SELECT 1 FROM invoice_lifecycle_events previous
          WHERE previous.lifecycle_event_id = NEW.previous_event_id
            AND previous.invoice_id = NEW.invoice_id
            AND previous.sequence = NEW.sequence - 1
        ))
      BEGIN
        SELECT RAISE(ABORT, 'Invalid invoice lifecycle sequence');
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS payment_refunds_validate_insert
      BEFORE INSERT ON payment_refunds
      WHEN NOT EXISTS (
        SELECT 1
        FROM payment_identities original
        JOIN payment_identities refund
          ON refund.payment_id = NEW.refund_payment_id
        WHERE original.payment_id = NEW.original_payment_id
          AND original.financial_account_id = NEW.original_financial_account_id
          AND original.financial_direction != refund.financial_direction
          AND refund.financial_account_id = NEW.refund_financial_account_id
          AND original.party_id = NEW.party_id
          AND original.party_role = NEW.party_role
          AND original.currency_code = NEW.currency_code
          AND refund.party_id = NEW.party_id
          AND refund.party_role = NEW.party_role
          AND refund.currency_code = NEW.currency_code
          AND (NEW.invoice_id IS NULL OR EXISTS (
            SELECT 1 FROM invoices i
            WHERE i.invoice_id = NEW.invoice_id
              AND i.financial_account_id = NEW.invoice_financial_account_id
              AND i.party_id = NEW.party_id
              AND i.party_role = NEW.party_role
              AND i.currency_code = NEW.currency_code
              AND ((i.action = 'sale' AND NEW.party_role = 'customer'
                    AND original.financial_direction = 'in')
                OR (i.action = 'purchase' AND NEW.party_role = 'supplier'
                    AND original.financial_direction = 'out'))
          ))
      )
      BEGIN
        SELECT RAISE(ABORT, 'Refund identity or invoice mismatch');
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS refund_allocation_reversals_validate_insert
      BEFORE INSERT ON refund_allocation_reversals
      WHEN NOT EXISTS (
        SELECT 1
        FROM payment_refunds r
        JOIN invoice_allocations a
          ON a.allocation_id = NEW.allocation_id
        JOIN allocation_reversals ar
          ON ar.allocation_reversal_id = NEW.allocation_reversal_id
          AND ar.allocation_id = a.allocation_id
        WHERE r.refund_id = NEW.refund_id
          AND r.original_payment_id = NEW.original_payment_id
          AND r.invoice_id = NEW.invoice_id
          AND r.invoice_id IS NOT NULL
          AND a.payment_id = NEW.original_payment_id
          AND a.invoice_id = NEW.invoice_id
      )
      BEGIN
        SELECT RAISE(ABORT, 'Refund allocation reversal mismatch');
      END
    ''');

    for (final table in [
      'invoice_allocations',
      'allocation_reversals',
      'allocation_status_history',
      'payment_refunds',
      'refund_financial_transactions',
      'refund_allocation_reversals',
      'invoice_lifecycle_events',
    ]) {
      await customStatement(
        'CREATE TRIGGER IF NOT EXISTS ${table}_immutable_update '
        'BEFORE UPDATE ON $table BEGIN '
        "SELECT RAISE(ABORT, '$table is append-only'); END",
      );
      await customStatement(
        'CREATE TRIGGER IF NOT EXISTS ${table}_immutable_delete '
        'BEFORE DELETE ON $table BEGIN '
        "SELECT RAISE(ABORT, '$table is append-only'); END",
      );
    }
  }

  static Future<AppDatabase> open({required String path}) async {
    await File(path).parent.create(recursive: true);
    final database = AppDatabase._(
      NativeDatabase(
        File(path),
        setup: (database) => database.execute('PRAGMA foreign_keys = ON'),
      ),
    );
    try {
      await database.storedSchemaVersion;
      return database;
    } catch (error, stackTrace) {
      await database.close();
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<int> get storedSchemaVersion async {
    final row = await customSelect('PRAGMA user_version').getSingle();
    return row.read<int>('user_version');
  }
}
