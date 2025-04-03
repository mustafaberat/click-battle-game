import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _backgroundMusicKey = 'background_music_enabled';
  static const String _touchSoundKey = 'touch_sound_enabled';
  static const String _volumeKey = 'sound_volume';

  final SharedPreferences _prefs;

  bool _backgroundMusicEnabled;
  bool _touchSoundEnabled;
  double _volume;

  SettingsService(this._prefs)
      : _backgroundMusicEnabled = _prefs.getBool(_backgroundMusicKey) ?? false,
        _touchSoundEnabled = _prefs.getBool(_touchSoundKey) ?? false,
        _volume = _prefs.getDouble(_volumeKey) ?? 0.7;

  // Getters
  bool get backgroundMusicEnabled => _backgroundMusicEnabled;
  bool get touchSoundEnabled => _touchSoundEnabled;
  double get volume => _volume;

  // Setters
  Future<void> setBackgroundMusicEnabled(bool value) async {
    if (_backgroundMusicEnabled != value) {
      _backgroundMusicEnabled = value;
      await _prefs.setBool(_backgroundMusicKey, value);
      notifyListeners();
    }
  }

  Future<void> setTouchSoundEnabled(bool value) async {
    if (_touchSoundEnabled != value) {
      _touchSoundEnabled = value;
      await _prefs.setBool(_touchSoundKey, value);
      notifyListeners();
    }
  }

  Future<void> setVolume(double value) async {
    if (_volume != value) {
      _volume = value;
      await _prefs.setDouble(_volumeKey, value);
      notifyListeners();
    }
  }

  // Reset settings to defaults
  Future<void> resetToDefaults() async {
    await Future.wait([
      setBackgroundMusicEnabled(true),
      setTouchSoundEnabled(true),
      setVolume(0.7),
    ]);
  }
} 