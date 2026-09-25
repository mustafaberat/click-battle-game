import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clickbattle/constants/app_strings.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  late SharedPreferences _prefs;
  String _currentLanguage = 'en';

  /// Priority order from ARU Soft mobile rules.
  static const List<String> languageOrder = [
    'en',
    'es',
    'pt',
    'zh',
    'ja',
    'de',
    'fr',
    'ko',
    'it',
    'tr',
  ];

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Español',
    'pt': 'Português',
    'zh': '中文',
    'ja': '日本語',
    'de': 'Deutsch',
    'fr': 'Français',
    'ko': '한국어',
    'it': 'Italiano',
    'tr': 'Türkçe',
  };

  LocalizationService() {
    _initPrefs();
  }

  String get currentLanguage => _currentLanguage;

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs.getString(_languageKey);
    if (saved != null && AppStrings.translations.containsKey(saved)) {
      _currentLanguage = saved;
    } else {
      _currentLanguage = _deviceLanguage();
      await _prefs.setString(_languageKey, _currentLanguage);
    }
    notifyListeners();
  }

  String _deviceLanguage() {
    final code =
        PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    if (AppStrings.translations.containsKey(code)) return code;
    // zh_Hans / zh_CN → zh
    if (code.startsWith('zh')) return 'zh';
    return 'en';
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
}
