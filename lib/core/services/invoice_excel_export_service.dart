import 'dart:io';
import 'dart:math' as math;

import 'package:arqamy/core/helpers/excel_labels.dart';
import 'package:arqamy/core/helpers/formatters.dart';
import 'package:arqamy/core/helpers/invoice_action.dart';
import 'package:arqamy/core/helpers/invoice_discount.dart';
import 'package:arqamy/core/helpers/invoice_export_columns.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:excel_plus/excel_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Exports invoice data directly into an `.xlsx` workbook.
///
/// This reads the same structured [Invoice] objects the app already holds, so
/// no data is copied out of the generated PDF. Each invoice gets one worksheet
/// with a row per product and a totals block underneath.
///
/// Which table columns are written is adjustable per export via
/// [InvoiceColumnVisibility]; package weight is not a regular column, it is
/// written as a note under the table (or as a per-row column when packages
/// have different weights).
class InvoiceExcelExportService {
  const InvoiceExcelExportService._();

  /// Builds the workbook bytes. Kept separate from file I/O so it can be
  /// tested (and reused for future batch exports) without platform channels.
  static List<int> buildWorkbook(
    Invoice invoice, {
    String locale = 'ar',
    InvoiceColumnVisibility excelColumns = InvoiceColumnVisibility.allVisible,
  }) {
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

    // Package weight is removed from the regular columns; it is shown as a
    // note under the table, or as a per-row column when weights differ.
    final packageWeights = InvoicePackageWeights.fromProducts(invoice.products);
    final packageWeightDisplay = resolvePackageWeightDisplay(
      enabled: excelColumns.isVisible(InvoiceTableColumn.packageWeight),
      weights: packageWeights,
    );

    final visibleColumns = _visibleColumns(excelColumns, packageWeightDisplay);
    final columnCount = visibleColumns.length;
    final numericColumns = <int>{
      for (var index = 0; index < visibleColumns.length; index++)
        if (_isNumeric(visibleColumns[index])) index,
    };

    for (var column = 0; column < columnCount; column++) {
      sheet.setColumnWidth(
        column,
        visibleColumns[column] == InvoiceTableColumn.product ? 22 : 17,
      );
    }

    sheet.appendRow([
      for (final column in visibleColumns) TextCellValue(labels.header(column)),
    ]);
    _styleRow(sheet, 0, headerStyle, const <int>{}, columnCount);

    final typeLabel = _typeLabel(invoice.invoiceAction, labels);
    for (var index = 0; index < invoice.products.length; index++) {
      final product = invoice.products[index];
      final rowIndex = index + 1;
      sheet.appendRow([
        for (final column in visibleColumns)
          _cellFor(column, product, invoice, typeLabel),
      ]);
      _styleRow(sheet, rowIndex, numberStyle, numericColumns, columnCount);
    }

    var totalsRowIndex = invoice.products.length + 1;

    // Package weight note under the table when every package has one weight.
    if (packageWeightDisplay == PackageWeightDisplay.note &&
        packageWeights.singleWeight != null) {
      final noteRow = List<CellValue?>.filled(math.max(columnCount, 1), null);
      noteRow[0] = TextCellValue(
        labels.packageWeightNote(
          AppFormatters.number(packageWeights.singleWeight!),
        ),
      );
      sheet.appendRow(noteRow);
      totalsRowIndex++;
    }

    // Totals block: label next to the value in the last two columns.
    final totalsColumnCount = math.max(columnCount, 2);
    final labelColumn = totalsColumnCount - 2;
    final valueColumn = totalsColumnCount - 1;

    final totals = <MapEntry<String, double>>[];
    if (invoice.discount != null) {
      totals.add(
        MapEntry(labels.subtotal, invoice.subtotalCost ?? invoice.totalCost),
      );
      final discount = invoice.discount!;
      final discountLabel = discount.type == InvoiceDiscountType.percent
          ? '${labels.discount} (${discount.value.toStringAsFixed(2)}%)'
          : labels.discount;
      totals.add(MapEntry(discountLabel, discount.amount));
    }
    totals.addAll([
      MapEntry(labels.invoiceTotal, invoice.totalCost),
      MapEntry(labels.collected, invoice.paid),
      MapEntry(labels.remaining, invoice.rest),
    ]);
    for (final entry in totals) {
      final row = List<CellValue?>.filled(totalsColumnCount, null);
      row[labelColumn] = TextCellValue(entry.key);
      row[valueColumn] = DoubleCellValue(entry.value);
      sheet.appendRow(row);
      sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: labelColumn,
                  rowIndex: totalsRowIndex,
                ),
              )
              .cellStyle =
          totalLabelStyle;
      sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: valueColumn,
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
    InvoiceColumnVisibility excelColumns = InvoiceColumnVisibility.allVisible,
  }) async {
    final bytes = buildWorkbook(
      invoice,
      locale: locale,
      excelColumns: excelColumns,
    );
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
    InvoiceColumnVisibility excelColumns = InvoiceColumnVisibility.allVisible,
  }) async {
    final filePath = await generateAndSaveInvoice(
      invoice,
      locale: locale,
      excelColumns: excelColumns,
    );
    await SharePlus.instance.share(ShareParams(files: [XFile(filePath)]));
  }

  /// Columns written, in invoice order. Package weight is not a regular
  /// column; it is added only when packages have different weights.
  static List<InvoiceTableColumn> _visibleColumns(
    InvoiceColumnVisibility columns,
    PackageWeightDisplay packageWeightDisplay,
  ) {
    final result = <InvoiceTableColumn>[];
    for (final column in InvoiceTableColumn.values) {
      if (column == InvoiceTableColumn.packageWeight) {
        // Package weight is not a regular column; it is written as a note
        // under the table, or as a per-row column when packages differ.
        if (packageWeightDisplay == PackageWeightDisplay.column) {
          result.add(column);
        }
        continue;
      }
      if (columns.isVisible(column)) result.add(column);
    }
    return result;
  }

  static bool _isNumeric(InvoiceTableColumn column) => switch (column) {
    InvoiceTableColumn.weight ||
    InvoiceTableColumn.packageWeight ||
    InvoiceTableColumn.packageCount ||
    InvoiceTableColumn.netWeight ||
    InvoiceTableColumn.price ||
    InvoiceTableColumn.total => true,
    _ => false,
  };

  static CellValue _cellFor(
    InvoiceTableColumn column,
    Product product,
    Invoice invoice,
    String typeLabel,
  ) => switch (column) {
    InvoiceTableColumn.serial => TextCellValue(invoice.invoiceSerial),
    InvoiceTableColumn.date => TextCellValue(invoice.formattedDate),
    InvoiceTableColumn.time => TextCellValue(invoice.formattedTime),
    InvoiceTableColumn.customer => TextCellValue(invoice.customerName),
    InvoiceTableColumn.type => TextCellValue(typeLabel),
    InvoiceTableColumn.product => TextCellValue(product.name),
    InvoiceTableColumn.weight => DoubleCellValue(product.weight),
    InvoiceTableColumn.packageWeight => DoubleCellValue(product.packageWeight),
    InvoiceTableColumn.packageCount => IntCellValue(product.numberPackage),
    InvoiceTableColumn.netWeight => DoubleCellValue(product.netWeight),
    InvoiceTableColumn.price => DoubleCellValue(product.price),
    InvoiceTableColumn.total => DoubleCellValue(product.lineTotal.toDouble()),
  };

  static void _styleRow(
    Sheet sheet,
    int rowIndex,
    CellStyle style,
    Set<int> numericColumns,
    int columnCount,
  ) {
    for (var column = 0; column < columnCount; column++) {
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
