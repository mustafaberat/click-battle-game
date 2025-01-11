import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';

class HomeStyles {
  static BoxDecoration get titleContainer => BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.white.withOpacity(0.1),
        blurRadius: 20,
        spreadRadius: 5,
      ),
    ],
  );

  static TextStyle get titleText => AppTextStyles.title.copyWith(
    shadows: [
      const Shadow(
        color: Colors.blue,
        blurRadius: 20,
        offset: Offset(0, 0),
      ),
    ],
  );

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

  static const EdgeInsets titlePadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 10,
  );

  static const double backgroundCircleSize = 20;
  static const double backgroundLineWidth = 2;
  static const double backgroundOpacity = 0.1;
} 