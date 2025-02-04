import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart' show debugPrint;

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _player = AudioPlayer();
  static const String _musicEnabledKey = 'music_enabled';
  static const String _volumeKey = 'volume';
  static const double defaultVolume = 0.2;
  late SharedPreferences _prefs;
  bool _isMusicEnabled = false;
  double _volume = 0.5;
  bool _isInitialized = false;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  bool get isMusicEnabled => _isMusicEnabled;
  double get volume => _player.volume;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _isMusicEnabled = _prefs.getBool(_musicEnabledKey) ?? false;
      double savedVolume = _prefs.getDouble(_volumeKey) ?? defaultVolume;
      
      await _player.setAsset('lib/assets/audio/bg-music.mp3');
      await _player.setLoopMode(LoopMode.all);
      await setVolume(savedVolume);
      
      _isInitialized = true;
      
      if (_isMusicEnabled) {
        await _player.play();
      }
    } catch (e) {
      debugPrint('Failed to initialize audio service: $e');
      // Continue without audio if initialization fails
      _isInitialized = true;
    }
  }

  Future<void> startMusic() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_isMusicEnabled) {
      try {
        await _player.play();
      } catch (e) {
        debugPrint('Failed to start music: $e');
      }
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _player.setVolume(volume);
    await _prefs.setDouble(_volumeKey, volume);
  }

  Future<void> toggleMusic(bool enabled) async {
    _isMusicEnabled = enabled;
    await _prefs.setBool(_musicEnabledKey, enabled);
    
    if (enabled) {
      await _player.play();
    } else {
      await _player.pause();
    }
  }

  bool get isInitialized => _isInitialized;

  void dispose() {
    if (_isInitialized) {
      _player.dispose();
    }
  }
} 