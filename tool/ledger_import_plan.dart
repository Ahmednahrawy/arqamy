// ignore_for_file: avoid_print
// Read-only preview of how an Arqamy invoice backup would enter the ledger.
//
// Usage:
//   dart tool/ledger_import_plan.dart <backup.json> --currency=EGP
//
// The currency must be named explicitly: it is never assumed (Decision 38).
// Nothing is written anywhere, and only counts are printed.
import 'dart:io';

import 'package:arqamy/core/helpers/invoice_backup.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_import_planner.dart';

void main(List<String> args) {
  final paths = args.where((arg) => !arg.startsWith('--')).toList();
  final currencyArgs = args.where((arg) => arg.startsWith('--currency='));
  final code = currencyArgs.isEmpty
      ? null
      : currencyArgs.first.substring('--currency='.length).toUpperCase();
  if (paths.length != 1 || code == null || !RegExp(r'^[A-Z]{3}$').hasMatch(code)) {
    stderr.writeln(
      'Usage: dart tool/ledger_import_plan.dart <backup.json> --currency=EGP\n'
      'The currency must be confirmed explicitly; it is never assumed.',
    );
    exit(64);
  }

  final LedgerImportPlan plan;
  try {
    var text = File(paths.single).readAsStringSync();
    if (text.startsWith('\uFEFF')) text = text.substring(1);
    plan = LedgerImportPlanner(
      currency: LedgerCurrency(
        code: code,
        minorUnitScale: 2,
        displayName: code,
      ),
    ).plan(InvoiceBackup.decode(text));
  } on InvoiceBackupFormatException catch (error) {
    stderr.writeln('Not a valid invoice backup: ${error.message}');
    exit(65);
  } on FileSystemException catch (error) {
    stderr.writeln('Could not read the file: ${error.message}');
    exit(66);
  }

  final reasons = <String, int>{};
  void count(String reason) => reasons[reason] = (reasons[reason] ?? 0) + 1;
  for (final held in plan.held) {
    for (final issue in held.issues) {
            count(issue.name);
    }
  }

  print('Currency:                 ${plan.currency.code}');
  print('Invoices:                 ${plan.ready.length + plan.held.length}');
  print('Ready to import:         ${plan.ready.length}');
  print('Held for a decision:      ${plan.held.length}');
  for (final entry in reasons.entries) {
    print('  ${entry.key}: ${entry.value}');
  }
  print('Accounts that would be needed: ${plan.accountsNeeded.length}');
}