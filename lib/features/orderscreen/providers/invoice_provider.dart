import 'dart:async';
import 'dart:convert';

import 'package:arqamy/core/helpers/product_list_constants.dart';
import 'package:arqamy/core/helpers/money.dart';
import 'package:arqamy/core/helpers/invoice_discount.dart';
import 'package:arqamy/core/helpers/invoice_backup.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/core/helpers/invoice_action.dart';
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
  final Map<String, Map<InvoiceAction, double>> _masterProductPrices = {};
  final List<Invoice> _invoices = []; // قائمة الفواتير المخزنة
  bool _invoicesLoaded = false;
  List<Product>? _productsViewCache;
  List<Product>? _groupedProductsCache;
  double? _totalCostCache;
  bool? _hasPackageProductsCache;

  List<Product> get products =>
      _productsViewCache ??= List<Product>.unmodifiable(_products);
  String? get invoiceAction => _invoiceAction;
  String? get customerName => _customerName;
  List<String> get masterProductList => List.unmodifiable(_masterProductList);
  Map<String, Map<InvoiceAction, double>> get masterProductPrices =>
      Map<String, Map<InvoiceAction, double>>.unmodifiable({
        for (final entry in _masterProductPrices.entries)
          entry.key: Map<InvoiceAction, double>.unmodifiable(entry.value),
      });
  List<Invoice> get invoices => List.unmodifiable(_invoices);
  String get draftInvoiceId => _draftInvoiceId ??= Invoice.generateId();

  double? defaultProductPrice(String productName, InvoiceAction action) =>
      _masterProductPrices[productName]?[action];

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
    return _totalCostCache = calculateInvoiceTotal(_products);
  }

  static double calculateInvoiceTotal(Iterable<Product> products) {
    return Money.sum(products.map((product) => product.lineTotal)).toDouble();
  }

  static double calculateOutstandingBalance(double totalCost, double paid) {
    final remaining =
        Money.fromDouble(totalCost).abs() - Money.fromDouble(paid);
    return remaining.toDouble();
  }

  /// Payable total after applying a resolved discount to the product subtotal.
  static double calculatePayableTotal(
    double subtotal,
    InvoiceDiscount? discount,
  ) =>
      InvoiceDiscount.payableTotal(subtotal, discount);

  bool get hasPackageProducts {
    return _hasPackageProductsCache ??= _products.any(
      (product) => product.numberPackage > 0,
    );
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
    final Map<(String, double, double), Product> grouped = {};

    for (final p in _products) {
      final key = (p.name, p.price, p.packageWeight);
      if (grouped.containsKey(key)) {
        final existing = grouped[key]!;
        grouped[key] = Product(
          name: existing.name,
          weight: existing.weight + p.weight,
          packageWeight: existing.packageWeight,
          numberPackage: existing.numberPackage + p.numberPackage,
          price: existing.price,
          lineTotalOverride: existing.lineTotal + p.lineTotal,
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
      await _ensureInvoicesLoaded();
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
      await _ensureInvoicesLoaded();
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

  Future<T> _withInvoiceMutationLock<T>(Future<T> Function() mutation) async {
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
    return _withInvoiceMutationLock(_loadInvoicesFromStorage);
  }

  Future<void> _ensureInvoicesLoaded() async {
    if (_invoicesLoaded) return;
    await _loadInvoicesFromStorage();
  }

  // Must only be called while holding _invoiceMutationQueue.
  Future<void> _loadInvoicesFromStorage() async {
    try {
      final String? invoicesJson = _invoiceStorageReader != null
          ? await _invoiceStorageReader()
          : (await SharedPreferences.getInstance()).getString('saved_invoices');

      if (invoicesJson != null) {
        final List<dynamic> invoicesList = json.decode(invoicesJson);
        final loadedInvoices = invoicesList
            .map((invoiceJson) => Invoice.fromJson(invoiceJson))
            .toList();
        _replaceInvoices(loadedInvoices);
      }
      _invoicesLoaded = true;
      notifyListeners();
    } catch (error) {
      debugPrint('Error loading invoices: $error');
      rethrow;
    }
  }

  Future<void> _saveInvoicesToStorage(List<Invoice> invoices) async {
    final invoicesJson = json.encode(
      invoices.map((invoice) => invoice.toJson()).toList(),
    );
    final saved = _invoiceStorageWriter != null
        ? await _invoiceStorageWriter(invoicesJson)
        : await (await SharedPreferences.getInstance()).setString(
            'saved_invoices',
            invoicesJson,
          );
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
    final normalizedCustomerName = _normalizeCustomerName(customerName);
    if (normalizedCustomerName.isEmpty) return [];

    return _invoices
        .where(
          (invoice) =>
              _normalizeCustomerName(invoice.customerName) ==
              normalizedCustomerName,
        )
        .toList();
  }

  static String _normalizeCustomerName(String customerName) =>
      customerName.trim().split(RegExp(r'\s+')).join(' ').toLowerCase();

  static double calculateCustomerBalance(Iterable<Invoice> invoices) {
    var balance = Money.zero;
    for (final invoice in invoices) {
      final rest = Money.fromDouble(invoice.rest);
      balance = switch (InvoiceAction.tryParse(invoice.invoiceAction)) {
        InvoiceAction.purchase => balance + rest,
        InvoiceAction.storage => balance,
        // Sales and unknown legacy types reduce the balance, as before.
        InvoiceAction.sale || null => balance - rest,
      };
    }
    return balance.toDouble();
  }

  /// Links invoices to customers in one all-or-nothing save.
  ///
  /// [customerIdByInvoiceId] maps an invoice id to the customer id to set.
  /// Invoices that already have a customer ID are never changed, and an id
  /// shared by several saved invoices is skipped because the invoices cannot
  /// be told apart. Returns how many invoices were linked.
  Future<int> assignCustomerIds(
    Map<String, String> customerIdByInvoiceId,
  ) async {
    for (final customerId in customerIdByInvoiceId.values) {
      if (customerId.trim().isEmpty) {
        throw ArgumentError.value(
          customerIdByInvoiceId,
          'customerIdByInvoiceId',
          'A customer ID cannot be empty.',
        );
      }
    }
    return _withInvoiceMutationLock(() async {
      await _ensureInvoicesLoaded();
      final occurrences = <String, int>{};
      for (final invoice in _invoices) {
        occurrences[invoice.id] = (occurrences[invoice.id] ?? 0) + 1;
      }

      var linked = 0;
      final updatedInvoices = <Invoice>[];
      for (final invoice in _invoices) {
        final customerId = customerIdByInvoiceId[invoice.id];
        if (customerId == null ||
            invoice.customerId != null ||
            occurrences[invoice.id]! > 1) {
          updatedInvoices.add(invoice);
          continue;
        }
        updatedInvoices.add(invoice.withCustomerId(customerId));
        linked++;
      }
      if (linked == 0) return 0;

      await _saveInvoicesToStorage(updatedInvoices);
      _replaceInvoices(updatedInvoices);
      notifyListeners();
      return linked;
    });
  }

  Future<void> deleteInvoice(String invoiceId) {
    return _withInvoiceMutationLock(() async {
      await _ensureInvoicesLoaded();
      final index = _uniqueInvoiceIndex(invoiceId);
      if (index == -1) return;

      final updatedInvoices = List<Invoice>.of(_invoices)..removeAt(index);
      await _saveInvoicesToStorage(updatedInvoices);
      _replaceInvoices(updatedInvoices);
      notifyListeners();
    });
  }

  // Load products from local storage
  /// Backup text containing every saved invoice.
  String exportBackup({DateTime? now}) {
    return InvoiceBackup.encode(_invoices, exportedAt: now ?? DateTime.now());
  }

  /// Counts what [restoreBackup] would add and replace, without changing
  /// anything. Throws [InvoiceBackupFormatException] for an invalid backup.
  InvoiceRestoreResult previewRestore(String backupText) {
    final restored = InvoiceBackup.decode(backupText);
    final savedIds = {for (final invoice in _invoices) invoice.id};
    var added = 0;
    var replaced = 0;
    for (final invoice in restored) {
      if (savedIds.contains(invoice.id)) {
        replaced++;
      } else {
        added++;
      }
    }
    return InvoiceRestoreResult(added: added, replaced: replaced);
  }

  /// Merges the invoices in [backupText] into the saved invoices.  ///
  /// Invoices with the same id are replaced; all others are kept. Nothing
  /// changes if the text is not a valid backup or the storage write fails.
  Future<InvoiceRestoreResult> restoreBackup(String backupText) async {
    final restored = InvoiceBackup.decode(backupText);
    return _withInvoiceMutationLock(() async {
      await _ensureInvoicesLoaded();
      final updatedInvoices = List<Invoice>.of(_invoices);
      var added = 0;
      var replaced = 0;
      for (final invoice in restored) {
        final index = updatedInvoices.indexWhere(
          (saved) => saved.id == invoice.id,
        );
        if (index == -1) {
          updatedInvoices.add(invoice);
          added++;
        } else {
          updatedInvoices[index] = invoice;
          replaced++;
        }
      }

      await _saveInvoicesToStorage(updatedInvoices);
      _replaceInvoices(updatedInvoices);
      notifyListeners();
      return InvoiceRestoreResult(added: added, replaced: replaced);
    });
  }

  static const String _masterProductPricesKey = 'master_product_prices';

  // Load products from local storage
  Future<void> loadMasterProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _loadMasterProductPrices(prefs);
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

  void _loadMasterProductPrices(SharedPreferences prefs) {
    _masterProductPrices.clear();
    final pricesJson = prefs.getString(_masterProductPricesKey);
    if (pricesJson == null) return;

    try {
      final decoded = json.decode(pricesJson);
      if (decoded is! Map) return;
      for (final entry in decoded.entries) {
        if (entry.key is! String) continue;
        final value = entry.value;
        final prices = <InvoiceAction, double>{};

        if (value is num && _isValidDefaultPrice(value)) {
          // Legacy format: one price applied to every invoice type.
          for (final action in InvoiceAction.values) {
            prices[action] = value.toDouble();
          }
        } else if (value is Map) {
          for (final action in InvoiceAction.values) {
            final stored = value[action.name];
            if (stored is num && _isValidDefaultPrice(stored)) {
              prices[action] = stored.toDouble();
            }
          }
        }

        if (prices.isNotEmpty) {
          _masterProductPrices[entry.key as String] = prices;
        }
      }
    } catch (e) {
      debugPrint('Error reading product prices: $e');
    }
  }

  bool _isValidDefaultPrice(num price) => price.isFinite && price >= 0;

  Future<void> _saveMasterProductPrices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _masterProductPricesKey,
        json.encode({
          for (final entry in _masterProductPrices.entries)
            entry.key: {
              for (final price in entry.value.entries)
                price.key.name: price.value,
            },
        }),
      );
    } catch (e) {
      debugPrint('Error saving product prices: $e');
    }
  }

  /// Sets an optional default [price] for one invoice type of a master
  /// product. Passing [null] (or an invalid value) removes that default.
  Future<void> setMasterProductPrice(
    String productName,
    InvoiceAction action,
    double? price,
  ) async {
    final name = productName.trim();
    if (name.isEmpty) return;

    final prices = _masterProductPrices[name];
    final validPrice = price != null && _isValidDefaultPrice(price);
    if (!validPrice) {
      if (prices == null || prices.remove(action) == null) return;
      if (prices.isEmpty) _masterProductPrices.remove(name);
    } else {
      if (prices?[action] == price) return;
      (_masterProductPrices[name] ??= {})[action] = price;
    }

    await _saveMasterProductPrices();
    notifyListeners();
  }

  /// Adds a new master product together with its optional default prices.
  ///
  /// Both lists are written before notifying listeners, so the product never
  /// appears without the prices chosen when it was first added.
  Future<void> addMasterProduct(
    String productName, {
    Map<InvoiceAction, double> prices = const {},
  }) async {
    final name = productName.trim();
    if (name.isEmpty || _masterProductList.contains(name)) return;

    _masterProductList.add(name);
    final validPrices = {
      for (final entry in prices.entries)
        if (_isValidDefaultPrice(entry.value)) entry.key: entry.value,
    };
    final hadPrices = validPrices.isNotEmpty;
    if (hadPrices) _masterProductPrices[name] = validPrices;

    await _saveMasterProducts();
    if (hadPrices) await _saveMasterProductPrices();
    notifyListeners();
  }

  /// Replaces the whole master product list and its default prices, e.g. after
  /// restoring a product backup. Duplicates and invalid prices are skipped.
  Future<void> replaceMasterProducts(
    List<String> products,
    Map<String, Map<InvoiceAction, double>> prices,
  ) async {
    final names = <String>[];
    for (final candidate in products) {
      final name = candidate.trim();
      if (name.isNotEmpty && !names.contains(name)) names.add(name);
    }

    final importedPrices = <String, Map<InvoiceAction, double>>{};
    for (final entry in prices.entries) {
      final name = entry.key.trim();
      if (!names.contains(name)) continue;
      final valid = {
        for (final price in entry.value.entries)
          if (_isValidDefaultPrice(price.value)) price.key: price.value,
      };
      if (valid.isNotEmpty) importedPrices[name] = valid;
    }

    _masterProductList = names;
    _masterProductPrices
      ..clear()
      ..addAll(importedPrices);
    await _saveMasterProducts();
    await _saveMasterProductPrices();
    notifyListeners();
  }

  // Edit existing product
  Future<void> editMasterProduct(int index, String newName) async {
    final trimmedName = newName.trim();
    if (index >= 0 &&
        index < _masterProductList.length &&
        trimmedName.isNotEmpty) {
      final oldName = _masterProductList[index];
      final prices = _masterProductPrices.remove(oldName);
      _masterProductList[index] = trimmedName;
      if (prices != null) {
        _masterProductPrices[trimmedName] = prices;
      }
      await _saveMasterProducts();
      if (prices != null) {
        await _saveMasterProductPrices();
      }
      notifyListeners();
    }
  }

  // Delete product
  Future<void> deleteMasterProduct(int index) async {
    if (index >= 0 && index < _masterProductList.length) {
      final removedName = _masterProductList.removeAt(index);
      final hadPrices = _masterProductPrices.remove(removedName) != null;
      await _saveMasterProducts();
      if (hadPrices) {
        await _saveMasterProductPrices();
      }
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
    return List<String>.from(ProductListConstants.productList);
  }
}
