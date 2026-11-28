import 'dart:convert';

import 'package:arqamy/features/data/models/product_stock.dart';
import 'package:arqamy/features/inventoryscreen/ui/pages/inventory_screen.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode(['Rice', 'Sugar']),
    });
  });

  group('master product stock', () {
    test('missing stock starts at zero and persists edits', () async {
      final provider = InvoiceProvider();
      await provider.loadMasterProducts();
      expect(provider.stockForProduct('Rice'), ProductStock.empty);

      await provider.setMasterProductStock('Rice', quantity: 24, minOQ: 5);

      final reloaded = InvoiceProvider();
      await reloaded.loadMasterProducts();
      expect(reloaded.stockForProduct('Rice').quantity, 24);
      expect(reloaded.stockForProduct('Rice').minOQ, 5);
      expect(reloaded.stockForProduct('Sugar'), ProductStock.empty);
    });

    test('only updates the fields that were provided', () async {
      final provider = InvoiceProvider();
      await provider.loadMasterProducts();
      await provider.setMasterProductStock('Rice', quantity: 10, minOQ: 2);
      await provider.setMasterProductStock('Rice', quantity: 8);

      expect(provider.stockForProduct('Rice').quantity, 8);
      expect(provider.stockForProduct('Rice').minOQ, 2);
    });

    test(
      'rejects unknown products and negative or malformed saved values',
      () async {
        SharedPreferences.setMockInitialValues({
          'master_products': json.encode(['Rice']),
          'master_product_stock': json.encode({
            'Rice': {'quantity': -1, 'minOQ': 2},
            'Sugar': {'quantity': 5, 'minOQ': 1},
            'Broken': {'quantity': 'many', 'minOQ': 1},
          }),
        });
        final provider = InvoiceProvider();
        await provider.loadMasterProducts();

        expect(provider.stockForProduct('Rice'), ProductStock.empty);
        expect(provider.masterProductStock, isEmpty);

        await provider.setMasterProductStock('Sugar', quantity: 4);
        await provider.setMasterProductStock('Rice', quantity: -3, minOQ: 1);
        expect(provider.stockForProduct('Rice'), ProductStock.empty);
        expect(provider.stockForProduct('Sugar'), ProductStock.empty);
      },
    );

    test('renaming keeps stock and deleting removes it', () async {
      final provider = InvoiceProvider();
      await provider.loadMasterProducts();
      await provider.setMasterProductStock('Rice', quantity: 7, minOQ: 3);

      await provider.editMasterProduct(0, 'Brown Rice');
      expect(provider.stockForProduct('Brown Rice').quantity, 7);
      expect(provider.masterProductStock.containsKey('Rice'), isFalse);

      await provider.deleteMasterProduct(0);
      expect(provider.masterProductStock, isEmpty);
    });

    test('restoring a product list drops stock for removed products', () async {
      final provider = InvoiceProvider();
      await provider.loadMasterProducts();
      await provider.setMasterProductStock('Rice', quantity: 9, minOQ: 1);
      await provider.setMasterProductStock('Sugar', quantity: 4, minOQ: 2);

      await provider.replaceMasterProducts(['Rice'], const {});

      expect(provider.stockForProduct('Rice').quantity, 9);
      expect(provider.masterProductStock.containsKey('Sugar'), isFalse);

      final reloaded = InvoiceProvider();
      await reloaded.loadMasterProducts();
      expect(reloaded.masterProductStock.keys, ['Rice']);
    });
  });

  testWidgets('inventory follows the master product list and edits stock', (
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

    expect(find.text('Rice'), findsOneWidget);
    expect(find.textContaining('12.50'), findsOneWidget);
    expect(find.text('Sugar'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('edit-stock-Rice')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('inventory-quantity-field')),
      '20',
    );
    await tester.enterText(
      find.byKey(const ValueKey('inventory-minimum-field')),
      '5',
    );
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(ElevatedButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(provider.stockForProduct('Rice').quantity, 20);
    expect(provider.stockForProduct('Rice').minOQ, 5);
    final prefs = await SharedPreferences.getInstance();
    final stored = json.decode(prefs.getString('master_product_stock')!);
    expect(stored['Rice'], {'quantity': 20, 'minOQ': 5});

    await provider.addMasterProduct('Lentils');
    await tester.pumpAndSettle();
    expect(find.text('Lentils'), findsOneWidget);
  });
}
