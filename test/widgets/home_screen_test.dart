import 'package:clickbattle/screens/home/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('home shows title, start, settings and how to play',
      (tester) async {
    final app = await pumpScreen(tester, const HomeScreen());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('CLICK'), findsOneWidget);
    expect(find.text('BATTLE'), findsOneWidget);
    expect(find.text(app.getText('tapToStart').toUpperCase()), findsOneWidget);
    expect(find.text(app.getText('settings').toUpperCase()), findsOneWidget);
    expect(find.text(app.getText('howToPlay').toUpperCase()), findsOneWidget);
    expect(find.text(app.getText('arcadeTagline')), findsOneWidget);
    expect(find.text(app.getText('welcomeMessage')), findsOneWidget);
  });
}
