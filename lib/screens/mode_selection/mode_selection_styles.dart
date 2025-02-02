import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';

class ModeSelectionStyles {
  static BoxDecoration buttonDecoration(Color color, BuildContext context) => BoxDecoration(
    borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
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

  static TextStyle Function(BuildContext context) get modeTitle => AppTextStyles.heading;
  
  static TextStyle Function(BuildContext context) get difficultyText => AppTextStyles.button;
  
  static TextStyle speedText(BuildContext context) => AppTextStyles.body(context).copyWith(
    color: Colors.white.withOpacity(0.8),
    fontSize: 14,
  );

  static const double difficultyButtonWidth = 100;
  static const double difficultyButtonSpacing = 20;
  static const EdgeInsets difficultyButtonPadding = EdgeInsets.symmetric(vertical: 15);
} 