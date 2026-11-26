import 'dart:convert';
import 'dart:io';

import 'package:arqamy/core/helpers/invoice_action.dart';
import 'package:arqamy/core/services/product_list_backup_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

const _products = ['Rice', 'Corn', 'Wheat'];

Map<String, Map<InvoiceAction, double>> _prices() => {
  'Rice': {
    InvoiceAction.purchase: 12.5,
    InvoiceAction.sale: 15,
    InvoiceAction.storage: 2,
  },
  'Corn': {InvoiceAction.sale: 7.25},
};

String _backupWith(String productsJson) => jsonEncode({
  'format': ProductListBackupService.format,
  'version': ProductListBackupService.version,
  'products': productsJson,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('round trips all products and prices with a versioned schema', () {
    final json = ProductListBackupService.encodeProducts(_products, _prices());
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    expect(decoded['format'], 'arqamy-products');
    expect(decoded['version'], 1);

    final backup = ProductListBackupService.decodeProducts(json);
    expect(backup.products, _products);
    expect(backup.prices['Rice'], _prices()['Rice']);
    expect(backup.prices['Corn'], _prices()['Corn']);
    expect(backup.prices.containsKey('Wheat'), isFalse);
  });

  test('rejects malformed files before anything can be restored', () {
    final wrongFormat = jsonEncode({
      'format': 'something-else',
      'version': 1,
      'products': [],
    });
    final wrongVersion = jsonEncode({
      'format': ProductListBackupService.format,
      'version': 2,
      'products': [],
    });
    final missingProducts = jsonEncode({
      'format': ProductListBackupService.format,
      'version': 1,
    });
    final unknownPriceType = _backupWith(
      jsonEncode([
        {
          'name': 'Rice',
          'defaultPrices': {'unknown': 1},
        },
      ]),
    );
    final negativePrice = _backupWith(
      jsonEncode([
        {
          'name': 'Rice',
          'defaultPrices': {'sale': -1},
        },
      ]),
    );
    final duplicateNames = _backupWith(
      jsonEncode([
        {'name': 'Rice'},
        {'name': 'Rice'},
      ]),
    );

    for (final text in [
      '',
      'not json',
      '[]',
      wrongFormat,
      wrongVersion,
      missingProducts,
      unknownPriceType,
      negativePrice,
      duplicateNames,
    ]) {
      expect(
        () => ProductListBackupService.decodeProducts(text),
        throwsA(isA<ProductListBackupFormatException>()),
        reason: 'should reject: $text',
      );
    }
  });

  test('accepts a byte-order mark and products without prices', () {
    final json = ProductListBackupService.encodeProducts(['Rice'], {});
    final backup = ProductListBackupService.decodeProducts('\uFEFF$json');
    expect(backup.products, ['Rice']);
    expect(backup.prices, isEmpty);
  });

  test('Android restore uses the app chooser channel', () async {
    final directory = await Directory.systemTemp.createTemp(
      'arqamy_pick_backup_test_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final backupPath = p.join(directory.path, 'chosen.json');
    await File(backupPath).writeAsString(
      ProductListBackupService.encodeProducts(
        ['Rice'],
        {
          'Rice': {InvoiceAction.sale: 7.5},
        },
      ),
    );

    String? pickedPath = backupPath;
    String? calledMethod;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const channel = MethodChannel('com.nahro.arqamy/backup');
    messenger.setMockMethodCallHandler(channel, (call) async {
      calledMethod = call.method;
      return pickedPath;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(channel, null);
      debugDefaultTargetPlatformOverride = null;
    });
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    final chosen = await ProductListBackupService.pickBackup();
    expect(calledMethod, 'pickBackupFile');
    expect(chosen!.products, ['Rice']);
    expect(chosen.prices['Rice']?[InvoiceAction.sale], 7.5);

    pickedPath = null;
    expect(await ProductListBackupService.pickBackup(), isNull);
  });

  test('saves the backup into the temporary directory', () async {
    final directory = await Directory.systemTemp.createTemp(
      'arqamy_product_backup_test_',
    );
    addTearDown(() => directory.delete(recursive: true));

    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getTemporaryDirectory') return directory.path;
      throw MissingPluginException('Unexpected method ${call.method}');
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    final path = await ProductListBackupService.generateAndSaveBackup(
      _products,
      _prices(),
      now: DateTime.utc(2026, 11, 26, 14, 30),
    );
    expect(p.dirname(path), directory.path);
    expect(p.basename(path), 'arqamy-products-20261126-1430.json');
    final decoded = ProductListBackupService.decodeProducts(
      await File(path).readAsString(),
    );
    expect(decoded.products, _products);
  });
}
