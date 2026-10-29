// ignore_for_file: invalid_use_of_visible_for_testing_member
/// Play Store visuals: real Click Battle UI + IPTV-style frames.
///
/// Run: `APP_ROOT=. ../lib/scripts/generate_game_images.sh`
/// Out:
///   play/gorseller/{lang}/01-*.png          phone 1080×1920
///   play/gorseller/{lang}/tablet/01-*.png   tablet 1440×2560
///   play/gorseller/{lang}/tv/01-*.png       TV 1920×1080
///   play/gorseller/{lang}/feature.png       1024×500
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:clickbattle/components/arcade_chrome.dart';
import 'package:clickbattle/constants/app_colors.dart';
import 'package:clickbattle/screens/game/game_over_popup.dart';
import 'package:clickbattle/screens/game/game_screen.dart';
import 'package:clickbattle/screens/home/home_screen.dart';
import 'package:clickbattle/screens/how_to_play/how_to_play_screen.dart';
import 'package:clickbattle/screens/mode_selection/mode_selection_screen.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'package:clickbattle/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Size _phoneCanvas = Size(1080, 1920);
const Size _tabletCanvas = Size(1440, 2560);
const Size _tvCanvas = Size(1920, 1080);
const Size _featureCanvas = Size(1024, 500);
const String _outRoot = 'play/gorseller';

const Map<String, Map<String, String>> _phoneSlogans = {
  'en': {
    'home': 'TAP FASTER',
    'duel': 'CLAIM THE SCREEN',
    'setup': 'PICK YOUR BATTLE',
    'howto': 'LEARN IN SECONDS',
    'over': 'WIN THE DUEL',
  },
  'es': {
    'home': 'TOCA MÁS RÁPIDO',
    'duel': 'DOMINA LA PANTALLA',
    'setup': 'ELIGE TU BATALLA',
    'howto': 'APRENDE AL INSTANTE',
    'over': 'GANA EL DUELO',
  },
  'pt': {
    'home': 'TOQUE MAIS RÁPIDO',
    'duel': 'DOMINE A TELA',
    'setup': 'ESCOLHA A BATALHA',
    'howto': 'APRENDA EM SEGUNDOS',
    'over': 'VENÇA O DUELO',
  },
  'zh': {
    'home': '点得更快',
    'duel': '占领屏幕',
    'setup': '选择对战',
    'howto': '几秒学会',
    'over': '赢得决斗',
  },
  'ja': {
    'home': 'もっと速くタップ',
    'duel': '画面を奪え',
    'setup': 'バトルを選ぶ',
    'howto': 'すぐ覚えられる',
    'over': 'デュエルに勝て',
  },
  'de': {
    'home': 'SCHNELLER TIPPEN',
    'duel': 'EROBERE DEN SCREEN',
    'setup': 'WÄHLE DEIN MATCH',
    'howto': 'IN SEKUNDEN LERNEN',
    'over': 'GEWINNE DAS DUELL',
  },
  'fr': {
    'home': 'TAPE PLUS VITE',
    'duel': 'PRENDS L’ÉCRAN',
    'setup': 'CHOISIS LE COMBAT',
    'howto': 'APPRENDS EN SECONDES',
    'over': 'GAGNE LE DUEL',
  },
  'ko': {
    'home': '더 빨리 탭',
    'duel': '화면을 차지해',
    'setup': '배틀을 고르세요',
    'howto': '몇 초면 배워요',
    'over': '결투에서 승리',
  },
  'it': {
    'home': 'TOCCA PIÙ VELOCE',
    'duel': 'CONQUISTA LO SCHERMO',
    'setup': 'SCEGLI LA BATTAGLIA',
    'howto': 'IMPARA IN UN ATTIMO',
    'over': 'VINCI IL DUELLO',
  },
  'tr': {
    'home': 'DAHA HIZLI TIKLA',
    'duel': 'EKRANI ELE GEÇİR',
    'setup': 'SAVAŞINI SEÇ',
    'howto': 'SANİYELERDE ÖĞREN',
    'over': 'DÜELLOYU KAZAN',
  },
};

const Map<String, String> _tabletSlogan = {
  'en': 'BUILT FOR BIG SCREENS',
  'es': 'PENSADO PARA PANTALLA GRANDE',
  'pt': 'FEITO PARA TELA GRANDE',
  'zh': '为大屏而生',
  'ja': '大画面向け',
  'de': 'FÜR GROSSE BILDSCHIRME',
  'fr': 'PENSÉ POUR GRAND ÉCRAN',
  'ko': '큰 화면에 최적화',
  'it': 'PER SCHERMI GRANDI',
  'tr': 'BÜYÜK EKRAN İÇİN',
};

const Map<String, String> _tvSlogan = {
  'en': 'PLAY ON THE BIG SCREEN',
  'es': 'JUEGA EN PANTALLA GRANDE',
  'pt': 'JOGUE NA TELA GRANDE',
  'zh': '大屏畅玩',
  'ja': '大画面で遊ぼう',
  'de': 'AUF DEM GROSSEN SCREEN',
  'fr': 'JOUE SUR GRAND ÉCRAN',
  'ko': '큰 화면에서 플레이',
  'it': 'GIOCA SUL GRANDE SCHERMO',
  'tr': 'BÜYÜK EKRANDA OYNA',
};

const Map<String, String> _featureTagline = {
  'en': 'Tap faster. Claim the screen.',
  'es': 'Toca más rápido. Domina la pantalla.',
  'pt': 'Toque mais rápido. Domine a tela.',
  'zh': '点得更快。占领屏幕。',
  'ja': 'もっと速くタップ。画面を奪え。',
  'de': 'Schneller tippen. Screen erobern.',
  'fr': 'Tape plus vite. Prends l’écran.',
  'ko': '더 빨리 탭. 화면을 차지해.',
  'it': 'Tocca più veloce. Conquista lo schermo.',
  'tr': 'Daha hızlı tıkla. Ekranı ele geçir.',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Play gorsellerini yaz (phone/tablet/tv/feature)', (tester) async {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
    await AppManager().initialize();
    await tester.runAsync(_loadFonts);

    for (final lang in LocalizationService.languageOrder) {
      await AppManager().setLanguage(lang);
      final phone = _phoneSlogans[lang]!;

      // --- Phone (portrait marketing) ---
      for (final entry in _shotBuilders(phone)) {
        await _shotFramed(
          tester,
          canvas: _phoneCanvas,
          outPath: '$_outRoot/$lang/${entry.id}.png',
          slogan: entry.slogan,
          landscape: false,
          buildPhone: entry.build,
          afterPump: entry.afterPump,
        );
      }

      // --- Tablet 7"/10" (same assets → both Play slots) ---
      final tabletPitch = _tabletSlogan[lang]!;
      for (final entry in _shotBuilders(phone)) {
        await _shotFramed(
          tester,
          canvas: _tabletCanvas,
          outPath: '$_outRoot/$lang/tablet/${entry.id}.png',
          slogan: tabletPitch,
          landscape: false,
          buildPhone: entry.build,
          afterPump: entry.afterPump,
        );
      }

      // --- TV / Chromebook wide ---
      final tvPitch = _tvSlogan[lang]!;
      // Fewer TV shots (max useful set)
      for (final entry in _shotBuilders(phone).where(
        (e) => e.id == '01-home' || e.id == '02-duel' || e.id == '05-over',
      )) {
        await _shotFramed(
          tester,
          canvas: _tvCanvas,
          outPath: '$_outRoot/$lang/tv/${entry.id}.png',
          slogan: tvPitch,
          landscape: true,
          buildPhone: entry.build,
          afterPump: entry.afterPump,
        );
      }

      // --- Feature graphic 1024×500 ---
      await _shotFeature(
        tester,
        lang: lang,
        tagline: _featureTagline[lang]!,
      );
    }
  }, timeout: const Timeout(Duration(minutes: 20)));
}

class _ShotSpec {
  const _ShotSpec({
    required this.id,
    required this.slogan,
    required this.build,
    this.afterPump,
  });
  final String id;
  final String slogan;
  final Widget Function(BuildContext) build;
  final Future<void> Function(WidgetTester)? afterPump;
}

List<_ShotSpec> _shotBuilders(Map<String, String> slogans) {
  return [
    _ShotSpec(
      id: '01-home',
      slogan: slogans['home']!,
      build: (_) => const HomeScreen(),
    ),
    _ShotSpec(
      id: '02-duel',
      slogan: slogans['duel']!,
      build: (_) => const _DuelStill(
        blueScore: 23,
        redScore: 12,
        scoreLimit: 50,
      ),
    ),
    _ShotSpec(
      id: '03-setup',
      slogan: slogans['setup']!,
      build: (_) => const ModeSelectionScreen(),
    ),
    _ShotSpec(
      id: '04-howto',
      slogan: slogans['howto']!,
      build: (_) => const HowToPlayScreen(),
    ),
    _ShotSpec(
      id: '05-over',
      slogan: slogans['over']!,
      build: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Expanded(flex: 45, child: Container(color: AppColors.neonRed)),
                Expanded(flex: 55, child: Container(color: AppColors.neonBlue)),
              ],
            ),
            GameOverPopup(
              player1Score: 12,
              player2Score: 18,
              isSinglePlayer: true,
              isTutorial: true,
              gameArgs: const {
                'mode': 'GameMode.scoreLimit',
                'playerMode': 'PlayerMode.singlePlayer',
                'scoreLimit': 20,
                'difficulty': 5,
              },
              onTutorialReplay: () {},
              onTutorialDone: () {},
            ),
          ],
        ),
      ),
      afterPump: (t) async {
        await t.pump(const Duration(milliseconds: 1600));
      },
    ),
  ];
}

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  expect(root, isNotNull, reason: 'FLUTTER_ROOT yok');
  final dir = '$root/bin/cache/artifacts/material_fonts';
  final home = Platform.environment['HOME'] ?? '';

  Future<ByteData> fileBytes(String path) async {
    final file = File(path);
    expect(file.existsSync(), isTrue, reason: 'Font yok: $path');
    return ByteData.sublistView(await file.readAsBytes());
  }

  Future<void> load(String family, String path) async {
    final loader = FontLoader(family)..addFont(fileBytes(path));
    await loader.load();
  }

  Future<void> loadIfExists(String family, String path) async {
    if (File(path).existsSync()) await load(family, path);
  }

  await load('MaterialIcons', '$dir/MaterialIcons-Regular.otf');
  await load('Roboto', '$dir/Roboto-Regular.ttf');
  await load('Bangers', 'fonts/Bangers-Regular.ttf');
  await load('Exo2', 'fonts/Exo2-ExtraBold.ttf');

  // Widget test sistem fontunu kullanmaz; 👆🤖⚡ ve CJK aksi halde □.
  await load('Apple Color Emoji', '/System/Library/Fonts/Apple Color Emoji.ttc');
  await load('Hiragino Sans GB', '/System/Library/Fonts/Hiragino Sans GB.ttc');
  await load('Hiragino Sans', '/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc');
  await load('Apple SD Gothic Neo', '/System/Library/Fonts/AppleSDGothicNeo.ttc');

  await loadIfExists(
    'CupertinoIcons',
    '$home/.pub-cache/hosted/pub.dev/cupertino_icons-1.0.9/assets/CupertinoIcons.ttf',
  );
}

Future<void> _shotFramed(
  WidgetTester tester, {
  required Size canvas,
  required String outPath,
  required String slogan,
  required bool landscape,
  required Widget Function(BuildContext) buildPhone,
  Future<void> Function(WidgetTester)? afterPump,
}) async {
  _setView(tester, canvas);
  final frameKey = GlobalKey();
  const phoneLogical = Size(390, 844);

  await tester.pumpWidget(
    RepaintBoundary(
      key: frameKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: landscape
            ? _TvFrame(
                slogan: slogan,
                phone: _phoneHost(phoneLogical, buildPhone),
              )
            : _StoreFrame(
                slogan: slogan,
                phone: _phoneHost(phoneLogical, buildPhone),
              ),
      ),
    ),
  );
  await _pumpFrames(tester);
  if (afterPump != null) await afterPump(tester);
  await tester.pump(const Duration(milliseconds: 100));
  await _writePng(tester, frameKey, outPath);
}

Widget _phoneHost(Size phoneLogical, Widget Function(BuildContext) buildPhone) {
  return _providers(
    child: MediaQuery(
      data: MediaQueryData(
        size: phoneLogical,
        devicePixelRatio: 1,
        padding: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
      ),
      child: SizedBox(
        width: phoneLogical.width,
        height: phoneLogical.height,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _theme(),
          builder: (context, child) {
            return DefaultTextStyle.merge(
              style: const TextStyle(fontFamilyFallback: ArcadeChrome.fontFallback),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: Builder(builder: buildPhone),
        ),
      ),
    ),
  );
}

Future<void> _shotFeature(
  WidgetTester tester, {
  required String lang,
  required String tagline,
}) async {
  _setView(tester, _featureCanvas);
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _FeatureGraphic(tagline: tagline),
      ),
    ),
  );
  await tester.pump();
  await _writePng(tester, key, '$_outRoot/$lang/feature.png');
}

Widget _providers({required Widget child}) {
  final app = AppManager();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: app.settingsService),
      ChangeNotifierProvider.value(value: app.localizationService),
      Provider.value(value: app),
    ],
    child: child,
  );
}

ThemeData _theme() {
  final base = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    brightness: Brightness.dark,
    fontFamily: 'Exo2',
    fontFamilyFallback: ArcadeChrome.fontFallback,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: 'Exo2',
      fontFamilyFallback: ArcadeChrome.fontFallback,
    ),
    primaryTextTheme: base.primaryTextTheme.apply(
      fontFamily: 'Exo2',
      fontFamilyFallback: ArcadeChrome.fontFallback,
    ),
  );
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 24; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void _setView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding.zero;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
}

Future<Uint8List?> _pngBytes(WidgetTester tester, GlobalKey key) {
  return tester.binding.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
}

Future<void> _writePng(WidgetTester tester, GlobalKey key, String path) async {
  final bytes = await _pngBytes(tester, key);
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes!);
}

/// Soft light-blue atmospheric frame + headline + device bezel (portrait).
class _StoreFrame extends StatelessWidget {
  const _StoreFrame({required this.slogan, required this.phone});

  final String slogan;
  final Widget phone;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFD6EAF8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _GlowBlob(
              color: const Color(0xFF7EC8E8).withOpacity(0.55),
              size: 320,
            ),
          ),
          Positioned(
            bottom: 40,
            left: -80,
            child: _GlowBlob(
              color: const Color(0xFFA8D8F0).withOpacity(0.5),
              size: 280,
            ),
          ),
          Positioned(
            top: 220,
            left: 40,
            child: Transform.rotate(
              angle: -0.35,
              child: Icon(
                Icons.sports_mma,
                size: 72,
                color: Colors.white.withOpacity(0.35),
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            right: 36,
            child: Icon(
              Icons.bolt_rounded,
              size: 64,
              color: AppColors.arcadeYellow.withOpacity(0.55),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(36, 28, 36, 40),
              child: Column(
                children: [
                  Text(
                    slogan,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Exo2',
                      fontFamilyFallback: ArcadeChrome.fontFallback,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0B2A4A),
                      letterSpacing: 1.2,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 9 / 19.5,
                        child: _DeviceBezel(child: phone),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 16:9 TV / Chromebook marketing still — slogan left, device right.
class _TvFrame extends StatelessWidget {
  const _TvFrame({required this.slogan, required this.phone});

  final String slogan;
  final Widget phone;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFD6EAF8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -40,
            left: -40,
            child: _GlowBlob(
              color: const Color(0xFF7EC8E8).withOpacity(0.5),
              size: 360,
            ),
          ),
          Positioned(
            bottom: -60,
            right: -40,
            child: _GlowBlob(
              color: AppColors.arcadeYellow.withOpacity(0.25),
              size: 300,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 36),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    slogan,
                    style: const TextStyle(
                      fontFamily: 'Exo2',
                      fontFamilyFallback: ArcadeChrome.fontFallback,
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0B2A4A),
                      height: 1.1,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 9 / 19.5,
                      child: _DeviceBezel(child: phone),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceBezel extends StatelessWidget {
  const _DeviceBezel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(42),
        border: Border.all(color: const Color(0xFF2A2A32), width: 10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2A4A).withOpacity(0.28),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
    );
  }
}

class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic({required this.tagline});
  final String tagline;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.neonRed,
            Color(0xFF1A0A12),
            AppColors.neonBlue,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: const Alignment(-0.85, 0),
            child: Icon(
              Icons.sports_mma,
              size: 160,
              color: Colors.black.withOpacity(0.25),
            ),
          ),
          Align(
            alignment: const Alignment(0.85, 0),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Icon(
                Icons.sports_mma,
                size: 160,
                color: Colors.black.withOpacity(0.25),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CLICK BATTLE',
                  style: TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 72,
                    color: AppColors.arcadeYellow,
                    letterSpacing: 2,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Exo2',
                    fontFamilyFallback: ArcadeChrome.fontFallback,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }
}

/// Mid-duel still for Play shots. Live [GameScreen] cannot pin scores/ratio
/// without changing match logic, so this capture-only scene mirrors the arena.
class _DuelStill extends StatelessWidget {
  const _DuelStill({
    required this.blueScore,
    required this.redScore,
    required this.scoreLimit,
  });

  final int blueScore;
  final int redScore;
  final int scoreLimit;

  static const double _blueShare = 0.65;

  @override
  Widget build(BuildContext context) {
    const blue = ArcadeChrome.blue;
    const red = ArcadeChrome.red;
    final remaining =
        '${scoreLimit - (blueScore > redScore ? blueScore : redScore)}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final w = constraints.maxWidth;
          final iconSize = w * 0.075;
          const lineH = 3.0;
          final topH =
              ((1 - _blueShare) * (h - lineH)).clamp(h * 0.08, h * 0.92);

          Widget tapStack({
            required bool robot,
            required double burstRadius,
            required List<Offset> plusOnes,
            required double iconScale,
          }) {
            return Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  _TapBurst(
                    color: Colors.white,
                    radius: burstRadius,
                    plusOnes: plusOnes,
                  ),
                  PlayerIcon(
                    isRobot: robot,
                    isTopPlayer: robot,
                    iconSize: iconSize,
                    scaleAnimation: AlwaysStoppedAnimation<double>(iconScale),
                    color: Colors.white,
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: topH,
                    width: double.infinity,
                    child: const _ShotArena(color: red, alignTop: true),
                  ),
                  Container(
                    height: lineH,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          red.withOpacity(0.25),
                          ArcadeChrome.yellow,
                          blue.withOpacity(0.25),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ArcadeChrome.yellow.withOpacity(0.45),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: _ShotArena(color: blue, alignTop: false),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: topH,
                child: tapStack(
                  robot: true,
                  burstRadius: 42,
                  iconScale: 1,
                  plusOnes: const [
                    Offset(20, 28),
                    Offset(-18, 22),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: topH + lineH,
                bottom: 0,
                child: tapStack(
                  robot: false,
                  burstRadius: 78,
                  iconScale: 0.86,
                  plusOnes: const [
                    Offset(28, -46),
                    Offset(-26, -54),
                    Offset(44, -20),
                    Offset(-40, -28),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: topH,
                child: FractionalTranslation(
                  translation: const Offset(0, -0.5),
                  child: Center(
                    child: ComicTimerChip(icon: Icons.flag, value: remaining),
                  ),
                ),
              ),
              Positioned(
                right: w * 0.06,
                top: topH + 8,
                child: ScoreDisplay(
                  score: blueScore,
                  color: Colors.white,
                  isAnimating: false,
                ),
              ),
              Positioned(
                right: w * 0.06,
                top: topH - 58,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationZ(3.14159),
                  child: ScoreDisplay(
                    score: redScore,
                    color: Colors.white,
                    isAnimating: false,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShotArena extends StatelessWidget {
  const _ShotArena({required this.color, required this.alignTop});

  final Color color;
  final bool alignTop;

  @override
  Widget build(BuildContext context) {
    final deep = Color.lerp(color, const Color(0xFF050508), 0.42)!;
    final edge = Color.lerp(color, Colors.white, 0.12)!;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: alignTop ? Alignment.topCenter : Alignment.bottomCenter,
              end: alignTop ? Alignment.bottomCenter : Alignment.topCenter,
              colors: [deep, color, edge],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.05,
              colors: [
                color.withOpacity(0.35),
                Colors.transparent,
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withOpacity(0.28),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.28),
              ],
              stops: const [0.0, 0.18, 0.82, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _TapBurst extends StatelessWidget {
  const _TapBurst({
    required this.color,
    required this.radius,
    required this.plusOnes,
  });

  final Color color;
  final double radius;
  final List<Offset> plusOnes;

  @override
  Widget build(BuildContext context) {
    final box = radius * 2.4;
    return IgnorePointer(
      child: SizedBox(
        width: box,
        height: box,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(box),
              painter: _RipplePainter(color: color, radius: radius),
            ),
            for (var i = 0; i < plusOnes.length; i++)
              Transform.translate(
                offset: plusOnes[i],
                child: Text(
                  '+1',
                  style: ArcadeChrome.ui(
                    size: i == 0 ? 16 : 12,
                    color: ArcadeChrome.yellow.withOpacity(i == 0 ? 1 : 0.75),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  const _RipplePainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 3; i++) {
      final t = (i + 1) / 3.0;
      canvas.drawCircle(
        c,
        radius * t,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.4 - i * 0.7
          ..color = color.withOpacity(0.58 - i * 0.16),
      );
    }
    canvas.drawCircle(
      c,
      radius * 0.18,
      Paint()..color = Colors.white.withOpacity(0.38),
    );
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
