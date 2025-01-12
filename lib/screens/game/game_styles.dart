import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';

class GameStyles {
  static TextStyle difficultyText(BuildContext context) => AppTextStyles.heading(context);
  static TextStyle playerName(BuildContext context) => AppTextStyles.heading(context);
  static TextStyle scoreText(BuildContext context) => TextStyle(
    color: Colors.white,
    fontSize: AppDimensions.headingFontSize(context),
    fontWeight: FontWeight.bold,
  );
  static TextStyle cpsText(BuildContext context) => AppTextStyles.body(context).copyWith(
    color: Colors.white70,
    fontSize: AppDimensions.bodyFontSize(context) * 1.125,
  );

  // Timer styles
  static TextStyle timerText(BuildContext context) => AppTextStyles.heading(context).copyWith(
    fontSize: AppDimensions.headingFontSize(context) * 1.17,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static TextStyle countdownText(BuildContext context) => TextStyle(
    color: Colors.white,
    fontSize: AppDimensions.titleFontSize(context) * 1.5,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        color: Colors.blue,
        blurRadius: AppDimensions.borderRadius(context),
        offset: const Offset(0, 0),
      ),
    ],
  );

  // Winner styles
  static TextStyle titleText(BuildContext context) => AppTextStyles.title(context).copyWith(
    color: Colors.white,
    shadows: [
      Shadow(
        color: Colors.blue,
        blurRadius: AppDimensions.borderRadius(context) * 0.5,
        offset: const Offset(0, 0),
      ),
    ],
  );

  static TextStyle winnerText(BuildContext context) => AppTextStyles.heading(context).copyWith(
    fontSize: AppDimensions.headingFontSize(context) * 1.5,
    color: Colors.white,
    shadows: [
      Shadow(
        color: Colors.green[400]!,
        blurRadius: AppDimensions.borderRadius(context) * 0.5,
        offset: const Offset(0, 0),
      ),
    ],
  );

  static TextStyle gameOverText(BuildContext context) => AppTextStyles.title(context).copyWith(
    color: Colors.white,
    fontSize: AppDimensions.titleFontSize(context),
    shadows: [
      Shadow(
        color: Colors.red,
        blurRadius: AppDimensions.borderRadius(context) * 0.75,
        offset: const Offset(0, 0),
      ),
    ],
  );

  static ButtonStyle buttonStyle(BuildContext context) => ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.padding(context) * 2.5,
      vertical: AppDimensions.padding(context) * 1.25,
    ),
    textStyle: AppTextStyles.button(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
    ),
  );

  static BoxDecoration clickAreaDecoration(BuildContext context, Color color) => BoxDecoration(
    shape: BoxShape.circle,
    color: color.withOpacity(0.3),
    border: Border.all(
      color: Colors.white.withOpacity(0.5),
      width: AppDimensions.borderRadius(context) * 0.067,
    ),
    boxShadow: [
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: AppDimensions.borderRadius(context) * 0.33,
        spreadRadius: AppDimensions.borderRadius(context) * 0.167,
      ),
    ],
  );

  static double clickAreaSize(BuildContext context) => 
      MediaQuery.of(context).size.width * 0.5;
  static double iconSize(BuildContext context) => 
      MediaQuery.of(context).size.width * 0.16;
  static EdgeInsets padding(BuildContext context) => 
      EdgeInsets.all(AppDimensions.padding(context));
  static double spacing(BuildContext context) => 
      AppDimensions.spacing(context);
  static double dividerHeight(BuildContext context) => 
      AppDimensions.borderRadius(context) * 0.067;
} 