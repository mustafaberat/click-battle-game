import 'package:clickbattle/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('home shows title, start, settings and how to play',
      (tester) async {
    final app = await pumpScreen(tester, const HomeScreen());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('homeHeroTitle')), findsOneWidget);
    expect(find.text(app.getText('tapToStart').toUpperCase()), findsOneWidget);
    expect(find.text(app.getText('settings').toUpperCase()), findsOneWidget);
    expect(find.text(app.getText('howToPlay').toUpperCase()), findsOneWidget);
    expect(find.text(app.getText('arcadeTagline')), findsOneWidget);
    expect(find.text(app.getText('welcomeMessage')), findsOneWidget);
  });

  testWidgets('tagline pill fits a 320x568 screen', (tester) async {
    await pumpScreen(tester, const HomeScreen(), size: const Size(320, 568));
    await tester.pump(const Duration(milliseconds: 600));
    final pill = find.byKey(const Key('homeTaglinePill'));
    expect(pill, findsOneWidget);
    final r = tester.getRect(pill);
    expect(r.left, greaterThanOrEqualTo(0));
    expect(r.right, lessThanOrEqualTo(320));
    expect(r.top, greaterThan(0));
    expect(r.bottom, lessThan(568));
    expect(tester.takeException(), isNull);
  });
}
