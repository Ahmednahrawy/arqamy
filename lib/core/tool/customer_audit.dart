// Read-only audit of customer names in an Arqamy invoice backup.
//
// Usage:
//   dart tool/customer_audit.dart path/to/arqamy-backup-XXXX.json
//   dart tool/customer_audit.dart path/to/arqamy-backup-XXXX.json --names
//
// Without --names only counts are printed, so nothing private leaves your
// machine. --names also lists the spellings of customers that need a decision.
import 'dart:convert';
import 'dart:io';

/// Groups spellings that probably mean the same customer. Used only to find
/// candidates for a human decision, never to merge anything automatically.
String _key(String name) {
  var value = name.replaceAll('\u0640', ''); // tatweel
  value = value.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), ''); // diacritics
  value = value
      .replaceAll(RegExp('[أإآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه');
  return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}

void main(List<String> args) {
  final showNames = args.contains('--names');
  final paths = args.where((arg) => !arg.startsWith('--')).toList();
  if (paths.length != 1) {
    stderr.writeln('Usage: dart tool/customer_audit.dart <backup.json> [--names]');
    exit(64);
  }

  final Object? root;
  try {
    root = jsonDecode(File(paths.single).readAsStringSync());
  } on Object catch (error) {
    stderr.writeln('Could not read the file: $error');
    exit(65);
  }
  if (root is! Map ||
      root['format'] != 'arqamy-invoices' ||
      root['invoices'] is! List) {
    stderr.writeln('This is not an Arqamy invoice backup.');
    exit(65);
  }

  final countsByName = <String, int>{};
  var invoiceCount = 0;
  var emptyNames = 0;
  for (final raw in root['invoices'] as List) {
    if (raw is! Map) continue;
    invoiceCount++;
    final name = raw['customerName'];
    if (name is! String || name.trim().isEmpty) {
      emptyNames++;
      continue;
    }
    countsByName[name] = (countsByName[name] ?? 0) + 1;
  }

  final spellingsByKey = <String, List<String>>{};
  for (final name in countsByName.keys) {
    spellingsByKey.putIfAbsent(_key(name), () => []).add(name);
  }
  final ambiguous = spellingsByKey.values
      .where((spellings) => spellings.length > 1)
      .toList();

  print('Invoices:                          $invoiceCount');
  print('Invoices with no customer name:    $emptyNames');
  print('Exact customer names:              ${countsByName.length}');
  print('Customers after normalizing:       ${spellingsByKey.length}');
  print('Customers needing a decision:      ${ambiguous.length}');

  if (showNames) {
    for (var index = 0; index < ambiguous.length; index++) {
      final spellings = ambiguous[index];
      final total = spellings.fold<int>(0, (sum, s) => sum + countsByName[s]!);
      print('\nGroup ${index + 1} (${spellings.length} spellings, $total invoices):');
      for (final spelling in spellings) {
        print('  "$spelling" x${countsByName[spelling]}');
      }
    }
  }
}