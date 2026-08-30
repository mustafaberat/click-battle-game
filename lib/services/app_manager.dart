import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:clickbattle/services/audio_service.dart';
import 'package:clickbattle/services/ad_service.dart';
import 'package:clickbattle/services/settings_service.dart';
import 'package:clickbattle/services/localization_service.dart';
import 'package:clickbattle/constants/app_colors.dart';
import 'package:clickbattle/constants/app_strings.dart';
import 'package:clickbattle/configs/config.dart';

/// AppManager is a centralized class that manages access to all important services and constants.
/// It organizes variables by their usage to make them easier to access from anywhere in the app.
class AppManager {
  // Singleton instance
  static final AppManager _instance = AppManager._internal();
  factory AppManager() => _instance;
  AppManager._internal();

  // Services
  late SettingsService settingsService;
  late AudioService audioService;
  late AdService adService;
  late LocalizationService localizationService;
  late SharedPreferences prefs;

  bool _isInitialized = false;

  // Initialize all services
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Initialize SharedPreferences
    prefs = await SharedPreferences.getInstance();
    
    // Initialize Services
    settingsService = SettingsService(prefs);
    audioService = AudioService();
    adService = AdService();
    localizationService = LocalizationService();
    
    // Initialize services that require async initialization
    await audioService.initialize();
    adService.initialize();
    
    _isInitialized = true;
  }

  // ==================== COMMON VARIABLES ====================
  // Variables used across multiple screens/components

  // App Identity
  String get appName => ClickBattleConfig.appName;

  // ==================== AUDIO RELATED VARIABLES ====================
  
  // Background Music
  bool get isMusicEnabled => settingsService.backgroundMusicEnabled;
  Future<void> setMusicEnabled(bool value) => settingsService.setBackgroundMusicEnabled(value);
  
  // Sound Effects
  bool get isSoundEnabled => settingsService.touchSoundEnabled;
  Future<void> setSoundEnabled(bool value) => settingsService.setTouchSoundEnabled(value);
  
  // Volume
  double get volume => settingsService.volume;
  Future<void> setVolume(double value) => settingsService.setVolume(value);
  
  void startMusic() => audioService.startMusic();
  Future<void> toggleMusic(bool enabled) => audioService.toggleMusic(enabled);

  // ==================== ADVERTISEMENT RELATED VARIABLES ====================
  
  BannerAd? get bannerAd => adService.bannerAd;
  
  void loadGameoverAd() => adService.loadGameoverHomeButtonFullScreenAd();
  
  Future<void> showGameoverAd({int timeoutSeconds = 5}) => 
      adService.showGameoverHomeButtonFullScreenAd(timeoutSeconds: timeoutSeconds);
      
  void reloadBannerAd() {
    adService.dispose();
    adService.initialize();
  }

  // ==================== LOCALIZATION RELATED VARIABLES ====================
  
  String get currentLanguage => localizationService.currentLanguage;
  Future<void> setLanguage(String languageCode) => localizationService.setLanguage(languageCode);
  String getText(String key) => localizationService.getText(key);
  Map<String, String> get supportedLanguages => LocalizationService.supportedLanguages;

  // ==================== COLOR RELATED VARIABLES ====================
  
  // Primary Colors
  Color get primaryBlue => AppColors.primaryBlue;
  Color get primaryRed => AppColors.primaryRed;
  Color get primaryOrange => AppColors.primaryOrange;
  
  // Game Colors
  Color get player1Color => AppColors.player1;
  Color get player2Color => AppColors.player2;
  Color get timeModeColor => AppColors.timeMode;
  Color get scoreModeColor => AppColors.scoreMode;
  
  // Background Colors
  Color get backgroundColor => AppColors.background;
  Color get cardBackgroundColor => AppColors.cardBackground;
  Color get overlayBackgroundColor => AppColors.overlayBackground;
  
  // State Colors
  Color get hoveredBlue => AppColors.hoveredBlue;
  Color get hoveredRed => AppColors.hoveredRed;
  Color get hoveredOrange => AppColors.hoveredOrange;
  Color get hoveredGreen => AppColors.hoveredGreen;
  
  // Utility Colors
  Color get white => AppColors.white;
  Color get white70 => AppColors.white70;
  Color get white38 => AppColors.white38;
  Color get white24 => AppColors.white24;
  Color get white10 => AppColors.white10;
  Color get white05 => AppColors.white05;
  Color get shadowDark => AppColors.shadowDark;
  
  // Button Colors
  Color get buttonHover => AppColors.buttonHover;
  Color get buttonPressed => AppColors.buttonPressed;
  Color get buttonDisabled => AppColors.buttonDisabled;

  // ==================== GAME CONFIGURATION VARIABLES ====================
  
  // Player Colors from Config
  Color get configPlayer1Color => ClickBattleConfig.player1Color;
  Color get configPlayer2Color => ClickBattleConfig.player2Color;
  Color get configBorderColor => ClickBattleConfig.borderColor;
  
  // Game Settings
  IconData get fingerIcon => ClickBattleConfig.fingerIcon;
  int get timerInitTime => ClickBattleConfig.timerInitTime;
  int get maxClickCount => ClickBattleConfig.maxClickCount;
  
  // UI Settings
  double get scoreDisplayFontSize => ClickBattleConfig.scoreDisplayFontSize;
  double get appNameFontSize => ClickBattleConfig.appNameFontSize;
  double get timerFontSize => ClickBattleConfig.timerFontSize;
  double get timerIconSize => ClickBattleConfig.timerIconSize;
  
  // Ad IDs
  String get adMobAppId => ClickBattleConfig.adMobAppId;
  String get homePageBannerAdUnitId => ClickBattleConfig.homePageBannerAdUnitId;
  String get gameoverHomeButtonFullScreenAdUnitId => ClickBattleConfig.gameoverHomeButtonFullScreenAdUnitId;

  // ==================== RESOURCE CLEANUP ====================
  
  void dispose() {
    audioService.dispose();
    adService.dispose();
  }
} 