// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:arqamy/core/providers/language.dart';
import 'package:arqamy/core/providers/theme.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
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

    await tester.tap(find.byTooltip('تغيير نوع الفاتورة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('بيع'));
    await tester.pumpAndSettle();
    expect(invoiceProvider.invoiceAction, 'بيع');
    expect(invoiceProvider.products, hasLength(1));
    expect(find.text('فاتورة: بيع'), findsOneWidget);
    expect(find.byTooltip('تغيير نوع الفاتورة'), findsOneWidget);

    await tester.tap(find.text('جديد'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'جديد'));
    await tester.pumpAndSettle();

    expect(invoiceProvider.products, isEmpty);
  });

  testWidgets('saving an invoice from the page does not share a PDF',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final invoiceProvider = InvoiceProvider()
      ..setCustomerName('Test customer')
      ..setInvoiceAction('شراء')
      ..addProduct(
        Product(
          name: 'Rice',
          weight: 5,
          packageWeight: 0,
          numberPackage: 0,
          price: 10,
        ),
      );

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

    await tester.ensureVisible(find.text('حفظ'));
    await tester.tap(find.widgetWithText(TextButton, 'حفظ'));
    await tester.pumpAndSettle();

    expect(invoiceProvider.invoices, hasLength(1));
    expect(invoiceProvider.invoices.single.customerName, 'Test customer');
    expect(
      (await SharedPreferences.getInstance()).getString('saved_invoices'),
      isNotNull,
    );
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('payment controls are outside the invoice preview',
      (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    tester.view.viewPadding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewPadding);
    SharedPreferences.setMockInitialValues({});
    final invoiceProvider = InvoiceProvider()..setInvoiceAction('شراء');
    for (var index = 0; index < 8; index++) {
      invoiceProvider.addProduct(
        Product(
          name: 'Product $index',
          weight: 5,
          packageWeight: 0,
          numberPackage: 0,
          price: 10,
        ),
      );
    }
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
    expect(find.text('معاينة '), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    final preview = find.byType(BottomSheet);
    expect(
      find.descendant(of: preview, matching: find.text('تحصيل')),
      findsNothing,
    );
    expect(
      find.descendant(of: preview, matching: find.text('حفظ')),
      findsNothing,
    );
    expect(
      find.descendant(of: preview, matching: find.text('مشاركة')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: preview,
        matching: find.byTooltip('مشاركة عبر واتساب'),
      ),
      findsNothing,
    );
    final sheetRect = tester.getRect(preview);
    await tester.flingFrom(
      Offset(sheetRect.center.dx, sheetRect.top + 24),
      const Offset(0, 500),
      1200,
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -2000),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('حفظ')).bottom, lessThanOrEqualTo(776));
    expect(
      tester.getRect(find.byTooltip('مشاركة عبر واتساب')).bottom,
      lessThanOrEqualTo(776),
    );
    expect(tester.takeException(), isNull);
  });


 testWidgets('invoice preview shows the current payment amount and actions',
      (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({});
    final invoiceProvider = InvoiceProvider()
      ..setInvoiceAction('شراء')
      ..addProduct(
        Product(
          name: 'Rice',
          weight: 5,
          packageWeight: 0,
          numberPackage: 0,
          price: 10,
        ),
      );

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

    final previewButton = find.byType(FloatingActionButton);
    expect(tester.getRect(previewButton).center.dx, greaterThan(180));
    await tester.ensureVisible(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'تحصيل',
      ),
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'تحصيل',
      ),
      '25',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(previewButton);
    await tester.pumpAndSettle();

    expect(find.text('إجمالي المبلغ: 50.00 L.E'), findsOneWidget);
    expect(find.text('التحصيل : 25.00 L.E'), findsOneWidget);
    expect(find.text('الباقي: 25.00 L.E'), findsOneWidget);

    final saveButton = find.ancestor(
      of: find.text('حفظ'),
      matching: find.byType(TextButton),
    );
    final sendButton = find.ancestor(
      of: find.text('إرسال'),
      matching: find.byType(TextButton),
    );
    expect(tester.getSize(saveButton).width, lessThan(100));
    expect(find.byTooltip('مشاركة عبر واتساب'), findsOneWidget);
    expect(tester.getSize(sendButton).width, greaterThan(100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('invoice summary can be dismissed by dragging its handle down',
      (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({});
    final invoiceProvider = InvoiceProvider()
      ..setInvoiceAction('شراء')
      ..addProduct(
        Product(
          name: 'Rice',
          weight: 5,
          packageWeight: 0,
          numberPackage: 0,
          price: 10,
        ),
      );

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
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final sheetRect = tester.getRect(find.byType(BottomSheet));
    await tester.flingFrom(
      Offset(sheetRect.center.dx, sheetRect.top + 24),
      const Offset(0, 500),
      1200,
    );
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('order entry fits tablet screens without clipping',
      (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Language()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => InvoiceProvider()),
          ChangeNotifierProvider(create: (_) => InvoiceSettingsProvider()),
        ],
        child: MyApp(appRouter: AppRouter()),
      ),
    );
    await tester.pumpAndSettle();

    final addButtonText = tester.getRect(find.text('أضف منتج'));
    final addButton = find.ancestor(
      of: find.text('أضف منتج'),
      matching: find.byType(TextButton),
    );
    final addButtonSize = tester.getSize(addButton);
    expect(addButtonText.left, greaterThanOrEqualTo(0));
    expect(addButtonText.right, lessThanOrEqualTo(1280));
    expect(addButtonSize.width, lessThanOrEqualTo(420));
    expect(addButtonSize.height, 52);
    expect(tester.takeException(), isNull);
  });

  testWidgets('order entry keeps the table and button text readable on mobile',
      (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({});
    final invoiceProvider = InvoiceProvider()
      ..setInvoiceAction('شراء')
      ..addProduct(
        Product(
          name: 'Rice',
          weight: 5,
          packageWeight: 0,
          numberPackage: 0,
          price: 10,
        ),
      );
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
    final tableSize = tester.getSize(find.byType(DataTable).first);
    final addButtonText = tester.getRect(find.text('أضف منتج'));
    final addButton = tester.getRect(
      find.ancestor(
        of: find.text('أضف منتج'),
        matching: find.byType(TextButton),
      ),
    );
    expect(tableSize.width, greaterThanOrEqualTo(320));
    expect(addButton.contains(addButtonText.topLeft), isTrue);
    expect(addButton.contains(addButtonText.bottomRight), isTrue);
    expect(tester.takeException(), isNull);
  });
}
