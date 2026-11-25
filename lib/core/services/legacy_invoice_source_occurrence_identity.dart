import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Stable identity for one record occurrence inside an immutable source snapshot.
///
/// This identity is intentionally independent of the legacy invoice ID and
/// invoice serial. Identical records at different array positions remain
/// distinct occurrences.
class LegacyInvoiceSourceOccurrenceIdentity {
  const LegacyInvoiceSourceOccurrenceIdentity._({
    required this.version,
    required this.snapshotSha256,
    required this.sourceIndex,
    required this.recordSha256,
    required this.key,
  });

  static const currentVersion = 1;

  factory LegacyInvoiceSourceOccurrenceIdentity.create({
    required String snapshotSha256,
    required int sourceIndex,
    required String rawJson,
  }) {
    if (sourceIndex < 0) {
      throw ArgumentError.value(sourceIndex, 'sourceIndex', 'Must be >= 0.');
    }
    if (!_isSha256(snapshotSha256)) {
      throw ArgumentError.value(
        snapshotSha256,
        'snapshotSha256',
        'Must be a 64-character hexadecimal SHA-256 digest.',
      );
    }

    final recordSha256 = sha256.convert(utf8.encode(rawJson)).toString();
    final key = 'v$currentVersion:$snapshotSha256:$sourceIndex:$recordSha256';

    return LegacyInvoiceSourceOccurrenceIdentity._(
      version: currentVersion,
      snapshotSha256: snapshotSha256,
      sourceIndex: sourceIndex,
      recordSha256: recordSha256,
      key: key,
    );
  }

  final int version;
  final String snapshotSha256;
  final int sourceIndex;
  final String recordSha256;

  /// Versioned, deterministic key suitable for later migration staging.
  final String key;

  static bool _isSha256(String value) =>
      RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(value);
}
