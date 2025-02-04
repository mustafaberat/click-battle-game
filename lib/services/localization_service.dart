import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clickbattle/constants/app_strings.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  late SharedPreferences _prefs;
  String _currentLanguage = 'en';

  LocalizationService() {
    _initPrefs();
  }

  String get currentLanguage => _currentLanguage;

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _currentLanguage = _prefs.getString(_languageKey) ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (AppStrings.translations.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      await _prefs.setString(_languageKey, languageCode);
      notifyListeners();
    }
  }

  String getText(String key) {
    return AppStrings.translations[_currentLanguage]?[key] ?? 
           AppStrings.translations['en']?[key] ?? 
           'Missing text';
  }

  static Map<String, String> get supportedLanguages => {
    'en': 'English',
    'tr': 'Türkçe',
    'zh': '中文',
    'de': 'Deutsch',
    'es': 'Español',
  };
} 