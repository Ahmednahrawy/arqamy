import 'dart:io';

import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Saves every invoice to a backup file and hands it to the share sheet.
class InvoiceBackupService {
  const InvoiceBackupService._();

  /// Returns the number of invoices backed up, or 0 when there is nothing to
  /// back up (nothing is shared in that case).
  static Future<int> shareBackup(
    InvoiceProvider provider, {
    DateTime? now,
  }) async {
    // Reload first so a backup never misses invoices that were not opened yet.
    await provider.loadInvoices();
    final count = provider.invoices.length;
    if (count == 0) return 0;

    final timestamp = now ?? DateTime.now();
    final directory = await getTemporaryDirectory();
    final file = File(p.join(directory.path, backupFileName(timestamp)));
    await file.writeAsString(
      provider.exportBackup(now: timestamp),
      flush: true,
    );
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'application/json')]),
    );
    return count;
  }

  static String backupFileName(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'arqamy-backup-${time.year}${two(time.month)}${two(time.day)}'
        '-${two(time.hour)}${two(time.minute)}.json';
  }
}