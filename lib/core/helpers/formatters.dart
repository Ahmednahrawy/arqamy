import 'package:intl/intl.dart';

import 'package:arqamy/generated/l10n.dart';

/// Locale-aware display formatters shared by screens and PDF invoices.
class AppFormatters {
  const AppFormatters._();

  /// Formats a number with thousands separators and exactly two decimals.
  /// Latin digits are used in both locales to keep figures unambiguous.
  static String number(double value) =>
      NumberFormat('#,##0.00', 'en').format(value);

  static String currency(double value, S strings) =>
      '${number(value)} ${strings.currency}';

  static String weight(double value, S strings) =>
      '${number(value)} ${strings.kilograms}';

  /// Arabic has dual and plural forms; English only singular/plural.
  static String invoiceCount(int count, S strings, String locale) {
    if (locale == 'ar') {
      if (count == 1) return strings.invoice_count_one;
      if (count == 2) return strings.invoice_count_two;
      if (count >= 3 && count <= 10) {
        return '$count ${strings.invoices_few}';
      }
      return '$count ${strings.invoices_many}';
    }
    if (count == 1) return strings.invoice_count_one;
    return '$count ${strings.invoices_few}';
  }
}
