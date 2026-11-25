import 'dart:convert';
import 'dart:io';

import 'package:arqamy/core/services/legacy_invoice_snapshot_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'arqamy_legacy_snapshot_test_',
    );
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  test('preserves the exact raw preference and verifies its SHA-256', () async {
    const raw = ' [ { "id" : "legacy", "unknown": true } ] \n';
    final service = LegacyInvoiceSnapshotService(
      readSource: () async => raw,
      directory: temporaryDirectory,
      clock: () => DateTime.utc(2026, 11, 25, 12),
    );

    final snapshot = await service.capture();

    expect(await snapshot.rawFile.readAsString(), raw);
    expect(snapshot.sourceExists, isTrue);
    expect(snapshot.byteLength, utf8.encode(raw).length);
    expect(snapshot.sha256, sha256.convert(utf8.encode(raw)).toString());
    expect(snapshot.capturedAt, DateTime.utc(2026, 11, 25, 12));

    final manifest = jsonDecode(await snapshot.manifestFile.readAsString())
        as Map<String, dynamic>;
    expect(manifest['sourceKey'], 'saved_invoices');
    expect(manifest['sourceExists'], isTrue);
    expect(manifest['sha256'], snapshot.sha256);
    expect(manifest['byteLength'], snapshot.byteLength);
  });

  test('distinguishes a missing preference from an empty preference', () async {
    final missing = await LegacyInvoiceSnapshotService(
      readSource: () async => null,
      directory: temporaryDirectory,
    ).capture();
    final empty = await LegacyInvoiceSnapshotService(
      readSource: () async => '',
      directory: temporaryDirectory,
    ).capture();

    expect(missing.sourceExists, isFalse);
    expect(empty.sourceExists, isTrue);
    expect(missing.sha256, empty.sha256);
    expect(await missing.rawFile.readAsBytes(), isEmpty);
    expect(await empty.rawFile.readAsBytes(), isEmpty);

    final missingManifest =
        jsonDecode(await missing.manifestFile.readAsString())
            as Map<String, dynamic>;
    final emptyManifest =
        jsonDecode(await empty.manifestFile.readAsString())
            as Map<String, dynamic>;
    expect(missingManifest['sourceExists'], isFalse);
    expect(emptyManifest['sourceExists'], isTrue);
  });

  test('reuses a verified content-addressed raw snapshot', () async {
    const raw = '[{"id":"same"}]';
    final service = LegacyInvoiceSnapshotService(
      readSource: () async => raw,
      directory: temporaryDirectory,
    );

    final first = await service.capture();
    final second = await service.capture();

    expect(second.rawFile.path, first.rawFile.path);
    expect(await second.rawFile.readAsString(), raw);
  });

  test('fails rather than trusting a corrupt existing snapshot', () async {
    const raw = '[{"id":"source"}]';
    final digest = sha256.convert(utf8.encode(raw)).toString();
    final existing = File(
      '${temporaryDirectory.path}/saved-invoices-$digest.raw',
    );
    await existing.writeAsString('corrupt');

    final service = LegacyInvoiceSnapshotService(
      readSource: () async => raw,
      directory: temporaryDirectory,
    );

    await expectLater(service.capture(), throwsStateError);
  });

  test('does not create a snapshot if reading the source fails', () async {
    final service = LegacyInvoiceSnapshotService(
      readSource: () async => throw StateError('read failed'),
      directory: temporaryDirectory,
    );

    await expectLater(service.capture(), throwsStateError);
    expect(await temporaryDirectory.list().toList(), isEmpty);
  });
}
