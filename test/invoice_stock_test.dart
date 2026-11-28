import 'dart:convert';

import 'package:arqamy/core/helpers/invoice_action.dart';
import 'package:arqamy/features/data/models/product_stock.dart';
import 'package:arqamy/features/inventoryscreen/ui/pages/inventory_screen.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Product _product({
  String name = 'Rice',
  double weight = 1,
  double packageWeight = 0,
  int numberPackage = 0,
}) {
  return Product(
    name: name,
    weight: weight,
    packageWeight: packageWeight,
    numberPackage: numberPackage,
    price: 10,
  );
}

Invoice _invoice({
  required String id,
  required InvoiceAction action,
  required List<Product> products,
}) {
  final total = products.fold<double>(
    0,
    (sum, product) => sum + product.netWeight * product.price,
  );
  return Invoice(
    id: id,
    customerName: 'Customer',
    products: products,
    totalCost: total,
    paid: 0,
    rest: total,
    formattedDate: 'Nov 28, 2026',
    formattedTime: '12:00',
    invoiceAction: action.storedValue,
    invoiceSerial: id,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode(['Rice', 'Sugar']),
    });
  });

  Future<InvoiceProvider> seededProvider({
    int quantity = 10,
    int minOQ = 2,
  }) async {
    final provider = InvoiceProvider();
    await provider.loadMasterProducts();
    await provider.setMasterProductStock(
      'Rice',
      quantity: quantity,
      minOQ: minOQ,
    );
    return provider;
  }

  test('purchase increases stock and sale decreases it', () async {
    final provider = await seededProvider();

    await provider.saveInvoice(
      _invoice(
        id: 'purchase-1',
        action: InvoiceAction.purchase,
        products: [_product(weight: 5)],
      ),
    );
    expect(
      provider.stockForProduct('Rice'),
      const ProductStock(quantity: 15, minOQ: 2),
    );

    await provider.saveInvoice(
      _invoice(
        id: 'sale-1',
        action: InvoiceAction.sale,
        products: [_product(weight: 3)],
      ),
    );
    expect(
      provider.stockForProduct('Rice'),
      const ProductStock(quantity: 12, minOQ: 2),
    );

    final prefs = await SharedPreferences.getInstance();
    final stored = json.decode(prefs.getString('master_product_stock')!);
    expect(stored['Rice'], {'quantity': 12, 'minOQ': 2});

    final reloaded = InvoiceProvider();
    await reloaded.loadMasterProducts();
    expect(reloaded.stockForProduct('Rice').quantity, 12);
  });

  test('storage invoices leave stock unchanged', () async {
    final provider = await seededProvider();

    await provider.saveInvoice(
      _invoice(
        id: 'storage-1',
        action: InvoiceAction.storage,
        products: [_product(weight: 99)],
      ),
    );

    expect(provider.stockForProduct('Rice').quantity, 10);
  });

  test(
    'replacing, editing and deleting an invoice never double-count it',
    () async {
      final provider = await seededProvider();

      await provider.saveInvoice(
        _invoice(
          id: 'inv-1',
          action: InvoiceAction.purchase,
          products: [_product(weight: 5)],
        ),
      );
      expect(provider.stockForProduct('Rice').quantity, 15);

      await provider.saveInvoice(
        _invoice(
          id: 'inv-1',
          action: InvoiceAction.purchase,
          products: [_product(weight: 8)],
        ),
      );
      expect(provider.stockForProduct('Rice').quantity, 18);

      await provider.updateInvoice(
        _invoice(
          id: 'inv-1',
          action: InvoiceAction.sale,
          products: [_product(weight: 2)],
        ),
      );
      // The old +8 is removed, then the new sale takes away another 2.
      expect(provider.stockForProduct('Rice').quantity, 8);

      await provider.deleteInvoice('inv-1');
      // Deleting the sale gives back its 2 units, returning to the manual 10.
      expect(provider.stockForProduct('Rice').quantity, 10);
    },
  );

  test('sales stop at zero instead of storing negative stock', () async {
    final provider = await seededProvider(quantity: 1);

    await provider.saveInvoice(
      _invoice(
        id: 'sale-1',
        action: InvoiceAction.sale,
        products: [_product(weight: 5)],
      ),
    );

    expect(provider.stockForProduct('Rice').quantity, 0);
  });

  test('package weight is removed before a line moves stock', () async {
    final provider = await seededProvider();

    await provider.saveInvoice(
      _invoice(
        id: 'purchase-1',
        action: InvoiceAction.purchase,
        products: [_product(weight: 10, packageWeight: 2, numberPackage: 2)],
      ),
    );

    // net weight = 10 - (2 * 2) = 6
    expect(provider.stockForProduct('Rice').quantity, 16);
  });

  test('restoring a backup applies and replaces stock effects', () async {
    final provider = await seededProvider();
    final original = _invoice(
      id: 'inv-1',
      action: InvoiceAction.purchase,
      products: [_product(weight: 5)],
    );
    await provider.saveInvoice(original);
    expect(provider.stockForProduct('Rice').quantity, 15);

    final backup = provider.exportBackup(now: DateTime(2026));
    await provider.deleteInvoice('inv-1');
    expect(provider.stockForProduct('Rice').quantity, 10);

    await provider.restoreBackup(backup);
    expect(provider.stockForProduct('Rice').quantity, 15);

    await provider.updateInvoice(
      _invoice(
        id: 'inv-1',
        action: InvoiceAction.purchase,
        products: [_product(weight: 9)],
      ),
    );
    expect(provider.stockForProduct('Rice').quantity, 19);

    await provider.restoreBackup(backup);
    expect(provider.stockForProduct('Rice').quantity, 15);
  });

  testWidgets('inventory updates when a purchase invoice is saved', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode(['Rice']),
      'master_product_prices': json.encode({
        'Rice': {'purchase': 12.5},
      }),
      'master_product_stock': json.encode({
        'Rice': {'quantity': 12, 'minOQ': 3},
      }),
    });
    final provider = InvoiceProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: provider)],
        child: MaterialApp(
          localizationsDelegates: const [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: const InventoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Quantity: 12'), findsOneWidget);

    await tester.runAsync(
      () => provider.saveInvoice(
        _invoice(
          id: 'purchase-1',
          action: InvoiceAction.purchase,
          products: [_product(weight: 5)],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Quantity: 17'), findsOneWidget);
    expect(provider.stockForProduct('Rice').quantity, 17);
  });
}
