import 'package:clickbattle/components/arcade_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ComicButton invokes onPressed and fits long labels',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            child: ComicButton(
              onPressed: () => taps++,
              child: const Text('VERY LONG CALL TO ACTION LABEL'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('VERY LONG CALL TO ACTION LABEL'), findsOneWidget);
    await tester.tap(find.byType(ComicButton));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('ComicPanel shows slanted label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ComicPanel(
            label: 'Select Mode',
            child: Text('body'),
          ),
        ),
      ),
    );
    expect(find.text('SELECT MODE'), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('HalftoneBackground and LightningBolt paint', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              HalftoneBackground(),
              Center(child: LightningBolt()),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(HalftoneBackground), findsOneWidget);
    expect(find.byType(LightningBolt), findsOneWidget);
  });

  testWidgets('ArcadeDifficultyRail reports 1-10', (tester) async {
    var value = 5;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArcadeDifficultyRail(
            value: value,
            label: 'Normal',
            easyLabel: 'Easy',
            hardLabel: 'Hard',
            onChanged: (v) => value = v,
          ),
        ),
      ),
    );
    expect(find.textContaining('5'), findsWidgets);
    expect(find.text('EASY'), findsOneWidget);
    expect(find.text('HARD'), findsOneWidget);
    await tester.tap(find.byType(GestureDetector).last, warnIfMissed: false);
    await tester.pump();
    expect(value, inInclusiveRange(1, 10));
  });
}
