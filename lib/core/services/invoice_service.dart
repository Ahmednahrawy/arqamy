import 'dart:io';

import 'package:arqamy/core/helpers/utils.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';


class InvoiceService {
  /// Generates a PDF invoice and returns the saved file path
  static Future<String> generateAndSaveInvoice({
    required InvoiceProvider provider,
    required InvoiceSettingsProvider settings,
    required String customerName,
    required double totalCost,
    required double paid,
    required double rest,
    required String? formattedDate,
    required String? formattedTime,
    required String? invoiceAction,
     required String invoiceSerial,
  }) async {
    // Create PDF bytes
    final pdfDoc = await generatePDF(
      PdfPageFormat.a4,
      provider,
      settings,
      customerName,
      totalCost,
      paid,
      rest,
      formattedDate,
      formattedTime,
      invoiceAction,
      invoiceSerial,
    );

    // Save to temp folder
    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/${customerName}-${formattedDate}-${formattedTime}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(pdfDoc);

    return filePath;
  }

  /// Generates, saves, and shares the invoice PDF
  static Future<void> generateAndShareInvoice({
    required InvoiceProvider provider,
    required InvoiceSettingsProvider settings,
    required String customerName,
    required double totalCost,
    required double paid,
    required double rest,
    required String? formattedDate,
    required String? formattedTime,
    required String? invoiceAction,
    required String invoiceSerial,
  }) async {
    final filePath = await generateAndSaveInvoice(
      provider: provider,
      settings: settings,
      customerName: customerName,
      totalCost: totalCost,
      paid: paid,
      rest: rest,
      formattedDate: formattedDate,
      formattedTime: formattedTime,
      invoiceAction: invoiceAction,
      invoiceSerial: invoiceSerial,
    );

    await SharePlus.instance.share(ShareParams(files: [XFile(filePath)]));
  }
}
