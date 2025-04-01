import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:clickbattle/configs/config.dart';
import 'dart:async';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInitialized = false;
  bool _isInterstitialAdLoading = false;

  void initialize() {
    if (_isInitialized) return;
    
    MobileAds.instance.initialize();
    _loadBannerAd();
    _loadInterstitialAd();
    _isInitialized = true;
  }

  void _loadBannerAd() {
    _bannerAd?.dispose();
    
    _bannerAd = BannerAd(
      adUnitId: ClickBattleConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {},
        onAdFailedToLoad: (_, __) {},
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    if (_isInterstitialAdLoading) return;
    
    _isInterstitialAdLoading = true;
    InterstitialAd.load(
      adUnitId: ClickBattleConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
          
          // Set full screen content callback
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              _loadInterstitialAd(); // Reload for next time
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              ad.dispose();
              _loadInterstitialAd(); // Reload for next time
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isInterstitialAdLoading = false;
        },
      ),
    );
  }

  // Returns a Future that completes when ad is dismissed or after timeout
  Future<void> showInterstitialAd({int timeoutSeconds = 5}) async {
    if (_interstitialAd == null) {
      // If no ad is loaded, try to load one
      _loadInterstitialAd();
      return;
    }

    final completer = Completer<void>();
    
    // Set up the callback to resolve the completer when ad is dismissed
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _loadInterstitialAd(); // Reload for next time
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _loadInterstitialAd(); // Reload for next time
        if (!completer.isCompleted) completer.complete();
      },
    );

    // Show the ad
    await _interstitialAd!.show();
    
    // Set a timeout to ensure we don't wait forever if something goes wrong
    Timer(Duration(seconds: timeoutSeconds), () {
      if (!completer.isCompleted) completer.complete();
    });

    return completer.future;
  }

  BannerAd? get bannerAd => _bannerAd;

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _isInitialized = false;
  }
} 