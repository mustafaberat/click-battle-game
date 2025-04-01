# AppManager - Centralized Service and Configuration Access

This README file explains how to use the AppManager class, which provides centralized access to all services and configuration variables in the Click Battle application.

## Overview

AppManager is a singleton class that organizes all services and configuration variables into logical groups, making it easier to access them from anywhere in the application. The class uses getter methods to provide access to frequently used values, which improves code readability and maintainability.

## How to Access the AppManager

The AppManager is provided to the widget tree through Provider, so you can access it in your widgets like this:

```dart
final appManager = Provider.of<AppManager>(context, listen: false);
```

Or if you need to listen to changes:

```dart
final appManager = Provider.of<AppManager>(context);
```

## Available Services and Variables

The AppManager organizes variables into logical groups:

### Common Variables
- `appName` - The application name

### Audio Related Variables
- `isMusicEnabled` - Whether background music is enabled
- `isSoundEnabled` - Whether touch sound effects are enabled
- `volume` - The audio volume
- `setMusicEnabled(bool)` - Set the background music enabled state
- `setSoundEnabled(bool)` - Set the sound effects enabled state
- `setVolume(double)` - Set the audio volume
- `startMusic()` - Start playing background music
- `toggleMusic(bool)` - Toggle background music on/off

### Advertisement Related Variables
- `bannerAd` - Access the banner ad instance
- `loadGameoverAd()` - Load the gameover interstitial ad
- `showGameoverAd()` - Show the gameover interstitial ad

### Localization Related Variables
- `currentLanguage` - The current language code
- `setLanguage(String)` - Set the application language
- `getText(String)` - Get translated text for a given key
- `supportedLanguages` - Map of supported language codes and names

### Color Related Variables
- Primary Colors: `primaryBlue`, `primaryRed`, `primaryOrange`
- Game Colors: `player1Color`, `player2Color`, `timeModeColor`, `scoreModeColor`, `hardModeColor`
- Background Colors: `backgroundColor`, `cardBackgroundColor`, `overlayBackgroundColor`
- State Colors: `hoveredBlue`, `hoveredRed`, `hoveredOrange`, `hoveredGreen`
- Utility Colors: `white`, `white70`, `white38`, `shadowDark`
- Button Colors: `buttonHover`, `buttonPressed`, `buttonDisabled`

### Game Configuration Variables
- Player Colors: `configPlayer1Color`, `configPlayer2Color`, `configBorderColor`
- Game Settings: `fingerIcon`, `timerInitTime`, `maxClickCount`
- UI Settings: `scoreDisplayFontSize`, `appNameFontSize`, `timerFontSize`, `timerIconSize`
- Ad IDs: `adMobAppId`, `homePageBannerAdUnitId`, `gameoverHomeButtonFullScreenAdUnitId`

## Example Usage

```dart
// Initialize AppManager in main.dart (already done)
final appManager = AppManager();
await appManager.initialize();

// In a widget:
ElevatedButton(
  onPressed: () {
    final appManager = Provider.of<AppManager>(context, listen: false);
    appManager.toggleMusic(!appManager.isMusicEnabled);
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: appManager.primaryBlue,
  ),
  child: Text(
    appManager.getText('music_toggle'),
    style: TextStyle(
      color: appManager.white,
      fontSize: 16,
    ),
  ),
)
```

## Benefits

- **Centralized Configuration:** All configuration variables are accessed through a single class
- **Organized Access:** Variables are grouped by function
- **Simplified Imports:** No need to import multiple service classes in each file
- **Consistent Naming:** Variable names are consistent throughout the application
- **Improved Maintainability:** Changes to services require updates in only one place 