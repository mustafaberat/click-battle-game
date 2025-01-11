import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';

class GameStyles {
  static TextStyle get difficultyText => AppTextStyles.heading;
  static TextStyle get playerName => AppTextStyles.heading;
  static TextStyle get scoreText => const TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  static TextStyle get cpsText => AppTextStyles.body.copyWith(
    color: Colors.white70,
    fontSize: 18,
  );

  // Timer styles
  static TextStyle get timerText => AppTextStyles.heading.copyWith(
    fontSize: 28,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get countdownText => const TextStyle(
    color: Colors.white,
    fontSize: 72,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        color: Colors.blue,
        blurRadius: 20,
        offset: Offset(0, 0),
      ),
    ],
  );

  // Winner styles
  static TextStyle get titleText => AppTextStyles.title.copyWith(
    color: Colors.white,
    shadows: [
      Shadow(
        color: Colors.blue,
        blurRadius: 10,
        offset: Offset(0, 0),
      ),
    ],
  );

  static TextStyle get winnerText => AppTextStyles.heading.copyWith(
    fontSize: 36,
    color: Colors.white,
    shadows: [
      Shadow(
        color: Colors.green[400]!,
        blurRadius: 10,
        offset: Offset(0, 0),
      ),
    ],
  );

  static ButtonStyle get buttonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
    textStyle: AppTextStyles.button,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  );

  static BoxDecoration clickAreaDecoration(Color color) => BoxDecoration(
    shape: BoxShape.circle,
    color: color.withOpacity(0.3),
    border: Border.all(
      color: Colors.white.withOpacity(0.5),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: 10,
        spreadRadius: 5,
      ),
    ],
  );

  static const double clickAreaSize = 200;
  static const double iconSize = 64;
  static const EdgeInsets padding = EdgeInsets.all(16);
  static const double spacing = 20;
  static const double dividerHeight = 2;
} 