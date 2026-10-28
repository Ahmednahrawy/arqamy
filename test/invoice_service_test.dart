import 'dart:io';

import 'package:arqamy/core/services/invoice_service.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PDF files use safe, unique names and remain shareable via WhatsApp',
      () async {
    SharedPreferences.setMockInitialValues({});
    final tempDirectory = await Directory.systemTemp.createTemp(
      'arqamy_invoice_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));

    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const pathProviderChannel =
        MethodChannel('plugins.flutter.io/path_provider');
    const whatsappChannel = MethodChannel('com.nahro.arqamy/whatsapp');
    messenger.setMockMethodCallHandler(pathProviderChannel, (call) async {
      if (call.method == 'getTemporaryDirectory') return tempDirectory.path;
      throw MissingPluginException('Unexpected method ${call.method}');
    });

    String? whatsappFilePath;
    messenger.setMockMethodCallHandler(whatsappChannel, (call) async {
      expect(call.method, 'sharePdfToWhatsApp');
      whatsappFilePath = (call.arguments as Map)['filePath'] as String;
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(pathProviderChannel, null);
      messenger.setMockMethodCallHandler(whatsappChannel, null);
      debugDefaultTargetPlatformOverride = null;
    });

    final provider = InvoiceProvider()
      ..addProduct(
        Product(
          name: 'Rice',
          weight: 2,
          packageWeight: 0,
          numberPackage: 0,
          price: 10,
        ),
      );
    final settings = InvoiceSettingsProvider();
    await settings.loadSettings();
    const sameCustomer = '../Customer:*?<>|.';
    const sameDate = 'Oct 28, 2026';
    const sameTime = '12:34';
    final firstId = Invoice.generateId();
    final secondId = Invoice.generateId();

    final firstPath = await InvoiceService.generateAndSaveInvoice(
      provider: provider,
      settings: settings,
      customerName: sameCustomer,
      invoiceId: firstId,
      totalCost: 20,
      paid: 0,
      rest: 20,
      formattedDate: sameDate,
      formattedTime: sameTime,
      invoiceAction: 'شراء',
      invoiceSerial: '1001',
    );
    final secondPath = await InvoiceService.generateAndSaveInvoice(
      provider: provider,
      settings: settings,
      customerName: sameCustomer,
      invoiceId: secondId,
      totalCost: 20,
      paid: 0,
      rest: 20,
      formattedDate: sameDate,
      formattedTime: sameTime,
      invoiceAction: 'شراء',
      invoiceSerial: '1001',
    );

    expect(firstPath, isNot(secondPath));
    expect(p.dirname(firstPath), tempDirectory.path);
    expect(p.basename(firstPath), contains(firstId));
    expect(p.basename(secondPath), contains(secondId));
    expect(p.basename(firstPath), matches(RegExp(r'^[^<>:"/\\|?*]+$')));
    expect(p.basename(firstPath).contains('..'), isFalse);
    expect(await File(firstPath).exists(), isTrue);
    expect(await File(secondPath).exists(), isTrue);
    expect(
      String.fromCharCodes((await File(firstPath).readAsBytes()).take(5)),
      '%PDF-',
    );

    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await InvoiceService.generateAndShareInvoiceToWhatsApp(
      provider: provider,
      settings: settings,
      customerName: sameCustomer,
      invoiceId: firstId,
      totalCost: 20,
      paid: 0,
      rest: 20,
      formattedDate: sameDate,
      formattedTime: sameTime,
      invoiceAction: 'شراء',
      invoiceSerial: '1001',
    );

    expect(whatsappFilePath, isNotNull);
    expect(await File(whatsappFilePath!).exists(), isTrue);
  });
}
