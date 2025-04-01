import 'package:flutter/material.dart';

class ClickBattleConfig {
  // GENERAL CONFIGS
  static String appName = 'Click Battle';
  static Color player1Color = Colors.redAccent.withOpacity(0.7);
  static Color player2Color = Colors.blueAccent.withOpacity(0.7);
  static Color borderColor = Colors.black;
  static IconData fingerIcon = Icons.touch_app;
  static int timerInitTime = 4;
  static int maxClickCount = 30;

  // SCORE COMPONENT CONFIGS
  static const double scoreDisplayFontSize = 24;
  static double appNameFontSize = 24;
  static double timerFontSize = 24;
  static double timerIconSize = 30;

  // AD CONFIGS
  static const String adMobAppId = 'ca-app-pub-1508520223269936~7354217156';
  // static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test banner ad unit ID
  static const String homePageBannerAdUnitId = 'ca-app-pub-1508520223269936/8664263543'; // My banner ad unit ID
  static const String gameoverHomeButtonFullScreenAdUnitId = 'ca-app-pub-1508520223269936/1038850543'; // HomePage full screen ad unit ID
}