
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language extends ChangeNotifier {
  // Default language (Arabic)
  Locale _currentLocale = const Locale('ar');
  Language() {
    _loadSavedLanguage();
  }
  Locale get currentLocale => _currentLocale;
  void _updateLocale(String languageCode) {
    _currentLocale = Locale(languageCode);
  }

  // Switch language function
  Future<void> switchLanguage(String languageCode) async{
    if (languageCode == 'en' || languageCode == 'ar') {
      _updateLocale(languageCode);
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', languageCode);
    } else {
      throw ArgumentError('Unsupported language code: $languageCode');
    }
  }

  // Method to check if the current language is Arabic
  bool get isArabic => _currentLocale.languageCode == 'ar';

  List<Map<String, String>> get languageOptions => [
        {
          'code': 'en',
          // 'assetPath': 'assets/images/english_flag.png',
          'text': 'English'
        },
        {
          'code': 'ar',
          // 'assetPath': 'assets/imageps/saudi_flag.png',
          'text': 'العربية'
        },
      ];
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('languageCode');

    if (savedLang != null && (savedLang == 'ar' || savedLang == 'en')) {
      _updateLocale(savedLang);
      notifyListeners();
    }
  }
}
