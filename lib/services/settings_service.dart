import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _soundKey = 'sound_enabled';
  static const String _hapticKey = 'haptic_enabled';
  static const String _darkModeKey = 'dark_mode';
  static const String _volumeKey = 'sound_volume';

  final SharedPreferences _prefs;

  bool _soundEnabled;
  bool _hapticEnabled;
  bool _darkMode;
  double _soundVolume;

  SettingsService(this._prefs)
      : _soundEnabled = _prefs.getBool(_soundKey) ?? true,
        _hapticEnabled = _prefs.getBool(_hapticKey) ?? true,
        _darkMode = _prefs.getBool(_darkModeKey) ?? false,
        _soundVolume = _prefs.getDouble(_volumeKey) ?? 0.7;

  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;
  bool get darkMode => _darkMode;
  double get soundVolume => _soundVolume;

  // Setters
  Future<void> setSoundEnabled(bool value) async {
    if (_soundEnabled != value) {
      _soundEnabled = value;
      await _prefs.setBool(_soundKey, value);
      notifyListeners();
    }
  }

  Future<void> setHapticEnabled(bool value) async {
    if (_hapticEnabled != value) {
      _hapticEnabled = value;
      await _prefs.setBool(_hapticKey, value);
      notifyListeners();
    }
  }

  Future<void> setDarkMode(bool value) async {
    if (_darkMode != value) {
      _darkMode = value;
      await _prefs.setBool(_darkModeKey, value);
      notifyListeners();
    }
  }

  Future<void> setSoundVolume(double value) async {
    if (_soundVolume != value) {
      _soundVolume = value;
      await _prefs.setDouble(_volumeKey, value);
      notifyListeners();
    }
  }

  // Reset settings to defaults
  Future<void> resetToDefaults() async {
    await Future.wait([
      setSoundEnabled(true),
      setHapticEnabled(true),
      setDarkMode(false),
      setSoundVolume(0.7),
    ]);
  }
} 