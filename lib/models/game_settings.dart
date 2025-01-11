import 'package:flutter/foundation.dart';

class GameSettings with ChangeNotifier {
  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;
  bool _isAnimationEnabled = true;
  double _volume = 1.0;
  bool _isVibrationEnabled = true;

  // Getters
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isAnimationEnabled => _isAnimationEnabled;
  double get volume => _volume;
  bool get isVibrationEnabled => _isVibrationEnabled;

  // Setters with notification
  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;
    notifyListeners();
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    notifyListeners();
  }

  void toggleAnimation() {
    _isAnimationEnabled = !_isAnimationEnabled;
    notifyListeners();
  }

  void setVolume(double value) {
    _volume = value;
    notifyListeners();
  }

  void toggleVibration() {
    _isVibrationEnabled = !_isVibrationEnabled;
    notifyListeners();
  }
} 