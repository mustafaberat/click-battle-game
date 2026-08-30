import 'package:flutter/material.dart';
import 'package:clickbattle/constants/app_colors.dart';

class AppDimensions {
  // Border Radius
  static const double borderRadiusLarge = 24.0;
  static const double borderRadiusMedium = 15.0;
  static const double borderRadiusSmall = 16.0;

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
  static const double fontSizeXXSmall = 12.0;

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
  static double borderRadius(BuildContext context) => borderRadiusLarge;
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