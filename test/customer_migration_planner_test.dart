import 'package:arqamy/features/customerscreen/data/customer_migration_planner.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _invoice(String id, String name, {String? customerId}) {
  return Invoice(
    id: id,
    customerName: name,
    products: [
      Product(
        name: 'قمح',
        weight: 10,
        packageWeight: 0,
        numberPackage: 0,
        price: 5,
      ),
    ],
    totalCost: 50,
    paid: 0,
    rest: 50,
    formattedDate: 'Nov 21, 2026',
    formattedTime: '10:30',
    invoiceAction: 'بيع',
    invoiceSerial: id,
    customerId: customerId,
  );
}

void main() {
  test('an empty list gives an empty plan', () {
    final plan = CustomerMigrationPlanner.plan([]);

    expect(plan.candidates, isEmpty);
    expect(plan.unnamedInvoiceIds, isEmpty);
  });

  test('one spelling is linked automatically with all its invoices', () {
    final plan = CustomerMigrationPlanner.plan([
      _invoice('a1', 'أحمد علي'),
      _invoice('a2', 'أحمد علي'),
    ]);

    final candidate = plan.candidates.single;
    expect(candidate.needsConfirmation, isFalse);
    expect(candidate.suggestedName, 'أحمد علي');
    expect(candidate.invoiceIds, ['a1', 'a2']);
    expect(plan.automatic, hasLength(1));
    expect(plan.needingConfirmation, isEmpty);
  });

  test('extra spaces and invisible marks are not a different spelling', () {
    final plan = CustomerMigrationPlanner.plan([
      _invoice('a1', 'أحمد علي '),
      _invoice('a2', 'أحمد  علي'),
      _invoice('a3', 'أحمد\u200F علي'),
    ]);

    final candidate = plan.candidates.single;
    expect(candidate.spellings, hasLength(1));
    expect(candidate.needsConfirmation, isFalse);
    expect(candidate.invoiceCount, 3);
    expect(candidate.suggestedName, 'أحمد علي');
  });

  test('different spellings of one name need confirmation', () {
    final plan = CustomerMigrationPlanner.plan([
      _invoice('a1', 'أحمد علي'),
      _invoice('a2', 'احمد علي'),
      _invoice('a3', 'أحمد علي'),
    ]);

    final candidate = plan.candidates.single;
    expect(candidate.needsConfirmation, isTrue);
    expect(candidate.invoiceCount, 3);
    expect(candidate.suggestedName, 'أحمد علي');
    expect(
      candidate.spellings.map((spelling) => spelling.name),
      ['أحمد علي', 'احمد علي'],
    );
    expect(candidate.spellings.first.invoiceIds, ['a1', 'a3']);
    expect(plan.needingConfirmation, hasLength(1));
    expect(plan.automatic, isEmpty);
  });

  test('spellings that tie keep the order they first appeared', () {
    final plan = CustomerMigrationPlanner.plan([
      _invoice('a1', 'احمد'),
      _invoice('a2', 'أحمد'),
    ]);

    expect(
      plan.candidates.single.spellings.map((spelling) => spelling.name),
      ['احمد', 'أحمد'],
    );
  });

  test('invoices that already have a customer ID are skipped', () {
    final plan = CustomerMigrationPlanner.plan([
      _invoice('a1', 'أحمد علي', customerId: 'customer-1'),
      _invoice('a2', 'منى'),
    ]);

    expect(plan.candidates.single.suggestedName, 'منى');
    expect(plan.candidates.single.invoiceIds, ['a2']);
  });

  test('blank names are reported, never guessed', () {
    final plan = CustomerMigrationPlanner.plan([
      _invoice('a1', ''),
      _invoice('a2', '   '),
      _invoice('a3', '\u0640'),
      _invoice('a4', 'منى'),
    ]);

    expect(plan.unnamedInvoiceIds, ['a1', 'a2', 'a3']);
    expect(plan.candidates.single.suggestedName, 'منى');
  });

  test('candidates are ordered by invoice count, then name', () {
    final plan = CustomerMigrationPlanner.plan([
      _invoice('a1', 'سمير'),
      _invoice('a2', 'منى'),
      _invoice('a3', 'منى'),
      _invoice('a4', 'منى'),
      _invoice('a5', 'علي'),
      _invoice('a6', 'علي'),
      _invoice('a7', 'علي'),
    ]);

    expect(
      plan.candidates.map((candidate) => candidate.suggestedName),
      ['علي', 'منى', 'سمير'],
    );
  });
}