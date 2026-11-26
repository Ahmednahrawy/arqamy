import 'dart:convert';
import 'dart:io';

import 'package:arqamy/core/helpers/invoice_action.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// The products and default prices read from a product backup file.
class ProductListBackup {
  const ProductListBackup({required this.products, required this.prices});

  final List<String> products;
  final Map<String, Map<InvoiceAction, double>> prices;
}

/// A file that cannot be used as a strict product backup.
class ProductListBackupFormatException implements Exception {
  const ProductListBackupFormatException(this.message);

  final String message;

  @override
  String toString() => 'ProductListBackupFormatException: $message';
}

/// Versioned JSON backup/restore for the master product list.
///
/// Prices are stored under the canonical [InvoiceAction.name] keys, so the
/// file never depends on the device language or on spreadsheet headings.
class ProductListBackupService {
  const ProductListBackupService._();

  static const String format = 'arqamy-products';
  static const int version = 1;
  static const int maxBackupBytes = 50 * 1024 * 1024;

  static String encodeProducts(
    List<String> products,
    Map<String, Map<InvoiceAction, double>> prices,
  ) {
    return const JsonEncoder.withIndent('  ').convert({
      'format': format,
      'version': version,
      'products': [
        for (final name in products) _encodeProduct(name, prices[name] ?? {}),
      ],
    });
  }

  static Map<String, Object?> _encodeProduct(
    String name,
    Map<InvoiceAction, double> prices,
  ) {
    final encodedPrices = <String, double>{};
    for (final action in InvoiceAction.values) {
      final price = prices[action];
      if (price != null && price.isFinite && price >= 0) {
        encodedPrices[action.name] = price;
      }
    }
    return {'name': name, 'defaultPrices': encodedPrices};
  }

  static ProductListBackup decodeProducts(String text) {
    final clean = text.startsWith('\uFEFF') ? text.substring(1) : text;
    final Object? decoded;
    try {
      decoded = jsonDecode(clean);
    } on FormatException {
      throw const ProductListBackupFormatException(
        'The file is not valid JSON.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ProductListBackupFormatException(
        'The backup root must be an object.',
      );
    }
    if (decoded['format'] != format) {
      throw const ProductListBackupFormatException(
        'This is not a product backup.',
      );
    }
    if (decoded['version'] != version) {
      throw const ProductListBackupFormatException(
        'This product backup version is not supported.',
      );
    }
    final rawProducts = decoded['products'];
    if (rawProducts is! List) {
      throw const ProductListBackupFormatException(
        'The backup has no product list.',
      );
    }

    final products = <String>[];
    final prices = <String, Map<InvoiceAction, double>>{};
    for (final item in rawProducts) {
      if (item is! Map) {
        throw const ProductListBackupFormatException(
          'A product entry is invalid.',
        );
      }
      final rawName = item['name'];
      if (rawName is! String || rawName.trim().isEmpty) {
        throw const ProductListBackupFormatException(
          'A product has no valid name.',
        );
      }
      final name = rawName.trim();
      if (products.contains(name)) {
        throw ProductListBackupFormatException('Duplicate product "$name".');
      }
      products.add(name);

      final rawPrices = item['defaultPrices'];
      if (rawPrices == null) continue;
      if (rawPrices is! Map) {
        throw const ProductListBackupFormatException(
          'Default prices must be an object.',
        );
      }
      final parsedPrices = <InvoiceAction, double>{};
      for (final entry in rawPrices.entries) {
        if (entry.key is! String) {
          throw const ProductListBackupFormatException(
            'A price type is invalid.',
          );
        }
        InvoiceAction? action;
        for (final candidate in InvoiceAction.values) {
          if (candidate.name == entry.key) action = candidate;
        }
        if (action == null) {
          throw ProductListBackupFormatException(
            'Unknown price type "${entry.key}".',
          );
        }
        final rawPrice = entry.value;
        if (rawPrice is! num) {
          throw const ProductListBackupFormatException(
            'A default price is not a number.',
          );
        }
        final price = rawPrice.toDouble();
        if (!price.isFinite || price < 0) {
          throw const ProductListBackupFormatException(
            'Prices must be zero or more.',
          );
        }
        parsedPrices[action] = price;
      }
      if (parsedPrices.isNotEmpty) prices[name] = parsedPrices;
    }
    return ProductListBackup(products: products, prices: prices);
  }

  static String backupTextFromBytes(List<int> bytes) {
    if (bytes.isEmpty) {
      throw const ProductListBackupFormatException('The file is empty.');
    }
    if (bytes.length > maxBackupBytes) {
      throw const ProductListBackupFormatException('The file is too large.');
    }
    try {
      return utf8.decode(bytes);
    } on FormatException {
      throw const ProductListBackupFormatException(
        'The file is not valid text.',
      );
    }
  }

  /// Lets the user choose a backup file and returns its strict contents.
  static Future<ProductListBackup?> pickBackup() async {
    final file = await FilePicker.pickFile(allowedExtensions: ['json']);
    if (file == null) return null;
    return decodeProducts(backupTextFromBytes(await file.readAsBytes()));
  }

  static Future<String> generateAndSaveBackup(
    List<String> products,
    Map<String, Map<InvoiceAction, double>> prices, {
    DateTime? now,
  }) async {
    final time = now ?? DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    final fileName =
        'arqamy-products-${time.year}${two(time.month)}'
        '${two(time.day)}-${two(time.hour)}${two(time.minute)}.json';
    final directory = await getTemporaryDirectory();
    final path = p.join(directory.path, fileName);
    await File(
      path,
    ).writeAsString(encodeProducts(products, prices), flush: true);
    return path;
  }

  /// Writes the backup and opens the system share sheet with the `.json` file.
  static Future<int> shareBackup(
    List<String> products,
    Map<String, Map<InvoiceAction, double>> prices,
  ) async {
    final path = await generateAndSaveBackup(products, prices);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path, mimeType: 'application/json')]),
    );
    return products.length;
  }
}
