import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1A237E);  // Deep blue
  static const accent = Color(0xFF4CAF50);   // Green
  static const background = Color(0xFF0D47A1); // Darker blue
  static const surface = Color(0xFF1565C0);   // Medium blue
  static const error = Color(0xFFD32F2F);     // Red
}

class AppDimensions {
  static double padding(BuildContext context) => 16.0;
  static double spacing(BuildContext context) => 8.0;
  static double borderRadius(BuildContext context) => 12.0;
  static double buttonHeight(BuildContext context) => 56.0;
  
  static double titleFontSize(BuildContext context) => 24.0;
  static double headingFontSize(BuildContext context) => 20.0;
  static double bodyFontSize(BuildContext context) => 16.0;
  static double smallFontSize(BuildContext context) => 14.0;
}

class AppTextStyles {
  static TextStyle title(BuildContext context) => TextStyle(
    fontSize: AppDimensions.titleFontSize(context),
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle heading(BuildContext context) => TextStyle(
    fontSize: AppDimensions.headingFontSize(context),
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle body(BuildContext context) => TextStyle(
    fontSize: AppDimensions.bodyFontSize(context),
    color: Colors.white,
  );

  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: AppDimensions.bodyFontSize(context),
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
} 