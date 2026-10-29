import 'package:clickbattle/screens/mode_selection/mode_selection_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('game setup keeps all existing options', (tester) async {
    final app = await pumpScreen(tester, const ModeSelectionScreen());
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.text(app.getText('gameSetup').toUpperCase()),
      findsOneWidget,
    );
    expect(
      find.text(app.getText('singlePlayer').toUpperCase()),
      findsOneWidget,
    );
    expect(
      find.text(app.getText('twoPlayers').toUpperCase()),
      findsOneWidget,
    );
    expect(
      find.text(app.getText('timeAttack').toUpperCase()),
      findsOneWidget,
    );
    expect(
      find.text(app.getText('survival').toUpperCase()),
      findsOneWidget,
    );
    expect(find.text('10'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(
      find.text(app.getText('startBattle').toUpperCase()),
      findsOneWidget,
    );
    expect(find.textContaining('5'), findsWidgets);
  });

  testWidgets('switching to two players hides difficulty', (tester) async {
    final app = await pumpScreen(tester, const ModeSelectionScreen());
    await tester.tap(find.text(app.getText('twoPlayers').toUpperCase()));
    await tester.pump();
    expect(find.text(app.getText('easy').toUpperCase()), findsNothing);
  });
}
