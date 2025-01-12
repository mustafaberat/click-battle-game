import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/screens/game/game_styles.dart';
import 'package:clickbattle/screens/game/game_screen.dart';

class GameOverPopup extends StatelessWidget {
  final int player1Score;
  final int player2Score;
  final bool isSinglePlayer;
  final Map<String, dynamic> gameArgs;

  const GameOverPopup({
    Key? key,
    required this.player1Score,
    required this.player2Score,
    required this.isSinglePlayer,
    required this.gameArgs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Game Over!',
              style: GameStyles.gameOverText(context),
            ),
            SizedBox(height: AppDimensions.spacing(context) * 2),
            Text(
              player1Score > player2Score 
                ? (isSinglePlayer ? 'You Win!' : 'Player 1 Wins!')
                : player2Score > player1Score
                  ? (isSinglePlayer ? 'Robot Wins!' : 'Player 2 Wins!')
                  : 'It\'s a Tie!',
              style: GameStyles.winnerText(context),
            ),
            SizedBox(height: AppDimensions.spacing(context) * 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: AppDimensions.buttonHeight(context),
                  child: ElevatedButton(
                    style: GameStyles.buttonStyle(context),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(gameArgs: gameArgs),
                        ),
                      );
                    },
                    child: Text(
                      'Play Again',
                      style: AppTextStyles.button(context),
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.spacing(context) * 2),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: AppDimensions.buttonHeight(context),
                  child: ElevatedButton(
                    style: GameStyles.buttonStyle(context),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Home',
                      style: AppTextStyles.button(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 