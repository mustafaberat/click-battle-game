import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';

class HomeStyles {
  static BoxDecoration titleContainer(BuildContext context) => BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
    boxShadow: [
      BoxShadow(
        color: Colors.white.withOpacity(0.1),
        blurRadius: AppDimensions.borderRadius(context),
        spreadRadius: AppDimensions.padding(context),
      ),
    ],
  );

  static TextStyle titleText(BuildContext context) => AppTextStyles.title(context).copyWith(
    shadows: [
      Shadow(
        color: Colors.blue,
        blurRadius: AppDimensions.borderRadius(context),
        offset: const Offset(0, 0),
      ),
    ],
  );

  static BoxDecoration buttonDecoration(BuildContext context, Color color) => BoxDecoration(
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
        blurRadius: AppDimensions.padding(context),
        spreadRadius: AppDimensions.padding(context) * 0.2,
      ),
    ],
  );

  static EdgeInsets titlePadding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: AppDimensions.padding(context) * 1.25,
    vertical: AppDimensions.padding(context) * 0.625,
  );

  static double backgroundCircleSize(BuildContext context) => 
      MediaQuery.of(context).size.width * 0.05;
  static double backgroundLineWidth(BuildContext context) => 
      MediaQuery.of(context).size.width * 0.005;
  static const double backgroundOpacity = 0.1;
} 