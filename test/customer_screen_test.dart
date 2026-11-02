import 'package:arqamy/features/customerscreen/ui/pages/customer_screen.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arqamy/generated/l10n.dart';

class _CustomerScreenStorage {
  bool failNextRead = false;
  bool failNextWrite = false;

  Future<String?> read() async {
    if (failNextRead) {
      failNextRead = false;
      throw StateError('storage unavailable');
    }
    return (await SharedPreferences.getInstance()).getString('saved_invoices');
  }

  Future<bool> write(String json) async {
    if (failNextWrite) {
      failNextWrite = false;
      throw StateError('storage unavailable');
    }
    return (await SharedPreferences.getInstance())
        .setString('saved_invoices', json);
  }
}

Invoice _invoice({
  String id = 'legacy-id',
  String customerName = 'Customer',
  String action = 'شراء',
  double rest = 20,
  double totalCost = 20,
  double paid = 0,
  List<Product>? products,
  String invoiceSerial = 'legacy-serial',
}) {
  return Invoice(
    id: id,
    customerName: customerName,
    products: products ??
        [
          Product(
            name: 'Rice',
            weight: 2,
            packageWeight: 0,
            numberPackage: 0,
            price: 10,
          ),
        ],
    totalCost: totalCost,
    paid: paid,
    rest: rest,
    formattedDate: 'Oct 28, 2026',
    formattedTime: '12:34',
    invoiceAction: action,
    invoiceSerial: invoiceSerial,
  );
}

Widget _customerScreen(
  InvoiceProvider provider, {
  Locale locale = const Locale('ar'),
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: provider),
      ChangeNotifierProvider(create: (_) => InvoiceSettingsProvider()),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const ScaffoldMessenger(
        child: CustomerScreen(),
      ),
    ),
  );
}

void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('initial invoice load failure shows user-visible feedback',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final storage = _CustomerScreenStorage()..failNextRead = true;
    final provider = InvoiceProvider.withStorageWriter(
      storage.write,
      invoiceStorageReader: storage.read,
    );

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('تعذر تحميل سجل الفواتير'),
      findsOneWidget,
    );
    expect(find.textContaining('storage unavailable'), findsOneWidget);
  });

  testWidgets('post-edit reload failure is reported after successful edit',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final storage = _CustomerScreenStorage();
    final provider = InvoiceProvider.withStorageWriter(
      storage.write,
      invoiceStorageReader: storage.read,
    );
    await provider.saveInvoice(_invoice());

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('فاتورة #legacy-serial'), findsOneWidget);

    await tester.tap(find.byTooltip('خيارات الفاتورة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تعديل'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('paid-amount')), '5');
    storage.failNextRead = true;
    await tester.ensureVisible(find.text('حفظ التغييرات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ التغييرات'));
    await tester.pumpAndSettle();

    expect(provider.invoices.single.id, 'legacy-id');
    expect(provider.invoices.single.invoiceSerial, 'legacy-serial');
    expect(provider.invoices.single.paid, 5);
    expect(
      find.textContaining('تم حفظ التعديل، لكن تعذر تحديث سجل الفواتير'),
      findsOneWidget,
    );
    expect(find.textContaining('storage unavailable'), findsOneWidget);
  });

  testWidgets('delete persistence failure reports error and keeps invoice',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final storage = _CustomerScreenStorage();
    final provider = InvoiceProvider.withStorageWriter(
      storage.write,
      invoiceStorageReader: storage.read,
    );
    await provider.saveInvoice(_invoice());

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('خيارات الفاتورة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف').last);
    await tester.pumpAndSettle();
    expect(find.text('تأكيد الحذف'), findsOneWidget);

    storage.failNextWrite = true;
    await tester.tap(find.widgetWithText(ElevatedButton, 'حذف'));
    await tester.pumpAndSettle();

    expect(find.text('تأكيد الحذف'), findsOneWidget);
    expect(find.text('فاتورة #legacy-serial'), findsOneWidget);
    expect(provider.invoices.single.id, 'legacy-id');
    expect(
      find.textContaining('تعذر حذف الفاتورة'),
      findsOneWidget,
    );
    expect(find.textContaining('storage unavailable'), findsOneWidget);
  });

  testWidgets('editing customer and action refreshes history and summary',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    await provider.saveInvoice(_invoice(action: 'تخزين'));

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('خيارات الفاتورة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تعديل'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('customer-name')),
      'Supplier A',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('invoice-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('invoice-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('بيع').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('حفظ التغييرات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ التغييرات'));
    await tester.pumpAndSettle();

    expect(provider.invoices.single.customerName, 'Supplier A');
    expect(provider.invoices.single.invoiceAction, 'بيع');
    expect(find.text('فاتورة #legacy-serial'), findsNothing);
    final oldCustomerStorageSummary = find.byKey(
      const ValueKey('customer-storage-summary'),
    );
    expect(
      find.descendant(
        of: oldCustomerStorageSummary,
        matching: find.text('0.00 ج.م'),
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField), 'Supplier A');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('فاتورة #legacy-serial'), findsOneWidget);
    expect(find.text('صافي مستحق للعميل'), findsOneWidget);
    expect(find.text('مشتريات'), findsOneWidget);
    expect(find.text('مبيعات'), findsOneWidget);
    final newCustomerStorageSummary = find.byKey(
      const ValueKey('customer-storage-summary'),
    );
    expect(
      find.descendant(
        of: newCustomerStorageSummary,
        matching: find.text('0.00 ج.م'),
      ),
      findsOneWidget,
    );
    expect(find.text('20.00 ج.م'), findsNWidgets(2));
  });

  testWidgets(
      'storage summary aggregates paid and unpaid invoices without changing '
      'purchase and sales totals', (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    await provider.saveInvoice(
      _invoice(
        id: 'storage-paid',
        action: 'تخزين',
        totalCost: 120,
        paid: 120,
        rest: 0,
        products: [
          Product(
            name: 'Rice',
            weight: 10,
            packageWeight: 1,
            numberPackage: 2,
            price: 5,
          ),
          Product(
            name: 'Beans',
            weight: 5,
            packageWeight: 0,
            numberPackage: 0,
            price: 8,
          ),
        ],
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'storage-unpaid',
        action: 'تخزين',
        totalCost: 60,
        paid: 0,
        rest: 60,
        products: [
          Product(
            name: 'Oil',
            weight: 20,
            packageWeight: 2,
            numberPackage: 3,
            price: 6,
          ),
        ],
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'purchase',
        action: 'شراء',
        totalCost: 100,
        rest: 100,
        products: const [],
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'sale',
        action: 'بيع',
        totalCost: 30,
        rest: 30,
        products: const [],
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'another-customer-storage',
        customerName: 'Supplier',
        action: 'تخزين',
        totalCost: 900,
        rest: 900,
        products: const [],
      ),
    );

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final storageSummary = find.byKey(
      const ValueKey('customer-storage-summary'),
    );
    expect(
      find.descendant(
        of: storageSummary,
        matching: find.text('180.00 ج.م'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: storageSummary,
        matching: find.text('27.00 كجم'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: storageSummary,
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    expect(find.text('100.00 ج.م'), findsOneWidget);
    expect(find.text('30.00 ج.م'), findsOneWidget);
    expect(find.text('70.00 ج.م'), findsOneWidget);
  });

  testWidgets(
      'provider updates refresh selected customer history and summaries',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    final original = _invoice(
      id: 'tracked-invoice',
      customerName: 'Customer',
      action: 'تخزين',
      totalCost: 20,
      rest: 20,
      products: [
        Product(
          name: 'Rice',
          weight: 2,
          packageWeight: 0,
          numberPackage: 0,
          price: 10,
        ),
      ],
    );
    await provider.saveInvoice(original);

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('فاتورة #legacy-serial'), findsOneWidget);
    final storageSummary = find.byKey(
      const ValueKey('customer-storage-summary'),
    );
    expect(
      find.descendant(of: storageSummary, matching: find.text('20.00 ج.م')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: storageSummary, matching: find.text('2.00 كجم')),
      findsOneWidget,
    );

    await provider.updateInvoice(
      _invoice(
        id: original.id,
        customerName: 'Customer',
        action: 'بيع',
        totalCost: 30,
        rest: 30,
        products: [
          Product(
            name: 'Rice',
            weight: 3,
            packageWeight: 0,
            numberPackage: 0,
            price: 10,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('فاتورة #legacy-serial'), findsOneWidget);
    expect(find.text('30.00 ج.م'), findsNWidgets(2));
    expect(
      find.descendant(of: storageSummary, matching: find.text('0.00 ج.م')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: storageSummary, matching: find.text('0.00 كجم')),
      findsOneWidget,
    );

    await provider.updateInvoice(
      _invoice(
        id: original.id,
        customerName: 'Customer Two',
        action: 'تخزين',
        totalCost: 45,
        rest: 45,
        products: [
          Product(
            name: 'Rice',
            weight: 5,
            packageWeight: 0,
            numberPackage: 0,
            price: 9,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('فاتورة #legacy-serial'), findsNothing);
    expect(
      find.descendant(of: storageSummary, matching: find.text('0.00 ج.م')),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField), 'Customer Two');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('فاتورة #legacy-serial'), findsOneWidget);
    expect(find.textContaining('الإجمالي 45.00 ج.م'), findsOneWidget);
    expect(
      find.descendant(of: storageSummary, matching: find.text('45.00 ج.م')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: storageSummary, matching: find.text('5.00 كجم')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: storageSummary, matching: find.text('1')),
      findsOneWidget,
    );
    expect(find.text('الحساب متوازن'), findsOneWidget);
    expect(provider.invoices.single.id, original.id);
    expect(provider.invoices.single.invoiceSerial, original.invoiceSerial);
  });

  testWidgets('customer history scrolls without overflow above the keyboard',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    await provider.saveInvoice(_invoice());

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('customer-invoice-search')));
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('فاتورة #legacy-serial'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('فاتورة #legacy-serial'), findsOneWidget);
  });

  testWidgets(
      'invoice search matches serial and normalized product names and clears',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    await provider.saveInvoice(
      _invoice(
        id: 'customer-one-1',
        invoiceSerial: 'SER-001',
        products: [
          Product(
            name: 'Brown Rice',
            weight: 2,
            packageWeight: 0,
            numberPackage: 0,
            price: 10,
          ),
        ],
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'customer-one-2',
        invoiceSerial: 'SER-002',
        products: [
          Product(
            name: 'Oats',
            weight: 1,
            packageWeight: 0,
            numberPackage: 0,
            price: 15,
          ),
        ],
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'customer-two',
        customerName: 'Customer Two',
        invoiceSerial: 'SER-003',
        products: [
          Product(
            name: 'Brown Rice',
            weight: 3,
            packageWeight: 0,
            numberPackage: 0,
            price: 12,
          ),
        ],
      ),
    );

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('فاتورة #SER-001'), findsOneWidget);
    expect(find.text('فاتورة #SER-002'), findsOneWidget);
    expect(find.text('فاتورة #SER-003'), findsNothing);

    final searchField = find.byKey(const ValueKey('customer-invoice-search'));
    await tester.enterText(searchField, '  ser-002  ');
    await tester.pumpAndSettle();
    expect(find.text('فاتورة #SER-002'), findsOneWidget);
    expect(find.text('فاتورة #SER-001'), findsNothing);
    expect(find.text('فاتورة #SER-003'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('clear-invoice-search')));
    await tester.pumpAndSettle();
    expect(find.text('فاتورة #SER-001'), findsOneWidget);
    expect(find.text('فاتورة #SER-002'), findsOneWidget);

    await tester.enterText(searchField, '  bRoWn    rice  ');
    await tester.pumpAndSettle();
    expect(find.text('فاتورة #SER-001'), findsOneWidget);
    expect(find.text('فاتورة #SER-002'), findsNothing);
    expect(find.text('فاتورة #SER-003'), findsNothing);

    await tester.enterText(searchField, 'SER-003');
    await tester.pumpAndSettle();
    expect(find.text('لا توجد فواتير تطابق البحث'), findsOneWidget);
    expect(find.text('فاتورة #SER-003'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('clear-invoice-search')));
    await tester.pumpAndSettle();
    expect(find.text('فاتورة #SER-001'), findsOneWidget);
    expect(find.text('فاتورة #SER-002'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Customer Two');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('فاتورة #SER-003'), findsOneWidget);
    expect(find.text('فاتورة #SER-001'), findsNothing);
    expect(find.text('فاتورة #SER-002'), findsNothing);
    expect(find.text('Clear search'), findsNothing);
  });

  testWidgets('invoice search empty state is localized in English',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    await provider.saveInvoice(
      _invoice(id: 'english-search', invoiceSerial: 'SER-EN'),
    );

    await tester.pumpWidget(
      _customerScreen(provider, locale: const Locale('en')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(
      find.text('Search by serial or product name'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const ValueKey('customer-invoice-search')),
      'missing',
    );
    await tester.pumpAndSettle();

    expect(find.text('No invoices match your search'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('clear-invoice-search')));
    await tester.pumpAndSettle();
    expect(find.text('فاتورة #SER-EN'), findsOneWidget);
  });

  testWidgets('invoice search results reflect provider updates',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    final invoice = _invoice(
      id: 'search-updated',
      invoiceSerial: 'SER-UPDATE',
      products: [
        Product(
          name: 'Brown Rice',
          weight: 2,
          packageWeight: 0,
          numberPackage: 0,
          price: 10,
        ),
      ],
    );
    await provider.saveInvoice(invoice);

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final searchField = find.byKey(const ValueKey('customer-invoice-search'));
    await tester.enterText(searchField, 'brown');
    await tester.pumpAndSettle();
    expect(find.text('فاتورة #SER-UPDATE'), findsOneWidget);

    await provider.updateInvoice(
      _invoice(
        id: invoice.id,
        invoiceSerial: invoice.invoiceSerial,
        products: [
          Product(
            name: 'White Rice',
            weight: 2,
            packageWeight: 0,
            numberPackage: 0,
            price: 10,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('فاتورة #SER-UPDATE'), findsNothing);
    expect(find.text('لا توجد فواتير تطابق البحث'), findsOneWidget);

    await provider.updateInvoice(
      _invoice(
        id: invoice.id,
        invoiceSerial: invoice.invoiceSerial,
        products: [
          Product(
            name: 'Brown Rice',
            weight: 2,
            packageWeight: 0,
            numberPackage: 0,
            price: 10,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('فاتورة #SER-UPDATE'), findsOneWidget);
  });

  testWidgets('storage summary shows localized zero values without storage',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    await provider.saveInvoice(
      _invoice(id: 'purchase-only', action: 'شراء'),
    );

    await tester.pumpWidget(
      _customerScreen(provider, locale: const Locale('en')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final storageSummary = find.byKey(
      const ValueKey('customer-storage-summary'),
    );
    expect(
      find.descendant(
        of: storageSummary,
        matching: find.text('Storage value'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: storageSummary, matching: find.text('0.00 EGP')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: storageSummary,
        matching: find.text('0.00 kg'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: storageSummary,
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('customer balance labels match positive negative and zero signs',
      (tester) async {
    _useTallViewport(tester);
    final scenarios = [
      (action: 'شراء', rest: 20.0, label: 'صافي مستحق لك'),
      (action: 'بيع', rest: 20.0, label: 'صافي مستحق للعميل'),
      (action: 'شراء', rest: 0.0, label: 'الحساب متوازن'),
    ];

    for (final scenario in scenarios) {
      SharedPreferences.setMockInitialValues({});
      final provider = InvoiceProvider();
      await provider.saveInvoice(
        _invoice(action: scenario.action, rest: scenario.rest),
      );

      await tester.pumpWidget(_customerScreen(provider));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Customer');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text(scenario.label), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('successful delete removes invoice and closes confirmation',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final storage = _CustomerScreenStorage();
    final provider = InvoiceProvider.withStorageWriter(
      storage.write,
      invoiceStorageReader: storage.read,
    );
    await provider.saveInvoice(_invoice());

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('خيارات الفاتورة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'حذف'));
    await tester.pumpAndSettle();

    expect(find.text('تأكيد الحذف'), findsNothing);
    expect(find.text('فاتورة #legacy-serial'), findsNothing);
    expect(provider.invoices, isEmpty);
    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(reloadedProvider.invoices, isEmpty);
  });
}
