import 'dart:convert';

import 'package:arqamy/core/helpers/invoice_action.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('stores separate purchase, sale and storage defaults', () async {
    final provider = InvoiceProvider();
    await provider.loadMasterProducts();
    for (final action in InvoiceAction.values) {
      expect(provider.defaultProductPrice('Rice', action), isNull);
    }

    await provider.setMasterProductPrice('Rice', InvoiceAction.purchase, 12.5);
    await provider.setMasterProductPrice('Rice', InvoiceAction.sale, 15);
    await provider.setMasterProductPrice('Rice', InvoiceAction.storage, 2);

    final snapshot = provider.masterProductPrices['Rice'];
    expect(snapshot, isA<Map<InvoiceAction, double>>());
    expect(snapshot?[InvoiceAction.purchase], 12.5);
    expect(snapshot?[InvoiceAction.sale], 15);
    expect(snapshot?[InvoiceAction.storage], 2);

    final reloaded = InvoiceProvider();
    await reloaded.loadMasterProducts();
    expect(reloaded.defaultProductPrice('Rice', InvoiceAction.purchase), 12.5);
    expect(reloaded.defaultProductPrice('Rice', InvoiceAction.sale), 15);
    expect(reloaded.defaultProductPrice('Rice', InvoiceAction.storage), 2);

    await reloaded.setMasterProductPrice('Rice', InvoiceAction.sale, null);
    final cleared = InvoiceProvider();
    await cleared.loadMasterProducts();
    expect(cleared.defaultProductPrice('Rice', InvoiceAction.purchase), 12.5);
    expect(cleared.defaultProductPrice('Rice', InvoiceAction.sale), isNull);
    expect(cleared.defaultProductPrice('Rice', InvoiceAction.storage), 2);
  });

  test('adding a product stores all of its initial default prices', () async {
    final provider = InvoiceProvider();
    await provider.loadMasterProducts();

    await provider.addMasterProduct(
      'Lentils',
      prices: {
        InvoiceAction.purchase: 12.5,
        InvoiceAction.sale: 15.25,
        InvoiceAction.storage: 2,
      },
    );

    expect(provider.masterProductList, contains('Lentils'));
    final reloaded = InvoiceProvider();
    await reloaded.loadMasterProducts();
    expect(
      reloaded.defaultProductPrice('Lentils', InvoiceAction.purchase),
      12.5,
    );
    expect(reloaded.defaultProductPrice('Lentils', InvoiceAction.sale), 15.25);
    expect(reloaded.defaultProductPrice('Lentils', InvoiceAction.storage), 2);
  });

  test('replaces all products and prices when restoring a backup', () async {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode(['Old']),
      'master_product_prices': json.encode({
        'Old': {'sale': 99},
      }),
    });
    final provider = InvoiceProvider();
    await provider.loadMasterProducts();

    await provider.replaceMasterProducts(
      ['Lentils', 'Corn'],
      {
        'Lentils': {InvoiceAction.purchase: 12},
        'Corn': {InvoiceAction.sale: 7.5},
        'Removed': {InvoiceAction.sale: 1},
      },
    );

    expect(provider.masterProductList, ['Lentils', 'Corn']);
    final reloaded = InvoiceProvider();
    await reloaded.loadMasterProducts();
    expect(reloaded.masterProductList, ['Lentils', 'Corn']);
    expect(reloaded.defaultProductPrice('Lentils', InvoiceAction.purchase), 12);
    expect(reloaded.defaultProductPrice('Corn', InvoiceAction.sale), 7.5);
    expect(reloaded.defaultProductPrice('Old', InvoiceAction.sale), isNull);
    expect(reloaded.masterProductPrices.containsKey('Removed'), isFalse);
  });

  test('a legacy single price becomes the default for every action', () async {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode(['a', 'b']),
      'master_product_prices': json.encode({'a': 3.5}),
    });
    final provider = InvoiceProvider();
    await provider.loadMasterProducts();

    for (final action in InvoiceAction.values) {
      expect(provider.defaultProductPrice('a', action), 3.5);
    }
    expect(provider.defaultProductPrice('b', InvoiceAction.purchase), isNull);
  });

  test('renaming or deleting a product keeps all prices consistent', () async {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode(['a', 'b']),
      'master_product_prices': json.encode({
        'a': {'purchase': 3.5, 'sale': 4.5},
      }),
    });
    final provider = InvoiceProvider();
    await provider.loadMasterProducts();

    await provider.editMasterProduct(0, 'renamed');
    expect(provider.masterProductList, ['renamed', 'b']);
    expect(provider.defaultProductPrice('a', InvoiceAction.purchase), isNull);
    expect(
      provider.defaultProductPrice('renamed', InvoiceAction.purchase),
      3.5,
    );
    expect(provider.defaultProductPrice('renamed', InvoiceAction.sale), 4.5);

    final afterRename = InvoiceProvider();
    await afterRename.loadMasterProducts();
    expect(
      afterRename.defaultProductPrice('renamed', InvoiceAction.storage),
      isNull,
    );

    await afterRename.deleteMasterProduct(0);
    final afterDelete = InvoiceProvider();
    await afterDelete.loadMasterProducts();
    expect(afterDelete.masterProductPrices, isEmpty);
  });

  test('invalid stored prices are ignored', () async {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode(['a', 'b', 'c']),
      'master_product_prices': json.encode({
        'a': {'purchase': 4, 'sale': -1, 'storage': 'not a number'},
        'b': -1,
        'c': 'not a number',
      }),
    });
    final provider = InvoiceProvider();
    await provider.loadMasterProducts();

    expect(provider.defaultProductPrice('a', InvoiceAction.purchase), 4.0);
    expect(provider.defaultProductPrice('a', InvoiceAction.sale), isNull);
    expect(provider.defaultProductPrice('a', InvoiceAction.storage), isNull);
    expect(provider.defaultProductPrice('b', InvoiceAction.purchase), isNull);
    expect(provider.defaultProductPrice('c', InvoiceAction.purchase), isNull);
  });
}
