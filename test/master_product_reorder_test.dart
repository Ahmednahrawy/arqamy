import 'dart:convert';

import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reorderMasterProducts takes the raw ReorderableListView index', () async {
    SharedPreferences.setMockInitialValues({
      'master_products': json.encode(['a', 'b', 'c', 'd']),
    });
    final provider = InvoiceProvider();
    await provider.loadMasterProducts();

    // Dragging "a" below "c" reports a raw new index of 3.
    await provider.reorderMasterProducts(0, 3);
    expect(provider.masterProductList, ['b', 'c', 'a', 'd']);

    // Dragging "d" to the top reports a raw new index of 0.
    await provider.reorderMasterProducts(3, 0);
    expect(provider.masterProductList, ['d', 'b', 'c', 'a']);
  });
}