import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

import 'package:arqamy/core/helpers/invoice_backup.dart';
import 'package:arqamy/features/settingscreen/data/models/invoice_settings_snapshot.dart';

class InvoiceSettingsProvider extends ChangeNotifier {
  static const String defaultLogoPath = 'assets/images/arqamy.png';
  static const String _logoKey = 'logoPath';
  static const String _managerNameKey = 'managerName';
  static const String _managerPhoneKey = 'managerPhone';
  static const String _companyNameKey = 'companyName';
  static const String _companyDescriptionKey = 'companyDescription';
  static const String _qrDataKey = 'qrData';
  static const String _defaultPackageWeightKey = 'defaultPackageWeight';
  static const String _defaultPackageNumberKey = 'defaultPackageNumber';
  static const String _showPackageWeightKey = 'showPackageWeight';
  static const String _showPackageNumberKey = 'showPackageNumber';

  String _logoPath = defaultLogoPath;
  String _managerName = '';
  String _managerPhone = '';
  String _companyName = '';
  String _companyDescription = '';
  String _qrData = '';
  double _defaultPackageWeight = 2;
  int _defaultPackageNumber = 0;
  bool _showPackageWeight = true;
  bool _showPackageNumber = true;

  String get logoPath => _logoPath;
  String get managerName => _managerName;
  String get managerPhone => _managerPhone;
  String get companyName => _companyName;
  String get companyDescription => _companyDescription;
  String get qrData => _qrData;
  double get defaultPackageWeight => _defaultPackageWeight;
  int get defaultPackageNumber => _defaultPackageNumber;
  bool get showPackageWeight => _showPackageWeight;
  bool get showPackageNumber => _showPackageNumber;

  InvoiceSettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = InvoiceSettingsSnapshot.defaults();
    _logoPath = _readLogo(prefs.get(_logoKey));
    _managerName = prefs.getString(_managerNameKey) ?? '';
    _managerPhone = prefs.getString(_managerPhoneKey) ?? '';
    _companyName = prefs.getString(_companyNameKey) ?? '';
    _companyDescription = prefs.getString(_companyDescriptionKey) ?? '';
    _qrData = prefs.getString(_qrDataKey) ?? '';
    _defaultPackageWeight = _readDouble(
      prefs.get(_defaultPackageWeightKey),
      defaults.defaultPackageWeight,
    );
    _defaultPackageNumber = _readInt(
      prefs.get(_defaultPackageNumberKey),
      defaults.defaultPackageNumber,
    );
    _showPackageWeight = _readBool(
      prefs.get(_showPackageWeightKey),
      defaults.showPackageWeight,
    );
    _showPackageNumber = _readBool(
      prefs.get(_showPackageNumberKey),
      defaults.showPackageNumber,
    );
    notifyListeners();
  }

  // --- NEW METHOD TO HANDLE PERMANENT FILE STORAGE ---
  Future<String> _saveImagePermanently(String temporaryPath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(temporaryPath);
    // Create a consistent file name for the logo
    final newPath = p.join(appDir.path, 'invoice_logo_$fileName');

    final temporaryFile = File(temporaryPath);

    // Copy the file to the permanent location and return the new path
    final permanentFile = await temporaryFile.copy(newPath);
    return permanentFile.path;
  }

  Future<void> updateSettings({
    String? logoPath,
    String? managerName,
    String? managerPhone,
    String? companyName,
    String? companyDescription,
    String? qrData,
    double? defaultPackageWeight,
    int? defaultPackageNumber,
    bool? showPackageWeight,
    bool? showPackageNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    var changed = false;

    if (logoPath != null) {
      String path;
      if (logoPath.startsWith('assets/')) {
        // If it's the default asset path, save it as is
        path = logoPath;
      } else {
        // If it's a new temporary path, save the file permanently first
        path = await _saveImagePermanently(logoPath);
      }
      _logoPath = path;
      await prefs.setString(_logoKey, path);
      changed = true;
    }
    if (managerName != null) {
      _managerName = managerName;
      await prefs.setString(_managerNameKey, managerName);
      changed = true;
    }
    if (managerPhone != null) {
      _managerPhone = managerPhone;
      await prefs.setString(_managerPhoneKey, managerPhone);
      changed = true;
    }
    if (companyName != null) {
      _companyName = companyName;
      await prefs.setString(_companyNameKey, companyName);
      changed = true;
    }
    if (companyDescription != null) {
      _companyDescription = companyDescription;
      await prefs.setString(_companyDescriptionKey, companyDescription);
      changed = true;
    }
    if (qrData != null) {
      _qrData = qrData;
      await prefs.setString(_qrDataKey, qrData);
      changed = true;
    }
    if (defaultPackageWeight != null) {
      if (!defaultPackageWeight.isFinite || defaultPackageWeight < 0) {
        throw ArgumentError.value(
          defaultPackageWeight,
          'defaultPackageWeight',
          'must be zero or more',
        );
      }
      _defaultPackageWeight = defaultPackageWeight;
      await prefs.setDouble(_defaultPackageWeightKey, defaultPackageWeight);
      changed = true;
    }
    if (defaultPackageNumber != null) {
      if (defaultPackageNumber < 0) {
        throw ArgumentError.value(
          defaultPackageNumber,
          'defaultPackageNumber',
          'must be zero or more',
        );
      }
      _defaultPackageNumber = defaultPackageNumber;
      await prefs.setInt(_defaultPackageNumberKey, defaultPackageNumber);
      changed = true;
    }
    if (showPackageWeight != null) {
      _showPackageWeight = showPackageWeight;
      await prefs.setBool(_showPackageWeightKey, showPackageWeight);
      changed = true;
    }
    if (showPackageNumber != null) {
      _showPackageNumber = showPackageNumber;
      await prefs.setBool(_showPackageNumberKey, showPackageNumber);
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  InvoiceSettingsSnapshot snapshot() => InvoiceSettingsSnapshot(
    logoPath: _logoPath,
    managerName: _managerName,
    managerPhone: _managerPhone,
    companyName: _companyName,
    companyDescription: _companyDescription,
    qrData: _qrData,
    defaultPackageWeight: _defaultPackageWeight,
    defaultPackageNumber: _defaultPackageNumber,
    showPackageWeight: _showPackageWeight,
    showPackageNumber: _showPackageNumber,
  );

  /// Applies a complete settings snapshot. Used by restore and reset.
  Future<void> applySnapshot(InvoiceSettingsSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final logo = _readLogo(snapshot.logoPath);
    await prefs.setString(_logoKey, logo);
    await prefs.setString(_managerNameKey, snapshot.managerName);
    await prefs.setString(_managerPhoneKey, snapshot.managerPhone);
    await prefs.setString(_companyNameKey, snapshot.companyName);
    await prefs.setString(_companyDescriptionKey, snapshot.companyDescription);
    await prefs.setString(_qrDataKey, snapshot.qrData);
    await prefs.setDouble(_defaultPackageWeightKey, snapshot.defaultPackageWeight);
    await prefs.setInt(_defaultPackageNumberKey, snapshot.defaultPackageNumber);
    await prefs.setBool(_showPackageWeightKey, snapshot.showPackageWeight);
    await prefs.setBool(_showPackageNumberKey, snapshot.showPackageNumber);

    _logoPath = logo;
    _managerName = snapshot.managerName;
    _managerPhone = snapshot.managerPhone;
    _companyName = snapshot.companyName;
    _companyDescription = snapshot.companyDescription;
    _qrData = snapshot.qrData;
    _defaultPackageWeight = snapshot.defaultPackageWeight;
    _defaultPackageNumber = snapshot.defaultPackageNumber;
    _showPackageWeight = snapshot.showPackageWeight;
    _showPackageNumber = snapshot.showPackageNumber;
    notifyListeners();
  }

  /// Restores settings from an invoice backup. Returns true when the backup
  /// carried settings.
  Future<bool> restoreFromBackup(String backupText) async {
    final restored = InvoiceBackup.decodeSettings(backupText);
    if (restored == null) return false;
    await applySnapshot(restored);
    return true;
  }

  Future<void> resetToDefaults() =>
      applySnapshot(InvoiceSettingsSnapshot.defaults());

  static String _readLogo(Object? raw) {
    if (raw is! String || raw.trim().isEmpty) return defaultLogoPath;
    if (raw.startsWith('assets/')) return raw;
    if (!File(raw).existsSync()) return defaultLogoPath;
    return raw;
  }

  static double _readDouble(Object? raw, double fallback) {
    if (raw is! num || !raw.isFinite || raw < 0) return fallback;
    return raw.toDouble();
  }

  static int _readInt(Object? raw, int fallback) {
    final value = _readDouble(raw, fallback.toDouble());
    if (value != value.truncateToDouble()) return fallback;
    return value.toInt();
  }

  static bool _readBool(Object? raw, bool fallback) {
    if (raw is! bool) return fallback;
    return raw;
  }
}
