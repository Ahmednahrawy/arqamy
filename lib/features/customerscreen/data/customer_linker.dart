import 'package:arqamy/features/customerscreen/data/customer_migration_planner.dart';
import 'package:arqamy/features/customerscreen/data/customer_registry.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';

class CustomerLinkResult {
  const CustomerLinkResult({
    this.customersCreated = 0,
    this.customersReused = 0,
    this.invoicesLinked = 0,
    this.groupsNeedingConfirmation = 0,
    this.unnamedInvoices = 0,
  });

  final int customersCreated;
  final int customersReused;
  final int invoicesLinked;

  /// Customers the owner still has to confirm or choose between.
  final int groupsNeedingConfirmation;

  /// Invoices with no usable customer name; never guessed.
  final int unnamedInvoices;
}

/// Links legacy invoices to customers, but only where there is no doubt:
/// one spelling, one registry match or none. Everything else is left for the
/// owner to confirm (Decision 39).
class CustomerLinker {
  CustomerLinker({
    required this.provider,
    required this.registry,
    required this.backup,
  });

  final InvoiceProvider provider;
  final CustomerRegistry registry;

  /// Saves a safety copy of all invoices. It must throw when it cannot, so
  /// nothing is ever linked without a backup (Decision 34).
  final Future<void> Function() backup;

  Future<CustomerLinkResult> linkAutomaticMatches() async {
    await provider.loadInvoices();
    final plan = CustomerMigrationPlanner.plan(provider.invoices);
    final automatic = plan.automatic.toList();
    var needingConfirmation = plan.needingConfirmation.length;
    final unnamed = plan.unnamedInvoiceIds.length;
    if (automatic.isEmpty) {
      return CustomerLinkResult(
        groupsNeedingConfirmation: needingConfirmation,
        unnamedInvoices: unnamed,
      );
    }

    await backup();

    final assignments = <String, String>{};
    var created = 0;
    var reused = 0;
    for (final candidate in automatic) {
      final matches = await registry.findByName(candidate.suggestedName);
      if (matches.length > 1) {
        // The registry itself is ambiguous: leave this one to the owner.
        needingConfirmation++;
        continue;
      }
      final customer = matches.isEmpty
          ? await registry.createCustomer(candidate.suggestedName)
          : matches.single;
      if (matches.isEmpty) {
        created++;
      } else {
        reused++;
      }
      for (final invoiceId in candidate.invoiceIds) {
        assignments[invoiceId] = customer.id;
      }
    }

    final linked = await provider.assignCustomerIds(assignments);
    return CustomerLinkResult(
      customersCreated: created,
      customersReused: reused,
      invoicesLinked: linked,
      groupsNeedingConfirmation: needingConfirmation,
      unnamedInvoices: unnamed,
    );
  }
}