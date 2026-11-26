import 'dart:convert';

import 'package:arqamy/config/routes/app_router.dart';
import 'package:arqamy/core/providers/language.dart';
import 'package:arqamy/core/providers/theme.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:arqamy/my_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> openOrderForm(
    WidgetTester tester,
    InvoiceProvider provider,
    String actionLabel,
  ) async {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode(['تمر سيوي']),
      'master_product_prices': json.encode({
        'تمر سيوي': {'purchase': 12.5, 'sale': 15.0, 'storage': 2.0},
      }),
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Language()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: provider),
          ChangeNotifierProvider(create: (_) => InvoiceSettingsProvider()),
        ],
        child: MyApp(appRouter: AppRouter()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(actionLabel));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اختر منتج'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(ListTile, 'تمر سيوي').last,
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
  }

  Finder fieldWithLabel(String label) => find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  );

  testWidgets(
    'the purchase default fills the form but stays editable per invoice',
    (WidgetTester tester) async {
      final provider = InvoiceProvider();
      await openOrderForm(tester, provider, 'شراء');

      expect(
        tester.widget<TextField>(fieldWithLabel('السعر')).controller!.text,
        '12.50',
      );

      await tester.enterText(fieldWithLabel('الوزن أو العدد'), '5');
      await tester.enterText(fieldWithLabel('السعر'), '9');
      await tester.tap(find.text('أضف منتج'));
      await tester.pumpAndSettle();

      expect(provider.products, hasLength(1));
      expect(provider.products.single.price, 9.0);

      final prefs = await SharedPreferences.getInstance();
      final stored = json.decode(prefs.getString('master_product_prices')!);
      expect(stored['تمر سيوي']['purchase'], 12.5);
    },
  );

  testWidgets('the sale default fills the form', (WidgetTester tester) async {
    await openOrderForm(tester, InvoiceProvider(), 'بيع');
    expect(
      tester.widget<TextField>(fieldWithLabel('السعر')).controller!.text,
      '15.00',
    );
  });

  testWidgets('the storage default fills the form', (
    WidgetTester tester,
  ) async {
    await openOrderForm(tester, InvoiceProvider(), 'تخزين');
    expect(
      tester.widget<TextField>(fieldWithLabel('السعر')).controller!.text,
      '2.00',
    );
  });
}
