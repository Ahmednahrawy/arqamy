import 'dart:convert';
import 'dart:io';

import 'package:arqamy/core/services/legacy_invoice_snapshot_service.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/payment_ledger/data/legacy_invoice_audit.dart';
import 'package:crypto/crypto.dart';

enum LegacyInvoicePreflightClassification {
  ready,
  needsReview,
  duplicateIdentity,
  malformedRecord,
}

enum LegacyInvoicePreflightFatalIssue {
  sourceMissing,
  snapshotIntegrityFailure,
  invalidUtf8,
  invalidJson,
  invalidTopLevelShape,
}

class LegacyInvoicePreflightOccurrence {
  const LegacyInvoicePreflightOccurrence({
    required this.sourceIndex,
    required this.classification,
    required this.invoiceId,
    required this.serial,
    required this.issues,
    required this.malformedReasons,
    required this.rawJson,
    this.invoice,
  });

  final int sourceIndex;
  final LegacyInvoicePreflightClassification classification;
  final String? invoiceId;
  final String? serial;
  final List<LegacyInvoiceIssue> issues;
  final List<String> malformedReasons;

  /// Exact JSON text for this array occurrence, excluding surrounding whitespace.
  final String rawJson;

  /// Present only when the record has the complete legacy invoice structure.
  /// This is an in-memory model; the original raw snapshot remains authoritative.
  final Invoice? invoice;
}

class LegacyInvoicePreflightReport {
  const LegacyInvoicePreflightReport({
    required this.snapshotSha256,
    required this.sourceExists,
    required this.occurrences,
    this.fatalIssue,
  });

  final String snapshotSha256;
  final bool sourceExists;
  final List<LegacyInvoicePreflightOccurrence> occurrences;
  final LegacyInvoicePreflightFatalIssue? fatalIssue;

  bool get isComplete => fatalIssue == null;

  int count(LegacyInvoicePreflightClassification classification) =>
      occurrences.where((item) => item.classification == classification).length;

  int get totalOccurrences => occurrences.length;
}

/// Read-only parser and record-level preflight for an immutable invoice snapshot.
///
/// It never writes to SharedPreferences, Drift, or any business repository.
class LegacyInvoicePreflightService {
  const LegacyInvoicePreflightService();

  Future<LegacyInvoicePreflightReport> inspect(
    LegacyInvoiceSnapshot snapshot,
  ) async {
    if (!snapshot.sourceExists) {
      return _fatal(snapshot, LegacyInvoicePreflightFatalIssue.sourceMissing);
    }

    late final List<int> bytes;
    try {
      bytes = await snapshot.rawFile.readAsBytes();
    } on FileSystemException {
      return _fatal(
        snapshot,
        LegacyInvoicePreflightFatalIssue.snapshotIntegrityFailure,
      );
    }
    if (bytes.length != snapshot.byteLength ||
        sha256.convert(bytes).toString() != snapshot.sha256) {
      return _fatal(
        snapshot,
        LegacyInvoicePreflightFatalIssue.snapshotIntegrityFailure,
      );
    }

    late final String raw;
    try {
      raw = utf8.decode(bytes);
    } on FormatException {
      return _fatal(snapshot, LegacyInvoicePreflightFatalIssue.invalidUtf8);
    }

    late final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return _fatal(snapshot, LegacyInvoicePreflightFatalIssue.invalidJson);
    }

    if (decoded is! List) {
      return _fatal(
        snapshot,
        LegacyInvoicePreflightFatalIssue.invalidTopLevelShape,
      );
    }

    final fragments = _arrayElementFragments(raw);
    final records = <_ParsedOccurrence>[];
    final idCounts = <String, int>{};
    for (var index = 0; index < decoded.length; index++) {
      final parsed = _parseOccurrence(
        index,
        decoded[index],
        fragments[index],
      );
      records.add(parsed);
      final id = parsed.invoiceId;
      if (id != null) idCounts[id] = (idCounts[id] ?? 0) + 1;
    }

    final occurrences = <LegacyInvoicePreflightOccurrence>[];
    for (final record in records) {
      final duplicate = record.invoiceId != null &&
          idCounts[record.invoiceId]! > 1;
      if (record.invoice == null) {
        occurrences.add(
          LegacyInvoicePreflightOccurrence(
            sourceIndex: record.sourceIndex,
            classification: LegacyInvoicePreflightClassification.malformedRecord,
            invoiceId: record.invoiceId,
            serial: record.serial,
            issues: duplicate
                ? const [LegacyInvoiceIssue.duplicateInvoiceId]
                : const [],
            malformedReasons: List.unmodifiable(record.malformedReasons),
            rawJson: record.rawJson,
          ),
        );
        continue;
      }

      final auditIssues = LegacyInvoiceAudit.run([record.invoice!])
          .findings
          .expand((finding) => finding.issues)
          .toSet();
      if (duplicate) auditIssues.add(LegacyInvoiceIssue.duplicateInvoiceId);

      final classification = duplicate
          ? LegacyInvoicePreflightClassification.duplicateIdentity
          : auditIssues.isEmpty
              ? LegacyInvoicePreflightClassification.ready
              : LegacyInvoicePreflightClassification.needsReview;

      occurrences.add(
        LegacyInvoicePreflightOccurrence(
          sourceIndex: record.sourceIndex,
          classification: classification,
          invoiceId: record.invoiceId,
          serial: record.serial,
          issues: List.unmodifiable(auditIssues),
          malformedReasons: const [],
          rawJson: record.rawJson,
          invoice: record.invoice,
        ),
      );
    }

    return LegacyInvoicePreflightReport(
      snapshotSha256: snapshot.sha256,
      sourceExists: snapshot.sourceExists,
      occurrences: List.unmodifiable(occurrences),
    );
  }

  LegacyInvoicePreflightReport _fatal(
    LegacyInvoiceSnapshot snapshot,
    LegacyInvoicePreflightFatalIssue issue,
  ) {
    return LegacyInvoicePreflightReport(
      snapshotSha256: snapshot.sha256,
      sourceExists: snapshot.sourceExists,
      occurrences: const [],
      fatalIssue: issue,
    );
  }

  _ParsedOccurrence _parseOccurrence(
    int index,
    Object? value,
    String rawJson,
  ) {
    if (value is! Map) {
      return _ParsedOccurrence.malformed(
        index,
        ['Record must be a JSON object.'],
        rawJson: rawJson,
      );
    }

    final map = <String, dynamic>{};
    for (final entry in value.entries) {
      if (entry.key is! String) {
        return _ParsedOccurrence.malformed(
          index,
          ['Record contains a non-string field name.'],
          rawJson: rawJson,
        );
      }
      map[entry.key as String] = entry.value;
    }

    final id = _optionalString(map, 'id');
    final serial = _optionalString(map, 'invoiceSerial');
    final errors = <String>[];

    _requireString(map, 'id', errors);
    _requireString(map, 'customerName', errors);
    _requireString(map, 'formattedDate', errors);
    _requireString(map, 'formattedTime', errors);
    _requireString(map, 'invoiceSerial', errors);
    _requireNumber(map, 'totalCost', errors);
    _requireNumber(map, 'paid', errors);
    _requireNumber(map, 'rest', errors);

    if (map.containsKey('invoiceAction') &&
        map['invoiceAction'] != null &&
        map['invoiceAction'] is! String) {
      errors.add('Field "invoiceAction" must be a string or null.');
    }
    if (map.containsKey('customerId') &&
        map['customerId'] != null &&
        map['customerId'] is! String) {
      errors.add('Field "customerId" must be a string or null.');
    }

    final products = map['products'];
    if (products is! List) {
      errors.add('Field "products" must be a list.');
    } else {
      for (var productIndex = 0; productIndex < products.length; productIndex++) {
        final product = products[productIndex];
        if (product is! Map) {
          errors.add('Product at index $productIndex must be an object.');
          continue;
        }
        _requireString(product, 'name', errors,
            prefix: 'Product at index $productIndex: ');
        _requireNumber(product, 'weight', errors,
            prefix: 'Product at index $productIndex: ');
        _requireNumber(product, 'packageWeight', errors,
            prefix: 'Product at index $productIndex: ');
        _requireNumber(product, 'price', errors,
            prefix: 'Product at index $productIndex: ');
        if (product['numberPackage'] is! int) {
          errors.add(
            'Product at index $productIndex: field "numberPackage" must be an integer.',
          );
        }
      }
    }

    if (errors.isNotEmpty) {
      return _ParsedOccurrence.malformed(
        index,
        errors,
        invoiceId: id,
        serial: serial,
        rawJson: rawJson,
      );
    }

    final invoice = Invoice(
      id: map['id'] as String,
      customerName: map['customerName'] as String,
      products: [
        for (final product in products! as List)
          Product(
            name: product['name'] as String,
            weight: (product['weight'] as num).toDouble(),
            packageWeight: (product['packageWeight'] as num).toDouble(),
            numberPackage: product['numberPackage'] as int,
            price: (product['price'] as num).toDouble(),
          ),
      ],
      totalCost: (map['totalCost'] as num).toDouble(),
      paid: (map['paid'] as num).toDouble(),
      rest: (map['rest'] as num).toDouble(),
      formattedDate: map['formattedDate'] as String,
      formattedTime: map['formattedTime'] as String,
      invoiceAction: map['invoiceAction'] as String?,
      invoiceSerial: map['invoiceSerial'] as String,
      customerId: map['customerId'] as String?,
    );

    return _ParsedOccurrence.valid(index, invoice, rawJson);
  }

  void _requireString(
    Map<dynamic, dynamic> map,
    String key,
    List<String> errors, {
    String prefix = '',
  }) {
    if (map[key] is! String) {
      errors.add('$prefix field "$key" must be a string.');
    }
  }

  void _requireNumber(
    Map<dynamic, dynamic> map,
    String key,
    List<String> errors, {
    String prefix = '',
  }) {
    final value = map[key];
    if (value is! num || !value.isFinite) {
      errors.add('$prefix field "$key" must be a finite number.');
    }
  }

  String? _optionalString(Map<String, dynamic> map, String key) =>
      map[key] is String ? map[key] as String : null;

  /// Splits a validated top-level JSON array without re-encoding its elements.
  /// This retains each source occurrence's original formatting and field order.
  List<String> _arrayElementFragments(String raw) {
    final fragments = <String>[];
    var index = raw.indexOf('[') + 1;
    while (index < raw.length) {
      while (index < raw.length &&
          (raw.codeUnitAt(index) == 0x20 ||
              raw.codeUnitAt(index) == 0x0A ||
              raw.codeUnitAt(index) == 0x0D ||
              raw.codeUnitAt(index) == 0x09)) {
        index++;
      }
      if (index >= raw.length || raw[index] == ']') break;

      final start = index;
      var objectDepth = 0;
      var arrayDepth = 0;
      var inString = false;
      var escaped = false;
      while (index < raw.length) {
        final character = raw[index];
        if (inString) {
          if (escaped) {
            escaped = false;
          } else if (character == '\\') {
            escaped = true;
          } else if (character == '"') {
            inString = false;
          }
        } else {
          if (character == '"') {
            inString = true;
          } else if (character == '{') {
            objectDepth++;
          } else if (character == '}') {
            objectDepth--;
          } else if (character == '[') {
            arrayDepth++;
          } else if (character == ']') {
            if (arrayDepth == 0 && objectDepth == 0) break;
            arrayDepth--;
          } else if (character == ',' &&
              objectDepth == 0 &&
              arrayDepth == 0) {
            break;
          }
        }
        index++;
      }

      var end = index;
      while (end > start &&
          (raw.codeUnitAt(end - 1) == 0x20 ||
              raw.codeUnitAt(end - 1) == 0x0A ||
              raw.codeUnitAt(end - 1) == 0x0D ||
              raw.codeUnitAt(end - 1) == 0x09)) {
        end--;
      }
      fragments.add(raw.substring(start, end));

      if (index < raw.length && raw[index] == ',') index++;
    }
    return fragments;
  }
}

class _ParsedOccurrence {
  const _ParsedOccurrence._({
    required this.sourceIndex,
    required this.invoiceId,
    required this.serial,
    required this.invoice,
    required this.malformedReasons,
    required this.rawJson,
  });

  factory _ParsedOccurrence.valid(
    int index,
    Invoice invoice,
    String rawJson,
  ) =>
      _ParsedOccurrence._(
        sourceIndex: index,
        invoiceId: invoice.id,
        serial: invoice.invoiceSerial,
        invoice: invoice,
        malformedReasons: const [],
        rawJson: rawJson,
      );

  factory _ParsedOccurrence.malformed(
    int index,
    List<String> reasons, {
    String? invoiceId,
    String? serial,
    required String rawJson,
  }) =>
      _ParsedOccurrence._(
        sourceIndex: index,
        invoiceId: invoiceId,
        serial: serial,
        invoice: null,
        malformedReasons: List.unmodifiable(reasons),
        rawJson: rawJson,
      );

  final int sourceIndex;
  final String? invoiceId;
  final String? serial;
  final Invoice? invoice;
  final List<String> malformedReasons;
  final String rawJson;
}
