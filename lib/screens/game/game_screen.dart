import 'package:flutter/material.dart';
import 'package:clickbattle/screens/game/game_styles.dart';
import 'dart:async';

class GameScreen extends StatefulWidget {
  final Map<String, dynamic> gameArgs;

  const GameScreen({Key? key, required this.gameArgs}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int player1Score = 0;
  int player2Score = 0;
  double colorRatio = 0.5;
  bool gameEnded = false;
  bool isGameStarted = false;
  int countdownSeconds = 3;
  
  // Game mode variables
  late final bool isTimeMode;
  late final bool isSinglePlayer;
  late final int timeLimit;
  late final int scoreLimit;
  late final int difficulty;
  int remainingSeconds = 0;
  Timer? gameTimer;
  Timer? countdownTimer;

  // Animation controllers
  late AnimationController _colorAnimationController;
  late Animation<double> _colorAnimation;
  late AnimationController _clickEffectController;
  late Animation<double> _clickEffectAnimation;

  // Click effect positions
  Offset? _lastClickPosition;
  bool _isPlayer1Click = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize game mode
    isTimeMode = widget.gameArgs['mode'] == 'GameMode.timeLimit';
    isSinglePlayer = widget.gameArgs['playerMode'] == 'PlayerMode.singlePlayer';
    timeLimit = widget.gameArgs['timeLimit'] ?? 60;
    scoreLimit = widget.gameArgs['scoreLimit'] ?? 100;
    difficulty = widget.gameArgs['difficulty'] ?? 2;
    remainingSeconds = timeLimit;

    // Start countdown
    startCountdown();
    
    // Color transition animation
    _colorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _colorAnimation = Tween<double>(begin: 0.5, end: 0.5).animate(
      CurvedAnimation(
        parent: _colorAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Click effect animation
    _clickEffectController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _clickEffectAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _clickEffectController,
        curve: Curves.easeOut,
      ),
    );
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdownSeconds > 0) {
          countdownSeconds--;
        } else {
          isGameStarted = true;
          countdownTimer?.cancel();
          
          // Start game timer if in time mode
          if (isTimeMode) {
            gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              setState(() {
                if (remainingSeconds > 0) {
                  remainingSeconds--;
                } else {
                  _endGame();
                }
              });
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    countdownTimer?.cancel();
    _colorAnimationController.dispose();
    _clickEffectController.dispose();
    super.dispose();
  }

  void _endGame() {
    setState(() {
      gameEnded = true;
      gameTimer?.cancel();
    });
  }

  void _updateScore(bool isPlayer1, Offset tapPosition) {
    if (gameEnded || !isGameStarted) return;

    setState(() {
      if (isPlayer1) {
        player1Score++;
      } else {
        player2Score++;
      }

      // Store click position and player for animation
      _lastClickPosition = tapPosition;
      _isPlayer1Click = isPlayer1;

      // Calculate new color ratio (fixed to match click side)
      double newRatio = player1Score / (player1Score + player2Score);
      
      // Update color animation
      _colorAnimation = Tween<double>(
        begin: colorRatio,
        end: newRatio,
      ).animate(CurvedAnimation(
        parent: _colorAnimationController,
        curve: Curves.easeInOut,
      ));
      
      colorRatio = newRatio;
      _colorAnimationController.forward(from: 0.0);
      _clickEffectController.forward(from: 0.0);

      // Check for winner in score mode
      if (!isTimeMode && (player1Score >= scoreLimit || player2Score >= scoreLimit)) {
        _endGame();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isTimeMode 
          ? Text(
              isGameStarted 
                ? _formatTime(remainingSeconds)
                : 'Starting in $countdownSeconds',
              style: GameStyles.timerText,
            )
          : Text('Score to win: $scoreLimit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Animated color split background
          AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              return Row(
                children: [
                  Expanded(
                    flex: (_colorAnimation.value * 100).round(),
                    child: Container(color: Colors.blue[700]),
                  ),
                  Expanded(
                    flex: ((1 - _colorAnimation.value) * 100).round(),
                    child: Container(color: Colors.red[700]),
                  ),
                ],
              );
            },
          ),
          // Click effect overlay
          if (_lastClickPosition != null)
            AnimatedBuilder(
              animation: _clickEffectAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ClickEffectPainter(
                    position: _lastClickPosition!,
                    progress: _clickEffectAnimation.value,
                    color: _isPlayer1Click ? Colors.blue : Colors.red,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          // Game content
          Row(
            children: [
              // Player 1 side
              Expanded(
                child: GestureDetector(
                  onTapDown: (details) => _updateScore(true, details.globalPosition),
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isSinglePlayer ? 'Player' : 'Player 1',
                          style: GameStyles.playerName,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          player1Score.toString(),
                          style: GameStyles.scoreText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Center divider
              Container(
                width: 2,
                color: Colors.white.withOpacity(0.5),
              ),
              // Player 2 side
              Expanded(
                child: GestureDetector(
                  onTapDown: (details) => _updateScore(false, details.globalPosition),
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isSinglePlayer ? 'Computer' : 'Player 2',
                          style: GameStyles.playerName,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          player2Score.toString(),
                          style: GameStyles.scoreText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Countdown overlay
          if (!isGameStarted)
            Container(
              color: Colors.black54,
              child: Center(
                child: Text(
                  countdownSeconds.toString(),
                  style: GameStyles.countdownText,
                ),
              ),
            ),
          // Winner overlay
          if (gameEnded)
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Container(
                  color: Colors.black.withOpacity(0.5 * value),
                  child: Transform.scale(
                    scale: value,
                    child: child,
                  ),
                );
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Winner!',
                      style: GameStyles.titleText,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      player1Score > player2Score 
                        ? (isSinglePlayer ? 'Player' : 'Player 1') 
                        : (isSinglePlayer ? 'Computer' : 'Player 2'),
                      style: GameStyles.winnerText,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Final Score: $player1Score - $player2Score',
                      style: GameStyles.scoreText,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: GameStyles.buttonStyle,
                      child: const Text('Play Again'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ClickEffectPainter extends CustomPainter {
  final Offset position;
  final double progress;
  final Color color;

  ClickEffectPainter({
    required this.position,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity((1 - progress) * 0.3)
      ..style = PaintingStyle.fill;

    final radius = progress * 100.0;
    canvas.drawCircle(position, radius, paint);

    // Draw ripple effect
    final ripplePaint = Paint()
      ..color = color.withOpacity((1 - progress) * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(position, radius * 1.2, ripplePaint);
  }

  @override
  bool shouldRepaint(covariant ClickEffectPainter oldDelegate) {
    return position != oldDelegate.position ||
           progress != oldDelegate.progress ||
           color != oldDelegate.color;
  }
} 