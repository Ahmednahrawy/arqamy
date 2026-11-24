import 'package:arqamy/core/database/app_database.dart';
import 'package:arqamy/core/services/invoice_backup_service.dart';
import 'package:arqamy/features/customerscreen/data/customer_linker.dart';
import 'package:arqamy/features/customerscreen/data/customer_registry.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the ledger database only for the length of one linking run, so the
/// rest of the app never depends on it yet.
class CustomerLinkingService {
  const CustomerLinkingService._();

  static Future<String> ledgerDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return p.join(directory.path, 'ledger', 'arqamy_ledger.sqlite');
  }

  static Future<CustomerLinkResult> linkCustomers(
    InvoiceProvider provider,
  ) async {
    final database = await AppDatabase.open(path: await ledgerDatabasePath());
    try {
      final linker = CustomerLinker(
        provider: provider,
        registry: CustomerRegistry(database),
        backup: () async {
          await InvoiceBackupService.saveLocalBackup(provider);
        },
      );
      return await linker.linkAutomaticMatches();
    } finally {
      await database.close();
    }
  }
}