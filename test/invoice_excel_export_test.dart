import 'dart:io';

import 'package:arqamy/core/helpers/excel_labels.dart';
import 'package:arqamy/core/helpers/invoice_discount.dart';
import 'package:arqamy/core/helpers/invoice_export_columns.dart';
import 'package:arqamy/core/helpers/money.dart';
import 'package:arqamy/core/services/invoice_excel_export_service.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:excel_plus/excel_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

Invoice _invoice() => Invoice(
  id: 'invoice-id-1',
  customerName: 'Ahmed',
  products: [
    Product(
      name: 'Rice',
      weight: 12.5,
      packageWeight: 0.5,
      numberPackage: 2,
      price: 15,
    ),
    Product(
      name: 'Corn',
      weight: 8,
      packageWeight: 0,
      numberPackage: 0,
      price: 10,
      lineTotalOverride: Money.fromDouble(79.99),
    ),
  ],
  totalCost: 252.49,
  paid: 200,
  rest: 52.49,
  formattedDate: 'Nov 26, 2026',
  formattedTime: '14:30',
  invoiceAction: 'بيع',
  invoiceSerial: '20261126-001',
);

String _text(Data? cell) => (cell?.value as TextCellValue).value.text ?? '';

double _number(Data? cell) {
  final value = cell?.value;
  return switch (value) {
    DoubleCellValue() => value.value,
    IntCellValue() => value.value.toDouble(),
    _ => throw StateError('Expected a numeric cell, got $value'),
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('exports one sheet with numeric product lines and totals', () {
    final invoice = _invoice();
    final workbook = Excel.decodeBytes(
      InvoiceExcelExportService.buildWorkbook(invoice, locale: 'en'),
    );

    expect(workbook.tables.keys, equals(['20261126-001']));
    final sheet = workbook.tables['20261126-001']!;
    expect(sheet.isRTL, isFalse);

    final rows = sheet.rows;
    expect(_text(rows[0][0]), ExcelLabels.en.serial);
    expect(_text(rows[0][5]), ExcelLabels.en.product);
    expect(_text(rows[0][10]), ExcelLabels.en.totalEgp);

    expect(_text(rows[1][0]), invoice.invoiceSerial);
    expect(_text(rows[1][3]), 'Ahmed');
    expect(_text(rows[1][4]), ExcelLabels.en.sale);
    expect(_text(rows[1][5]), 'Rice');
    expect(_number(rows[1][6]), 12.5);
    expect((rows[1][7]!.value as IntCellValue).value, 2);
    expect(_number(rows[1][8]), 11.5);
    expect(_number(rows[1][9]), 15);
    expect(_number(rows[1][10]), 172.5);

    expect(_text(rows[2][5]), 'Corn');
    expect(_number(rows[2][10]), 79.99);

    // A single shared package weight is written as a note under the rows.
    expect(_text(rows[3][0]), ExcelLabels.en.packageWeightNote('0.50'));

    expect(_text(rows[4][9]), ExcelLabels.en.invoiceTotal);
    expect(_number(rows[4][10]), invoice.totalCost);
    expect(_text(rows[5][9]), ExcelLabels.en.collected);
    expect(_number(rows[5][10]), invoice.paid);
    expect(_text(rows[6][9]), ExcelLabels.en.remaining);
    expect(_number(rows[6][10]), invoice.rest);
  });

  test('exports subtotal and resolved discount when one was entered', () {
    final base = _invoice();
    final invoice = Invoice(
      id: base.id,
      customerName: base.customerName,
      products: base.products,
      totalCost: 227.24,
      paid: 200,
      rest: 27.24,
      formattedDate: base.formattedDate,
      formattedTime: base.formattedTime,
      invoiceAction: base.invoiceAction,
      invoiceSerial: base.invoiceSerial,
      subtotalCost: 252.49,
      discount: const InvoiceDiscount(
        type: InvoiceDiscountType.percent,
        value: 10,
        amount: 25.25,
      ),
    );
    final workbook = Excel.decodeBytes(
      InvoiceExcelExportService.buildWorkbook(invoice, locale: 'en'),
    );
    final rows = workbook.tables['20261126-001']!.rows;

    expect(_text(rows[4][9]), ExcelLabels.en.subtotal);
    expect(_number(rows[4][10]), closeTo(252.49, 0.001));
    expect(_text(rows[5][9]), '${ExcelLabels.en.discount} (10.00%)');
    expect(_number(rows[5][10]), closeTo(25.25, 0.001));
    expect(_text(rows[6][9]), ExcelLabels.en.invoiceTotal);
    expect(_number(rows[6][10]), closeTo(227.24, 0.001));
  });

  test('hiding package weight removes both its column and its note', () {
    final columns = const InvoiceColumnVisibility().setVisible(
      InvoiceTableColumn.packageWeight,
      false,
    );
    final workbook = Excel.decodeBytes(
      InvoiceExcelExportService.buildWorkbook(
        _invoice(),
        locale: 'en',
        excelColumns: columns,
      ),
    );
    final rows = workbook.tables['20261126-001']!.rows;

    expect(rows[0].length, 11);
    expect(
      rows[0].map(_text).toList(),
      isNot(contains(ExcelLabels.en.packageWeightKg)),
    );
    expect(
      _text(rows[3][9]),
      ExcelLabels.en.invoiceTotal,
    );
  });

  test('different package weights are written as a per-row column', () {
    final base = _invoice();
    final invoice = Invoice(
      id: base.id,
      customerName: base.customerName,
      products: [
        base.products.first,
        Product(
          name: 'Corn',
          weight: 8,
          packageWeight: 0.25,
          numberPackage: 1,
          price: 10,
        ),
      ],
      totalCost: base.totalCost,
      paid: base.paid,
      rest: base.rest,
      formattedDate: base.formattedDate,
      formattedTime: base.formattedTime,
      invoiceAction: base.invoiceAction,
      invoiceSerial: base.invoiceSerial,
    );
    final workbook = Excel.decodeBytes(
      InvoiceExcelExportService.buildWorkbook(invoice, locale: 'en'),
    );
    final rows = workbook.tables['20261126-001']!.rows;

    expect(_text(rows[0][7]), ExcelLabels.en.packageWeightKg);
    expect(_number(rows[1][7]), 0.5);
    expect(_number(rows[2][7]), 0.25);
    expect(_text(rows[3][10]), ExcelLabels.en.invoiceTotal);
  });

  test('Arabic export uses Arabic headers and an RTL sheet', () {
    final workbook = Excel.decodeBytes(
      InvoiceExcelExportService.buildWorkbook(_invoice(), locale: 'ar'),
    );
    final sheet = workbook.tables['20261126-001']!;

    expect(sheet.isRTL, isTrue);
    expect(_text(sheet.rows[0][0]), ExcelLabels.ar.serial);
    expect(_text(sheet.rows[1][4]), ExcelLabels.ar.sale);
  });

  test(
    'sanitizes sheet names and saves the workbook in the temp directory',
    () async {
      SharedPreferences.setMockInitialValues({});
      final tempDirectory = await Directory.systemTemp.createTemp(
        'arqamy_excel_test_',
      );
      addTearDown(() => tempDirectory.delete(recursive: true));

      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const pathProviderChannel = MethodChannel(
        'plugins.flutter.io/path_provider',
      );
      messenger.setMockMethodCallHandler(pathProviderChannel, (call) async {
        if (call.method == 'getTemporaryDirectory') return tempDirectory.path;
        throw MissingPluginException('Unexpected method ${call.method}');
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(pathProviderChannel, null);
      });

      final invoice = _invoice();
      const unsafeSerial = 'serial/with?chars:*[and]more';
      final workbook = Excel.decodeBytes(
        InvoiceExcelExportService.buildWorkbook(
          Invoice(
            id: invoice.id,
            customerName: invoice.customerName,
            products: invoice.products,
            totalCost: invoice.totalCost,
            paid: invoice.paid,
            rest: invoice.rest,
            formattedDate: invoice.formattedDate,
            formattedTime: invoice.formattedTime,
            invoiceAction: invoice.invoiceAction,
            invoiceSerial: unsafeSerial,
          ),
          locale: 'en',
        ),
      );
      expect(workbook.tables.keys.single.length, lessThanOrEqualTo(31));
      expect(
        workbook.tables.keys.single,
        isNot(contains(RegExp(r'[\\/*?:\[\]]'))),
      );

      final path = await InvoiceExcelExportService.generateAndSaveInvoice(
        invoice,
        locale: 'en',
      );
      expect(p.dirname(path), tempDirectory.path);
      expect(p.extension(path), '.xlsx');
      expect(p.basename(path), contains('20261126-001'));
      expect(p.basename(path), contains('Ahmed'));
      expect(await File(path).exists(), isTrue);
    },
  );
}
