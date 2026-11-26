import 'dart:io';

import 'package:arqamy/core/helpers/excel_labels.dart';
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
    expect(_text(rows[0][11]), ExcelLabels.en.totalEgp);

    expect(_text(rows[1][0]), invoice.invoiceSerial);
    expect(_text(rows[1][3]), 'Ahmed');
    expect(_text(rows[1][4]), ExcelLabels.en.sale);
    expect(_text(rows[1][5]), 'Rice');
    expect(_number(rows[1][6]), 12.5);
    expect((rows[1][8]!.value as IntCellValue).value, 2);
    expect(_number(rows[1][9]), 11.5);
    expect(_number(rows[1][10]), 15);
    expect(_number(rows[1][11]), 172.5);

    expect(_text(rows[2][5]), 'Corn');
    expect(_number(rows[2][11]), 79.99);

    expect(_text(rows[3][10]), ExcelLabels.en.invoiceTotal);
    expect(_number(rows[3][11]), invoice.totalCost);
    expect(_text(rows[4][10]), ExcelLabels.en.collected);
    expect(_number(rows[4][11]), invoice.paid);
    expect(_text(rows[5][10]), ExcelLabels.en.remaining);
    expect(_number(rows[5][11]), invoice.rest);
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
