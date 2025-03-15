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
  static final Color shadowMedium = Colors.black.withOpacity(0.2);
  
  // Interactive Colors
  static final Color buttonHover = primaryBlue.withOpacity(0.8);
  static final Color buttonPressed = primaryBlue.withOpacity(0.6);
  static final Color buttonDisabled = Colors.grey.withOpacity(0.3);
  
  // Amber Theme Colors
  static final Color amberHover = accentAmber.withOpacity(0.8);
  static final Color amberPressed = accentAmber.withOpacity(0.6);
  static final Color amberShadow = accentAmber.withOpacity(0.2);
  static final Color amberOverlay = accentAmber.withOpacity(0.3);
}
