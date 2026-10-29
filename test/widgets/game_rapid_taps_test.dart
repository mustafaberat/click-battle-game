import 'package:clickbattle/components/tap_burst_layer.dart';
import 'package:clickbattle/screens/game/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('200 rapid taps all count exactly and FX stay bounded',
      (tester) async {
    await pumpScreen(
      tester,
      const GameScreen(
        gameArgs: {
          'mode': 'GameMode.scoreLimit',
          'playerMode': 'PlayerMode.multiPlayer',
          'scoreLimit': 1000,
        },
      ),
    );
    // Countdown 3-2-1-GO.
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 1));
    }

    final zone = find.byKey(const Key('player1HitZone'));
    expect(zone, findsOneWidget);
    final center = tester.getCenter(zone);

    // Many taps between frames: score must still be exact.
    for (int i = 0; i < 200; i++) {
      await tester.tapAt(center + Offset((i % 7) * 5.0, (i % 5) * 4.0));
      if (i % 20 == 19) await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.text('200'), findsOneWidget);
    expect(find.text('0'), findsWidgets); // opponent untouched

    // Let FX + territory animations finish; nothing should keep ticking.
    for (int i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final layer = tester.widget<TapBurstLayer>(find.byType(TapBurstLayer));
    expect(layer.controller.liveCount, 0);
    expect(find.text('200'), findsOneWidget);
  });
}
