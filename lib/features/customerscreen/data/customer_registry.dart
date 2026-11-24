import 'package:arqamy/core/database/app_database.dart';
import 'package:arqamy/core/helpers/customer_name_key.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation_repository.dart';
import 'package:drift/drift.dart';

/// Thrown when a name matches more than one registered customer, so the owner
/// must choose instead of the app guessing (Decision 39).
class AmbiguousCustomerNameException implements Exception {
  const AmbiguousCustomerNameException(this.name, this.matches);

  final String name;
  final List<LedgerParty> matches;

  @override
  String toString() =>
      'AmbiguousCustomerNameException: "$name" matches ${matches.length} '
      'customers';
}

/// The customer directory: parties that have the customer role.
///
/// A customer's id never changes. Renaming changes only the current display
/// name; invoices keep the name they were issued with.
class CustomerRegistry {
  CustomerRegistry(
    this._database, {
    LedgerFoundationRepository? repository,
    DateTime Function()? clock,
  }) : _repository =
           repository ?? LedgerFoundationRepository(_database, clock: clock),
       _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final LedgerFoundationRepository _repository;
  final DateTime Function() _clock;

  /// All customers, ordered by display name.
  Future<List<LedgerParty>> listCustomers() async {
    final query = _database.select(_database.parties).join([
      innerJoin(
        _database.partyRoles,
        _database.partyRoles.partyId.equalsExp(_database.parties.id),
      ),
    ])
      ..where(_database.partyRoles.role.equals(LedgerPartyRole.customer.name))
      ..orderBy([OrderingTerm.asc(_database.parties.displayName)]);
    final rows = await query.get();
    return [
      for (final row in rows)
        LedgerParty(
          id: row.readTable(_database.parties).id,
          displayName: row.readTable(_database.parties).displayName,
        ),
    ];
  }

  Future<LedgerParty?> findById(String customerId) async {
    for (final customer in await listCustomers()) {
      if (customer.id == customerId) return customer;
    }
    return null;
  }

  /// Customers whose name is the same as [name] apart from spacing, case,
  /// diacritics and similar spelling variants. Never merges anything.
  Future<List<LedgerParty>> findByName(String name) async {
    final key = customerNameKey(name);
    if (key.isEmpty) return const [];
    return [
      for (final customer in await listCustomers())
        if (customerNameKey(customer.displayName) == key) customer,
    ];
  }

  Future<LedgerParty> createCustomer(String displayName) {
    final name = cleanCustomerName(displayName);
    if (customerNameKey(name).isEmpty) {
      throw ArgumentError.value(
        displayName,
        'displayName',
        'A customer needs a name.',
      );
    }
    return _database.transaction(() async {
      final party = await _repository.createParty(displayName: name);
      await _repository.addPartyRole(
        partyId: party.id,
        role: LedgerPartyRole.customer,
      );
      return party;
    });
  }

  /// Returns the one matching customer, creates one when none matches, and
  /// throws [AmbiguousCustomerNameException] when several match.
  Future<LedgerParty> findOrCreateCustomer(String displayName) async {
    final matches = await findByName(displayName);
    if (matches.length == 1) return matches.single;
    if (matches.length > 1) {
      throw AmbiguousCustomerNameException(displayName, matches);
    }
    return createCustomer(displayName);
  }

  Future<void> rename(String customerId, String newName) async {
    final name = cleanCustomerName(newName);
    if (customerNameKey(name).isEmpty) {
      throw ArgumentError.value(newName, 'newName', 'A customer needs a name.');
    }
    if (await findById(customerId) == null) {
      throw StateError('Unknown customer: $customerId');
    }
    await (_database.update(
      _database.parties,
    )..where((party) => party.id.equals(customerId))).write(
      PartiesCompanion(displayName: Value(name), updatedAt: Value(_clock())),
    );
  }
}