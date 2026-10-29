import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/analytics/analytics.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'package:clickbattle/components/arcade_chrome.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  bool _showBanner = false;
  late AppManager _app;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _app = Provider.of<AppManager>(context, listen: false);
    AnalyticsService.instance.logHomeReached();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    // Web / failed ads must not leave a black footer strip
    if (!kIsWeb) {
      _bannerAd = _app.bannerAd;
      // Only show after a short settle; AdWidget empty = black bar otherwise
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted || _bannerAd == null) return;
        setState(() => _showBanner = true);
      });
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    // Don't dispose shared banner owned by AdService
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _app = Provider.of<AppManager>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ArcadeVsBackdrop(),
          IgnorePointer(
            child: Align(
              alignment: const Alignment(-0.72, 0.05),
              child: Transform.rotate(
                angle: -0.4,
                child: Icon(
                  Icons.sports_mma,
                  size: 110,
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: const Alignment(0.72, 0.05),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(3.14159)..rotateZ(0.4),
                child: Icon(
                  Icons.sports_mma,
                  size: 110,
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Text(
                    'CLICK',
                    style: ArcadeChrome.display(
                      size: 56,
                      color: ArcadeChrome.yellow,
                      outline: ArcadeChrome.red,
                    ),
                  ),
                  Text(
                    'BATTLE',
                    style: ArcadeChrome.display(
                      size: 56,
                      color: Colors.white,
                      outline: ArcadeChrome.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _app.getText('welcomeMessage'),
                    textAlign: TextAlign.center,
                    style: ArcadeChrome.ui(
                      size: 13,
                      color: Colors.white.withOpacity(0.75),
                      weight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const Spacer(flex: 2),
                  ScaleTransition(
                    scale: Tween(begin: 0.98, end: 1.03).animate(
                      CurvedAnimation(
                        parent: _pulse,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () {
                          AnalyticsService.instance.logTapStart();
                          Navigator.pushNamed(context, '/mode_selection');
                        },
                        style: ArcadeChrome.yellowButton(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ChipBtn(
                          color: ArcadeChrome.red,
                          icon: Icons.settings,
                          label: _app.getText('settings'),
                          onTap: () {
                            AnalyticsService.instance.logTapSettings();
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ChipBtn(
                          color: ArcadeChrome.blue,
                          icon: Icons.help_outline,
                          label: _app.getText('howToPlay'),
                          onTap: () {
                            AnalyticsService.instance.logTapHowToPlay(
                              source: AnalyticsValues.sourceHome,
                            );
                            Navigator.pushNamed(context, '/how_to_play');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
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

class _ChipBtn extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ChipBtn({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: ArcadeChrome.yellow, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ArcadeChrome.ui(
                    size: 11,
                    color: ArcadeChrome.yellow,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
