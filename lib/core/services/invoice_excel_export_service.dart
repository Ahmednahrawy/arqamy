import 'dart:io';

import 'package:arqamy/core/helpers/excel_labels.dart';
import 'package:arqamy/core/helpers/invoice_action.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:excel_plus/excel_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Exports invoice data directly into an `.xlsx` workbook.
///
/// This reads the same structured [Invoice] objects the app already holds, so
/// no data is copied out of the generated PDF. Each invoice gets one worksheet
/// with a row per product and a totals block underneath.
class InvoiceExcelExportService {
  const InvoiceExcelExportService._();

  static const _columnCount = 12;
  static const _numericColumns = <int>{6, 7, 8, 9, 10, 11};
  static const _priceColumn = 10;
  static const _totalColumn = 11;

  /// Builds the workbook bytes. Kept separate from file I/O so it can be
  /// tested (and reused for future batch exports) without platform channels.
  static List<int> buildWorkbook(Invoice invoice, {String locale = 'ar'}) {
    final labels = ExcelLabels.forLocale(locale);
    final excel = Excel.createExcel();
    final sheetName = _sheetName(invoice);
    final sheet = excel[sheetName];
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != sheetName) {
      excel.delete(defaultSheet);
    }
    excel.setDefaultSheet(sheetName);
    sheet.isRTL = labels.isRtl;

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#DCE6F1'),
    );
    final numberStyle = CellStyle(numberFormat: NumFormat.standard_4);
    final totalLabelStyle = CellStyle(bold: true);
    final totalValueStyle = CellStyle(
      bold: true,
      numberFormat: NumFormat.standard_4,
    );
    for (final column in [
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      _priceColumn,
      _totalColumn,
    ]) {
      sheet.setColumnWidth(column, column == 5 ? 22 : 17);
    }

    sheet.appendRow([
      TextCellValue(labels.serial),
      TextCellValue(labels.date),
      TextCellValue(labels.time),
      TextCellValue(labels.customer),
      TextCellValue(labels.type),
      TextCellValue(labels.product),
      TextCellValue(labels.weightKg),
      TextCellValue(labels.packageWeightKg),
      TextCellValue(labels.packageCount),
      TextCellValue(labels.netWeightKg),
      TextCellValue(labels.priceEgp),
      TextCellValue(labels.totalEgp),
    ]);
    _styleRow(sheet, 0, headerStyle, const <int>{});

    final typeLabel = _typeLabel(invoice.invoiceAction, labels);
    for (var index = 0; index < invoice.products.length; index++) {
      final product = invoice.products[index];
      final rowIndex = index + 1;
      sheet.appendRow([
        TextCellValue(invoice.invoiceSerial),
        TextCellValue(invoice.formattedDate),
        TextCellValue(invoice.formattedTime),
        TextCellValue(invoice.customerName),
        TextCellValue(typeLabel),
        TextCellValue(product.name),
        DoubleCellValue(product.weight),
        DoubleCellValue(product.packageWeight),
        IntCellValue(product.numberPackage),
        DoubleCellValue(product.netWeight),
        DoubleCellValue(product.price),
        DoubleCellValue(product.lineTotal.toDouble()),
      ]);
      _styleRow(sheet, rowIndex, numberStyle, _numericColumns);
    }

    var totalsRowIndex = invoice.products.length + 1;
    for (final entry in <MapEntry<String, double>>[
      MapEntry(labels.invoiceTotal, invoice.totalCost),
      MapEntry(labels.collected, invoice.paid),
      MapEntry(labels.remaining, invoice.rest),
    ]) {
      final row = List<CellValue?>.filled(_columnCount, null);
      row[_priceColumn] = TextCellValue(entry.key);
      row[_totalColumn] = DoubleCellValue(entry.value);
      sheet.appendRow(row);
      sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: _priceColumn,
                  rowIndex: totalsRowIndex,
                ),
              )
              .cellStyle =
          totalLabelStyle;
      sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: _totalColumn,
                  rowIndex: totalsRowIndex,
                ),
              )
              .cellStyle =
          totalValueStyle;
      totalsRowIndex++;
    }

    final bytes = excel.save();
    if (bytes == null) {
      throw StateError('Could not encode the invoice Excel workbook');
    }
    return bytes;
  }

  /// Writes the workbook to the app's temporary directory and returns its path.
  static Future<String> generateAndSaveInvoice(
    Invoice invoice, {
    String locale = 'ar',
  }) async {
    final bytes = buildWorkbook(invoice, locale: locale);
    final tempDir = await getTemporaryDirectory();
    final fileName = [
      'invoice',
      _sanitizeFileNamePart(
        invoice.invoiceSerial,
        fallback: 'serial',
        maxCodeUnits: 40,
      ),
      _sanitizeFileNamePart(
        invoice.customerName,
        fallback: 'customer',
        maxCodeUnits: 60,
      ),
    ].join('-');
    final filePath = p.join(tempDir.path, '$fileName.xlsx');
    await File(filePath).writeAsBytes(bytes);
    return filePath;
  }

  /// Saves the workbook and opens the system share sheet with the `.xlsx` file.
  static Future<void> generateAndShareInvoice(
    Invoice invoice, {
    String locale = 'ar',
  }) async {
    final filePath = await generateAndSaveInvoice(invoice, locale: locale);
    await SharePlus.instance.share(ShareParams(files: [XFile(filePath)]));
  }

  static void _styleRow(
    Sheet sheet,
    int rowIndex,
    CellStyle style,
    Set<int> numericColumns,
  ) {
    for (var column = 0; column < _columnCount; column++) {
      if (numericColumns.isNotEmpty && !numericColumns.contains(column)) {
        continue;
      }
      sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: column,
                  rowIndex: rowIndex,
                ),
              )
              .cellStyle =
          style;
    }
  }

  static String _typeLabel(String? action, ExcelLabels labels) =>
      switch (InvoiceAction.tryParse(action)) {
        InvoiceAction.purchase => labels.purchase,
        InvoiceAction.sale => labels.sale,
        InvoiceAction.storage => labels.storage,
        null => action ?? '',
      };

  static String _sheetName(Invoice invoice) {
    final cleaned = invoice.invoiceSerial
        .replaceAll(RegExp(r'[\\/*?:\[\]]'), '_')
        .trim();
    final candidate = cleaned.isEmpty ? 'Invoice' : cleaned;
    final runes = candidate.runes.take(31).toList();
    return String.fromCharCodes(runes);
  }

  static String _sanitizeFileNamePart(
    String value, {
    required String fallback,
    required int maxCodeUnits,
  }) {
    final sanitized = value
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'^\.+'), '')
        .replaceAll(RegExp(r'[. ]+$'), '')
        .trim();
    if (sanitized.isEmpty) return fallback;

    final runes = <int>[];
    var codeUnits = 0;
    for (final rune in sanitized.runes) {
      final runeCodeUnits = rune > 0xFFFF ? 2 : 1;
      if (codeUnits + runeCodeUnits > maxCodeUnits) break;
      runes.add(rune);
      codeUnits += runeCodeUnits;
    }
    return runes.isEmpty ? fallback : String.fromCharCodes(runes);
  }
}
