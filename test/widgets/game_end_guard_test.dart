import 'package:clickbattle/screens/game/game_over_popup.dart';
import 'package:clickbattle/screens/game/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('taps during the FINISH moment do not change the score',
      (tester) async {
    final app = await pumpScreen(
      tester,
      const GameScreen(
        gameArgs: {
          'mode': 'GameMode.scoreLimit',
          'playerMode': 'PlayerMode.multiPlayer',
          'scoreLimit': 10,
        },
      ),
    );
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    final center = tester.getCenter(find.byKey(const Key('player1HitZone')));

    for (int i = 0; i < 10; i++) {
      await tester.tapAt(center);
    }
    await tester.pump();
    expect(find.byKey(const Key('finishMoment')), findsOneWidget);
    expect(
      find.text(app.getText('finishMoment').toUpperCase()),
      findsOneWidget,
    );
    expect(find.byType(GameOverPopup), findsNothing);
    expect(find.text('10'), findsOneWidget);

    // Keep spamming through the finish beat.
    for (int i = 0; i < 20; i++) {
      await tester.tapAt(center);
      await tester.pump(const Duration(milliseconds: 25));
    }
    expect(find.text('10'), findsOneWidget);
    expect(find.text('11'), findsNothing);
    expect(find.byType(GameOverPopup), findsNothing);

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('finishMoment')), findsNothing);
    expect(find.byType(GameOverPopup), findsOneWidget);
    final popup = tester.widget<GameOverPopup>(find.byType(GameOverPopup));
    expect(popup.player1Score, 10);
    expect(popup.player2Score, 0);
    await tester.pump(const Duration(milliseconds: 1600));
  });

  testWidgets('play again is locked for 0.8s after the popup opens',
      (tester) async {
    var replays = 0;
    final app = await pumpScreen(
      tester,
      GameOverPopup(
        player1Score: 10,
        player2Score: 4,
        isSinglePlayer: true,
        isTutorial: true,
        onTutorialReplay: () => replays++,
        onTutorialDone: () {},
      ),
    );
    final replay = find.text(app.getText('demoReplay').toUpperCase());

    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(replay, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(replay, warnIfMissed: false);
    await tester.pump();
    expect(replays, 0, reason: 'taps inside the 0.8s lock must be ignored');

    await tester.pump(const Duration(milliseconds: 400)); // ~0.9s
    await tester.tap(replay);
    await tester.pump();
    expect(replays, 1);
    await tester.pump(const Duration(milliseconds: 1000));
  });
}
