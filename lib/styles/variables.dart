import 'package:flutter/material.dart';
import 'package:clickbattle/constants/app_colors.dart';

// Common Properties used across different screens
class CommonProperties {
  // Colors
  static const Color accentColor = Color(0xFF2196F3);
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color white24Color = Color(0x3DFFFFFF);
  static const Color white70Color = Color(0xB3FFFFFF);
  static const Color white10Color = Color(0x1AFFFFFF);
  static const Color white38Color = Color(0x61FFFFFF);
  static const Color cardBackgroundColor = Color(0xFF2A2D3E);
  static const Color cardBorderColor = Color(0x1AFFFFFF);
  static const Color cardContentBackgroundColor = Color(0x0DFFFFFF);
  static const Color cardContentBorderColor = Color(0x1AFFFFFF);
  static const Color cardHeaderBorderColor = Color(0x1AFFFFFF);
  static const Color cardShadowColor = Color(0x40000000);
  static const Color accentAmberColor = Color(0xFFFFC107);
  static const Color black87Color = Color(0xDE000000);
  static const Color amberOverlayColor = Color(0x33FFC107);
  static const Color amberColor = Color(0xFFFFC107);
  static const Color blueColor = Color(0xFF2196F3);
  static const Color primaryBlue = Color(0xFF2196F3);

  // Common Layout Properties
  static const double cardPadding = 24.0;
  static const double cardBorderRadius = 24.0;
  static const double cardBorderWidth = 1.0;
  static const double cardShadowBlur = 10.0;
  static const double cardShadowSpread = 2.0;
  static const double cardHeaderPadding = 12.0;
  static const double cardHeaderBorderWidth = 1.0;
  static const double cardIconSize = 24.0;
  static const double cardIconSpacing = 12.0;
  static const double cardSpacing = 16.0;
  static const double cardContentPadding = 16.0;
  static const double cardContentBorderRadius = 16.0;
  static const double cardContentBorderWidth = 1.0;

  // Common Animation Durations
  static const Duration containerAnimationDuration = Duration(milliseconds: 200);
  static const Duration buttonAnimationDuration = Duration(milliseconds: 300);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 500);

  // Common Text Properties
  static const double defaultTextSize = 16.0;
  static const double headingTextSize = 20.0;
  static const double subheadingTextSize = 18.0;
  static const double smallTextSize = 14.0;
  static const double largeTextSize = 24.0;
  static const FontWeight defaultTextWeight = FontWeight.normal;
  static const FontWeight headingTextWeight = FontWeight.bold;
  static const FontWeight subheadingTextWeight = FontWeight.w600;
}

// Game Colors
class GameColors {
  static const Color player1Color = CommonProperties.accentColor;
  static const Color player2Color = Color(0xFFF44336); // Red
  static const Color backgroundColor = Color(0xFF1A1A1A);
  static const Color dividerColor = Color(0xFF2A2A2A);
  static const Color textColor = CommonProperties.textColor;
  static const Color shadowColor = Color(0xFF000000);
}

// Game Dimensions
class GameDimensions {
  static const double dividerHeight = 8.0;
  static const double dividerIndicatorHeight = 4.0;
  static const double dividerIndicatorWidth = 4.0;
  static const double dividerMarkHeight = 6.0;
  static const double dividerCenterMarkHeight = 12.0;
  static const double dividerMarkWidth = 2.0;
  static const double dividerMarkRadius = 1.0;
  static const double dividerShadowBlur = 6.0;
  static const double dividerShadowSpread = 2.0;
  static const double dividerShadowOpacity = 0.8;
  static const double dividerBackgroundOpacity = 0.3;
  static const double dividerGradientOpacity = 0.7;
}

// Game Animation Durations
class GameAnimationDurations {
  static const Duration colorTransitionDuration = Duration(milliseconds: 300);
  static const Duration dividerPulseDuration = Duration(milliseconds: 500);
  static const Duration clickAnimationDuration = Duration(milliseconds: 150);
  static const Duration particleAnimationDuration = Duration(milliseconds: 1000);
  static const Duration countdownDuration = Duration(seconds: 1);
}

// Game Animation Curves
class GameAnimationCurves {
  static const Curve colorTransitionCurve = Curves.easeInOut;
  static const Curve dividerPulseCurve = Curves.easeInOut;
  static const Curve clickAnimationCurve = Curves.easeInOutBack;
  static const Curve particleAnimationCurve = Curves.easeOutCirc;
}

// Game Particle Properties
class GameParticleProperties {
  static const int particleCount = 12;
  static const double particleVelocity = 2.0;
  static const double particleSize = 3.0;
  static const double particleSpiralFactor = 1.5;
  static const double particleTrailOpacity = 0.3;
  static const double particleConnectionDistance = 60.0;
  static const double particleLineWidth = 0.5;
}

// Game Score Properties
class GameScoreProperties {
  static const int defaultScoreLimit = 100;
  static const int defaultTimeLimit = 60;
  static const double maxScoreChange = 0.1;
  static const double significantLeadChange = 0.05;
}

// Game UI Properties
class GameUIProperties {
  static const double playerIconSizeRatio = 0.08;
  static const double playerIconScaleFactor = 0.3;
  static const double playerIconGlowOpacity = 0.15;
  static const double playerIconBorderOpacity = 0.3;
  static const double playerIconShadowOpacity = 0.2;
  static const double playerIconBackgroundGlowOpacity = 0.1;
  static const double playerIconIconOpacity = 0.9;
}

// Game Info Display Properties
class GameInfoDisplayProperties {
  static const double paddingHorizontalRatio = 0.6;
  static const double paddingVerticalRatio = 0.4;
  static const double iconSize = 22.0;
  static const double textOpacity = 0.95;
  static const double backgroundOpacity = 0.54;
  static const double borderOpacity = 0.6;
  static const double shadowOpacity = 0.4;
  static const double borderWidth = 1.5;
  static const double shadowBlur = 8.0;
  static const double shadowSpread = 1.0;
}

// Game Score Display Properties
class GameScoreDisplayProperties {
  static const double paddingHorizontalRatio = 0.8;
  static const double paddingVerticalRatio = 0.5;
  static const double textOpacity = 0.95;
  static const double backgroundOpacity = 0.54;
  static const double borderOpacity = 0.6;
  static const double shadowOpacity = 0.4;
  static const double borderWidth = 1.5;
  static const double shadowBlur = 8.0;
  static const double shadowSpread = 1.0;
  static const double bounceScale = 1.2;
  static const Duration bounceDuration = Duration(milliseconds: 300);
}

// Game Over Popup Properties
class GameOverPopupProperties {
  // Animation Durations
  static const Duration gameOverTextDuration = Duration(milliseconds: 800);
  static const Duration resultDisplayDuration = Duration(milliseconds: 600);
  static const Duration buttonsDisplayDuration = Duration(milliseconds: 800);
  static const Duration initialDelay = Duration(milliseconds: 500);
  static const Duration resultDelay = Duration(milliseconds: 1000);
  static const Duration scoreDisplayDelay = Duration(milliseconds: 1500);
  static const Duration buttonsDelay = Duration(milliseconds: 800);
  static const Duration adTimeout = Duration(seconds: 8);

  // Animation Values
  static const double gameOverTextInitialScale = 0.3;
  static const double gameOverTextFinalScale = 1.0;
  static const double resultInitialOpacity = 0.0;
  static const double resultFinalOpacity = 1.0;
  static const double buttonsInitialOpacity = 0.0;
  static const double buttonsFinalOpacity = 1.0;
  static const double buttonsInitialScale = 0.3;
  static const double buttonsFinalScale = 1.0;

  // Layout Properties
  static const double popupWidthRatio = 0.85;
  static const double popupMaxWidth = 400.0;
  static const double popupVerticalMargin = 24.0;
  static const double popupPadding = 24.0;
  static const double popupBorderRadius = 24.0;
  static const double popupBorderWidth = 2.0;
  static const double popupTopMargin = 20.0;
  static const double popupSpacing = 40.0;
  static const double winnerContainerMaxWidth = 280.0;
  static const double winnerContainerPadding = 24.0;
  static const double winnerContainerVerticalPadding = 12.0;
  static const double winnerContainerBorderRadius = 16.0;
  static const double winnerIconSize = 24.0;
  static const double winnerIconSpacing = 12.0;
  static const double scoreContainerMaxWidth = 280.0;
  static const double scoreContainerPadding = 20.0;
  static const double scoreDividerHeight = 80.0;
  static const double scoreDividerMargin = 20.0;
  static const double buttonHeight = 56.0;
  static const double buttonSpacing = 12.0;
  static const double buttonIconSize = 26.0;
  static const double buttonIconSpacing = 8.0;
  static const double buttonBorderRadius = 20.0;
  static const double buttonPadding = 24.0;

  // Font Sizes
  static const double gameOverFontSizeMin = 20.0;
  static const double gameOverFontSizeMax = 28.0;
  static const double gameOverFontSizeRatio = 0.07;
  static const double winnerFontSizeMin = 16.0;
  static const double winnerFontSizeMax = 20.0;
  static const double winnerFontSizeRatio = 0.05;
  static const double scoreFontSizeMin = 28.0;
  static const double scoreFontSizeMax = 40.0;
  static const double scoreFontSizeRatio = 0.1;
  static const double labelFontSizeMin = 12.0;
  static const double labelFontSizeMax = 16.0;
  static const double labelFontSizeRatio = 0.035;
  static const double buttonFontSize = 16.0;

  // Colors and Opacities
  static const Color popupBackgroundColor = CommonProperties.cardBackgroundColor;
  static const Color popupOverlayColor = Color(0xCC000000); // 0.8 opacity
  static const Color scoreDividerColor = CommonProperties.white24Color;
  static const Color scoreContainerColor = CommonProperties.cardContentBackgroundColor;
  static const Color buttonBackgroundColor = CommonProperties.white10Color;
  static const Color buttonDisabledBackgroundColor = CommonProperties.cardContentBackgroundColor;
  static const Color buttonDisabledForegroundColor = Color(0x4DFFFFFF); // 0.3 opacity
  static const Color textColor = CommonProperties.textColor;
  static const Color winnerTextColor = CommonProperties.textColor;
  static const Color scoreLabelColor = CommonProperties.white70Color;
  static const Color buttonTextColor = CommonProperties.textColor;
  static const double borderOpacity = 0.3;
  static const double shadowOpacity = 0.4;
  static const double textOpacity = 0.95;
  static const double iconOpacity = 0.95;
}

// Settings Screen Properties
class SettingsScreenProperties {
  // Animation Durations
  static const Duration containerAnimationDuration = CommonProperties.containerAnimationDuration;

  // Layout Properties
  static const double languageOptionWidthRatio = 0.25;
  static const double languageOptionPadding = 16.0;
  static const double languageOptionHorizontalPadding = 8.0;
  static const double languageOptionBorderRadius = 16.0;
  static const double languageOptionBorderWidth = 2.0;
  static const double languageOptionBorderWidthSelected = 2.0;
  static const double languageOptionBorderWidthUnselected = 1.0;
  static const double languageOptionSpacing = 8.0;
  static const double languageOptionIconSize = 40.0;
  static const double languageOptionTextSize = 14.0;
  static const double languageOptionTextSizeDropdown = 16.0;
  static const double languageOptionIconSizeDropdown = 22.0;
  static const double languageOptionIconSpacing = 12.0;
  static const double languageOptionDropdownPadding = 16.0;
  static const double languageOptionDropdownVerticalPadding = 4.0;
  static const double languageOptionDropdownBorderRadius = 16.0;
  static const double languageOptionDropdownBorderWidth = 1.0;

  // Card Properties
  static const double cardPadding = CommonProperties.cardPadding;
  static const double cardBorderRadius = CommonProperties.cardBorderRadius;
  static const double cardBorderWidth = CommonProperties.cardBorderWidth;
  static const double cardShadowBlur = CommonProperties.cardShadowBlur;
  static const double cardShadowSpread = CommonProperties.cardShadowSpread;
  static const double cardHeaderPadding = CommonProperties.cardHeaderPadding;
  static const double cardHeaderBorderWidth = CommonProperties.cardHeaderBorderWidth;
  static const double cardIconSize = CommonProperties.cardIconSize;
  static const double cardIconSpacing = CommonProperties.cardIconSpacing;
  static const double cardSpacing = CommonProperties.cardSpacing;
  static const double cardContentPadding = CommonProperties.cardContentPadding;
  static const double cardContentBorderRadius = CommonProperties.cardContentBorderRadius;
  static const double cardContentBorderWidth = CommonProperties.cardContentBorderWidth;

  // Audio Settings Properties
  static const double volumeIconSize = 20.0;
  static const double volumeSliderTrackHeight = 4.0;
  static const double volumeSliderThumbRadius = 8.0;
  static const double volumeSliderOverlayRadius = 16.0;
  static const double volumeSliderOverlayOpacity = 0.2;

  // Rate App Properties
  static const double rateButtonHeight = 46.0;
  static const double rateButtonPadding = 20.0;
  static const double rateButtonBorderRadius = 12.0;
  static const double rateButtonElevation = 2.0;
  static const double rateButtonIconSize = 20.0;
  static const double rateButtonIconSpacing = 8.0;
  static const double rateButtonTextSize = 15.0;
  static const double rateButtonTextWeight = 600.0;

  // About Section Properties
  static const double aboutListTilePadding = 0.0;
  static const double aboutDividerHeight = 1.0;
  static const double aboutTextSize = 16.0;
  static const double aboutTextWeight = 500.0;

  // Colors
  static const Color accentColor = CommonProperties.accentColor;
  static const Color textColor = CommonProperties.textColor;
  static const Color white24Color = CommonProperties.white24Color;
  static const Color white70Color = CommonProperties.white70Color;
  static const Color white10Color = CommonProperties.white10Color;
  static const Color white38Color = CommonProperties.white38Color;
  static const Color cardBackgroundColor = CommonProperties.cardBackgroundColor;
  static const Color cardBorderColor = CommonProperties.cardBorderColor;
  static const Color cardContentBackgroundColor = CommonProperties.cardContentBackgroundColor;
  static const Color cardContentBorderColor = CommonProperties.cardContentBorderColor;
  static const Color cardHeaderBorderColor = CommonProperties.cardHeaderBorderColor;
  static const Color cardShadowColor = CommonProperties.cardShadowColor;
  static const Color accentAmberColor = CommonProperties.accentAmberColor;
  static const Color black87Color = CommonProperties.black87Color;
  static const Color amberOverlayColor = CommonProperties.amberOverlayColor;
  static const Color amberColor = CommonProperties.amberColor;
  static const Color blueColor = CommonProperties.blueColor;
  static const Color primaryBlue = CommonProperties.primaryBlue;
} 