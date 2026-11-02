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

@DriftDatabase(
  tables: [
    Currencies,
    Parties,
    PartyRoles,
    FinancialAccounts,
    Invoices,
    InvoiceLines,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createAll();
      }
    },
  );

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
