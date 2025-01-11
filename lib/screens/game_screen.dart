import 'package:flutter/material.dart';
import 'package:clickbattle/screens/mode_selection_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final Map<String, dynamic> gameArgs;
  int player1Score = 0;
  int player2Score = 0;
  double player1CPS = 0;
  double player2CPS = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    gameArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  String get difficultyText {
    if (gameArgs['mode'] != 'single_player') return '';
    
    switch (gameArgs['difficulty']) {
      case GameDifficulty.low:
        return 'Easy Mode - Target: 1.5 CPS';
      case GameDifficulty.normal:
        return 'Normal Mode - Target: 3 CPS';
      case GameDifficulty.hard:
        return 'Hard Mode - Target: 5 CPS';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gameArgs['mode'] == 'two_player' ? 'Two Players' : 'Single Player'),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[900]!,
              Colors.blue[600]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (gameArgs['mode'] == 'single_player')
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    difficultyText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: _buildPlayerArea(
                  'Player 1',
                  player1Score,
                  player1CPS,
                  Colors.blue[400]!,
                  () {
                    setState(() {
                      player1Score++;
                      // Update CPS calculation here
                    });
                  },
                ),
              ),
              if (gameArgs['mode'] == 'two_player') ...[
                const Divider(color: Colors.white, height: 2),
                Expanded(
                  child: _buildPlayerArea(
                    'Player 2',
                    player2Score,
                    player2CPS,
                    Colors.red[400]!,
                    () {
                      setState(() {
                        player2Score++;
                        // Update CPS calculation here
                      });
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerArea(
    String playerName,
    int score,
    double cps,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              playerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'CPS: ${cps.toStringAsFixed(1)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.3),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.touch_app,
                  size: 64,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 