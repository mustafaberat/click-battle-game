import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:clickbattle/configs/config.dart';
import 'dart:async';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _gameoverHomeButtonFullScreenAd;
  bool _isInitialized = false;
  bool _isGameoverHomeButtonFullScreenAdLoading = false;

  void initialize() {
    if (_isInitialized) return;
    
    MobileAds.instance.initialize();
    _loadBannerAd();
    // Don't preload interstitial ad, it will be loaded on demand
    _isInitialized = true;
  }

  void _loadBannerAd() {
    _bannerAd?.dispose();
    
    _bannerAd = BannerAd(
      adUnitId: ClickBattleConfig.homePageBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {},
        onAdFailedToLoad: (_, __) {},
      ),
    )..load();
  }

  void loadGameoverHomeButtonFullScreenAd() {
    if (_isGameoverHomeButtonFullScreenAdLoading) return;
    
    _isGameoverHomeButtonFullScreenAdLoading = true;
    InterstitialAd.load(
      adUnitId: ClickBattleConfig.gameoverHomeButtonFullScreenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _gameoverHomeButtonFullScreenAd = ad;
          _isGameoverHomeButtonFullScreenAdLoading = false;
          
          // Set full screen content callback
          _gameoverHomeButtonFullScreenAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              // We don't reload automatically after dismissal, since it's on-demand
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              ad.dispose();
              // We don't reload automatically after failure, since it's on-demand
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isGameoverHomeButtonFullScreenAdLoading = false;
        },
      ),
    );
  }

  // Returns a Future that completes when ad is dismissed or after timeout
  Future<void> showGameoverHomeButtonFullScreenAd({int timeoutSeconds = 5}) async {
    // If ad is not loaded yet, try loading it first
    if (_gameoverHomeButtonFullScreenAd == null) {
      loadGameoverHomeButtonFullScreenAd();
      // Wait a bit to see if the ad loads quickly
      await Future.delayed(Duration(milliseconds: 1000));
      // If still not loaded, just return and don't show an ad
      if (_gameoverHomeButtonFullScreenAd == null) {
        return;
      }
    }

    final completer = Completer<void>();
    
    // Set up the callback to resolve the completer when ad is dismissed
    _gameoverHomeButtonFullScreenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _gameoverHomeButtonFullScreenAd = null;
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _gameoverHomeButtonFullScreenAd = null;
        if (!completer.isCompleted) completer.complete();
      },
      // The close button is automatically provided by the AdMob SDK,
      // we don't need to implement that part
    );

    // Show the ad
    await _gameoverHomeButtonFullScreenAd!.show();
    
    // Set a timeout to ensure we don't wait forever if something goes wrong
    Timer(Duration(seconds: timeoutSeconds), () {
      if (!completer.isCompleted) completer.complete();
    });

    return completer.future;
  }

  BannerAd? get bannerAd => _bannerAd;

  void dispose() {
    _bannerAd?.dispose();
    _gameoverHomeButtonFullScreenAd?.dispose();
    _bannerAd = null;
    _gameoverHomeButtonFullScreenAd = null;
    _isInitialized = false;
  }
} 