import 'package:arqamy/core/database/app_database.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class LedgerFoundationRepository {
  LedgerFoundationRepository(
    this._database, {
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
  }) : _uuid = uuid,
       _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _clock;

  Future<void> addCurrency(LedgerCurrency currency) {
    return _database
        .into(_database.currencies)
        .insert(
          CurrenciesCompanion.insert(
            code: currency.code,
            minorUnitScale: currency.minorUnitScale,
            displayName: currency.displayName,
          ),
        );
  }

  Future<LedgerParty> createParty({required String displayName}) async {
    final party = LedgerParty(id: _uuid.v4(), displayName: displayName);
    final now = _clock();
    await _database
        .into(_database.parties)
        .insert(
          PartiesCompanion.insert(
            id: party.id,
            displayName: party.displayName,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return party;
  }

  Future<void> addPartyRole({
    required String partyId,
    required LedgerPartyRole role,
  }) {
    return _database
        .into(_database.partyRoles)
        .insert(PartyRolesCompanion.insert(partyId: partyId, role: role.name));
  }

  Future<LedgerFinancialAccount> createFinancialAccount({
    required String partyId,
    required LedgerPartyRole role,
    required String currencyCode,
  }) async {
    final account = LedgerFinancialAccount(
      id: _uuid.v4(),
      partyId: partyId,
      role: role,
      currencyCode: currencyCode,
    );
    await _database
        .into(_database.financialAccounts)
        .insert(
          FinancialAccountsCompanion.insert(
            id: account.id,
            partyId: account.partyId,
            role: account.role.name,
            currencyCode: account.currencyCode,
            createdAt: _clock(),
          ),
        );
    return account;
  }

  Future<void> saveInvoiceDraft(LedgerInvoiceDraft invoice) {
    return _database.transaction(() async {
      await _database
          .into(_database.invoices)
          .insert(
            InvoicesCompanion.insert(
              id: invoice.id,
              serial: invoice.serial,
              legacyRecordKey: Value(invoice.legacyRecordKey),
              legacyInvoiceId: Value(invoice.legacyInvoiceId),
              sourceJson: Value(invoice.sourceJson),
              partyId: Value(invoice.partyId),
              partyRole: Value(invoice.partyRole?.name),
              financialAccountId: Value(invoice.financialAccountId),
              currencyCode: Value(invoice.currencyCode),
              action: invoice.action.name,
              legacyAction: Value(invoice.legacyAction),
              totalMinor: Value(invoice.totalMinor),
              legacyTotalValue: Value(invoice.legacyTotalValue),
              legacyPaidValue: Value(invoice.legacyPaidValue),
              legacyRemainingValue: Value(invoice.legacyRemainingValue),
              issuedAt: Value(invoice.issuedAt),
              createdAt: _clock(),
              updatedAt: _clock(),
            ),
          );
      for (final line in invoice.lines) {
        await _database
            .into(_database.invoiceLines)
            .insert(
              InvoiceLinesCompanion.insert(
                id: line.id,
                invoiceId: invoice.id,
                lineIndex: line.lineIndex,
                productName: line.productName,
                quantityDecimal: Value(line.quantityDecimal),
                packageWeightDecimal: Value(line.packageWeightDecimal),
                packageCount: Value(line.packageCount),
                unitPriceDecimal: Value(line.unitPriceDecimal),
                lineTotalMinor: Value(line.lineTotalMinor),
                currencyCode: Value(line.currencyCode),
                sourceJson: Value(line.sourceJson),
              ),
            );
      }
    });
  }

  Future<Invoice?> getInvoice(String invoiceId) {
    return (_database.select(
      _database.invoices,
    )..where((invoice) => invoice.id.equals(invoiceId))).getSingleOrNull();
  }

  Future<List<InvoiceLine>> getInvoiceLines(String invoiceId) {
    return (_database.select(_database.invoiceLines)
          ..where((line) => line.invoiceId.equals(invoiceId))
          ..orderBy([(line) => OrderingTerm.asc(line.lineIndex)]))
        .get();
  }
}
