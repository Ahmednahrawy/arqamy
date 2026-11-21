import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter_test/flutter_test.dart';

// Half of the smallest money unit (0.01). A future decimal-safe
// implementation must also stay inside this tolerance.
const _halfCent = 0.005;

Product _product({
  required double weight,
  double packageWeight = 0,
  int numberPackage = 0,
  required double price,
}) {
  return Product(
    name: 'Item',
    weight: weight,
    packageWeight: packageWeight,
    numberPackage: numberPackage,
    price: price,
  );
}

void main() {
  test('fractional weights, packages and prices give the exact decimal total',
      () {
    final product = _product(
      weight: 12.345,
      packageWeight: 0.5,
      numberPackage: 2,
      price: 7.25,
    );

    expect(product.netWeight, closeTo(11.345, 1e-9));
    expect(product.totalPrice, closeTo(82.25, 1e-9));
  });

  test('many small lines add up to the exact decimal total', () {
    final products = List.generate(
      10,
      (_) => _product(weight: 0.1, price: 1.1),
    );

    expect(
      InvoiceProvider.calculateInvoiceTotal(products),
      closeTo(1.1, _halfCent),
    );
  });

  test('grouping identical products does not change the total', () {
    final provider = InvoiceProvider()
      ..addProduct(_product(weight: 1.1, price: 3.3))
      ..addProduct(_product(weight: 2.2, price: 3.3));

    expect(provider.groupedProducts, hasLength(1));
    expect(provider.totalCost, closeTo(10.89, 1e-9));
    expect(
      InvoiceProvider.calculateInvoiceTotal(provider.groupedProducts),
      closeTo(provider.totalCost, 1e-9),
    );
  });

  test('outstanding balance with fractional totals and payments', () {
    expect(
      InvoiceProvider.calculateOutstandingBalance(82.25125, 50.1),
      closeTo(32.15, 1e-9),
    );
  });
    test('merged summary lines add up to the invoice total', () {
    final provider = InvoiceProvider()
      ..addProduct(_product(weight: 0.5, price: 0.99))
      ..addProduct(_product(weight: 0.5, price: 0.99));

    expect(provider.totalCost, closeTo(1.00, 1e-9));
    expect(provider.groupedProducts.single.totalPrice, closeTo(1.00, 1e-9));
  });
}