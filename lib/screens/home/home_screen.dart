import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/analytics/analytics.dart';
import 'package:clickbattle/constants/app_colors.dart';
import 'package:clickbattle/constants/app_images.dart';
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

  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    for (final path in AppImages.precache) {
      precacheImage(AssetImage(path), context, onError: (_, __) {});
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
                  Expanded(
                    child: _HomeHero(
                      entrance: _handsAnim,
                      tagline: _app.getText('welcomeMessage'),
                    ),
                  ),
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.04).animate(
                      CurvedAnimation(
                        parent: _pulse,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: ComicButton(
                      height: 64,
                      onPressed: () {
                        Navigator.pushNamed(context, '/mode_selection');
                      },
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
                          onPressed: () {
                            AnalyticsService.instance.logSettingsOpen(
                              source: AnalyticsValues.sourceHome,
                            );
                            Navigator.pushNamed(context, '/settings');
                          },
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
                          onPressed: () {
                            AnalyticsService.instance.logHowToPlayOpen(
                              source: AnalyticsValues.sourceHome,
                            );
                            Navigator.pushNamed(context, '/how_to_play');
                          },
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

/// Raster hero art: fills from the very top of the screen (behind the status
/// bar) down to the vertical centre of the START button, edge to edge.
class _HomeHero extends StatelessWidget {
  final Animation<double> entrance;
  final String tagline;

  const _HomeHero({required this.entrance, required this.tagline});

  static const double _hPad = 22;
  static const double _bottomBleed = 64 / 2 + 8;
  static const double _srcW = 1080;
  static const double _srcH = 1440;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth + _hPad * 2;
        final h = c.maxHeight + topInset + _bottomBleed;
        final scale = math.max(w / _srcW, h / _srcH);
        final imgH = _srcH * scale;
        final imgTop = (h - imgH) / 2;
        // Box of the scaled hero (same as the Positioned below).
        final pillY = imgTop + 0.705 * imgH;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -_hPad,
              right: -_hPad,
              top: -topInset,
              bottom: -_bottomBleed,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(entrance),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Semantics(
                        label: 'CLICK BATTLE',
                        image: true,
                        child: Image.asset(
                          AppImages.homeHero,
                          key: const Key('homeHeroTitle'),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          filterQuality: FilterQuality.medium,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                    Positioned(
                      left: _hPad + 24,
                      right: _hPad + 24,
                      top: pillY,
                      child: FractionalTranslation(
                        translation: const Offset(0, -0.5),
                        child: Center(
                          child: _TaglinePill(text: tagline),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Small red comic caption pill under the BATTLE plate: white text, black
/// border, hard offset shadow, tilted ~5° (rising to the right).
class _TaglinePill extends StatelessWidget {
  final String text;

  const _TaglinePill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -5 * math.pi / 180,
      child: Container(
        key: const Key('homeTaglinePill'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: ArcadeChrome.red,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: ArcadeChrome.ink, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: ArcadeChrome.ink,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ArcadeChrome.ui(
                size: 15,
                weight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ).copyWith(height: 1.15),
            ),
          ),
        ),
      ),
    );
  }
}
