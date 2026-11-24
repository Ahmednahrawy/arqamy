import 'package:arqamy/core/database/app_database.dart';
import 'package:arqamy/core/services/invoice_backup_service.dart';
import 'package:arqamy/features/customerscreen/data/customer_linking_service.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_import_executor.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_import_planner.dart';

/// Connects the import planner and executor to the app's saved invoices.
class LedgerImportService {
  const LedgerImportService._();

  /// Confirmed by the owner for every existing invoice (Decision 38).
  static const currency = LedgerCurrency(
    code: 'EGP',
    minorUnitScale: 2,
    displayName: 'Egyptian pound',
  );

  /// Reads the saved invoices and proposes an import. Writes nothing.
  static Future<LedgerImportPlan> preview(InvoiceProvider provider) async {
    await provider.loadInvoices();
    return LedgerImportPlanner(currency: currency).plan(provider.invoices);
  }

  /// Writes [plan] into the ledger database, after a backup. The database is
  /// opened only for the length of this call.
  static Future<LedgerImportResult> run(
    InvoiceProvider provider,
    LedgerImportPlan plan,
  ) async {
    final database = await AppDatabase.open(
      path: await CustomerLinkingService.ledgerDatabasePath(),
    );
    try {
      return await LedgerImportExecutor(
        database,
        backup: () async {
          await InvoiceBackupService.saveLocalBackup(provider);
        },
      ).execute(plan);
    } finally {
      await database.close();
    }
  }
}