import 'dart:io';
import 'dart:ui' as ui;

import 'package:clickbattle/components/arcade_chrome.dart';
import 'package:clickbattle/screens/game/game_over_popup.dart';
import 'package:clickbattle/screens/game/game_screen.dart';
import 'package:clickbattle/screens/home/home_screen.dart';
import 'package:clickbattle/screens/mode_selection/mode_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_harness.dart';

const _shotKey = ValueKey('restyle-shot');

/// Fonts are bundled (fonts/) and preloaded in flutter_test_config.dart.
/// Raster assets decode asynchronously; give them real time before capture.
Future<void> _waitFonts(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 400)),
  );
  await tester.pump();
}

Future<void> _save(WidgetTester tester, String name) async {
  await tester.pump();
  await tester.runAsync(() async {
    final finder = find.byKey(_shotKey);
    final boundary = tester.renderObject(finder) as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.25);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory(
      Platform.environment['RESTYLE_SHOTS_DIR'] ?? 'build/restyle_shots',
    );
    dir.createSync(recursive: true);
    File('${dir.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Future<void> _tick(WidgetTester tester, {int frames = 12, int ms = 80}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(Duration(milliseconds: ms));
  }
}

void main() {
  testWidgets('capture restyled screens', (tester) async {
    final app = await bootTestApp();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> pumpShot(Widget child) async {
      await tester.pumpWidget(
        wrapWithApp(
          RepaintBoundary(
            key: _shotKey,
            child: MediaQuery(
              data: const MediaQueryData(size: Size(390, 844)),
              child: child,
            ),
          ),
          app,
        ),
      );
      await tester.pump();
      await _waitFonts(tester);
      await tester.pump();
    }

    await pumpShot(const HomeScreen());
    await _tick(tester, frames: 8);
    await _save(tester, 'screen_home');

    await pumpShot(const ModeSelectionScreen());
    await _tick(tester, frames: 6);
    await _save(tester, 'screen_game_setup');

    await pumpShot(
      const GameScreen(
        gameArgs: {
          'mode': 'GameMode.timeLimit',
          'playerMode': 'PlayerMode.singlePlayer',
          'timeLimit': 10,
          'scoreLimit': 10,
          'difficulty': 1,
        },
      ),
    );
    // Countdown 3-2-1-GO then the match is live.
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.tapAt(const Offset(118, 700));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    await _save(tester, 'screen_gameplay');

    await pumpShot(
      const GameScreen(
        key: ValueKey('finish-shot'),
        gameArgs: {
          'mode': 'GameMode.scoreLimit',
          'playerMode': 'PlayerMode.singlePlayer',
          'scoreLimit': 3,
          'difficulty': 1,
        },
      ),
    );
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    for (int i = 0; i < 3; i++) {
      await tester.tapAt(const Offset(195, 700));
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await _save(tester, 'screen_finish_moment');
    await tester.pump(const Duration(milliseconds: 2000));

    await pumpShot(
      const Scaffold(
        backgroundColor: ArcadeChrome.navy,
        body: GameOverPopup(
          player1Score: 23,
          player2Score: 12,
          isSinglePlayer: true,
        ),
      ),
    );
    await _tick(tester, frames: 20, ms: 80);
    await _save(tester, 'screen_game_over');
  });

  testWidgets('capture home at 320x568', (tester) async {
    final app = await bootTestApp();
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      wrapWithApp(
        const RepaintBoundary(
          key: _shotKey,
          child: MediaQuery(
            data: MediaQueryData(size: Size(320, 568)),
            child: HomeScreen(),
          ),
        ),
        app,
      ),
    );
    await _waitFonts(tester);
    await _tick(tester, frames: 8);
    await _save(tester, 'screen_home_320x568');
  });
}
