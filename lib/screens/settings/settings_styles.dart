import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';

class SettingsStyles {
  static BoxDecoration get itemContainer => BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(15),
  );

  static TextStyle get itemText => AppTextStyles.body;

  static Color get activeColor => AppColors.accent;
  static Color get inactiveColor => Colors.white.withOpacity(0.3);

  static const EdgeInsets listPadding = EdgeInsets.all(16.0);
  static const EdgeInsets itemMargin = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets itemPadding = EdgeInsets.all(16);
  static const double iconSize = 24;
  static const double spacing = 16;
} 