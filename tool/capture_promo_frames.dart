// ignore_for_file: invalid_use_of_visible_for_testing_member
/// Play Store promo video frames: real Click Battle UI in a landscape plate.
///
/// Run: `flutter test tool/capture_promo_frames.dart`
/// Out:
///   build/promo_frames/frame_XXXX.png
///   play/promo/clickbattle-promo.mp4
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:clickbattle/components/arcade_chrome.dart';
import 'package:clickbattle/constants/app_colors.dart';
import 'package:clickbattle/screens/game/game_over_popup.dart';
import 'package:clickbattle/screens/game/game_screen.dart';
import 'package:clickbattle/screens/home/home_screen.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Size _canvas = Size(1920, 1080);
const Size _phoneLogical = Size(390, 844);
const String _frameDir = 'build/promo_frames';
const String _outMp4 = 'play/promo/clickbattle-promo.mp4';
const int _fps = 30;
const Duration _tick = Duration(milliseconds: 33);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Click Battle promo frames + mp4', (tester) async {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
    await AppManager().initialize();
    await AppManager().setLanguage('en');
    await tester.runAsync(_loadFonts);

    final icon = await tester.runAsync(_loadIcon);
    expect(icon, isNotNull, reason: 'play/gorseller/icon-512.png yok');

    final out = Directory(_frameDir);
    if (out.existsSync()) out.deleteSync(recursive: true);
    out.createSync(recursive: true);
    Directory('play/promo').createSync(recursive: true);

    final oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final s = '${details.exception}';
      if (s.contains('MissingPluginException') ||
          s.contains('google_mobile_ads') ||
          s.contains('channel-error')) {
        return;
      }
      oldOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = oldOnError);

    _setView(tester);
    final key = GlobalKey();
    var frame = 1;

    Future<void> show(Widget child) async {
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: child,
          ),
        ),
      );
      await tester.pump();
    }

    Future<void> grab() async {
      await _writePng(tester, key, _framePath(frame));
      if (frame % 30 == 1) {
        debugPrint('promo frame $frame');
      }
      frame++;
    }

    Future<void> holdLast(int extra) async {
      final src = File(_framePath(frame - 1));
      final bytes = src.readAsBytesSync();
      for (var i = 0; i < extra; i++) {
        File(_framePath(frame)).writeAsBytesSync(bytes);
        frame++;
      }
    }

    // --- 1. Logo intro (~2.4s) ---
    const introFrames = 28;
    for (var i = 0; i < introFrames; i++) {
      final t = (i / (introFrames - 1)).clamp(0.0, 1.0);
      await show(_IntroCard(icon: icon!, t: Curves.easeOutBack.transform(t)));
      await tester.pump(_tick);
      await grab();
    }
    await holdLast(44); // hold to ~2.4s

    // --- 2. Home (~2.2s) ---
    await show(
      _PromoPlate(
        left: 'TAP FASTER',
        right: '2 PLAYER DUEL',
        phone: _phoneHost((_) => const HomeScreen()),
      ),
    );
    for (var i = 0; i < 66; i++) {
      await tester.pump(_tick);
      await grab();
    }

    // --- 3. Two-player duel: countdown + takeover (~11.5s) ---
    await show(
      _PromoPlate(
        left: 'CLAIM THE SCREEN',
        right: 'TAP TO TAKE OVER',
        phone: _phoneHost(
          (_) => const GameScreen(
            gameArgs: {
              'mode': 'GameMode.scoreLimit',
              'playerMode': 'PlayerMode.twoPlayer',
              'scoreLimit': 200,
              'difficulty': 5,
            },
          ),
        ),
      ),
    );
    await tester.pump();

    // Countdown 3-2-1 at ~1.7x so it fits the promo (3s game → ~1.7s video).
    for (var i = 0; i < 52; i++) {
      await tester.pump(const Duration(milliseconds: 58));
      await grab();
    }

    Rect gameRect() => tester.getRect(find.byType(GameScreen));

    Offset tapBlue(int i) {
      final r = gameRect();
      return Offset(
        r.left + r.width * (0.32 + 0.36 * ((i * 17) % 10) / 10),
        r.top + r.height * (0.66 + 0.18 * ((i * 13) % 10) / 10),
      );
    }

    Offset tapRed(int i) {
      final r = gameRect();
      return Offset(
        r.left + r.width * (0.32 + 0.36 * ((i * 11) % 10) / 10),
        r.top + r.height * (0.16 + 0.18 * ((i * 19) % 10) / 10),
      );
    }

    for (var i = 0; i < 292; i++) {
      if (i % 3 == 0) await tester.tapAt(tapBlue(i));
      if (i % 5 == 0) await tester.tapAt(tapRed(i));
      await tester.pump(_tick);
      await grab();
    }

    // --- 4. Robot / AI mode (~5.0s) ---
    await show(
      _PromoPlate(
        left: 'VS THE ROBOT',
        right: 'BEAT THE AI',
        phone: _phoneHost(
          (_) => const GameScreen(
            gameArgs: {
              'mode': 'GameMode.scoreLimit',
              'playerMode': 'PlayerMode.singlePlayer',
              'scoreLimit': 200,
              'difficulty': 6,
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 3100));

    for (var i = 0; i < 150; i++) {
      if (i % 4 == 0) await tester.tapAt(tapBlue(i + 3));
      await tester.pump(_tick);
      await grab();
    }

    // --- 5. Win screen (~3.4s) ---
    await show(
      _PromoPlate(
        left: 'WIN THE DUEL',
        right: 'PLAY AGAIN',
        phone: _phoneHost(
          (_) => Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    Expanded(flex: 38, child: Container(color: AppColors.neonRed)),
                    Expanded(flex: 62, child: Container(color: AppColors.neonBlue)),
                  ],
                ),
                GameOverPopup(
                  player1Score: 24,
                  player2Score: 16,
                  isSinglePlayer: true,
                  isTutorial: false,
                  gameArgs: const {
                    'mode': 'GameMode.scoreLimit',
                    'playerMode': 'PlayerMode.singlePlayer',
                    'scoreLimit': 20,
                    'difficulty': 6,
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 102; i++) {
      await tester.pump(_tick);
      await grab();
    }

    // --- 6. End card (~3.2s) ---
    const endAnim = 24;
    for (var i = 0; i < endAnim; i++) {
      final t = (i / (endAnim - 1)).clamp(0.0, 1.0);
      await show(_EndCard(icon: icon!, t: Curves.easeOutCubic.transform(t)));
      await tester.pump(_tick);
      await grab();
    }
    await holdLast(72);

    final total = frame - 1;
    debugPrint('promo frames written: $total');
    expect(total, inInclusiveRange(750, 900));

    await tester.runAsync(() async {
      await _encodeMp4(total);
    });
  }, timeout: const Timeout(Duration(minutes: 25)));
}

String _framePath(int i) =>
    '$_frameDir/frame_${i.toString().padLeft(4, '0')}.png';

Future<void> _encodeMp4(int frameCount) async {
  final ffmpeg = await _whichFfmpeg();
  expect(ffmpeg, isNotNull, reason: 'ffmpeg yok — brew install ffmpeg');

  final result = await Process.run(ffmpeg!, [
    '-y',
    '-framerate', '$_fps',
    '-i', '$_frameDir/frame_%04d.png',
    '-frames:v', '$frameCount',
    '-c:v', 'libx264',
    '-profile:v', 'high',
    '-level', '4.0',
    '-pix_fmt', 'yuv420p',
    '-preset', 'medium',
    '-crf', '18',
    '-movflags', '+faststart',
    '-an',
    _outMp4,
  ]);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  expect(result.exitCode, 0, reason: 'ffmpeg encode failed');
}

Future<String?> _whichFfmpeg() async {
  for (final c in ['ffmpeg', '/opt/homebrew/bin/ffmpeg', '/usr/local/bin/ffmpeg']) {
    if (c == 'ffmpeg') {
      final r = await Process.run('which', ['ffmpeg']);
      if (r.exitCode == 0) {
        final path = (r.stdout as String).trim();
        if (path.isNotEmpty) return path;
      }
    } else if (File(c).existsSync()) {
      return c;
    }
  }
  final py = await Process.run('python3', [
    '-c',
    'import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())',
  ]);
  if (py.exitCode == 0) {
    final path = (py.stdout as String).trim();
    if (path.isNotEmpty && File(path).existsSync()) return path;
  }
  return null;
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
  await load('Apple Color Emoji', '/System/Library/Fonts/Apple Color Emoji.ttc');

  await loadIfExists(
    'CupertinoIcons',
    '$home/.pub-cache/hosted/pub.dev/cupertino_icons-1.0.9/assets/CupertinoIcons.ttf',
  );
}

Future<ui.Image> _loadIcon() async {
  final bytes = await File('play/gorseller/icon-512.png').readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  return (await codec.getNextFrame()).image;
}

Widget _phoneHost(Widget Function(BuildContext) buildPhone) {
  final app = AppManager();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: app.settingsService),
      ChangeNotifierProvider.value(value: app.localizationService),
      Provider.value(value: app),
    ],
    child: MediaQuery(
      data: const MediaQueryData(
        size: _phoneLogical,
        devicePixelRatio: 1,
        padding: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
      ),
      child: SizedBox(
        width: _phoneLogical.width,
        height: _phoneLogical.height,
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

void _setView(WidgetTester tester) {
  tester.view.physicalSize = _canvas;
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
  File(path).writeAsBytesSync(bytes!);
}

class _PromoPlate extends StatelessWidget {
  const _PromoPlate({
    required this.left,
    required this.right,
    required this.phone,
  });

  final String left;
  final String right;
  final Widget phone;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFD6EAF8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            top: -50,
            left: -50,
            child: _GlowBlob(color: Color(0x887EC8E8), size: 380),
          ),
          Positioned(
            bottom: -70,
            right: -40,
            child: _GlowBlob(
              color: AppColors.arcadeYellow.withOpacity(0.28),
              size: 320,
            ),
          ),
          Positioned(
            top: 64,
            left: 56,
            child: Transform.rotate(
              angle: -0.4,
              child: Icon(
                Icons.sports_mma,
                size: 64,
                color: Colors.white.withOpacity(0.42),
              ),
            ),
          ),
          Positioned(
            bottom: 72,
            right: 52,
            child: Icon(
              Icons.bolt_rounded,
              size: 58,
              color: AppColors.arcadeYellow.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
            child: Row(
              children: [
                SizedBox(
                  width: 360,
                  child: _SideTitle(left),
                ),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 9 / 19.5,
                      child: _DeviceBezel(child: phone),
                    ),
                  ),
                ),
                SizedBox(
                  width: 360,
                  child: _SideTitle(right, alignEnd: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideTitle extends StatelessWidget {
  const _SideTitle(this.text, {this.alignEnd = false});
  final String text;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: alignEnd ? TextAlign.right : TextAlign.left,
      style: const TextStyle(
        fontFamily: 'Exo2',
        fontFamilyFallback: ArcadeChrome.fontFallback,
        fontSize: 42,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0B2A4A),
        height: 1.08,
        letterSpacing: 0.8,
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

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.icon, required this.t});
  final ui.Image icon;
  final double t;

  @override
  Widget build(BuildContext context) {
    final scale = 0.72 + 0.28 * t;
    final opacity = t.clamp(0.0, 1.0);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.neonRed, Color(0xFF1A0A12), AppColors.neonBlue],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(64),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.arcadeYellow.withOpacity(0.35 * t),
                      blurRadius: 36,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: RawImage(image: icon, fit: BoxFit.cover),
              ),
              const SizedBox(height: 28),
              Text(
                'CLICK BATTLE',
                style: ArcadeChrome.display(
                  size: 72,
                  color: ArcadeChrome.yellow,
                  outline: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EndCard extends StatelessWidget {
  const _EndCard({required this.icon, required this.t});
  final ui.Image icon;
  final double t;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.neonRed, Color(0xFF1A0A12), AppColors.neonBlue],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Opacity(
        opacity: t,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 0.9 + 0.1 * t,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.arcadeYellow.withOpacity(0.3),
                      blurRadius: 24,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: RawImage(image: icon, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Click Battle — 2 Player Tap Duel',
              textAlign: TextAlign.center,
              style: ArcadeChrome.display(
                size: 46,
                color: ArcadeChrome.yellow,
                outline: Colors.black,
              ),
            ),
            const SizedBox(height: 22),
            Opacity(
              opacity: t,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: ArcadeChrome.yellow,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  'GET IT ON GOOGLE PLAY',
                  style: ArcadeChrome.ui(
                    size: 18,
                    color: Colors.black,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
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
