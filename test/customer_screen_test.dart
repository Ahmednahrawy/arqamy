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
  String? action = 'شراء',
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

Future<void> _selectFilterOption(
  WidgetTester tester, {
  required String key,
  required String option,
}) async {
  await tester.tap(find.byKey(const ValueKey('show-invoice-filters')));
  await tester.pumpAndSettle();
  final dropdown = find.byKey(ValueKey(key));
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('apply-invoice-filters')));
  await tester.pumpAndSettle();
}

Future<void> _resetInvoiceFilters(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('show-invoice-filters')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('reset-invoice-filters')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('apply-invoice-filters')));
  await tester.pumpAndSettle();
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
    expect(find.text('صافي مستحق لك'), findsOneWidget);
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
    expect(find.text('45.00 جنيه'), findsNWidgets(2));
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

  testWidgets(
      'recent invoices are visible and searchable before selecting a customer',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    final firstInvoice = _invoice(
      id: 'recent-first',
      customerName: 'Customer Alpha',
      invoiceSerial: 'REC-001',
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
    final secondInvoice = _invoice(
      id: 'recent-second',
      customerName: 'Supplier Beta',
      invoiceSerial: 'REC-002',
      products: [
        Product(
          name: 'Oats',
          weight: 1,
          packageWeight: 0,
          numberPackage: 0,
          price: 15,
        ),
      ],
    );
    await provider.saveInvoice(firstInvoice);
    await provider.saveInvoice(secondInvoice);

    await tester.pumpWidget(
      _customerScreen(provider, locale: const Locale('en')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recent invoices'), findsOneWidget);
    expect(find.text('Search by serial, product or customer'), findsOneWidget);
    expect(find.text('Invoice #REC-001'), findsOneWidget);
    expect(find.text('Invoice #REC-002'), findsOneWidget);
    expect(find.text('Customer name: Customer Alpha'), findsOneWidget);
    expect(find.text('Customer name: Supplier Beta'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Invoice #REC-002')).dy,
      lessThan(tester.getTopLeft(find.text('Invoice #REC-001')).dy),
    );

    final searchField = find.byKey(const ValueKey('customer-invoice-search'));
    await tester.enterText(searchField, 'supplier beta');
    await tester.pumpAndSettle();
    expect(find.text('Invoice #REC-002'), findsOneWidget);
    expect(find.text('Invoice #REC-001'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('clear-invoice-search')));
    await tester.pumpAndSettle();
    await tester.enterText(searchField, 'brown rice');
    await tester.pumpAndSettle();
    expect(find.text('Invoice #REC-001'), findsOneWidget);
    expect(find.text('Invoice #REC-002'), findsNothing);

    await tester.enterText(searchField, 'Oats');
    await tester.pumpAndSettle();
    expect(find.text('Invoice #REC-002'), findsOneWidget);
    expect(find.text('Invoice #REC-001'), findsNothing);

    await provider.updateInvoice(
      _invoice(
        id: secondInvoice.id,
        customerName: 'Supplier Beta',
        invoiceSerial: secondInvoice.invoiceSerial,
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
    await tester.pumpAndSettle();
    expect(find.text('No invoices match your search'), findsOneWidget);

    await tester.enterText(searchField, 'Brown Rice');
    await tester.pumpAndSettle();
    expect(find.text('Invoice #REC-002'), findsOneWidget);
    expect(find.text('Invoice #REC-001'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Customer Alpha');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Invoice #REC-001'), findsOneWidget);
    expect(find.text('Invoice #REC-002'), findsNothing);
    expect(
      tester.widget<TextField>(searchField).controller!.text,
      isEmpty,
    );
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
    await tester.scrollUntilVisible(
      find.text('فاتورة #legacy-serial'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
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
    expect(find.text('Invoice action'), findsNothing);
    expect(find.text('Payment status'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('show-invoice-filters')));
    await tester.pumpAndSettle();
    expect(find.text('Invoice filters'), findsOneWidget);
    expect(find.text('Invoice action'), findsOneWidget);
    expect(find.text('Payment status'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('customer-invoice-search')),
      'missing',
    );
    await tester.pumpAndSettle();

    expect(find.text('No invoices match your search'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('clear-invoice-search')));
    await tester.pumpAndSettle();
    expect(find.text('Invoice #SER-EN'), findsOneWidget);
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

  testWidgets('invoice action filters preserve unknown actions under All',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    await provider.saveInvoice(
      _invoice(id: 'action-purchase', action: 'شراء', invoiceSerial: 'ACT-1'),
    );
    await provider.saveInvoice(
      _invoice(id: 'action-sale', action: 'بـيع', invoiceSerial: 'ACT-2'),
    );
    await provider.saveInvoice(
      _invoice(id: 'action-storage', action: 'تخزين', invoiceSerial: 'ACT-3'),
    );
    await provider.saveInvoice(
      _invoice(id: 'action-null', action: null, invoiceSerial: 'ACT-4'),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'action-legacy',
        action: 'legacy',
        invoiceSerial: 'ACT-5',
      ),
    );

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('invoice-action-filter')), findsNothing);
    expect(find.byKey(const ValueKey('invoice-payment-status-filter')),
        findsNothing);
    expect(find.byKey(const ValueKey('show-invoice-filters')), findsOneWidget);
    for (final serial in ['ACT-1', 'ACT-2', 'ACT-3', 'ACT-4', 'ACT-5']) {
      expect(find.text('فاتورة #$serial'), findsOneWidget);
    }

    await _selectFilterOption(
      tester,
      key: 'invoice-action-filter',
      option: 'شراء',
    );
    expect(find.text('فاتورة #ACT-1'), findsOneWidget);
    expect(find.text('فاتورة #ACT-2'), findsNothing);

    await _selectFilterOption(
      tester,
      key: 'invoice-action-filter',
      option: 'بيع',
    );
    expect(find.text('فاتورة #ACT-2'), findsOneWidget);
    expect(find.text('فاتورة #ACT-1'), findsNothing);

    await _selectFilterOption(
      tester,
      key: 'invoice-action-filter',
      option: 'تخزين',
    );
    expect(find.text('فاتورة #ACT-3'), findsOneWidget);
    expect(find.text('فاتورة #ACT-2'), findsNothing);

    await _resetInvoiceFilters(tester);
    for (final serial in ['ACT-1', 'ACT-2', 'ACT-3', 'ACT-4', 'ACT-5']) {
      expect(find.text('فاتورة #$serial'), findsOneWidget);
    }
  });

  testWidgets('payment filters follow stored paid and rest semantics',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    await provider.saveInvoice(
      _invoice(
        id: 'paid',
        invoiceSerial: 'PAY-PAID',
        paid: 10,
        rest: 0,
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'zero-value',
        invoiceSerial: 'PAY-ZERO',
        paid: 0,
        rest: 0,
        totalCost: 0,
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'overpaid',
        invoiceSerial: 'PAY-OVERPAID',
        paid: 25,
        rest: -5,
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'partially-paid',
        invoiceSerial: 'PAY-PARTIAL',
        paid: 5,
        rest: 10,
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'unpaid',
        invoiceSerial: 'PAY-UNPAID',
        paid: 0,
        rest: 10,
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'negative-paid',
        invoiceSerial: 'PAY-NEGATIVE',
        paid: -1,
        rest: 10,
      ),
    );

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();
    await _selectFilterOption(
      tester,
      key: 'invoice-payment-status-filter',
      option: 'مدفوعة',
    );
    for (final serial in ['PAY-PAID', 'PAY-ZERO', 'PAY-OVERPAID']) {
      expect(find.text('فاتورة #$serial'), findsOneWidget);
    }
    expect(find.text('فاتورة #PAY-PARTIAL'), findsNothing);

    await _selectFilterOption(
      tester,
      key: 'invoice-payment-status-filter',
      option: 'مدفوعة جزئياً',
    );
    expect(find.text('فاتورة #PAY-PARTIAL'), findsOneWidget);
    expect(find.text('فاتورة #PAY-PAID'), findsNothing);

    await _selectFilterOption(
      tester,
      key: 'invoice-payment-status-filter',
      option: 'غير مدفوعة',
    );
    expect(find.text('فاتورة #PAY-UNPAID'), findsOneWidget);
    expect(find.text('فاتورة #PAY-NEGATIVE'), findsOneWidget);
    expect(find.text('فاتورة #PAY-PARTIAL'), findsNothing);
  });

  testWidgets('search combines with action and payment filters and resets',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    await provider.saveInvoice(
      _invoice(
        id: 'sale-brown-partial',
        action: 'بيع',
        paid: 5,
        rest: 10,
        invoiceSerial: 'COMB-1',
        products: [
          Product(
            name: 'Brown Rice',
            weight: 1,
            packageWeight: 0,
            numberPackage: 0,
            price: 10,
          ),
        ],
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'sale-brown-paid',
        action: 'بيع',
        paid: 15,
        rest: 0,
        invoiceSerial: 'COMB-2',
        products: [
          Product(
            name: 'Brown Rice',
            weight: 1,
            packageWeight: 0,
            numberPackage: 0,
            price: 10,
          ),
        ],
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'storage-brown-partial',
        action: 'تخزين',
        paid: 5,
        rest: 10,
        invoiceSerial: 'COMB-3',
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'sale-oats-partial',
        action: 'بيع',
        paid: 5,
        rest: 10,
        invoiceSerial: 'COMB-4',
        products: [
          Product(
            name: 'Oats',
            weight: 1,
            packageWeight: 0,
            numberPackage: 0,
            price: 10,
          ),
        ],
      ),
    );

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();
    await _selectFilterOption(
      tester,
      key: 'invoice-action-filter',
      option: 'بيع',
    );
    await _selectFilterOption(
      tester,
      key: 'invoice-payment-status-filter',
      option: 'مدفوعة جزئياً',
    );
    await tester.enterText(
      find.byKey(const ValueKey('customer-invoice-search')),
      'brown',
    );
    await tester.pumpAndSettle();
    expect(find.text('فاتورة #COMB-1'), findsOneWidget);
    expect(find.text('فاتورة #COMB-2'), findsNothing);
    expect(find.text('فاتورة #COMB-3'), findsNothing);
    expect(find.text('فاتورة #COMB-4'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('clear-invoice-search')));
    await tester.pumpAndSettle();
    expect(find.text('فاتورة #COMB-1'), findsOneWidget);
    expect(find.text('فاتورة #COMB-4'), findsOneWidget);
    expect(find.text('فاتورة #COMB-2'), findsNothing);

    await _resetInvoiceFilters(tester);
    for (final serial in ['COMB-1', 'COMB-2', 'COMB-3', 'COMB-4']) {
      expect(find.text('فاتورة #$serial'), findsOneWidget);
    }
  });

  testWidgets('customer changes reset filters and provider updates refresh',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    final customerAlphaInvoice = _invoice(
      id: 'alpha-sale',
      customerName: 'Customer Alpha',
      action: 'بيع',
      invoiceSerial: 'CUST-A',
    );
    final customerBetaSale = _invoice(
      id: 'beta-sale',
      customerName: 'Customer Beta',
      action: 'بيع',
      invoiceSerial: 'CUST-B-SALE',
    );
    await provider.saveInvoice(customerAlphaInvoice);
    await provider.saveInvoice(customerBetaSale);
    await provider.saveInvoice(
      _invoice(
        id: 'beta-purchase',
        customerName: 'Customer Beta',
        action: 'شراء',
        invoiceSerial: 'CUST-B-PURCHASE',
      ),
    );

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();
    final customerField = find.byType(TextFormField);
    await tester.enterText(customerField, 'Customer Alpha');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await _selectFilterOption(
      tester,
      key: 'invoice-action-filter',
      option: 'بيع',
    );
    expect(find.text('فاتورة #CUST-A'), findsOneWidget);

    await tester.enterText(customerField, 'Customer Beta');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('فاتورة #CUST-B-SALE'), findsOneWidget);
    expect(find.text('فاتورة #CUST-B-PURCHASE'), findsOneWidget);
    expect(find.text('فاتورة #CUST-A'), findsNothing);

    await _selectFilterOption(
      tester,
      key: 'invoice-action-filter',
      option: 'بيع',
    );
    expect(find.text('فاتورة #CUST-B-SALE'), findsOneWidget);
    expect(find.text('فاتورة #CUST-B-PURCHASE'), findsNothing);

    await provider.updateInvoice(
      _invoice(
        id: customerBetaSale.id,
        customerName: customerBetaSale.customerName,
        action: 'شراء',
        invoiceSerial: customerBetaSale.invoiceSerial,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('لا توجد فواتير تطابق البحث أو عوامل التصفية'),
      findsOneWidget,
    );
  });

  testWidgets('filters do not limit customer summaries or storage balance',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    final storageInvoice = _invoice(
      id: 'summary-storage',
      action: 'تخزين',
      totalCost: 30,
      paid: 15,
      rest: 15,
      invoiceSerial: 'SUM-STORAGE',
    );
    final purchaseInvoice = _invoice(
      id: 'summary-purchase',
      action: 'شراء',
      totalCost: 40,
      paid: 0,
      rest: 40,
      invoiceSerial: 'SUM-PURCHASE',
    );
    await provider.saveInvoice(storageInvoice);
    await provider.saveInvoice(purchaseInvoice);

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await _selectFilterOption(
      tester,
      key: 'invoice-action-filter',
      option: 'تخزين',
    );
    await _selectFilterOption(
      tester,
      key: 'invoice-payment-status-filter',
      option: 'مدفوعة جزئياً',
    );

    expect(find.text('فاتورة #SUM-STORAGE'), findsOneWidget);
    expect(find.text('فاتورة #SUM-PURCHASE'), findsNothing);
    expect(find.text('صافي مستحق للعميل'), findsOneWidget);
    expect(find.text('40.00 ج.م'), findsNWidgets(2));
    final storageSummary = find.byKey(
      const ValueKey('customer-storage-summary'),
    );
    expect(
      find.descendant(of: storageSummary, matching: find.text('30.00 ج.م')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: storageSummary, matching: find.text('1')),
      findsOneWidget,
    );

    await provider.updateInvoice(
      _invoice(
        id: purchaseInvoice.id,
        customerName: purchaseInvoice.customerName,
        action: purchaseInvoice.invoiceAction,
        totalCost: 40,
        paid: 0,
        rest: 50,
        invoiceSerial: purchaseInvoice.invoiceSerial,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('فاتورة #SUM-STORAGE'), findsOneWidget);
    expect(find.text('فاتورة #SUM-PURCHASE'), findsNothing);
    expect(find.text('50.00 ج.م'), findsNWidgets(2));
    expect(
      find.descendant(of: storageSummary, matching: find.text('30.00 ج.م')),
      findsOneWidget,
    );
    expect(find.text('الحساب متوازن'), findsNothing);
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
      (action: 'شراء', rest: 20.0, label: 'صافي مستحق للعميل'),
      (action: 'بيع', rest: 20.0, label: 'صافي مستحق لك'),
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

  testWidgets('invoice cards show stored amounts and matching payment status',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    await provider.saveInvoice(
      _invoice(
        id: 'card-zero-rest',
        invoiceSerial: 'CARD-PAID',
        totalCost: 50,
        paid: 50,
        rest: 0,
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'card-overpaid',
        invoiceSerial: 'CARD-OVERPAID',
        totalCost: 50,
        paid: 55,
        rest: -5,
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'card-partial',
        invoiceSerial: 'CARD-PARTIAL',
        totalCost: 100,
        paid: 40,
        rest: 60,
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'card-unpaid',
        invoiceSerial: 'CARD-UNPAID',
        totalCost: 75,
        paid: 0,
        rest: 75,
      ),
    );
    await provider.saveInvoice(
      _invoice(
        id: 'card-storage',
        action: 'تخزين',
        invoiceSerial: 'CARD-STORAGE',
        totalCost: 30,
        paid: 10,
        rest: 20,
      ),
    );

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();

    for (final id in ['card-zero-rest', 'card-overpaid']) {
      final card = find.byKey(ValueKey('invoice-card-$id'));
      expect(find.descendant(of: card, matching: find.text('مدفوعة')),
          findsOneWidget);
    }

    final partialCard = find.byKey(const ValueKey('invoice-card-card-partial'));
    expect(
      find.descendant(
        of: partialCard,
        matching: find.text('مدفوعة جزئياً'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: partialCard,
        matching: find.text('100.00 جنيه'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: partialCard,
        matching: find.text('40.00 جنيه'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: partialCard,
        matching: find.text('60.00 جنيه'),
      ),
      findsOneWidget,
    );

    final unpaidCard = find.byKey(const ValueKey('invoice-card-card-unpaid'));
    expect(
      find.descendant(of: unpaidCard, matching: find.text('غير مدفوعة')),
      findsOneWidget,
    );
    final storageCard = find.byKey(const ValueKey('invoice-card-card-storage'));
    expect(
      find.descendant(of: storageCard, matching: find.text('تخزين')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: storageCard,
        matching: find.text('مدفوعة جزئياً'),
      ),
      findsOneWidget,
    );

    final paidCard = find.byKey(const ValueKey('invoice-card-card-zero-rest'));
    expect(
      find.descendant(of: paidCard, matching: find.text('فاتورة #CARD-PAID')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: paidCard,
        matching: find.textContaining('التاريخ: Oct 28, 2026'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: paidCard, matching: find.text('50.00 جنيه')),
      findsNWidgets(2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('invoice card labels and direction follow the active locale',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    await provider.saveInvoice(
      _invoice(
        id: 'localized-card',
        action: 'بيع',
        invoiceSerial: 'LOCALIZED-1',
        totalCost: 20,
        paid: 5,
        rest: 15,
      ),
    );

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();
    final arabicCard =
        find.byKey(const ValueKey('invoice-card-localized-card'));
    expect(
      tester
          .widget<Directionality>(
            find.descendant(
                of: arabicCard, matching: find.byType(Directionality)),
          )
          .textDirection,
      TextDirection.rtl,
    );
    expect(find.text('بيع'), findsOneWidget);
    expect(find.text('مدفوعة جزئياً'), findsOneWidget);
    expect(find.text('إجمالي الفاتورة'), findsOneWidget);
    expect(find.text('المبلغ المدفوع'), findsOneWidget);
    expect(find.text('المبلغ المتبقي'), findsOneWidget);
    expect(find.textContaining('التاريخ: Oct 28, 2026'), findsOneWidget);

    await tester.pumpWidget(
      _customerScreen(provider, locale: const Locale('en')),
    );
    await tester.pumpAndSettle();
    final englishCard =
        find.byKey(const ValueKey('invoice-card-localized-card'));
    expect(
      tester
          .widget<Directionality>(
            find.descendant(
                of: englishCard, matching: find.byType(Directionality)),
          )
          .textDirection,
      TextDirection.ltr,
    );
    expect(find.text('Invoice #LOCALIZED-1'), findsOneWidget);
    expect(find.text('Sale'), findsOneWidget);
    expect(find.text('Partially paid'), findsOneWidget);
    expect(find.text('Invoice total'), findsOneWidget);
    expect(find.text('Amount paid'), findsOneWidget);
    expect(find.text('Outstanding balance'), findsOneWidget);
    expect(find.textContaining('Date: Oct 28, 2026'), findsOneWidget);
    expect(find.text('20.00 EGP'), findsOneWidget);
    expect(find.text('5.00 EGP'), findsOneWidget);
    expect(find.text('15.00 EGP'), findsOneWidget);
  });

  testWidgets('invoice cards fit narrow 320px and 360px screens',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    await provider.saveInvoice(
      _invoice(
        id: 'narrow-card',
        invoiceSerial: 'NARROW-320-360',
        customerName: 'A customer with a longer name',
        totalCost: 1234.56,
        paid: 234.56,
        rest: 1000,
      ),
    );

    for (final width in [320.0, 360.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(_customerScreen(provider));
      await tester.pumpAndSettle();
      final card = find.byKey(const ValueKey('invoice-card-narrow-card'));
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();

      expect(card, findsOneWidget);
      expect(find.text('إجمالي الفاتورة'), findsOneWidget);
      expect(find.text('المبلغ المدفوع'), findsOneWidget);
      expect(find.text('المبلغ المتبقي'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('invoice card opens details and retains invoice actions',
      (tester) async {
    _useTallViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    await provider.saveInvoice(_invoice(invoiceSerial: 'CARD-ACTIONS'));

    await tester.pumpWidget(_customerScreen(provider));
    await tester.pumpAndSettle();

    await tester.tap(find.text('فاتورة #CARD-ACTIONS'));
    await tester.pumpAndSettle();
    expect(find.text('الملخص المالي'), findsOneWidget);
    expect(find.text('إغلاق'), findsOneWidget);
    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('خيارات الفاتورة'));
    await tester.pumpAndSettle();
    expect(find.text('تعديل'), findsOneWidget);
    expect(find.text('مشاركة'), findsOneWidget);
    expect(find.text('حذف'), findsOneWidget);
  });
}
