import 'package:flutter/material.dart';
import 'package:clickbattle/screens/game/game_styles.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/screens/game/game_over_popup.dart';
import 'dart:async';
import 'dart:math' show pi, Random, cos, sin, max;

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
  Timer? _robotTimer;

  // Animation controllers
  late AnimationController _colorAnimationController;
  late Animation<double> _colorAnimation;
  late AnimationController _clickEffectController;
  late Animation<double> _clickEffectAnimation;

  // Click effect positions
  Offset? _lastClickPosition;
  bool _isPlayer1Click = false;

  final List<SparkParticle> _particles = [];
  final Random _random = Random();

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

    // Replace click effect animation with new spark animation
    _clickEffectController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _clickEffectController.addListener(() {
      if (_clickEffectController.isAnimating) {
        setState(() {});
      }
    });
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

          // Start robot clicks in single player mode
          if (isSinglePlayer && isGameStarted) {
            _startRobotClicks();
          }
        }
      });
    });
  }

  void _startRobotClicks() {
    final interval = 1000 ~/ difficulty;
    final random = Random();
    
    _robotTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (!gameEnded && isGameStarted) {
        // Generate random position within the top half of the screen
        final robotClickPosition = Offset(
          random.nextDouble() * MediaQuery.of(context).size.width,
          random.nextDouble() * (MediaQuery.of(context).size.height / 2 - 50) + 25,
        );
        _updateScore(false, robotClickPosition);
      } else {
        _robotTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    countdownTimer?.cancel();
    _robotTimer?.cancel();
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

  void _createSparkEffect(bool isPlayer1, Offset position) {
    _lastClickPosition = position;
    _isPlayer1Click = isPlayer1;
    _particles.clear();
    
    // Player 1 (blue) clicks create red and white sparks
    // Player 2 (red) clicks create blue and white sparks
    final colors = isPlayer1 
        ? [Colors.red[700]!, Colors.white, Colors.red[700]!, Colors.white]
        : [Colors.blue[700]!, Colors.white, Colors.blue[700]!, Colors.white];
    
    for (int i = 0; i < 20; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final velocity = 2.0 + _random.nextDouble() * 3.0;
      final color = colors[_random.nextInt(4)];

      _particles.add(SparkParticle(
        position: position,
        angle: angle,
        velocity: velocity,
        color: color,
      ));
    }
    
    _clickEffectController.forward(from: 0.0);
  }

  void _updateScore(bool isPlayer1, Offset tapPosition) {
    if (gameEnded || !isGameStarted) return;

    setState(() {
      if (isPlayer1) {
        player1Score++;
      } else {
        player2Score++;
      }

      _createSparkEffect(isPlayer1, tapPosition);

      double totalScore = (player1Score + player2Score).toDouble();
      double newRatio = totalScore > 0 
          ? player1Score.toDouble() / totalScore
          : 0.5;
      
      double maxChange = 0.1;
      newRatio = colorRatio + (newRatio - colorRatio).clamp(-maxChange, maxChange);
      
      _colorAnimation = Tween<double>(
        begin: colorRatio,
        end: newRatio,
      ).animate(CurvedAnimation(
        parent: _colorAnimationController,
        curve: Curves.easeInOut,
      ));
      
      colorRatio = newRatio;
      _colorAnimationController.forward(from: 0.0);

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
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.08;

    return Scaffold(
      body: Stack(
        children: [
          // Animated color split background
          AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  Expanded(
                    flex: ((1 - _colorAnimation.value) * 100).round(),
                    child: Container(color: Colors.red[700]),
                  ),
                  Container(
                    height: 1,
                    color: Colors.white,
                  ),
                  Expanded(
                    flex: (_colorAnimation.value * 100).round(),
                    child: Container(color: Colors.blue[700]),
                  ),
                ],
              );
            },
          ),
          // Replace click effect overlay
          if (_lastClickPosition != null)
            CustomPaint(
              painter: SparkPainter(
                particles: _particles,
                progress: _clickEffectController.value,
              ),
              size: Size.infinite,
            ),
          // Timer overlay (left)
          Positioned(
            left: screenSize.width * 0.02,
            top: screenSize.height * 0.5 - 50,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding(context) * 0.5,
                vertical: AppDimensions.padding(context) * 0.75,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
              ),
              child: RotatedBox(
                quarterTurns: 3,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isTimeMode 
                        ? (isGameStarted 
                            ? '${remainingSeconds ~/ 60}'
                            : countdownSeconds.toString())
                        : '${scoreLimit - max(player1Score, player2Score)}',
                      style: GameStyles.timerText(context),
                    ),
                    SizedBox(width: 2),
                    Text(
                      isTimeMode && isGameStarted ? ':' : '',
                      style: GameStyles.timerText(context),
                    ),
                    SizedBox(width: 2),
                    if (isTimeMode && isGameStarted) Text(
                      '${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                      style: GameStyles.timerText(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Score overlay (right)
          Positioned(
            right: screenSize.width * 0.02,
            top: screenSize.height * 0.5 - 50,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding(context) * 0.5,
                vertical: AppDimensions.padding(context) * 0.75,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
              ),
              child: RotatedBox(
                quarterTurns: 3,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotatedBox(
                      quarterTurns: 2,
                      child: Text(
                        player2Score.toString(),
                        style: GameStyles.scoreText(context).copyWith(
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    RotatedBox(
                      quarterTurns: 2,
                      child: Text(
                        '|',
                        style: GameStyles.scoreText(context),
                      ),
                    ),
                    SizedBox(width: 8),
                    RotatedBox(
                      quarterTurns: 2,
                      child: Text(
                        player1Score.toString(),
                        style: GameStyles.scoreText(context).copyWith(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Game content
          AbsorbPointer(
            absorbing: !isGameStarted,
            child: Column(
              children: [
                // Player 2 (top) / Robot
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: isSinglePlayer ? null : (details) => _updateScore(false, details.globalPosition),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.transparent,
                      child: Center(
                        child: RotatedBox(
                          quarterTurns: isSinglePlayer ? 0 : 2,
                          child: Icon(
                            isSinglePlayer ? Icons.smart_toy : Icons.person,
                            size: iconSize,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Center divider
                Container(
                  height: 1,
                  color: Colors.white,
                ),
                // Player 1 (bottom)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) => _updateScore(true, details.globalPosition),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.transparent,
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: iconSize,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Countdown overlay
          if (!isGameStarted)
            Container(
              color: Colors.black26,
              child: Center(
                child: Text(
                  countdownSeconds.toString(),
                  style: GameStyles.countdownText(context),
                ),
              ),
            ),
          // Game over overlay
          if (gameEnded)
            GameOverPopup(
              player1Score: player1Score,
              player2Score: player2Score,
              isSinglePlayer: isSinglePlayer,
              gameArgs: widget.gameArgs,
            ),
        ],
      ),
    );
  }
}

class SparkParticle {
  Offset position;
  final double angle;
  final double velocity;
  final Color color;

  SparkParticle({
    required this.position,
    required this.angle,
    required this.velocity,
    required this.color,
  });

  void update(double progress) {
    final dx = cos(angle) * velocity * progress * 100;
    final dy = sin(angle) * velocity * progress * 100;
    position = position.translate(dx, dy);
  }
}

class SparkPainter extends CustomPainter {
  final List<SparkParticle> particles;
  final double progress;

  SparkPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(progress);
      
      final paint = Paint()
        ..color = particle.color.withOpacity((1 - progress) * 0.8)
        ..style = PaintingStyle.fill
        ..strokeWidth = 2.0;

      // Draw particle trail
      final path = Path();
      final trailLength = 10.0 * (1 - progress);
      final endPoint = particle.position;
      final startPoint = Offset(
        endPoint.dx - cos(particle.angle) * trailLength,
        endPoint.dy - sin(particle.angle) * trailLength,
      );

      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(endPoint.dx, endPoint.dy);

      canvas.drawPath(path, paint);

      // Draw sparkle
      final sparkSize = 3.0 * (1 - progress);
      canvas.drawCircle(particle.position, sparkSize, paint);
    }
  }

  @override
  bool shouldRepaint(SparkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
} 