import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/constants/app_colors.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'package:clickbattle/components/arcade_chrome.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  BannerAd? _bannerAd;
  bool _showBanner = false;
  Timer? _bannerTimer;
  late AppManager _app;
  late AnimationController _pulse;
  late AnimationController _hands;
  late AnimationController _glint;
  late Animation<double> _handsAnim;
  late Animation<double> _glintAnim;

  @override
  void initState() {
    super.initState();
    _app = Provider.of<AppManager>(context, listen: false);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _hands = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _handsAnim = CurvedAnimation(parent: _hands, curve: Curves.elasticOut);
    _glint = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _glintAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _glint,
        curve: const Interval(0.78, 0.92, curve: Curves.easeInOut),
      ),
    );
    _hands.forward();
    // Web / failed ads must not leave a black footer strip
    if (!kIsWeb) {
      _bannerAd = _app.bannerAd;
      // Only show after a short settle; AdWidget empty = black bar otherwise
      _bannerTimer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted || _bannerAd == null) return;
        setState(() => _showBanner = true);
      });
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _hands.dispose();
    _glint.dispose();
    _bannerTimer?.cancel();
    // Don't dispose shared banner owned by AdService
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _app = Provider.of<AppManager>(context);

    return Scaffold(
      backgroundColor: AppColors.comicNavy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ComicHeroBackdrop(
            handT: _handsAnim,
            glintT: _glintAnim,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Transform.rotate(
                    angle: -0.06,
                    child: Column(
                      children: [
                        Text(
                          'CLICK',
                          style: ArcadeChrome.display(
                            size: 58,
                            color: ArcadeChrome.yellow,
                            outlineWidth: 3.2,
                          ),
                        ),
                        Text(
                          'BATTLE',
                          style: ArcadeChrome.display(
                            size: 58,
                            color: ArcadeChrome.yellow,
                            outlineWidth: 3.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _app.getText('welcomeMessage'),
                    textAlign: TextAlign.center,
                    style: ArcadeChrome.ui(
                      size: 13,
                      color: Colors.white.withOpacity(0.85),
                      weight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const Spacer(flex: 3),
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.04).animate(
                      CurvedAnimation(
                        parent: _pulse,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: ComicButton(
                      height: 64,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/mode_selection'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 28,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _app.getText('tapToStart').toUpperCase(),
                            style: ArcadeChrome.ui(
                              size: 22,
                              color: Colors.black,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ComicButton(
                          color: ArcadeChrome.red,
                          foregroundColor: Colors.white,
                          height: 52,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/settings'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.settings, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                _app.getText('settings').toUpperCase(),
                                style: ArcadeChrome.ui(
                                  size: 12,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ComicButton(
                          color: ArcadeChrome.blue,
                          foregroundColor: Colors.white,
                          height: 52,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/how_to_play'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.help_outline, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                _app.getText('howToPlay').toUpperCase(),
                                style: ArcadeChrome.ui(
                                  size: 12,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _app.getText('arcadeTagline'),
                    style: ArcadeChrome.ui(
                      size: 12,
                      color: ArcadeChrome.yellow,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: _showBanner ? 58 : 16),
                ],
              ),
            ),
          ),
          if (_showBanner && _bannerAd != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
