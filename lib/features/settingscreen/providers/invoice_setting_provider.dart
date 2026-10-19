import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class InvoiceSettingsProvider extends ChangeNotifier {
  String _logoPath = 'assets/images/arqamy.png'; // default
  String _managerName = '';
  String _managerPhone = '';
  String _companyName = '';
  String _companyDescription = '';
  String _qrData = '';

  String get logoPath => _logoPath;
  String get managerName => _managerName;
  String get managerPhone => _managerPhone;
  String get companyName => _companyName;
  String get companyDescription => _companyDescription;
  String get qrData => _qrData;

  // Add a constructor that automatically loads settings
  InvoiceSettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Use the default path if nothing is saved
    _logoPath = prefs.getString('logoPath') ?? _logoPath;
    _managerName = prefs.getString('managerName') ?? '';
    _managerPhone = prefs.getString('managerPhone') ?? '';
    _companyName = prefs.getString('companyName') ?? '';
    _companyDescription = prefs.getString('companyDescription') ?? '';
    _qrData = prefs.getString('qrData') ?? '';
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
  }) async {
    final prefs = await SharedPreferences.getInstance();
    bool changed = false;

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
      await prefs.setString('logoPath', path);
      changed = true;
    }
    if (managerName != null) {
      _managerName = managerName;
      await prefs.setString('managerName', managerName);
      changed = true;
    }
    if (managerPhone != null) {
      _managerPhone = managerPhone;
      await prefs.setString('managerPhone', managerPhone);
      changed = true;
    }
    if (companyName != null) {
      _companyName = companyName;
      await prefs.setString('companyName', companyName);
      changed = true;
    }
    if (companyDescription != null) {
      _companyDescription = companyDescription;
      await prefs.setString('companyDescription', companyDescription);
      changed = true;
    }
    if (qrData != null) {
      _qrData = qrData;
      await prefs.setString('qrData', qrData);
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }
}
