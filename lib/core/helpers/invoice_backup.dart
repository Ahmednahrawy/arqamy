import 'dart:convert';

import 'package:arqamy/core/helpers/money.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';

/// Thrown when text is not a valid Arqamy invoice backup.
class InvoiceBackupFormatException implements Exception {
  const InvoiceBackupFormatException(this.message);

  final String message;

  @override
  String toString() => 'InvoiceBackupFormatException: $message';
}

/// Reads and writes invoice backups as versioned JSON text.
///
/// Reading validates every field and never trusts the file: a bad backup is
/// rejected as a whole with a clear message, so it can never half-restore.
class InvoiceBackup {
  const InvoiceBackup._();

  static const String format = 'arqamy-invoices';
  static const int version = 1;

  static String encode(
    Iterable<Invoice> invoices, {
    required DateTime exportedAt,
  }) {
    final list = invoices.toList();
    return const JsonEncoder.withIndent('  ').convert({
      'format': format,
      'version': version,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'invoiceCount': list.length,
      'invoices': [for (final invoice in list) invoice.toJson()],
    });
  }

  static List<Invoice> decode(String text) {
    Object? root;
    try {
      root = jsonDecode(text);
    } on FormatException {
      throw const InvoiceBackupFormatException('The file is not valid JSON.');
    }
    if (root is! Map || root['format'] != format) {
      throw const InvoiceBackupFormatException(
        'This is not an Arqamy invoice backup.',
      );
    }
    final fileVersion = root['version'];
    if (fileVersion is! int || fileVersion < 1) {
      throw const InvoiceBackupFormatException(
        'The backup has an invalid version.',
      );
    }
    if (fileVersion > version) {
      throw const InvoiceBackupFormatException(
        'This backup was made by a newer version of the app.',
      );
    }
    final rawInvoices = root['invoices'];
    if (rawInvoices is! List) {
      throw const InvoiceBackupFormatException(
        'The backup has no invoice list.',
      );
    }
    final expectedCount = root['invoiceCount'];
    if (expectedCount != null && expectedCount != rawInvoices.length) {
      throw InvoiceBackupFormatException(
        'The backup is incomplete: expected $expectedCount invoices '
        'but found ${rawInvoices.length}.',
      );
    }

    final invoices = <Invoice>[];
    final ids = <String>{};
    for (var index = 0; index < rawInvoices.length; index++) {
      final invoice = _parseInvoice(rawInvoices[index], index + 1);
      if (!ids.add(invoice.id)) {
        throw InvoiceBackupFormatException(
          'Duplicate invoice id: ${invoice.id}',
        );
      }
      invoices.add(invoice);
    }
    return invoices;
  }

  static Invoice _parseInvoice(Object? raw, int number) {
    if (raw is! Map) {
      throw _invalid(number, 'it is not an object');
    }
    final map = Map<String, dynamic>.from(raw);

    final id = _text(map, 'id', number);
    if (id.trim().isEmpty) {
      throw _invalid(number, 'id is empty');
    }
    final action = map['invoiceAction'];
    if (action != null && action is! String) {
      throw _invalid(number, 'invoiceAction is not text');
    }
    final rawProducts = map['products'];
    if (rawProducts is! List) {
      throw _invalid(number, 'products is not a list');
    }

    return Invoice(
      id: id,
      customerName: _text(map, 'customerName', number),
      products: [
        for (final product in rawProducts) _parseProduct(product, number),
      ],
      totalCost: _amount(map, 'totalCost', number),
      paid: _amount(map, 'paid', number),
      rest: _amount(map, 'rest', number),
      formattedDate: _text(map, 'formattedDate', number),
      formattedTime: _text(map, 'formattedTime', number),
      invoiceAction: action as String?,
      invoiceSerial: _text(map, 'invoiceSerial', number),
    );
  }

  static Product _parseProduct(Object? raw, int number) {
    if (raw is! Map) {
      throw _invalid(number, 'a product is not an object');
    }
    final map = Map<String, dynamic>.from(raw);
    final packages = _number(map, 'numberPackage', number);
    if (packages != packages.truncateToDouble()) {
      throw _invalid(number, 'numberPackage is not a whole number');
    }
    final product = Product(
      name: _text(map, 'name', number),
      weight: _number(map, 'weight', number),
      packageWeight: _number(map, 'packageWeight', number),
      numberPackage: packages.toInt(),
      price: _number(map, 'price', number),
    );
    if (Money.tryFromDouble(product.netWeight * product.price) == null) {
      throw _invalid(number, 'a product total is out of range');
    }
    return product;
  }

  static String _text(Map<String, dynamic> map, String key, int number) {
    final value = map[key];
    if (value is! String) {
      throw _invalid(number, '$key is missing or not text');
    }
    return value;
  }

  static double _number(Map<String, dynamic> map, String key, int number) {
    final value = map[key];
    if (value is! num || !value.isFinite) {
      throw _invalid(number, '$key is not a valid number');
    }
    return value.toDouble();
  }

  static double _amount(Map<String, dynamic> map, String key, int number) {
    final value = _number(map, key, number);
    if (Money.tryFromDouble(value) == null) {
      throw _invalid(number, '$key is out of range');
    }
    return value;
  }

  static InvoiceBackupFormatException _invalid(int number, String reason) =>
      InvoiceBackupFormatException('Invoice $number is invalid: $reason.');
}

/// What a restore changed.
class InvoiceRestoreResult {
  const InvoiceRestoreResult({required this.added, required this.replaced});

  /// Invoices that were not saved before.
  final int added;

  /// Saved invoices that were overwritten by the backup copy (same id).
  final int replaced;

  int get total => added + replaced;
}
