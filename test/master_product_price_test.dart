import 'dart:convert';

import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('stores an optional default price and reloads it', () async {
    final provider = InvoiceProvider();
    await provider.loadMasterProducts();
    expect(provider.defaultProductPrice('Rice'), isNull);

    await provider.setMasterProductPrice('Rice', 12.5);
    expect(provider.masterProductPrices['Rice'], 12.5);

    final reloaded = InvoiceProvider();
    await reloaded.loadMasterProducts();
    expect(reloaded.defaultProductPrice('Rice'), 12.5);

    await reloaded.setMasterProductPrice('Rice', null);
    final cleared = InvoiceProvider();
    await cleared.loadMasterProducts();
    expect(cleared.masterProductPrices, isEmpty);
  });

  test('renaming or deleting a product keeps prices consistent', () async {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode(['a', 'b']),
      'master_product_prices': json.encode({'a': 3.5}),
    });
    final provider = InvoiceProvider();
    await provider.loadMasterProducts();
    expect(provider.defaultProductPrice('a'), 3.5);

    await provider.editMasterProduct(0, 'renamed');
    expect(provider.masterProductList, ['renamed', 'b']);
    expect(provider.defaultProductPrice('a'), isNull);
    expect(provider.defaultProductPrice('renamed'), 3.5);

    final afterRename = InvoiceProvider();
    await afterRename.loadMasterProducts();
    expect(afterRename.defaultProductPrice('renamed'), 3.5);

    await afterRename.deleteMasterProduct(0);
    final afterDelete = InvoiceProvider();
    await afterDelete.loadMasterProducts();
    expect(afterDelete.masterProductPrices, isEmpty);
  });

  test('invalid stored prices are ignored', () async {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode(['a', 'b', 'c']),
      'master_product_prices': json.encode({
        'a': 4,
        'b': -1,
        'c': 'not a number',
      }),
    });
    final provider = InvoiceProvider();
    await provider.loadMasterProducts();

    expect(provider.masterProductPrices, {'a': 4.0});
    expect(provider.defaultProductPrice('b'), isNull);
    expect(provider.defaultProductPrice('c'), isNull);
  });
}
