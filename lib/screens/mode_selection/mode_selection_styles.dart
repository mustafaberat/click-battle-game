import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';

class ModeSelectionStyles {
  static BoxDecoration buttonDecoration(Color color) => BoxDecoration(
    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
    gradient: LinearGradient(
      colors: [
        color,
        color.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: 10,
        spreadRadius: 2,
      ),
    ],
  );

  static BoxDecoration difficultyButtonDecoration(Color color) => BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    gradient: LinearGradient(
      colors: [
        color,
        color.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: 10,
        spreadRadius: 2,
      ),
    ],
  );

  static TextStyle get modeTitle => AppTextStyles.heading;
  
  static TextStyle get difficultyText => AppTextStyles.button;
  
  static TextStyle get speedText => AppTextStyles.body.copyWith(
    color: Colors.white.withOpacity(0.8),
    fontSize: 14,
  );

  static const double difficultyButtonWidth = 100;
  static const double difficultyButtonSpacing = 20;
  static const EdgeInsets difficultyButtonPadding = EdgeInsets.symmetric(vertical: 15);
} 