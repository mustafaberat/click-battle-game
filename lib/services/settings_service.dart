import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _soundKey = 'sound_enabled';
  static const String _volumeKey = 'sound_volume';

  final SharedPreferences _prefs;

  bool _soundEnabled;
  double _soundVolume;

  SettingsService(this._prefs)
      : _soundEnabled = _prefs.getBool(_soundKey) ?? true,
        _soundVolume = _prefs.getDouble(_volumeKey) ?? 0.7;

  // Getters
  bool get soundEnabled => _soundEnabled;
  double get soundVolume => _soundVolume;

  // Setters
  Future<void> setSoundEnabled(bool value) async {
    if (_soundEnabled != value) {
      _soundEnabled = value;
      await _prefs.setBool(_soundKey, value);
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
      setSoundVolume(0.7),
    ]);
  }
} 