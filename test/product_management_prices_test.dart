import 'dart:convert';

import 'package:arqamy/core/helpers/invoice_action.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/settingscreen/ui/pages/product_management.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester, InvoiceProvider provider) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const ProductManagementScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('product management shows all three optional prices', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode(['Rice']),
      'master_product_prices': json.encode({
        'Rice': {'purchase': 1.0, 'sale': 2.0, 'storage': 3.0},
      }),
    });
    final provider = InvoiceProvider();
    await pumpScreen(tester, provider);

    for (final entry in {
      'purchase': '1.00',
      'sale': '2.00',
      'storage': '3.00',
    }.entries) {
      final field = find.byKey(
        ValueKey('product-default-price-Rice-${entry.key}'),
      );
      expect(field, findsOneWidget);
      expect(tester.widget<TextField>(field).controller!.text, entry.value);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('add dialog saves a default price for every invoice type', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode([]),
    });
    final provider = InvoiceProvider();
    await pumpScreen(tester, provider);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('add-product-name')), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('add-product-name')),
      'Lentils',
    );
    final prices = {'purchase': '12.50', 'sale': '15.25', 'storage': '2.00'};
    for (final entry in prices.entries) {
      final field = find.byKey(
        ValueKey('add-product-default-price-${entry.key}'),
      );
      expect(field, findsOneWidget);
      await tester.enterText(field, entry.value);
    }

    await tester.tap(find.widgetWithText(ElevatedButton, 'Add product'));
    await tester.pumpAndSettle();

    expect(provider.masterProductList, ['Lentils']);
    expect(
      provider.defaultProductPrice('Lentils', InvoiceAction.purchase),
      12.5,
    );
    expect(provider.defaultProductPrice('Lentils', InvoiceAction.sale), 15.25);
    expect(provider.defaultProductPrice('Lentils', InvoiceAction.storage), 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add dialog rejects an invalid default price', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode([]),
    });
    final provider = InvoiceProvider();
    await pumpScreen(tester, provider);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('add-product-name')),
      'Lentils',
    );
    await tester.enterText(
      find.byKey(const ValueKey('add-product-default-price-purchase')),
      '-1',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add product'));
    await tester.pumpAndSettle();

    expect(provider.masterProductList, isEmpty);
    expect(find.byKey(const ValueKey('add-product-name')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('product management exposes backup and restore buttons', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode([]),
    });
    await pumpScreen(tester, InvoiceProvider());

    final exportButton = find.byKey(const ValueKey('export-products'));
    final importButton = find.byKey(const ValueKey('import-products'));
    expect(exportButton, findsOneWidget);
    expect(importButton, findsOneWidget);
    expect(find.byTooltip('Export products'), findsOneWidget);
    expect(find.byTooltip('Import products'), findsOneWidget);

    await tester.tap(exportButton);
    await tester.pumpAndSettle();
    expect(find.text('There are no products to export'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search filters products and clear restores the full list', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode(['Rice', 'Corn', 'Wheat']),
    });
    await pumpScreen(tester, InvoiceProvider());

    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('Corn'), findsOneWidget);
    expect(find.text('Wheat'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('product-management-search')),
      'co',
    );
    await tester.pumpAndSettle();

    expect(find.text('Rice'), findsNothing);
    expect(find.text('Corn'), findsOneWidget);
    expect(find.text('Wheat'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('clear-product-search')));
    await tester.pumpAndSettle();

    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('Corn'), findsOneWidget);
    expect(find.text('Wheat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
