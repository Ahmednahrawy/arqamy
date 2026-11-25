import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A byte-for-byte snapshot of the legacy SharedPreferences invoice value.
///
/// This service deliberately reads the raw preference directly. It does not
/// load or serialize [InvoiceProvider] models, so malformed records and the
/// original JSON representation remain recoverable.
class LegacyInvoiceSnapshot {
  const LegacyInvoiceSnapshot({
    required this.sourceKey,
    required this.sourceExists,
    required this.sha256,
    required this.byteLength,
    required this.capturedAt,
    required this.rawFile,
    required this.manifestFile,
  });

  final String sourceKey;
  final bool sourceExists;
  final String sha256;
  final int byteLength;
  final DateTime capturedAt;
  final File rawFile;
  final File manifestFile;
}

/// Captures and verifies the exact legacy `saved_invoices` preference.
///
/// The raw file is content-addressed by SHA-256. A JSON manifest records
/// whether the preference existed, which distinguishes an absent key from
/// an existing empty string.
class LegacyInvoiceSnapshotService {
  LegacyInvoiceSnapshotService({
    Future<String?> Function()? readSource,
    Directory? directory,
    DateTime Function()? clock,
  }) : _readSource = readSource,
       _directory = directory,
       _clock = clock ?? DateTime.now;

  static const sourceKey = 'saved_invoices';

  final Future<String?> Function()? _readSource;
  final Directory? _directory;
  final DateTime Function() _clock;

  Future<LegacyInvoiceSnapshot> capture() async {
    final raw = await (_readSource ?? _readSharedPreference)();
    final bytes = utf8.encode(raw ?? '');
    final digest = sha256.convert(bytes).toString();
    final capturedAt = _clock().toUtc();
    final folder = _directory ?? await _defaultDirectory();
    await folder.create(recursive: true);

    final rawFile = File(p.join(folder.path, 'saved-invoices-$digest.raw'));
    final manifestFile = File(
      p.join(folder.path, 'saved-invoices-$digest.json'),
    );

    await _writeAndVerifyRawFile(rawFile, bytes, digest);

    final manifest = <String, Object>{
      'formatVersion': 1,
      'sourceKey': sourceKey,
      'sourceExists': raw != null,
      'sha256': digest,
      'byteLength': bytes.length,
      'capturedAt': capturedAt.toIso8601String(),
      'rawFileName': p.basename(rawFile.path),
    };
    final manifestText = const JsonEncoder.withIndent('  ').convert(manifest);
    final manifestBytes = utf8.encode(manifestText);
    final temporaryManifest = File('${manifestFile.path}.tmp');
    await temporaryManifest.writeAsBytes(manifestBytes, flush: true);
    await temporaryManifest.rename(manifestFile.path);

    return LegacyInvoiceSnapshot(
      sourceKey: sourceKey,
      sourceExists: raw != null,
      sha256: digest,
      byteLength: bytes.length,
      capturedAt: capturedAt,
      rawFile: rawFile,
      manifestFile: manifestFile,
    );
  }

  Future<String?> _readSharedPreference() async {
    return (await SharedPreferences.getInstance()).getString(sourceKey);
  }

  Future<Directory> _defaultDirectory() async {
    final support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'migration-snapshots'));
  }

  Future<void> _writeAndVerifyRawFile(
    File file,
    List<int> bytes,
    String expectedDigest,
  ) async {
    if (await file.exists()) {
      final existingBytes = await file.readAsBytes();
      if (sha256.convert(existingBytes).toString() == expectedDigest &&
          existingBytes.length == bytes.length) {
        return;
      }
      throw StateError('An existing snapshot file failed integrity checks.');
    }

    final temporary = File('${file.path}.tmp');
    try {
      await temporary.writeAsBytes(bytes, flush: true);
      final writtenBytes = await temporary.readAsBytes();
      if (writtenBytes.length != bytes.length ||
          sha256.convert(writtenBytes).toString() != expectedDigest) {
        throw StateError('The raw invoice snapshot failed verification.');
      }
      await temporary.rename(file.path);
    } finally {
      if (await temporary.exists()) {
        await temporary.delete();
      }
    }
  }
}
