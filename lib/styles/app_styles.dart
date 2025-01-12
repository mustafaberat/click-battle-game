import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1E1E1E);
  static const Color accent = Color(0xFF00B4D8);
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF2A2A2A);
  static const Color surface = Color(0xFF2A2A2A);
  static const Color error = Color(0xFFCF6679);
}

class AppDimensions {
  static double padding(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.04;
  }

  static double spacing(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.02;
  }

  static double borderRadius(BuildContext context) {
    return 12.0;
  }

  static double buttonHeight(BuildContext context) {
    return 56.0;
  }

  static double titleFontSize(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.06;
  }

  static double headingFontSize(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.05;
  }

  static double subtitleFontSize(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.04;
  }

  static double bodyFontSize(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.035;
  }

  static double buttonFontSize(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.04;
  }
}

class AppTextStyles {
  static TextStyle title(BuildContext context) {
    return TextStyle(
      fontSize: AppDimensions.titleFontSize(context),
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  static TextStyle heading(BuildContext context) {
    return TextStyle(
      fontSize: AppDimensions.headingFontSize(context),
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  static TextStyle subtitle(BuildContext context) {
    return TextStyle(
      fontSize: AppDimensions.subtitleFontSize(context),
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );
  }

  static TextStyle body(BuildContext context) {
    return TextStyle(
      fontSize: AppDimensions.bodyFontSize(context),
      color: Colors.white,
    );
  }

  static TextStyle button(BuildContext context) {
    return TextStyle(
      fontSize: AppDimensions.buttonFontSize(context),
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
  }
} 