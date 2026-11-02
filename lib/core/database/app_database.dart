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
    "CHECK (transaction_type IN ('payment', 'payment_reversal', 'replacement'))",
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createCashEventIndexesAndTriggers();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createAll();
      } else if (from < 3) {
        await m.createTable(paymentIdentities);
        await m.createTable(cashEvents);
        await m.createTable(financialTransactions);
        await m.createTable(cashEventVersions);
        await m.createTable(cashEventHeads);
        await m.createTable(reconciliationCases);
        await m.createTable(suspenseResolutions);
        await m.createTable(suspenseEntries);
      }
      await _createCashEventIndexesAndTriggers();
    },
  );

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

  static Future<AppDatabase> open({required String path}) async {
    await File(path).parent.create(recursive: true);
    final database = AppDatabase._(
      NativeDatabase(
        File(path),
        setup: (database) => database.execute('PRAGMA foreign_keys = ON'),
      ),
    );
    await database.storedSchemaVersion;
    return database;
  }

  Future<int> get storedSchemaVersion async {
    final row = await customSelect('PRAGMA user_version').getSingle();
    return row.read<int>('user_version');
  }
}
