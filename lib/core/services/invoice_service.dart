import 'dart:io';

import 'package:arqamy/core/helpers/utils.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';

class InvoiceService {
  static const _whatsappChannel = MethodChannel('com.nahro.arqamy/whatsapp');

  /// Generates a PDF invoice and returns the saved file path
  static Future<String> generateAndSaveInvoice({
    required InvoiceProvider provider,
    required InvoiceSettingsProvider settings,
    required String customerName,
    required String invoiceId,
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
    final fileName = [
      'invoice',
      _sanitizeFileNamePart(
        customerName,
        fallback: 'customer',
        maxCodeUnits: 60,
      ),
      _sanitizeFileNamePart(
        formattedDate ?? '',
        fallback: 'date',
        maxCodeUnits: 30,
      ),
      _sanitizeFileNamePart(
        formattedTime ?? '',
        fallback: 'time',
        maxCodeUnits: 20,
      ),
      _sanitizeFileNamePart(invoiceId, fallback: 'id', maxCodeUnits: 80),
    ].join('-');
    final filePath = p.join(tempDir.path, '$fileName.pdf');
    final file = File(filePath);
    await file.writeAsBytes(pdfDoc);

    return filePath;
  }

  /// Generates, saves, and shares the invoice PDF
  static Future<void> generateAndShareInvoice({
    required InvoiceProvider provider,
    required InvoiceSettingsProvider settings,
    required String customerName,
    required String invoiceId,
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
      invoiceId: invoiceId,
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

  /// Generates and shares an invoice directly to WhatsApp when available.
  static Future<void> generateAndShareInvoiceToWhatsApp({
    required InvoiceProvider provider,
    required InvoiceSettingsProvider settings,
    required String customerName,
    required String invoiceId,
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
      invoiceId: invoiceId,
      totalCost: totalCost,
      paid: paid,
      rest: rest,
      formattedDate: formattedDate,
      formattedTime: formattedTime,
      invoiceAction: invoiceAction,
      invoiceSerial: invoiceSerial,
    );
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _whatsappChannel.invokeMethod<void>(
        'sharePdfToWhatsApp',
        {'filePath': filePath},
      );
      return;
    }

    await SharePlus.instance.share(ShareParams(files: [XFile(filePath)]));
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
