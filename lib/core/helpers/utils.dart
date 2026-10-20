import 'dart:io';

import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/pw_grouped_table.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:arqamy/features/orderscreen/ui/widgets/pw_data_table.dart';

Future<Uint8List> generatePDF(
  final PdfPageFormat format,
  InvoiceProvider provider,
  InvoiceSettingsProvider settings,
  String customerName,
  final double totalCost,
  final double paid,
  final double rest,
  final String? formattedDate,
  final String? formattedTime,
  final String? invoiceAction,
  final String invoiceSerial,
) async {
  final doc = pw.Document(
    title: 'فاتورة العميل',
    compress: true,
  );
  final logoPath = settings.logoPath;

  /// ✅ Load logo (from gallery or fallback to default asset)
  pw.MemoryImage? logoImage;
  try {
    if (logoPath.isNotEmpty) {
      final logoFile = File(logoPath);
      if (await logoFile.exists()) {
        logoImage = pw.MemoryImage(await logoFile.readAsBytes());
      }
    }
  } catch (e) {
    print('Error loading logo: $e');
  }
  logoImage ??= pw.MemoryImage(
    (await rootBundle.load('assets/images/arqamy.png')).buffer.asUint8List(),
  );

  final arabicFont = await rootBundle.load("assets/fonts/Amiri-Regular.ttf");
  final ttf = pw.Font.ttf(arabicFont);

  // final DateTime now = DateTime.now();
  // String invoiceSerial =
  //     "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}"
  //     "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";

  final pageTheme = _myPageTheme(format, ttf);
  final products = provider.products;
  final grouped = provider.groupedProducts;
  final bool hasIdenticalProducts = provider.hasIdenticalProducts;
  final bool shouldShowPackageColumns = provider.shouldShowPackageColumns;

  String invoiceName = invoiceAction == "شراء"
      ? "فاتورة مشتريات"
      : invoiceAction == "بـيع"
          ? "فاتورة بيع"
          : "فاتورة تخزين";
  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      header: (final context) => pw.Center(
        child: pw.Row(children: [
          pw.Image(logoImage!, fit: pw.BoxFit.contain, width: 100),
          pw.SizedBox(width: 70),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text(
              'إدارة : ${settings.managerName}',
            ),
            pw.Text(
              'ت : ${settings.managerPhone}',
            ),
          ]),
          pw.SizedBox(width: 30),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('${settings.companyName}',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold, font: ttf)),
              pw.Text('${settings.companyDescription}'),
            ],
          ),
          pw.SizedBox(width: 70),
          pw.BarcodeWidget(
              data: '${settings.qrData}',
              width: 50,
              height: 50,
              barcode: pw.Barcode.qrCode(),
              drawText: false),
        ]),
      ),
      build: (final context) {
        List<pw.Widget> widgets = [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  '  فاتورة: $invoiceSerial \n $invoiceName ',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.normal,
                      font: ttf),
                ),
                pw.Text(
                  ' السيد: $customerName ',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                      fontSize: 30, fontWeight: pw.FontWeight.bold, font: ttf),
                ),
                pw.Text(
                  '  إصدار : $formattedDate- $formattedTime ',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.normal,
                      font: ttf),
                ),
              ],
            ),
          ),
          // table
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Container(
              alignment: pw.Alignment.center,
              child: PdfMyDataTable(
                products: products,
                // totalCost: totalCost,
                shouldShowPackageColumns: shouldShowPackageColumns,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
        ];
        // grouped table
        if (hasIdenticalProducts) {
          widgets.addAll([
            pw.Center(
              child: pw.Text("ملخص المنتجات",
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold, font: ttf)),
            ),
            pw.SizedBox(height: 10),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Container(
                alignment: pw.Alignment.center,
                child: PdfGroupedDataTable(
                  groupedProducts: grouped,
                  shouldShowPackageColumns: shouldShowPackageColumns,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
          ]);
        }
        ;
        widgets.addAll([
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text('إجمالي الفاتورة : \n $totalCost L.E',
                  style: const pw.TextStyle(fontSize: 20)),
              pw.Text(
                'تحصيل : \n $paid',
                style: const pw.TextStyle(fontSize: 20),
              ),
              pw.Text(
                'الباقي : \n $rest',
                style: const pw.TextStyle(fontSize: 20),
              )
            ],
          ),
        ]);
        return widgets;
      },
    ),
  );
  return doc.save();
}

pw.PageTheme _myPageTheme(PdfPageFormat format, pw.Font font) {
  return pw.PageTheme(
    pageFormat: PdfPageFormat.a4,
    theme: pw.ThemeData.withFont(base: font),
    margin: const pw.EdgeInsets.symmetric(
        horizontal: 1 * PdfPageFormat.cm, vertical: 0.5 * PdfPageFormat.cm),
    textDirection: pw.TextDirection.rtl,
    orientation: pw.PageOrientation.portrait,
  );
}
