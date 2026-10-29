import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('themeMode');
    _themeMode = switch (savedMode) {
      'system' => ThemeMode.system,
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ =>
        prefs.getBool('isDarkMode') == true ? ThemeMode.dark : ThemeMode.light,
    };
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    if (mode != ThemeMode.system) {
      await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
    }
    await prefs.setString(
        'themeMode',
        switch (mode) {
          ThemeMode.system => 'system',
          ThemeMode.dark => 'dark',
          ThemeMode.light => 'light',
        });
    _themeMode = mode;
    notifyListeners();
  }
}
