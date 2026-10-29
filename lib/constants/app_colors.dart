import 'package:flutter/material.dart';

/// Arcade Strip Comic palette — Click Battle restyle.
class AppColors {
  // Comic tokens
  static const Color comicNavy = Color(0xFF0D1B3E);
  static const Color comicPanel = Color(0xFF16264F);
  static const Color inkBlack = Color(0xFF111111);
  static const Color comicYellow = Color(0xFFFFD400);
  static const Color comicYellowDark = Color(0xFFE6C200);
  static const Color comicRed = Color(0xFFFF3B4E);
  static const Color comicBlue = Color(0xFF18B4FF);

  // Core neon (aliased to comic so existing call sites match store art)
  static const Color neonBlue = comicBlue;
  static const Color neonRed = comicRed;
  static const Color pureBlack = Color(0xFF000000);
  static const Color surface = comicNavy;
  static const Color surfaceElevated = comicPanel;

  // Primary / legacy aliases
  static const Color primaryBlue = neonBlue;
  static const Color primaryRed = neonRed;
  static const Color primaryOrange = Color(0xFFFF9F1C);

  // Backgrounds
  static const Color background = comicNavy;
  static const Color cardBackground = comicPanel;
  static const Color overlayBackground = Color(0xFF08122C);

  // Accents
  static const Color accentGreen = Color(0xFF39FF14);
  static const Color accentAmber = Color(0xFFFFCA28);
  /// Arcade Strip CTA yellow
  static const Color arcadeYellow = comicYellow;
  static const Color arcadeYellowDark = comicYellowDark;
  static const Color accent = primaryBlue;
  static const Color primary = background;

  // Game
  static const Color player1 = neonBlue;
  static const Color player2 = neonRed;
  static const Color timeMode = primaryOrange;
  static const Color scoreMode = accentGreen;

  // States
  static Color hoveredBlue = primaryBlue.withOpacity(0.8);
  static Color hoveredRed = primaryRed.withOpacity(0.8);
  static Color hoveredOrange = primaryOrange.withOpacity(0.8);
  static Color hoveredGreen = accentGreen.withOpacity(0.8);

  static const Color hardMode = primaryRed;

  // Utility
  static const Color white = Colors.white;
  static final Color white70 = Colors.white.withOpacity(0.7);
  static final Color white38 = Colors.white.withOpacity(0.38);
  static final Color white24 = Colors.white.withOpacity(0.24);
  static final Color white10 = Colors.white.withOpacity(0.1);
  static final Color white05 = Colors.white.withOpacity(0.05);

  static final Color shadowDark = Colors.black.withOpacity(0.5);
  static final Color shadowLight = Colors.white.withOpacity(0.08);
  static final Color shadowMedium = Colors.black.withOpacity(0.35);

  static final Color buttonHover = primaryBlue.withOpacity(0.85);
  static final Color buttonPressed = primaryBlue.withOpacity(0.65);
  static final Color buttonDisabled = Colors.grey.withOpacity(0.3);

  static final Color amberHover = accentAmber.withOpacity(0.8);
  static final Color amberPressed = accentAmber.withOpacity(0.6);
  static final Color amberShadow = accentAmber.withOpacity(0.2);
  static final Color amberOverlay = accentAmber.withOpacity(0.3);
}
