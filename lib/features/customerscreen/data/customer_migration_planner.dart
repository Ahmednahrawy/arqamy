import 'package:arqamy/core/helpers/customer_name_key.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';

/// One exact spelling of a customer name and the invoices that use it.
class CustomerSpelling {
  const CustomerSpelling({required this.name, required this.invoiceIds});

  final String name;
  final List<String> invoiceIds;

  int get invoiceCount => invoiceIds.length;
}

/// A group of spellings that probably belong to one customer.
class CustomerCandidate {
  const CustomerCandidate({required this.key, required this.spellings});

  /// Comparison key shared by every spelling (never stored or shown).
  final String key;

  /// Most used spelling first; spellings that tie keep the order in which they
  /// first appeared.
  final List<CustomerSpelling> spellings;

  String get suggestedName => spellings.first.name;

  int get invoiceCount =>
      spellings.fold(0, (sum, spelling) => sum + spelling.invoiceCount);

  Iterable<String> get invoiceIds =>
      spellings.expand((spelling) => spelling.invoiceIds);

  /// More than one spelling: the owner must confirm they are one customer
  /// (Decision 39) before any invoice is linked.
  bool get needsConfirmation => spellings.length > 1;
}

class CustomerMigrationPlan {
  const CustomerMigrationPlan({
    required this.candidates,
    required this.unnamedInvoiceIds,
  });

  final List<CustomerCandidate> candidates;

  /// Invoices with no usable customer name. They are never guessed.
  final List<String> unnamedInvoiceIds;

  Iterable<CustomerCandidate> get automatic =>
      candidates.where((candidate) => !candidate.needsConfirmation);

  Iterable<CustomerCandidate> get needingConfirmation =>
      candidates.where((candidate) => candidate.needsConfirmation);
}

/// Proposes which invoices belong to which customer. Read-only: it changes no
/// data and links nothing.
class CustomerMigrationPlanner {
  const CustomerMigrationPlanner._();

  static CustomerMigrationPlan plan(Iterable<Invoice> invoices) {
    final idsBySpellingByKey = <String, Map<String, List<String>>>{};
    final unnamed = <String>[];

    for (final invoice in invoices) {
      if (invoice.customerId != null) continue;
      final spelling = cleanCustomerName(invoice.customerName);
      final key = customerNameKey(spelling);
      if (key.isEmpty) {
        unnamed.add(invoice.id);
        continue;
      }
      idsBySpellingByKey
          .putIfAbsent(key, () => {})
          .putIfAbsent(spelling, () => [])
          .add(invoice.id);
    }

    final candidates = <CustomerCandidate>[
      for (final entry in idsBySpellingByKey.entries)
        CustomerCandidate(
          key: entry.key,
          spellings: _orderedSpellings(entry.value),
        ),
    ];
    candidates.sort((a, b) {
      final byCount = b.invoiceCount.compareTo(a.invoiceCount);
      if (byCount != 0) return byCount;
      final byName = a.suggestedName.compareTo(b.suggestedName);
      return byName != 0 ? byName : a.key.compareTo(b.key);
    });

    return CustomerMigrationPlan(
      candidates: List.unmodifiable(candidates),
      unnamedInvoiceIds: List.unmodifiable(unnamed),
    );
  }

  static List<CustomerSpelling> _orderedSpellings(
    Map<String, List<String>> idsBySpelling,
  ) {
    final entries = idsBySpelling.entries.toList();
    final firstSeen = {
      for (var index = 0; index < entries.length; index++)
        entries[index].key: index,
    };
    entries.sort((a, b) {
      final byCount = b.value.length.compareTo(a.value.length);
      return byCount != 0
          ? byCount
          : firstSeen[a.key]!.compareTo(firstSeen[b.key]!);
    });
    return List.unmodifiable([
      for (final entry in entries)
        CustomerSpelling(
          name: entry.key,
          invoiceIds: List.unmodifiable(entry.value),
        ),
    ]);
  }
}