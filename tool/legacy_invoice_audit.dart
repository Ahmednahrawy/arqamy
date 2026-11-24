// ignore_for_file: avoid_print
// Read-only readiness check of an Arqamy invoice backup before a ledger import.
//
// Usage:
//   dart tool/legacy_invoice_audit.dart path/to/arqamy-backup-XXXX.json
//   dart tool/legacy_invoice_audit.dart path/to/arqamy-backup-XXXX.json --ids
//
// Only counts are printed by default. --ids also lists the invoice serial
// numbers behind each finding (no customer names or amounts are printed).
import 'dart:io';

import 'package:arqamy/core/helpers/invoice_backup.dart';
import 'package:arqamy/features/payment_ledger/data/legacy_invoice_audit.dart';

const _labels = {
  LegacyInvoiceIssue.duplicateInvoiceId: 'Duplicate invoice id',
  LegacyInvoiceIssue.unknownAction: 'Unknown invoice type',
  LegacyInvoiceIssue.noCustomerId: 'Not linked to a customer yet',
  LegacyInvoiceIssue.noProducts: 'No products',
  LegacyInvoiceIssue.amountOutOfRange: 'Amount out of range',
  LegacyInvoiceIssue.moreThanTwoDecimals: 'More than two decimals',
  LegacyInvoiceIssue.negativePaid: 'Negative payment',
  LegacyInvoiceIssue.negativeTotal: 'Negative total',
  LegacyInvoiceIssue.zeroTotal: 'Zero total',
  LegacyInvoiceIssue.overpaid: 'Paid more than the total',
  LegacyInvoiceIssue.restDiffersFromTotalMinusPaid:
      'Remainder is not total minus paid',
  LegacyInvoiceIssue.totalDiffersFromLines: 'Total differs from product lines',
};

void main(List<String> args) {
  final showIds = args.contains('--ids');
  final paths = args.where((arg) => !arg.startsWith('--')).toList();
  if (paths.length != 1) {
    stderr.writeln(
      'Usage: dart tool/legacy_invoice_audit.dart <backup.json> [--ids]',
    );
    exit(64);
  }

  final LegacyInvoiceAuditReport report;
  try {
    var text = File(paths.single).readAsStringSync();
    if (text.startsWith('\uFEFF')) text = text.substring(1);
    report = LegacyInvoiceAudit.run(InvoiceBackup.decode(text));
  } on InvoiceBackupFormatException catch (error) {
    stderr.writeln('Not a valid invoice backup: ${error.message}');
    exit(65);
  } on FileSystemException catch (error) {
    stderr.writeln('Could not read the file: ${error.message}');
    exit(66);
  }

  print('Invoices:                 ${report.invoiceCount}');
  print('Without any finding:      ${report.cleanCount}');
  print('With at least one:        ${report.findings.length}');
  final counts = report.countsByIssue;
  for (final issue in LegacyInvoiceIssue.values) {
    final count = counts[issue];
    if (count == null) continue;
    print('  ${_labels[issue]}: $count');
    if (showIds) {
      final serials = report.findingsFor(issue).map((f) => f.serial).join(', ');
      print('    serials: $serials');
    }
  }
}