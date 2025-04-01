import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  late AppManager _appManager;

  @override
  void initState() {
    super.initState();
    _appManager = Provider.of<AppManager>(context, listen: false);
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = _appManager.bannerAd;
    if (_bannerAd != null) {
      setState(() => _isAdLoaded = true);
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appManager = Provider.of<AppManager>(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF001554),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          child: Column(
            children: [
              const Spacer(),
              // Logo and Title section
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Logo
                  Container(
                    width: size.height * 0.3,
                    height: size.height * 0.3,
                    constraints: BoxConstraints(
                      maxWidth: 300,
                      maxHeight: 300,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'lib/assets/app-icon.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing(context)),
                  // App Title
                  Text(
                    _appManager.getText('clickBattle'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading(context).copyWith(
                      fontSize: _appManager.appNameFontSize * 1.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      height: 1,
                      color: _appManager.white,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing(context) * 0.5),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall * 0.5,
                    ),
                    child: Text(
                      _appManager.getText('welcomeMessage'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subtitle(context).copyWith(
                        color: _appManager.white70,
                        fontSize: AppDimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Action Buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play Button
                  Container(
                    height: AppDimensions.buttonHeightLarge,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _appManager.primaryBlue,
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: _appManager.shadowDark,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/mode_selection'),
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sports_esports_rounded,
                                color: _appManager.white,
                                size: AppDimensions.iconSizeLarge,
                              ),
                              SizedBox(width: AppDimensions.spacing(context)),
                              Text(
                                _appManager.getText('tapToStart').toUpperCase(),
                                style: AppTextStyles.button(context).copyWith(
                                  fontSize: AppDimensions.fontSizeMedium,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: _appManager.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing(context) * 1.25),
                  // Settings Button
                  Container(
                    height: AppDimensions.buttonHeightMedium,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _appManager.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/settings'),
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.settings_rounded,
                                color: _appManager.white70,
                                size: AppDimensions.iconSizeMedium,
                              ),
                              SizedBox(width: AppDimensions.spacing(context)),
                              Text(
                                _appManager.getText('settings').toUpperCase(),
                                style: AppTextStyles.button(context).copyWith(
                                  color: _appManager.white70,
                                  letterSpacing: 2,
                                  fontSize: AppDimensions.fontSizeSmall,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Banner Ad
              if (_isAdLoaded && _bannerAd != null)
                Container(
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 