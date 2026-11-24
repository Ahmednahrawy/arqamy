import 'package:arqamy/core/database/app_database.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation_repository.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_import_planner.dart';
import 'package:drift/drift.dart';

class LedgerImportResult {
  const LedgerImportResult({
    this.currencyAdded = false,
    this.rolesAdded = 0,
    this.accountsCreated = 0,
    this.invoicesImported = 0,
    this.invoicesAlreadyImported = 0,
    this.skippedMissingParty = 0,
    this.held = 0,
  });

  final bool currencyAdded;
  final int rolesAdded;
  final int accountsCreated;
  final int invoicesImported;

  /// Invoices that were imported by an earlier run and left as they are.
  final int invoicesAlreadyImported;

  /// Invoices whose customer ID is not in the registry; never invented.
  final int skippedMissingParty;

  /// Invoices the planner held back for a human decision.
  final int held;
}

/// Writes a [LedgerImportPlan] into the ledger database.
///
/// Safe to repeat: invoices are keyed by their legacy record, and existing
/// currencies, roles and accounts are reused. Everything is written in one
/// transaction, after a backup.
class LedgerImportExecutor {
  LedgerImportExecutor(
    this._database, {
    required this.backup,
    LedgerFoundationRepository? repository,
  }) : _repository = repository ?? LedgerFoundationRepository(_database);

  final AppDatabase _database;
  final LedgerFoundationRepository _repository;

  /// Saves a safety copy of the legacy invoices. It must throw when it cannot,
  /// so nothing is ever imported without a backup (Decision 34).
  final Future<void> Function() backup;

  Future<LedgerImportResult> execute(LedgerImportPlan plan) async {
    if (plan.ready.isEmpty) {
      return LedgerImportResult(held: plan.held.length);
    }
    await backup();

    return _database.transaction(() async {
      final code = plan.currency.code;

      var currencyAdded = false;
      final existingCurrency = await (_database.select(
        _database.currencies,
      )..where((row) => row.code.equals(code))).getSingleOrNull();
      if (existingCurrency == null) {
        await _repository.addCurrency(plan.currency);
        currencyAdded = true;
      } else if (existingCurrency.minorUnitScale !=
          plan.currency.minorUnitScale) {
        throw StateError(
          'Currency $code is already stored with a different number of '
          'decimals.',
        );
      }

      var rolesAdded = 0;
      var accountsCreated = 0;
      final accountIds = <({String partyId, LedgerPartyRole role}), String>{};
      for (final need in plan.accountsNeeded) {
        if (!await _partyExists(need.partyId)) continue;
        if (!await _hasRole(need.partyId, need.role)) {
          await _repository.addPartyRole(
            partyId: need.partyId,
            role: need.role,
          );
          rolesAdded++;
        }
        final existing = await _findAccountId(need.partyId, need.role, code);
        if (existing != null) {
          accountIds[need] = existing;
        } else {
          final created = await _repository.createFinancialAccount(
            partyId: need.partyId,
            role: need.role,
            currencyCode: code,
          );
          accountIds[need] = created.id;
          accountsCreated++;
        }
      }

      var imported = 0;
      var alreadyImported = 0;
      var skippedMissingParty = 0;
      for (final item in plan.ready) {
        final accountId =
            accountIds[(partyId: item.partyId, role: item.partyRole)];
        if (accountId == null) {
          skippedMissingParty++;
          continue;
        }
        final alreadySaved = await _isSaved(item.draft.legacyRecordKey!);
        await _repository.saveInvoiceDraft(
          item.draft.withFinancialAccount(accountId),
        );
        if (alreadySaved) {
          alreadyImported++;
        } else {
          imported++;
        }
      }

      return LedgerImportResult(
        currencyAdded: currencyAdded,
        rolesAdded: rolesAdded,
        accountsCreated: accountsCreated,
        invoicesImported: imported,
        invoicesAlreadyImported: alreadyImported,
        skippedMissingParty: skippedMissingParty,
        held: plan.held.length,
      );
    });
  }

  Future<bool> _partyExists(String partyId) async {
    final row = await (_database.select(
      _database.parties,
    )..where((party) => party.id.equals(partyId))).getSingleOrNull();
    return row != null;
  }

  Future<bool> _hasRole(String partyId, LedgerPartyRole role) async {
    final row =
        await (_database.select(_database.partyRoles)..where(
              (entry) =>
                  entry.partyId.equals(partyId) & entry.role.equals(role.name),
            ))
            .getSingleOrNull();
    return row != null;
  }

  Future<String?> _findAccountId(
    String partyId,
    LedgerPartyRole role,
    String currencyCode,
  ) async {
    final rows =
        await (_database.select(_database.financialAccounts)
              ..where(
                (account) =>
                    account.partyId.equals(partyId) &
                    account.role.equals(role.name) &
                    account.currencyCode.equals(currencyCode),
              )
              ..orderBy([
                (account) => OrderingTerm.asc(account.createdAt),
                (account) => OrderingTerm.asc(account.id),
              ]))
            .get();
    return rows.isEmpty ? null : rows.first.id;
  }

  Future<bool> _isSaved(String legacyRecordKey) async {
    final row = await (_database.select(
      _database.invoices,
    )..where((invoice) => invoice.legacyRecordKey.equals(legacyRecordKey)))
        .getSingleOrNull();
    return row != null;
  }
}