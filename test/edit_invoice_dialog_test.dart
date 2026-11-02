import 'package:arqamy/features/customerscreen/ui/widgets/edit_invoice_dialog.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Invoice _invoice({
  String id = 'legacy-id',
  String serial = 'legacy-serial',
  String customerName = 'Customer',
  String formattedDate = 'Oct 28, 2026',
  String formattedTime = '12:34',
  String? action = 'شراء',
  List<Product>? products,
  double paid = 5,
}) {
  final invoiceProducts = products ??
      [
        Product(
          name: 'Rice',
          weight: 10,
          packageWeight: 1,
          numberPackage: 2,
          price: 5,
        ),
      ];
  final total = InvoiceProvider.calculateInvoiceTotal(invoiceProducts);
  return Invoice(
    id: id,
    customerName: customerName,
    products: invoiceProducts,
    totalCost: total,
    paid: paid,
    rest: InvoiceProvider.calculateOutstandingBalance(total, paid),
    formattedDate: formattedDate,
    formattedTime: formattedTime,
    invoiceAction: action,
    invoiceSerial: serial,
  );
}

Widget _app(InvoiceProvider provider, {String languageCode = 'en'}) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp(
      locale: Locale(languageCode),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showDialog<bool>(
                context: context,
                builder: (_) => EditInvoiceDialog(
                  invoice: provider.invoices.single,
                ),
              ),
              child: const Text('Open editor'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openEditor(WidgetTester tester) async {
  await tester.tap(find.text('Open editor'));
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('edits product fields and invoice metadata, then reloads',
      (tester) async {
    _useTallViewport(tester);
    final provider = InvoiceProvider();
    final original = _invoice();
    await provider.saveInvoice(original);
    await tester.pumpWidget(_app(provider));
    await _openEditor(tester);

    await tester.enterText(
        find.byKey(const ValueKey('product-name-0')), 'Barley');
    await tester.enterText(
        find.byKey(const ValueKey('product-weight-0')), '12');
    await tester.enterText(
        find.byKey(const ValueKey('product-package-weight-0')), '1.5');
    await tester.enterText(
        find.byKey(const ValueKey('product-package-count-0')), '2');
    await tester.enterText(find.byKey(const ValueKey('product-price-0')), '4');
    await tester.enterText(
        find.byKey(const ValueKey('customer-name')), 'Updated customer');
    await tester.enterText(find.byKey(const ValueKey('paid-amount')), '10');
    await _tapVisible(tester, find.byKey(const ValueKey('invoice-action')));
    await tester.tap(find.text('Sale').last);
    await tester.pumpAndSettle();

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('select-invoice-date')),
    );
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '11/2/2026');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('select-invoice-time')),
    );
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    final timeFields = find.byType(TextField);
    await tester.enterText(
        timeFields.at(timeFields.evaluate().length - 2), '9');
    await tester.enterText(timeFields.last, '47');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Invoice total'), findsOneWidget);
    expect(find.text('36.00'), findsOneWidget);
    expect(find.text('26.00'), findsOneWidget);

    await _tapVisible(tester, find.text('Save changes'));

    final updated = provider.invoices.single;
    expect(updated.id, original.id);
    expect(updated.invoiceSerial, original.invoiceSerial);
    expect(updated.customerName, 'Updated customer');
    expect(updated.invoiceAction, 'بيع');
    expect(updated.products.single.name, 'Barley');
    expect(updated.products.single.weight, 12);
    expect(updated.products.single.packageWeight, 1.5);
    expect(updated.products.single.numberPackage, 2);
    expect(updated.products.single.price, 4);
    expect(updated.totalCost, 36);
    expect(updated.paid, 10);
    expect(updated.rest, 26);
    expect(updated.formattedDate, isNot(original.formattedDate));
    expect(updated.formattedTime, isNot(original.formattedTime));

    final reloaded = InvoiceProvider();
    await reloaded.loadInvoices();
    final persisted = reloaded.invoices.single;
    expect(persisted.id, original.id);
    expect(persisted.invoiceSerial, original.invoiceSerial);
    expect(persisted.toJson(), updated.toJson());
    expect(
      persisted.toJson().keys,
      {
        'id',
        'customerName',
        'products',
        'totalCost',
        'paid',
        'rest',
        'formattedDate',
        'formattedTime',
        'invoiceAction',
        'invoiceSerial',
      },
    );
  });

  testWidgets('adds and removes product rows', (tester) async {
    _useTallViewport(tester);
    final provider = InvoiceProvider();
    final original = _invoice();
    await provider.saveInvoice(original);
    await tester.pumpWidget(_app(provider));
    await _openEditor(tester);

    await _tapVisible(tester, find.byKey(const ValueKey('add-product')));
    expect(find.byKey(const ValueKey('product-name-1')), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('product-name-1')), 'Corn');
    await tester.enterText(find.byKey(const ValueKey('product-weight-1')), '3');
    await tester.enterText(
        find.byKey(const ValueKey('product-package-weight-1')), '0');
    await tester.enterText(
        find.byKey(const ValueKey('product-package-count-1')), '0');
    await tester.enterText(find.byKey(const ValueKey('product-price-1')), '7');

    await _tapVisible(tester, find.byKey(const ValueKey('remove-product-0')));
    expect(find.byKey(const ValueKey('product-name-0')), findsOneWidget);
    await _tapVisible(tester, find.text('Save changes'));

    expect(provider.invoices.single.products, hasLength(1));
    expect(provider.invoices.single.products.single.name, 'Corn');
    expect(provider.invoices.single.totalCost, 21);
  });

  testWidgets('invalid names and numeric input block saving', (tester) async {
    _useTallViewport(tester);
    final provider = InvoiceProvider();
    final original = _invoice();
    await provider.saveInvoice(original);
    await tester.pumpWidget(_app(provider));
    await _openEditor(tester);

    await tester.enterText(find.byKey(const ValueKey('product-name-0')), '  ');
    await tester.enterText(
        find.byKey(const ValueKey('product-weight-0')), 'NaN');
    await tester.enterText(
        find.byKey(const ValueKey('product-package-count-0')), '1.5');
    await tester.enterText(
        find.byKey(const ValueKey('paid-amount')), 'Infinity');
    await _tapVisible(tester, find.text('Save changes'));

    expect(provider.invoices.single.toJson(), original.toJson());
    expect(find.text('Enter a name'), findsOneWidget);
    expect(find.text('Enter a valid finite number'), findsNWidgets(2));
    expect(find.text('Enter a whole number'), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('persistence failure keeps the original invoice and editor open',
      (tester) async {
    _useTallViewport(tester);
    var failWrites = false;
    final provider = InvoiceProvider.withStorageWriter((json) async {
      if (failWrites) throw StateError('storage unavailable');
      return true;
    });
    final original = _invoice();
    await provider.saveInvoice(original);
    failWrites = true;
    await tester.pumpWidget(_app(provider, languageCode: 'ar'));
    await _openEditor(tester);
    await tester.enterText(
        find.byKey(const ValueKey('customer-name')), 'Changed customer');

    await _tapVisible(tester, find.text('حفظ التغييرات'));

    expect(provider.invoices.single.toJson(), original.toJson());
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.textContaining('تعذر حفظ تعديلات الفاتورة'), findsOneWidget);
  });

  testWidgets('Arabic and ISO legacy dates remain readable and unchanged',
      (tester) async {
    _useTallViewport(tester);
    final arabicDate = DateFormat.yMMMd('ar').format(DateTime(2026, 10, 28));
    final fixtures = [
      _invoice(
        formattedDate: arabicDate,
        formattedTime: DateFormat.Hm('ar').format(DateTime(1970, 1, 1, 12, 34)),
      ),
      _invoice(
        id: 'iso-id',
        serial: 'iso-serial',
        formattedDate: '2026-10-28',
        formattedTime: '08:00',
      ),
    ];

    for (final invoice in fixtures) {
      final provider = InvoiceProvider();
      await provider.saveInvoice(invoice);
      await tester.pumpWidget(_app(provider, languageCode: 'ar'));
      await _openEditor(tester);
      expect(find.textContaining('تعذر قراءة التاريخ أو الوقت المحفوظ'),
          findsNothing);
      await _tapVisible(tester, find.text('حفظ التغييرات'));

      expect(provider.invoices.single.formattedDate, invoice.formattedDate);
      expect(provider.invoices.single.formattedTime, invoice.formattedTime);
    }
  });
}
