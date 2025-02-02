import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart' show debugPrint;

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _isMusicEnabled = true;
  double _volume = 0.5;
  bool _isInitialized = false;

  static const String _musicEnabledKey = 'music_enabled';
  static const String _volumeKey = 'music_volume';

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMusicEnabled = prefs.getBool(_musicEnabledKey) ?? false;
      _volume = prefs.getDouble(_volumeKey) ?? 0.5;

      await _bgmPlayer.setAsset('lib/assets/audio/bg-music.mp3');
      await _bgmPlayer.setLoopMode(LoopMode.all);
      await _bgmPlayer.setVolume(_isMusicEnabled ? _volume : 0);
      
      _isInitialized = true;
      
      // Only autoplay on non-web platforms and after user interaction
      if (_isMusicEnabled && !kIsWeb) {
        try {
          await _bgmPlayer.play();
        } catch (e) {
          debugPrint('Failed to autoplay music: $e');
          // Ignore autoplay errors
        }
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
        await _bgmPlayer.play();
      } catch (e) {
        debugPrint('Failed to start music: $e');
      }
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    if (_isInitialized) {
      await _bgmPlayer.setVolume(_isMusicEnabled ? volume : 0);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_volumeKey, volume);
    }
  }

  Future<void> toggleMusic(bool enabled) async {
    _isMusicEnabled = enabled;
    if (_isInitialized) {
      if (enabled) {
        await _bgmPlayer.setVolume(_volume);
        try {
          await _bgmPlayer.play();
        } catch (e) {
          debugPrint('Failed to toggle music: $e');
        }
      } else {
        await _bgmPlayer.setVolume(0);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_musicEnabledKey, enabled);
    }
  }

  double get volume => _volume;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isInitialized => _isInitialized;

  Future<void> dispose() async {
    if (_isInitialized) {
      await _bgmPlayer.dispose();
    }
  }
} 