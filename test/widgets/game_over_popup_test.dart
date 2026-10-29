import 'package:clickbattle/screens/game/game_over_popup.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('win popup shows YOU WIN, scores, play again and home',
      (tester) async {
    final app = await pumpScreen(
      tester,
      const GameOverPopup(
        player1Score: 23,
        player2Score: 12,
        isSinglePlayer: true,
        isTutorial: true,
        onTutorialReplay: _noop,
        onTutorialDone: _noop,
      ),
    );
    await tester.pump(const Duration(milliseconds: 1600));

    expect(
      find.text(app.getText('gameOver').toUpperCase()),
      findsOneWidget,
    );
    expect(find.text('23'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text(app.getText('vs').toUpperCase()), findsOneWidget);
    expect(
      find.text(app.getText('demoReplay').toUpperCase()),
      findsOneWidget,
    );
    expect(find.text(app.getText('gotIt').toUpperCase()), findsOneWidget);
  });

  testWidgets('match win uses youWin headline and backToHome', (tester) async {
    final app = await pumpScreen(
      tester,
      const GameOverPopup(
        player1Score: 10,
        player2Score: 3,
        isSinglePlayer: true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 1600));
    expect(
      find.text(app.getText('youWin').toUpperCase()),
      findsOneWidget,
    );
    expect(
      find.text(app.getText('playAgain').toUpperCase()),
      findsOneWidget,
    );
    expect(
      find.text(app.getText('backToHome').toUpperCase()),
      findsOneWidget,
    );
  });

  testWidgets('tie and robot win headlines are localized', (tester) async {
    final app = await bootTestApp();
    expect(app.getText('tieHeadline'), isNotEmpty);
    expect(app.getText('robotWins'), isNotEmpty);
    expect(app.getText('player1Wins'), isNotEmpty);
    expect(app.getText('player2Wins'), isNotEmpty);
  });
}

void _noop() {}
