import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Picks a backup file using Android's app chooser on Android.
///
/// `file_picker` opens the system document picker directly, which on some
/// devices only offers Google Drive. The native channel forces a resolver so
/// the user can choose Drive, Files, Dropbox or any other file provider.
class BackupFilePicker {
  const BackupFilePicker._();

  static const MethodChannel _channel = MethodChannel(
    'com.nahro.arqamy/backup',
  );

  /// Returns the local path of the chosen file, or null when cancelled.
  static Future<String?> pickFilePath() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _channel.invokeMethod<String?>('pickBackupFile');
    }
    final file = await FilePicker.pickFile();
    return file?.path;
  }

  /// Returns the bytes of the chosen file, or null when cancelled.
  static Future<List<int>?> pickBytes() async {
    final path = await pickFilePath();
    if (path == null) return null;
    return File(path).readAsBytes();
  }
}
