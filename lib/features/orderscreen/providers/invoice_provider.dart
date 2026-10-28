import 'dart:async';
import 'dart:convert';

import 'package:arqamy/core/helpers/product_list_constants.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:flutter/foundation.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceProvider extends ChangeNotifier {
  InvoiceProvider()
      : _invoiceStorageWriter = null,
        _invoiceStorageReader = null;

  @visibleForTesting
  InvoiceProvider.withStorageWriter(
    this._invoiceStorageWriter, {
    Future<String?> Function()? invoiceStorageReader,
  }) : _invoiceStorageReader = invoiceStorageReader;

  final Future<bool> Function(String invoicesJson)? _invoiceStorageWriter;
  final Future<String?> Function()? _invoiceStorageReader;
  Future<void> _invoiceMutationQueue = Future<void>.value();
  String? _draftInvoiceId;
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
  String get draftInvoiceId => _draftInvoiceId ??= Invoice.generateId();

  void prepareDraft() {
    _draftInvoiceId ??= Invoice.generateId();
  }

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
      total += product.totalPrice;
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
    if (_invoiceAction == action) return;
    _invoiceAction = action;
    notifyListeners();
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
    _draftInvoiceId = Invoice.generateId();
    notifyListeners();
  }

  void _invalidateProductSummaries() {
    _productsViewCache = null;
    _groupedProductsCache = null;
    _totalCostCache = null;
    _hasPackageProductsCache = null;
  }

  // 🔄 الدوال الجديدة لإدارة الفواتير
  Future<void> saveInvoice(Invoice invoice) {
    return _withInvoiceMutationLock(() async {
      final updatedInvoices = List<Invoice>.of(_invoices);
      final index = _uniqueInvoiceIndex(invoice.id);
      if (index == -1) {
        updatedInvoices.add(invoice);
      } else {
        updatedInvoices[index] = invoice;
      }

      await _saveInvoicesToStorage(updatedInvoices);
      _replaceInvoices(updatedInvoices);
      notifyListeners();
    });
  }

  Future<void> updateInvoice(Invoice invoice) {
    return _withInvoiceMutationLock(() async {
      final updatedInvoices = List<Invoice>.of(_invoices);
      final index = _uniqueInvoiceIndex(invoice.id);
      if (index == -1) {
        throw StateError('Invoice ${invoice.id} was not found');
      }
      updatedInvoices[index] = invoice;

      await _saveInvoicesToStorage(updatedInvoices);
      _replaceInvoices(updatedInvoices);
      notifyListeners();
    });
  }

  Future<T> _withInvoiceMutationLock<T>(
    Future<T> Function() mutation,
  ) async {
    final previousMutation = _invoiceMutationQueue;
    final release = Completer<void>();
    _invoiceMutationQueue = release.future;
    await previousMutation;
    try {
      return await mutation();
    } finally {
      release.complete();
    }
  }

  Future<void> loadInvoices() {
    return _withInvoiceMutationLock(() async {
      try {
        final String? invoicesJson = _invoiceStorageReader != null
            ? await _invoiceStorageReader()
            : (await SharedPreferences.getInstance())
                .getString('saved_invoices');

        if (invoicesJson != null) {
          final List<dynamic> invoicesList = json.decode(invoicesJson);
          final loadedInvoices = invoicesList
              .map((invoiceJson) => Invoice.fromJson(invoiceJson))
              .toList();
          _replaceInvoices(loadedInvoices);
        }
        notifyListeners();
      } catch (error) {
        debugPrint('Error loading invoices: $error');
        rethrow;
      }
    });
  }

  Future<void> _saveInvoicesToStorage(List<Invoice> invoices) async {
    final invoicesJson =
        json.encode(invoices.map((invoice) => invoice.toJson()).toList());
    final saved = _invoiceStorageWriter != null
        ? await _invoiceStorageWriter(invoicesJson)
        : await (await SharedPreferences.getInstance())
            .setString('saved_invoices', invoicesJson);
    if (!saved) {
      throw StateError('Failed to save invoices to local storage');
    }
  }

  int _uniqueInvoiceIndex(String invoiceId) {
    var match = -1;
    for (var index = 0; index < _invoices.length; index++) {
      if (_invoices[index].id != invoiceId) continue;
      if (match != -1) {
        throw StateError('Multiple invoices have the ID $invoiceId');
      }
      match = index;
    }
    return match;
  }

  void _replaceInvoices(List<Invoice> invoices) {
    _invoices
      ..clear()
      ..addAll(invoices);
  }

  List<Invoice> getInvoicesByCustomer(String customerName) {
    return _invoices
        .where((invoice) => invoice.customerName
            .toLowerCase()
            .contains(customerName.toLowerCase()))
        .toList();
  }

  static double calculateCustomerBalance(Iterable<Invoice> invoices) {
    return invoices.fold(0.0, (balance, invoice) {
      final action = invoice.invoiceAction?.replaceAll('\u0640', '').trim();
      switch (action) {
        case 'شراء':
          return balance + invoice.rest;
        case 'بيع':
          return balance - invoice.rest;
        case 'تخزين':
          return balance;
        default:
          return balance + invoice.rest;
      }
    });
  }

  Future<void> deleteInvoice(String invoiceId) {
    return _withInvoiceMutationLock(() async {
      final index = _uniqueInvoiceIndex(invoiceId);
      if (index == -1) return;

      final updatedInvoices = List<Invoice>.of(_invoices)..removeAt(index);
      await _saveInvoicesToStorage(updatedInvoices);
      _replaceInvoices(updatedInvoices);
      notifyListeners();
    });
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
