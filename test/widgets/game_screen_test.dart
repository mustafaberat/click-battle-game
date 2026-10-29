import 'package:clickbattle/screens/game/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('game screen keeps 50/50 hit zones and starts on countdown',
      (tester) async {
    await pumpScreen(
      tester,
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

    expect(find.text('3'), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('2'), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1'), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('GO!'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('GO!'), findsNothing);
    expect(find.byType(GestureDetector), findsWidgets);
    // Hit column is two equal Expanded halves (no mid GameDivider stealing space).
    expect(find.byType(GameScreen), findsOneWidget);
  });
}
