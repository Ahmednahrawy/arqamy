import 'dart:convert';

import 'package:arqamy/core/helpers/product_list_constants.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:flutter/foundation.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceProvider extends ChangeNotifier {
  final List<Product> _products = [];
  String? _invoiceAction;
  String? _customerName;
  List<String> _masterProductList = [];
  final List<Invoice> _invoices = []; // قائمة الفواتير المخزنة
  List<Product>? _productsViewCache;
  List<Product>? _groupedProductsCache;
  double? _totalCostCache;
  bool? _hasPackageProductsCache;

  List<Product> get products =>
      _productsViewCache ??= List<Product>.unmodifiable(_products);
  String? get invoiceAction => _invoiceAction;
  String? get customerName => _customerName;
  List<String> get masterProductList => List.unmodifiable(_masterProductList);
  List<Invoice> get invoices => List.unmodifiable(_invoices);

  void setCustomerName(String name) {
    // if(_customerName == null){
    _customerName = name;
    notifyListeners();
    // }
  }

  double get totalCost {
    final cached = _totalCostCache;
    if (cached != null) {
      return cached;
    }
    var total = 0.0;
    for (final product in _products) {
      final netWeight =
          product.weight - (product.packageWeight * product.numberPackage);
      total += netWeight * product.price;
    }
    return _totalCostCache = total;
  }

  bool get hasPackageProducts {
    return _hasPackageProductsCache ??=
        _products.any((product) => product.numberPackage > 0);
  }

  bool get shouldShowPackageColumns {
    return hasPackageProducts;
  }

  // NEW: Detect if there are identical products (same name + price)
  bool get hasIdenticalProducts {
    return _products.length > groupedProducts.length;
  }

  // Set invoice action only once (locks the invoice)
  void setInvoiceAction(String action) {
    if (_invoiceAction == null) {
      _invoiceAction = action;
      notifyListeners();
    }
  }

  /// Add product (always keep as separate row)
  void addProduct(Product product) {
    _products.add(product);
    _invalidateProductSummaries();
    notifyListeners();
  }

  /// 👇 Grouped view for totals (used in totals table)
  List<Product> get groupedProducts {
    final cached = _groupedProductsCache;
    if (cached != null) {
      return cached;
    }
    final Map<String, Product> grouped = {};

    for (final p in _products) {
      final key = '${p.name}-${p.price}';
      if (grouped.containsKey(key)) {
        final existing = grouped[key]!;
        grouped[key] = Product(
          name: existing.name,
          weight: existing.weight + p.weight,
          packageWeight: existing.packageWeight,
          numberPackage: existing.numberPackage + p.numberPackage,
          price: existing.price,
        );
      } else {
        grouped[key] = p;
      }
    }
    return _groupedProductsCache = List<Product>.unmodifiable(grouped.values);
  }

  void updateProduct(int index, Product newProduct) {
    _products[index] = newProduct;
    _invalidateProductSummaries();
    notifyListeners();
  }

  void removeProductAt(int index) {
    _products.removeAt(index);
    _invalidateProductSummaries();
    notifyListeners();
  }

  // Reset invoice (products + action)
  void clearInvoice() {
    _products.clear();
    _invalidateProductSummaries();
    _invoiceAction = null;
    _customerName = null;
    notifyListeners();
  }

  void _invalidateProductSummaries() {
    _productsViewCache = null;
    _groupedProductsCache = null;
    _totalCostCache = null;
    _hasPackageProductsCache = null;
  }

  // 🔄 الدوال الجديدة لإدارة الفواتير
  Future<void> saveInvoice(Invoice invoice) async {
    _invoices.add(invoice);
    try {
      await _saveInvoicesToStorage();
    } catch (_) {
      _invoices.remove(invoice);
      rethrow;
    }
    notifyListeners();
  }

  Future<void> loadInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? invoicesJson = prefs.getString('saved_invoices');

      if (invoicesJson != null) {
        final List<dynamic> invoicesList = json.decode(invoicesJson);
        _invoices.clear();
        _invoices.addAll(invoicesList
            .map((invoiceJson) => Invoice.fromJson(invoiceJson))
            .toList());
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading invoices: $e');
    }
  }

  Future<void> _saveInvicesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final invoicesJson =
        json.encode(_invoices.map((invoice) => invoice.toJson()).toList());
    final saved = await prefs.setString('saved_invoices', invoicesJson);
    if (!saved) {
      throw StateError('Failed to save invoices to local storage');
    }
  }

  List<Invoice> getInvoicesByCustomer(String customerName) {
    return _invoices
        .where((invoice) => invoice.customerName
            .toLowerCase()
            .contains(customerName.toLowerCase()))
        .toList();
  }

  Future<void> deleteInvoice(String invoiceId) async {
    final index = _invoices.indexWhere((invoice) => invoice.id == invoiceId);
    if (index == -1) return;

    final invoice = _invoices.removeAt(index);
    try {
      await _saveInvoicesToStorage();
    } catch (_) {
      _invoices.insert(index, invoice);
      rethrow;
    }
    notifyListeners();
  }

  // Load products from local storage
  Future<void> loadMasterProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? productsJson = prefs.getString('master_products');

      if (productsJson != null) {
        final List<dynamic> productsList = json.decode(productsJson);
        _masterProductList = productsList.cast<String>();
      } else {
        // If no saved products, use default list
        _masterProductList = _getDefaultProducts();
        await _saveMasterProducts();
      }
      notifyListeners();
    } catch (e) {
      // If error, use default list
      _masterProductList = _getDefaultProducts();
      notifyListeners();
    }
  }

// Save products to local storage
  Future<void> _saveMasterProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String productsJson = json.encode(_masterProductList);
      await prefs.setString('master_products', productsJson);
    } catch (e) {
      debugPrint('Error saving products: $e');
    }
  }

// Add new product
  Future<void> addMasterProduct(String productName) async {
    if (productName.trim().isNotEmpty &&
        !_masterProductList.contains(productName.trim())) {
      _masterProductList.add(productName.trim());
      await _saveMasterProducts();
      notifyListeners();
    }
  }

  // Edit existing product
  Future<void> editMasterProduct(int index, String newName) async {
    if (index >= 0 &&
        index < _masterProductList.length &&
        newName.trim().isNotEmpty) {
      _masterProductList[index] = newName.trim();
      await _saveMasterProducts();
      notifyListeners();
    }
  }

  // Delete product
  Future<void> deleteMasterProduct(int index) async {
    if (index >= 0 && index < _masterProductList.length) {
      _masterProductList.removeAt(index);
      await _saveMasterProducts();
      notifyListeners();
    }
  }

  // Reorder products
  Future<void> reorderMasterProducts(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = _masterProductList.removeAt(oldIndex);
    _masterProductList.insert(newIndex, item);
    await _saveMasterProducts();
    notifyListeners();
  }

  // Default products (from your constants)
  List<String> _getDefaultProducts() {
    return ProductListConstants.productList;
  }
}
