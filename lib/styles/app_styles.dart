import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2196F3);    // Main action color
  static const Color primaryRed = Color(0xFFEF5350);     // Competition/Multiplayer color
  static const Color primaryOrange = Color(0xFFFFA726);   // Time-related color
  
  // Background Colors
  static const Color background = Color(0xFF1A1A1A);     // Main background
  static const Color cardBackground = Color(0xFF2A2A2A);  // Card/Surface background
  static const Color overlayBackground = Color(0xFF212121); // Modal/Overlay background
  
  // Accent Colors
  static const Color accentGreen = Color(0xFF66BB6A);    // Success/Progress color
  static const Color accentAmber = Color(0xFFFFCA28);    // Warning/Star color
  static const Color accent = primaryBlue;               // Legacy support
  static const Color primary = background;               // Legacy support
  
  // Game Colors
  static const Color player1 = primaryBlue;
  static const Color player2 = primaryRed;
  static const Color timeMode = primaryOrange;
  static const Color scoreMode = accentGreen;
  
  // State Colors
  static Color hoveredBlue = primaryBlue.withOpacity(0.8);
  static Color hoveredRed = primaryRed.withOpacity(0.8);
  static Color hoveredOrange = primaryOrange.withOpacity(0.8);
  static Color hoveredGreen = accentGreen.withOpacity(0.8);
  
  // Difficulty Colors
  static const Color hardMode = primaryRed;
  
  // Utility Colors
  static const Color white = Colors.white;
  static final Color white70 = Colors.white.withOpacity(0.7);
  static final Color white38 = Colors.white.withOpacity(0.38);
  static final Color white24 = Colors.white.withOpacity(0.24);
  static final Color white10 = Colors.white.withOpacity(0.1);
  static final Color white05 = Colors.white.withOpacity(0.05);
  
  // Shadow Colors
  static final Color shadowDark = Colors.black.withOpacity(0.3);
  static final Color shadowLight = Colors.white.withOpacity(0.1);
}

class AppDimensions {
  // Border Radius
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusMedium = 15.0;
  static const double borderRadiusSmall = 10.0;

  // Padding & Margins
  static const double paddingLarge = 24.0;
  static const double paddingMedium = 16.0;
  static const double paddingSmall = 12.0;
  static const double paddingXSmall = 8.0;

  // Icon Sizes
  static const double iconSizeLarge = 32.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeSmall = 20.0;

  // Button Heights
  static const double buttonHeightLarge = 70.0;
  static const double buttonHeightMedium = 56.0;
  static const double buttonHeightSmall = 40.0;

  // Font Sizes
  static const double fontSizeLarge = 28.0;
  static const double fontSizeMedium = 20.0;
  static const double fontSizeSmall = 16.0;
  static const double fontSizeXSmall = 14.0;

  // Card Dimensions
  static const double cardElevation = 8.0;
  static const double cardBorderWidth = 2.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 800);

  // Legacy support (to be replaced)
  static double padding(BuildContext context) => paddingMedium;
  static double spacing(BuildContext context) => paddingMedium;
  static double buttonHeight(BuildContext context) => buttonHeightMedium;
  static double borderRadius(BuildContext context) => borderRadiusMedium;
  static double bodyFontSize(BuildContext context) => fontSizeSmall;
  static double buttonFontSize(BuildContext context) => fontSizeMedium;
  static double titleFontSize(BuildContext context) => fontSizeLarge;
  static double headingFontSize(BuildContext context) => fontSizeLarge;
  static double subtitleFontSize(BuildContext context) => fontSizeMedium;
}

class AppTextStyles {
  static TextStyle heading(BuildContext context) => TextStyle(
    color: AppColors.white,
    fontSize: AppDimensions.fontSizeLarge,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static TextStyle title(BuildContext context) => TextStyle(
    color: AppColors.white,
    fontSize: AppDimensions.fontSizeMedium,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle subtitle(BuildContext context) => TextStyle(
    color: AppColors.white70,
    fontSize: AppDimensions.fontSizeMedium,
    fontWeight: FontWeight.w500,
  );

  static TextStyle body(BuildContext context) => TextStyle(
    color: AppColors.white70,
    fontSize: AppDimensions.fontSizeSmall,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static TextStyle button(BuildContext context) => TextStyle(
    color: AppColors.white,
    fontSize: AppDimensions.fontSizeMedium,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  static TextStyle caption(BuildContext context) => TextStyle(
    color: AppColors.white70,
    fontSize: AppDimensions.fontSizeXSmall,
    fontWeight: FontWeight.w500,
  );

  static TextStyle label(BuildContext context) => TextStyle(
    color: AppColors.white70,
    fontSize: AppDimensions.fontSizeSmall,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
} 