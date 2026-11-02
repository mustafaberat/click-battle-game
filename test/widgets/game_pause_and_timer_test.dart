import 'package:clickbattle/screens/game/game_screen.dart';
import 'package:clickbattle/screens/game/pause_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_harness.dart';

Future<void> _startMatch(WidgetTester tester) async {
  for (int i = 0; i < 4; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

Future<void> _pressBack(WidgetTester tester) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  await navigator.maybePop();
  await tester.pump();
}

void main() {
  testWidgets('clock at 0:00 ends the match and further taps do not score',
      (tester) async {
    await pumpScreen(
      tester,
      const GameScreen(
        gameArgs: {
          'mode': 'GameMode.timeLimit',
          'playerMode': 'PlayerMode.multiPlayer',
          'timeLimit': 1,
        },
      ),
    );
    await _startMatch(tester);
    expect(find.text('0:01'), findsOneWidget);

    final center = tester.getCenter(find.byKey(const Key('player1HitZone')));
    await tester.tapAt(center);
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('0:00'), findsOneWidget);
    expect(find.byKey(const Key('finishMoment')), findsOneWidget);

    for (int i = 0; i < 12; i++) {
      await tester.tapAt(center);
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsNothing);
  });

  testWidgets('system back pauses the match instead of leaving',
      (tester) async {
    await pumpScreen(
      tester,
      const GameScreen(
        gameArgs: {
          'mode': 'GameMode.timeLimit',
          'playerMode': 'PlayerMode.multiPlayer',
          'timeLimit': 30,
        },
      ),
    );
    await _startMatch(tester);
    expect(find.text('0:30'), findsOneWidget);

    final center = tester.getCenter(find.byKey(const Key('player1HitZone')));
    await tester.tapAt(center);
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await _pressBack(tester);
    expect(find.byKey(const Key('pauseOverlay')), findsOneWidget);
    expect(find.byType(GameScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('0:30'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsNothing);

    await tester.tapAt(center);
    await tester.pump();
    expect(find.text('2'), findsNothing);

    await _pressBack(tester);
    expect(find.byKey(const Key('pauseOverlay')), findsNothing);
    expect(find.text('3'), findsWidgets);
    expect(find.text('0:30'), findsOneWidget);

    await tester.tapAt(center);
    await tester.pump();
    expect(find.text('2'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('2'), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1'), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('GO!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('GO!'), findsNothing);
    expect(find.text('0:30'), findsOneWidget);

    await tester.tapAt(center);
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('pause freezes the robot and the countdown', (tester) async {
    await pumpScreen(
      tester,
      const GameScreen(
        gameArgs: {
          'mode': 'GameMode.timeLimit',
          'playerMode': 'PlayerMode.singlePlayer',
          'timeLimit': 20,
          'difficulty': 10,
        },
      ),
    );
    expect(find.text('3'), findsWidgets);
    await tester.tap(find.byKey(const Key('pauseButton')));
    await tester.pump();
    expect(find.byType(PauseOverlay), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('3'), findsWidgets);
    expect(find.byType(PauseOverlay), findsOneWidget);

    await tester.tap(find.byKey(const Key('pauseResume')));
    await tester.pump();
    await _startMatch(tester);
    expect(find.text('0:20'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pauseButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('0:20'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('quit from pause returns to the previous screen', (tester) async {
    final app = await bootTestApp();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrapWithApp(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GameScreen(
                        gameArgs: {
                          'mode': 'GameMode.scoreLimit',
                          'playerMode': 'PlayerMode.multiPlayer',
                          'scoreLimit': 20,
                        },
                      ),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
        app,
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(GameScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('pauseButton')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('pauseQuit')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('pauseOverlay')), findsNothing);
    expect(find.byType(GameScreen), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });
}
