import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    expect(firstProduct.netWeight, 9);
    expect(firstProduct.totalPrice, 45);
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
  test('deleting an invoice removes it from persistent storage', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = InvoiceProvider();
    final invoice = Invoice(
      id: 'invoice-1',
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
      formattedDate: '2026-10-20',
      formattedTime: '08:00',
      invoiceSerial: '1001',
    );

    await provider.saveInvoice(invoice);
    await provider.deleteInvoice(invoice.id);

    final reloadedProvider = InvoiceProvider();
    await reloadedProvider.loadInvoices();
    expect(reloadedProvider.invoices, isEmpty);
  });
  test('customer balance subtracts sales from purchases', () {
    Invoice invoice({
      required String id,
      required String action,
      required double rest,
    }) {
      return Invoice(
        id: id,
        customerName: 'Customer',
        products: const [],
        totalCost: rest,
        paid: 0,
        rest: rest,
        formattedDate: '2026-10-20',
        formattedTime: '08:00',
        invoiceAction: action,
        invoiceSerial: id,
      );
    }

    final balance = InvoiceProvider.calculateCustomerBalance([
      invoice(id: 'buy-1', action: 'شراء', rest: 125),
      invoice(id: 'buy-2', action: 'شراء', rest: 550),
      invoice(id: 'sale-1', action: 'بـيع', rest: 375),
      invoice(id: 'storage-1', action: 'تخزين', rest: 900),
    ]);

    expect(balance, 300);
  });
}
