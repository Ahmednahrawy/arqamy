import 'package:arqamy/features/customerscreen/ui/pages/customer_screen.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Invoice _invoice() {
  return Invoice(
    id: 'legacy-id',
    customerName: 'Customer',
    products: [
      Product(
        name: 'Rice',
        weight: 2,
        packageWeight: 0,
        numberPackage: 0,
        price: 10,
      ),
    ],
    totalCost: 20,
    paid: 0,
    rest: 20,
    formattedDate: 'Oct 28, 2026',
    formattedTime: '12:34',
    invoiceSerial: 'legacy-serial',
  );
}

Widget _customerScreen(InvoiceProvider provider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: provider),
      ChangeNotifierProvider(create: (_) => InvoiceSettingsProvider()),
    ],
    child: const MaterialApp(
      home: ScaffoldMessenger(
        child: CustomerScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('initial invoice load failure shows user-visible feedback',
      (tester) async {
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

    await tester.enterText(find.byType(TextField).last, '5');
    storage.failNextRead = true;
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

  testWidgets('successful delete removes invoice and closes confirmation',
      (tester) async {
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
