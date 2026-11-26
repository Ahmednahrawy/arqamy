import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:arqamy/core/helpers/formatters.dart';
import 'package:arqamy/core/helpers/invoice_discount.dart';
import 'package:arqamy/core/helpers/utils.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _arabicPattern = r'[\u0600-\u06FF]';

Map<String, String> _readArb(String locale) {
  final file = File('lib/l10n/intl_$locale.arb');
  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final entry in decoded.entries)
      if (!entry.key.startsWith('@')) entry.key: entry.value as String,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ARB resources', () {
    late Map<String, String> en;
    late Map<String, String> ar;

    setUpAll(() {
      en = _readArb('en');
      ar = _readArb('ar');
    });

    test('English and Arabic declare the same keys', () {
      expect(ar.keys.toSet(), equals(en.keys.toSet()));
    });

    test('no translation is empty or a placeholder', () {
      for (final messages in [en, ar]) {
        messages.forEach((key, value) {
          expect(value.trim(), isNotEmpty, reason: 'empty value for "$key"');
          expect(
            value.toLowerCase(),
            isNot(contains('translation missing')),
            reason: 'placeholder value for "$key"',
          );
        });
      }
    });

    test('English values do not contain Arabic text', () {
      final arabic = RegExp(_arabicPattern);
      en.forEach((key, value) {
        expect(
          arabic.hasMatch(value),
          isFalse,
          reason: 'Arabic characters in English value for "$key": $value',
        );
      });
    });

    test('Arabic values differ from English and contain Arabic text', () {
      final arabic = RegExp(_arabicPattern);
      for (final key in en.keys) {
        expect(
          ar[key],
          isNot(equals(en[key])),
          reason: 'Arabic value for "$key" is identical to English',
        );
        expect(
          arabic.hasMatch(ar[key]!),
          isTrue,
          reason: 'Arabic value for "$key" has no Arabic characters',
        );
      }
    });
  });

  group('S localization', () {
    test('supports Arabic and English', () {
      final languages = S.delegate.supportedLocales
          .map((locale) => locale.languageCode)
          .toSet();
      expect(languages, containsAll(['ar', 'en']));
    });

    test('loads the expected Arabic and English strings', () async {
      final ar = await S.delegate.load(const Locale('ar'));
      expect(ar.save, 'حفظ');
      expect(ar.currency, 'ج.م');
      expect(ar.purchase, 'شراء');

      final en = await S.delegate.load(const Locale('en'));
      expect(en.save, 'Save');
      expect(en.currency, 'EGP');
      expect(en.purchase, 'Purchase');
    });
  });

  group('AppFormatters', () {
    test('uses Latin digits and thousands separators', () async {
      final ar = await S.delegate.load(const Locale('ar'));
      expect(AppFormatters.number(1234.5), '1,234.50');
      expect(AppFormatters.currency(1234.5, ar), '1,234.50 ج.م');
      expect(AppFormatters.weight(2, ar), '2.00 كجم');
    });

    test('handles Arabic plural forms for invoice counts', () async {
      final ar = await S.delegate.load(const Locale('ar'));
      expect(AppFormatters.invoiceCount(1, ar, 'ar'), 'فاتورة واحدة');
      expect(AppFormatters.invoiceCount(2, ar, 'ar'), 'فاتورتان');
      expect(AppFormatters.invoiceCount(5, ar, 'ar'), '5 فواتير');
      expect(AppFormatters.invoiceCount(11, ar, 'ar'), '11 فاتورة');
    });

    test('handles English plural forms for invoice counts', () async {
      final en = await S.delegate.load(const Locale('en'));
      expect(AppFormatters.invoiceCount(1, en, 'en'), '1 invoice');
      expect(AppFormatters.invoiceCount(3, en, 'en'), '3 invoices');
    });
  });

  group('PDF localization', () {
    test('generates distinct Arabic and English PDFs', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = InvoiceProvider()
        ..addProduct(
          Product(
            name: 'Rice',
            weight: 2,
            packageWeight: 0,
            numberPackage: 0,
            price: 10,
          ),
        );
      final settings = InvoiceSettingsProvider();
      await settings.loadSettings();

      Future<List<int>> build(String locale) => generatePDF(
            PdfPageFormat.a4,
            provider,
            settings,
            'Customer',
            20,
            5,
            15,
            'Oct 28, 2026',
            '12:34',
            'شراء',
            '1001',
            locale: locale,
          );

      final arabic = await build('ar');
      final english = await build('en');

      expect(String.fromCharCodes(arabic.take(5)), '%PDF-');
      expect(String.fromCharCodes(english.take(5)), '%PDF-');
      expect(arabic, isNot(equals(english)));
    });

    test('a percentage discount is included in the generated PDF', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = InvoiceProvider()
        ..addProduct(
          Product(
            name: 'Rice',
            weight: 2,
            packageWeight: 0,
            numberPackage: 0,
            price: 10,
          ),
        );
      final settings = InvoiceSettingsProvider();
      await settings.loadSettings();

      final bytes = await generatePDF(
        PdfPageFormat.a4,
        provider,
        settings,
        'Customer',
        18,
        5,
        13,
        'Oct 28, 2026',
        '12:34',
        'sale',
        '1002',
        locale: 'en',
        subtotalCost: 20,
        discount: const InvoiceDiscount(
          type: InvoiceDiscountType.percent,
          value: 10,
          amount: 2,
        ),
      );

      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });
}
