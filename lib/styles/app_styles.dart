import 'package:flutter/material.dart';

class AppColors {
  static final primary = Colors.blue[900]!;
  static final secondary = Colors.blue[600]!;
  static final accent = Colors.green[400]!;
  static final warning = Colors.orange[400]!;
  static final danger = Colors.red[400]!;
  static const white = Colors.white;
}

class AppGradients {
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A237E), // Dark blue
      Color(0xFF1E88E5), // Light blue
    ],
  );
}

class AppTextStyles {
  static const title = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const body = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  static const button = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

class AppDecorations {
  static BoxDecoration gradientBackground = BoxDecoration(
    gradient: AppGradients.backgroundGradient,
  );

  static BoxShadow defaultShadow = BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 10,
    spreadRadius: 2,
  );
}

class AppDimensions {
  static const double buttonHeight = 60;
  static const double buttonWidth = 220;
  static const double borderRadius = 30;
  static const double padding = 16;
  static const double spacing = 20;
} 