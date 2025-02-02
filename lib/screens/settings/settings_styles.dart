import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';

class SettingsStyles {
  // Container Decorations
  static BoxDecoration get itemContainer => BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
    border: Border.all(
      color: AppColors.white24,
      width: 1,
    ),
  );

  static BoxDecoration selectedItemContainer(Color color) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
    border: Border.all(
      color: Colors.transparent,
      width: 1,
    ),
  );

  // Text Styles
  static TextStyle get titleStyle => TextStyle(
    color: AppColors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle get subtitleStyle => TextStyle(
    color: AppColors.white70,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.1,
  );

  static TextStyle get itemTextStyle => TextStyle(
    color: AppColors.white,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.1,
  );

  // Icon Styles
  static double get mainIconSize => 28.0;
  static double get secondaryIconSize => 24.0;
  static double get smallIconSize => 20.0;

  // Colors
  static Color get activeColor => AppColors.primaryBlue;
  static Color get inactiveColor => AppColors.white10;
  static Color get borderColor => AppColors.white24;

  // Toggle Colors
  static Color get toggleActiveBackground => Colors.white;
  static Color get toggleInactiveBackground => Colors.black45;
  static Color get toggleActiveThumbColor => AppColors.primaryBlue;
  static Color get toggleInactiveThumbColor => Colors.white70;
  static Color get toggleActiveBorderColor => Colors.transparent;
  static Color get toggleInactiveBorderColor => AppColors.white24;

  // Spacing and Padding
  static const EdgeInsets sectionPadding = EdgeInsets.all(16.0);
  static const EdgeInsets itemPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
  static const EdgeInsets itemMargin = EdgeInsets.only(bottom: 12.0);
  
  // Dimensions
  static const double itemHeight = 80.0;
  static const double smallItemHeight = 52.0;
  static const double iconSpacing = 12.0;
  static const double dividerHeight = 16.0;
  static const double dividerWidth = 1.0;

  // Button Styles
  static BoxDecoration get buttonDecoration => BoxDecoration(
    color: AppColors.primaryBlue,
    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryBlue.withOpacity(0.3),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get hoveredButtonDecoration => buttonDecoration.copyWith(
    color: AppColors.hoveredBlue,
  );

  static TextStyle get buttonTextStyle => TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
} 