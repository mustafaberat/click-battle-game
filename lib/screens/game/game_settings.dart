import 'package:flutter/foundation.dart';

class GameSettings extends ChangeNotifier {
  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _isVibrationEnabled = true;
  double _volume = 1.0;

  final int timeLimit;
  final int scoreLimit;
  final int difficulty;
  final bool isSinglePlayer;
  final bool isTimeMode;

  GameSettings({
    required this.timeLimit,
    required this.scoreLimit,
    required this.difficulty,
    required this.isSinglePlayer,
    required this.isTimeMode,
    bool? isSoundEnabled,
    bool? isMusicEnabled,
    bool? isVibrationEnabled,
    double? volume,
  }) : 
    _isSoundEnabled = isSoundEnabled ?? true,
    _isMusicEnabled = isMusicEnabled ?? true,
    _isVibrationEnabled = isVibrationEnabled ?? true,
    _volume = volume ?? 1.0;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isVibrationEnabled => _isVibrationEnabled;
  double get volume => _volume;

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    notifyListeners();
  }

  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;
    notifyListeners();
  }

  void toggleVibration() {
    _isVibrationEnabled = !_isVibrationEnabled;
    notifyListeners();
  }

  void setVolume(double value) {
    _volume = value;
    notifyListeners();
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      timeLimit: json['timeLimit'] as int,
      scoreLimit: json['scoreLimit'] as int,
      difficulty: json['difficulty'] as int,
      isSinglePlayer: json['isSinglePlayer'] as bool,
      isTimeMode: json['isTimeMode'] as bool,
      isSoundEnabled: json['isSoundEnabled'] as bool?,
      isMusicEnabled: json['isMusicEnabled'] as bool?,
      isVibrationEnabled: json['isVibrationEnabled'] as bool?,
      volume: json['volume'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeLimit': timeLimit,
      'scoreLimit': scoreLimit,
      'difficulty': difficulty,
      'isSinglePlayer': isSinglePlayer,
      'isTimeMode': isTimeMode,
      'isSoundEnabled': _isSoundEnabled,
      'isMusicEnabled': _isMusicEnabled,
      'isVibrationEnabled': _isVibrationEnabled,
      'volume': _volume,
    };
  }
} 