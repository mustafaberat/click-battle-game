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
    fontSize: AppDimensions.buttonFontSize(context),
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
  static double buttonHeight(BuildContext context) => MediaQuery.of(context).size.height * 0.08;
  static double buttonWidth(BuildContext context) => MediaQuery.of(context).size.width * 0.6;
  static double borderRadius(BuildContext context) => MediaQuery.of(context).size.width * 0.08;
  static double padding(BuildContext context) => MediaQuery.of(context).size.width * 0.04;
  static double spacing(BuildContext context) => MediaQuery.of(context).size.height * 0.03;
  
  static double titleFontSize(BuildContext context) => MediaQuery.of(context).size.width * 0.12;
  static double headingFontSize(BuildContext context) => MediaQuery.of(context).size.width * 0.06;
  static double bodyFontSize(BuildContext context) => MediaQuery.of(context).size.width * 0.04;
  static double buttonFontSize(BuildContext context) => MediaQuery.of(context).size.width * 0.05;
} 