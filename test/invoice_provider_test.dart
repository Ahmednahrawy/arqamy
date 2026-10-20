import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('caches product summaries and invalidates them after changes', () {
    final provider = InvoiceProvider();
    final firstProduct = Product(
      name: 'Rice',
      weight: 10,
      packageWeight: 1,
      numberPackage: 1,
      price: 5,
    );

    provider.addProduct(firstProduct);
    final productsView = provider.products;
    final groupedProducts = provider.groupedProducts;

    expect(provider.totalCost, 45);
    expect(provider.hasPackageProducts, isTrue);
    expect(identical(provider.products, productsView), isTrue);
    expect(identical(provider.groupedProducts, groupedProducts), isTrue);

    provider.addProduct(
      Product(
        name: 'Rice',
        weight: 5,
        packageWeight: 1,
        numberPackage: 1,
        price: 5,
      ),
    );

    expect(productsView, hasLength(1));
    expect(provider.products, hasLength(2));
    expect(provider.totalCost, 65);
    expect(provider.groupedProducts, hasLength(1));
    expect(identical(provider.groupedProducts, groupedProducts), isFalse);

    provider.updateProduct(
      1,
      Product(
        name: 'Beans',
        weight: 4,
        packageWeight: 0,
        numberPackage: 0,
        price: 10,
      ),
    );
    expect(provider.totalCost, 85);
    expect(provider.groupedProducts, hasLength(2));

    provider.removeProductAt(1);
    expect(provider.totalCost, 45);
    provider.clearInvoice();
    expect(provider.totalCost, 0);
    expect(provider.hasPackageProducts, isFalse);
    expect(provider.groupedProducts, isEmpty);
  });
}
