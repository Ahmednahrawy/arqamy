// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:arqamy/core/providers/language.dart';
import 'package:arqamy/core/providers/theme.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/orderscreen/ui/pages/order_screen.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arqamy/config/routes/app_router.dart';
import 'package:arqamy/my_app.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('selecting a product allows adding it to the invoice',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final invoiceProvider = InvoiceProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Language()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: invoiceProvider),
          ChangeNotifierProvider(create: (_) => InvoiceSettingsProvider()),
        ],
        child: MyApp(appRouter: AppRouter()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Orderscreen), findsOneWidget);

    await tester.tap(find.text('شراء'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اختر منتج'));
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .ancestor(
            of: find.text('تمر سيوي').last,
            matching: find.byType(ListTile),
          )
          .last,
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'الوزن أو العدد',
      ),
      '5',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'السعر',
      ),
      '10',
    );
    await tester.tap(find.text('أضف منتج'));
    await tester.pumpAndSettle();
    expect(invoiceProvider.products, hasLength(1));
    expect(invoiceProvider.products.single.name, 'تمر سيوي');
    await tester.tap(find.text('جديد'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'جديد'));
    await tester.pumpAndSettle();

    expect(invoiceProvider.products, isEmpty);
  });
}
