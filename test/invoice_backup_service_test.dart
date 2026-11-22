import 'package:arqamy/core/services/invoice_backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('backup file names sort by date and are safe on every platform', () {
    expect(
      InvoiceBackupService.backupFileName(DateTime(2026, 11, 21, 9, 5)),
      'arqamy-backup-20261121-0905.json',
    );
    expect(
      InvoiceBackupService.backupFileName(DateTime(2027, 1, 2, 23, 59)),
      'arqamy-backup-20270102-2359.json',
    );
  });
}