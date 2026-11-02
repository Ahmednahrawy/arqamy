import 'package:arqamy/core/helpers/invoice_date_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(initializeDateFormatting);

  test('parses ISO, Arabic and English legacy dates strictly', () {
    final arabicDate = DateFormat.yMMMd('ar').format(DateTime(2026, 10, 28));
    final englishDate = DateFormat.yMMMd('en').format(DateTime(2026, 10, 29));

    expect(
      InvoiceDateParser.parseDate('2026-10-27'),
      DateTime(2026, 10, 27),
    );
    expect(
      InvoiceDateParser.parseDate(arabicDate),
      DateTime(2026, 10, 28),
    );
    expect(
      InvoiceDateParser.parseDate(englishDate),
      DateTime(2026, 10, 29),
    );
    expect(InvoiceDateParser.parseDate('2026-02-30'), isNull);
    expect(InvoiceDateParser.parseDate('10/11/2026'), isNull);
    expect(InvoiceDateParser.parseDate(''), isNull);
  });

  test('parses supported Arabic, English and ISO times strictly', () {
    final arabicTime = DateFormat.Hm('ar').format(DateTime(1970, 1, 1, 8, 5));
    final englishTime = DateFormat.jm('en').format(DateTime(1970, 1, 1, 20, 5));

    expect(
      InvoiceDateParser.parseTime(arabicTime),
      const TimeOfDay(hour: 8, minute: 5),
    );
    expect(
      InvoiceDateParser.parseTime(englishTime),
      const TimeOfDay(hour: 20, minute: 5),
    );
    expect(
      InvoiceDateParser.parseTime('08:05:30'),
      const TimeOfDay(hour: 8, minute: 5),
    );
    expect(InvoiceDateParser.parseTime('25:00'), isNull);
    expect(InvoiceDateParser.parseTime(''), isNull);
  });

  test('uses local midnight for missing or invalid time', () {
    expect(
      InvoiceDateParser.parseDateTime('2026-10-28', ''),
      DateTime(2026, 10, 28),
    );
    expect(
      InvoiceDateParser.parseDateTime('2026-10-28', '25:00'),
      DateTime(2026, 10, 28),
    );
  });

  test('ISO timestamps use local wall time or convert explicit offsets', () {
    expect(
      InvoiceDateParser.parseDateTime(
        '2026-10-28T08:15:30',
        '18:00',
      ),
      DateTime(2026, 10, 28, 8, 15, 30),
    );
    final explicitTimezone = InvoiceDateParser.parseDateTime(
      '2026-10-28T08:15:30+02:00',
      '18:00',
    );
    expect(
      explicitTimezone,
      DateTime.parse('2026-10-28T08:15:30+02:00').toLocal(),
    );
    expect(
      InvoiceDateParser.parseDateTime(
        '2026-10-28T08:15:30Z',
        '18:00',
      ),
      DateTime.utc(2026, 10, 28, 8, 15, 30).toLocal(),
    );
  });
}
