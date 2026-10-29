import 'package:clickbattle/analytics/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'recording_analytics_backend.dart';

void main() {
  testWidgets('logs screen_view for named routes on push and pop',
      (tester) async {
    final backend = RecordingAnalyticsBackend();
    final analytics = AnalyticsService(backend: backend);
    final observer = AnalyticsNavigatorObserver(analytics: analytics);

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        initialRoute: '/',
        routes: {
          '/': (_) => const Scaffold(body: Text('home')),
          '/settings': (_) => const Scaffold(body: Text('settings')),
          '/mode_selection': (_) => const Scaffold(body: Text('mode')),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(backend.screens.map((s) => s.screenName), [AnalyticsScreens.home]);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/mode_selection');
    await tester.pumpAndSettle();
    navigator.pushNamed('/settings');
    await tester.pumpAndSettle();
    navigator.pop();
    await tester.pumpAndSettle();

    expect(backend.screens.map((s) => s.screenName), [
      AnalyticsScreens.home,
      AnalyticsScreens.modeSelection,
      AnalyticsScreens.settings,
      AnalyticsScreens.modeSelection,
    ]);
  });
}
