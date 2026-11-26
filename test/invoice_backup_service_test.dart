import 'dart:convert';
import 'dart:io';

import 'package:arqamy/core/helpers/invoice_backup.dart';
import 'package:arqamy/core/services/invoice_backup_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Android invoice restore uses the app chooser channel', () async {
    final directory = await Directory.systemTemp.createTemp(
      'arqamy_invoice_pick_test_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final path = p.join(directory.path, 'chosen.json');
    await File(path).writeAsString('{"invoices":[]}');

    String? calledMethod;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const channel = MethodChannel('com.nahro.arqamy/backup');
    messenger.setMockMethodCallHandler(channel, (call) async {
      calledMethod = call.method;
      return path;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(channel, null);
      debugDefaultTargetPlatformOverride = null;
    });
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    expect(await InvoiceBackupService.pickBackupText(), '{"invoices":[]}');
    expect(calledMethod, 'pickBackupFile');
  });

  test('backup file names sort by date and are safe on every platform', () {
    expect(
      InvoiceBackupService.backupFileName(DateTime(2026, 11, 21, 9, 5)),
      'arqamy-backup-20261121-0905.json',
    );
    expect(
      InvoiceBackupService.backupFileName(DateTime(2027, 1, 2, 23, 59)),
      'arqamy-backup-20270102-2359.json',
    );
  });

  group('backupTextFromBytes', () {
    test('decodes UTF-8 including Arabic text', () {
      const text = '{"customerName":"أحمد"}';

      expect(InvoiceBackupService.backupTextFromBytes(utf8.encode(text)), text);
    });

    test('removes a leading byte-order mark', () {
      final bytes = [0xEF, 0xBB, 0xBF, ...utf8.encode('{}')];

      expect(InvoiceBackupService.backupTextFromBytes(bytes), '{}');
    });

    test('rejects bytes that are not valid text', () {
      expect(
        () => InvoiceBackupService.backupTextFromBytes([0xFF, 0xFE, 0xFD]),
        throwsA(isA<InvoiceBackupFormatException>()),
      );
    });

    test('rejects a file that is too large', () {
      expect(
        () => InvoiceBackupService.backupTextFromBytes(
          Uint8List(InvoiceBackupService.maxBackupBytes + 1),
        ),
        throwsA(isA<InvoiceBackupFormatException>()),
      );
    });
  });
}
