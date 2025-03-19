import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:clickbattle/configs/config.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    
    MobileAds.instance.initialize();
    _loadBannerAd();
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

  BannerAd? get bannerAd => _bannerAd;

  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isInitialized = false;
  }
} 