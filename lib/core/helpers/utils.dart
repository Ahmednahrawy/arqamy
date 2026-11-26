import 'dart:io';

import 'package:arqamy/core/helpers/formatters.dart';
import 'package:arqamy/core/helpers/invoice_action_l10n.dart';
import 'package:arqamy/core/helpers/invoice_discount.dart';
import 'package:arqamy/core/helpers/pdf_labels.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/pw_grouped_table.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:flutter/foundation.dart';
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
  final String invoiceSerial, {
  double? subtotalCost,
  InvoiceDiscount? discount,
  String locale = 'ar',
}) async {
  final labels = PdfLabels.forLocale(locale);
  final doc = pw.Document(title: labels.documentTitle, compress: true);
  final logoPath = settings.logoPath;

  /// Load logo (from gallery or fallback to default asset)
  pw.MemoryImage? logoImage;
  try {
    if (logoPath.isNotEmpty) {
      final logoFile = File(logoPath);
      if (await logoFile.exists()) {
        logoImage = pw.MemoryImage(await logoFile.readAsBytes());
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error loading logo: $e');
    }
  }
  logoImage ??= pw.MemoryImage(
    (await rootBundle.load('assets/images/arqamy.png')).buffer.asUint8List(),
  );

  final arabicFont = await rootBundle.load("assets/fonts/Amiri-Regular.ttf");
  final ttf = pw.Font.ttf(arabicFont);

  final pageTheme = _myPageTheme(format, ttf, labels.isRtl);
  final products = provider.products;
  final grouped = provider.groupedProducts;
  final bool hasIdenticalProducts = provider.hasIdenticalProducts;
  final bool shouldShowPackageColumns = provider.shouldShowPackageColumns;

  final invoiceName = _invoiceTitle(invoiceAction, labels);

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      header: (final context) => pw.Center(
        child: pw.Row(
          children: [
            pw.Image(logoImage!, fit: pw.BoxFit.contain, width: 100),
            pw.SizedBox(width: 70),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('${labels.management} : ${settings.managerName}'),
                pw.Text('${labels.phone} : ${settings.managerPhone}'),
              ],
            ),
            pw.SizedBox(width: 30),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  settings.companyName,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    font: ttf,
                  ),
                ),
                pw.Text(settings.companyDescription),
              ],
            ),
            pw.SizedBox(width: 70),
            pw.BarcodeWidget(
              data: settings.qrData,
              width: 50,
              height: 50,
              barcode: pw.Barcode.qrCode(),
              drawText: false,
            ),
          ],
        ),
      ),
      build: (final context) {
        List<pw.Widget> widgets = [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  '${labels.invoice}: $invoiceSerial\n$invoiceName',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.normal,
                    font: ttf,
                  ),
                ),
                pw.Text(
                  '${labels.mr}: $customerName',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                    font: ttf,
                  ),
                ),
                pw.Text(
                  '${labels.issued}: $formattedDate - $formattedTime',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.normal,
                    font: ttf,
                  ),
                ),
              ],
            ),
          ),
          // table
          pw.Align(
            alignment: pw.AlignmentDirectional.centerStart,
            child: pw.Container(
              alignment: pw.Alignment.center,
              child: PdfMyDataTable(
                products: products,
                shouldShowPackageColumns: shouldShowPackageColumns,
                labels: labels,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
        ];
        // grouped table
        if (hasIdenticalProducts) {
          widgets.addAll([
            pw.Center(
              child: pw.Text(
                labels.productSummary,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  font: ttf,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Align(
              alignment: pw.AlignmentDirectional.centerStart,
              child: pw.Container(
                alignment: pw.Alignment.center,
                child: PdfGroupedDataTable(
                  groupedProducts: grouped,
                  shouldShowPackageColumns: shouldShowPackageColumns,
                  labels: labels,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
          ]);
        }
        final totals = <pw.Widget>[];
        if (discount != null) {
          totals.addAll([
            pw.Text(
              '${labels.subtotal} :\n'
              '${AppFormatters.number(subtotalCost ?? totalCost)} ${labels.currency}',
              style: const pw.TextStyle(fontSize: 20),
            ),
            pw.Text(
              '${labels.discount} :\n'
              '${_discountText(discount, labels)}',
              style: const pw.TextStyle(fontSize: 20),
            ),
          ]);
        }
        totals.addAll([
          pw.Text(
            '${labels.invoiceTotal} :\n'
            '${AppFormatters.number(totalCost)} ${labels.currency}',
            style: const pw.TextStyle(fontSize: 20),
          ),
          pw.Text(
            '${labels.collected} :\n'
            '${AppFormatters.number(paid)} ${labels.currency}',
            style: const pw.TextStyle(fontSize: 20),
          ),
          pw.Text(
            '${labels.remaining} :\n'
            '${AppFormatters.number(rest)} ${labels.currency}',
            style: const pw.TextStyle(fontSize: 20),
          ),
        ]);
        widgets.add(
          pw.Wrap(
            spacing: 20,
            runSpacing: 10,
            children: totals,
          ),
        );
        return widgets;
      },
    ),
  );
  return doc.save();
}

String _discountText(InvoiceDiscount discount, PdfLabels labels) {
  if (discount.type == InvoiceDiscountType.percent) {
    return '${AppFormatters.number(discount.value)}% '
        '(${AppFormatters.number(discount.amount)} ${labels.currency})';
  }
  return '${AppFormatters.number(discount.amount)} ${labels.currency}';
}

String _invoiceTitle(String? invoiceAction, PdfLabels labels) {
  switch (InvoiceActionL10n.normalize(invoiceAction)) {
    case InvoiceActionL10n.purchase:
      return labels.purchaseTitle;
    case InvoiceActionL10n.sale:
      return labels.saleTitle;
    case InvoiceActionL10n.storage:
      return labels.storageTitle;
    default:
      return labels.storageTitle;
  }
}

pw.PageTheme _myPageTheme(PdfPageFormat format, pw.Font font, bool isRtl) {
  return pw.PageTheme(
    pageFormat: PdfPageFormat.a4,
    theme: pw.ThemeData.withFont(base: font),
    margin: const pw.EdgeInsets.symmetric(
      horizontal: 1 * PdfPageFormat.cm,
      vertical: 0.5 * PdfPageFormat.cm,
    ),
    textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
    orientation: pw.PageOrientation.portrait,
  );
}
