import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
    
    final prefs = await SharedPreferences.getInstance();
    _isMusicEnabled = prefs.getBool(_musicEnabledKey) ?? true;
    _volume = prefs.getDouble(_volumeKey) ?? 0.5;

    await _bgmPlayer.setAsset('lib/assets/audio/bg-music.mp3');
    await _bgmPlayer.setLoopMode(LoopMode.all);
    await _bgmPlayer.setVolume(_isMusicEnabled ? _volume : 0);
    
    _isInitialized = true;
    
    // Only autoplay on non-web platforms
    if (_isMusicEnabled && !kIsWeb) {
      await _bgmPlayer.play();
    }
  }

  Future<void> startMusic() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_isMusicEnabled) {
      await _bgmPlayer.play();
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _bgmPlayer.setVolume(_isMusicEnabled ? volume : 0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, volume);
  }

  Future<void> toggleMusic(bool enabled) async {
    _isMusicEnabled = enabled;
    if (enabled) {
      await _bgmPlayer.setVolume(_volume);
      await _bgmPlayer.play();
    } else {
      await _bgmPlayer.setVolume(0);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicEnabledKey, enabled);
  }

  double get volume => _volume;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isInitialized => _isInitialized;

  Future<void> dispose() async {
    await _bgmPlayer.dispose();
  }
} 