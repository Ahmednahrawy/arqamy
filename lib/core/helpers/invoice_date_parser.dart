import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class InvoiceDateParser {
  static final _isoDatePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
  static final _isoDateTimePattern = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})[Tt ]'
    r'(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{1,9}))?)?'
    r'([Zz]|[+-]\d{2}:?\d{2})?$',
  );
  static final _isoTimePattern = RegExp(
    r'^(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{1,9}))?)?$',
  );

  static DateTime? parseDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final timestampMatch = _isoDateTimePattern.firstMatch(trimmed);
    if (timestampMatch != null) {
      return _parseIsoDateTime(timestampMatch);
    }

    final isoDateMatch = _isoDatePattern.firstMatch(trimmed);
    if (isoDateMatch != null) {
      return _localDate(
        int.parse(isoDateMatch[1]!),
        int.parse(isoDateMatch[2]!),
        int.parse(isoDateMatch[3]!),
      );
    }

    for (final locale in const ['ar', 'en']) {
      try {
        return intl.DateFormat.yMMMd(locale).parseStrict(trimmed);
      } on FormatException {
        // Continue with the other supported persisted locale.
      }
    }
    return null;
  }

  static TimeOfDay? parseTime(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    for (final locale in const ['ar', 'en']) {
      for (final format in [
        intl.DateFormat.Hm(locale),
        intl.DateFormat.jm(locale),
      ]) {
        try {
          final parsed = format.parseStrict(trimmed);
          return TimeOfDay(hour: parsed.hour, minute: parsed.minute);
        } on FormatException {
          // Continue with the remaining supported formats.
        }
      }
    }

    final isoTimeMatch = _isoTimePattern.firstMatch(trimmed);
    if (isoTimeMatch == null) return null;
    final hour = int.parse(isoTimeMatch[1]!);
    final minute = int.parse(isoTimeMatch[2]!);
    final second = int.parse(isoTimeMatch[3] ?? '0');
    if (hour > 23 || minute > 59 || second > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static DateTime? parseDateTime(String date, String time) {
    final trimmedDate = date.trim();
    final timestampMatch = _isoDateTimePattern.firstMatch(trimmedDate);
    if (timestampMatch != null) {
      return _parseIsoDateTime(timestampMatch);
    }

    final parsedDate = parseDate(trimmedDate);
    if (parsedDate == null) return null;
    final parsedTime = parseTime(time);
    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      parsedTime?.hour ?? 0,
      parsedTime?.minute ?? 0,
    );
  }

  static DateTime? _parseIsoDateTime(RegExpMatch match) {
    final year = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final day = int.parse(match[3]!);
    final hour = int.parse(match[4]!);
    final minute = int.parse(match[5]!);
    final second = int.parse(match[6] ?? '0');
    if (!_isValidDate(year, month, day) ||
        hour > 23 ||
        minute > 59 ||
        second > 59) {
      return null;
    }

    final timezone = match[8];
    if (timezone != null) {
      final normalizedTimezone = timezone.toUpperCase() == 'Z'
          ? 'Z'
          : timezone.contains(':')
              ? timezone
              : '${timezone.substring(0, 3)}:${timezone.substring(3)}';
      final normalizedTimestamp =
          '${match[1]}-${match[2]}-${match[3]}T${match[4]}:${match[5]}'
          '${match[6] == null ? '' : ':${match[6]}'}'
          '${match[7] == null ? '' : '.${match[7]}'}$normalizedTimezone';
      final parsed = DateTime.tryParse(normalizedTimestamp);
      return parsed?.toLocal();
    }

    return DateTime(
      year,
      month,
      day,
      hour,
      minute,
      second,
      _fractionalMilliseconds(match[7]),
      _fractionalMicroseconds(match[7]),
    );
  }

  static int _fractionalMilliseconds(String? fraction) {
    if (fraction == null) return 0;
    return int.parse(fraction.padRight(3, '0').substring(0, 3));
  }

  static int _fractionalMicroseconds(String? fraction) {
    if (fraction == null) return 0;
    final microseconds = fraction.padRight(6, '0').substring(3, 6);
    return int.parse(microseconds);
  }

  static DateTime? _localDate(int year, int month, int day) {
    if (!_isValidDate(year, month, day)) return null;
    return DateTime(year, month, day);
  }

  static bool _isValidDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return false;
    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day;
  }
}
