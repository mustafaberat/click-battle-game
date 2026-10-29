import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// Background music disabled — stubs kept so call sites stay safe.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  AudioPlayer? _player;
  static const String _volumeKey = 'volume';
  static const double defaultVolume = 0.2;
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  double _volume = defaultVolume;

  factory AudioService() => _instance;

  AudioService._internal();

  AudioPlayer get _audioPlayer => _player ??= AudioPlayer();

  bool get isMusicEnabled => false;
  double get volume => _volume;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      _volume = _prefs.getDouble(_volumeKey) ?? defaultVolume;
      // Do not load or play bg-music.
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('Audio service init skipped: $e');
    }
    _isInitialized = true;
  }

  Future<void> startMusic() async {}

  Future<void> setVolume(double volume) async {
    _volume = volume;
    if (_isInitialized) {
      await _prefs.setDouble(_volumeKey, volume);
    }
  }

  Future<void> toggleMusic(bool enabled) async {
    // Music removed — ignore toggle, keep paused.
    try {
      await _audioPlayer.pause();
    } catch (_) {}
  }

  void dispose() {
    if (_isInitialized) {
      _player?.dispose();
    }
  }
}
