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

  // Particle groups for multiple simultaneous animations
  final List<ParticleGroup> _particleGroups = [];
  final Random _random = Random();

  // Replace pulse controllers with click controllers
  late final AnimationController _player1ClickController;
  late final AnimationController _player2ClickController;
  late final Animation<double> _player1ClickScale;
  late final Animation<double> _player2ClickScale;

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

    // Initialize click animations
    _player1ClickController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _player2ClickController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _player1ClickScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _player1ClickController,
        curve: Curves.easeInOutBack,
      ),
    );

    _player2ClickScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _player2ClickController,
        curve: Curves.easeInOutBack,
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
    // Dispose all particle group controllers
    for (final group in _particleGroups) {
      group.animationController.dispose();
    }
    _player1ClickController.dispose();
    _player2ClickController.dispose();
    super.dispose();
  }

  void _endGame() {
    setState(() {
      gameEnded = true;
      gameTimer?.cancel();
    });
  }

  void _createSparkEffect(bool isPlayer1, Offset position) {
    final List<SparkParticle> particles = [];
    
    // Player-specific colors
    final mainColor = isPlayer1 
        ? Colors.blue[400]!  // Player 1: Blue
        : Colors.red[400]!;  // Player 2: Red
    
    // Create circular ring particles
    for (int i = 0; i < 12; i++) {
      final angle = (i * pi / 6);  // Evenly distributed in a circle
      
      particles.add(SparkParticle(
        position: position,
        angle: angle,
        velocity: 2.0,
        color: i % 2 == 0 ? Colors.white : mainColor,  // Alternating colors
        type: ParticleType.circle,
        size: 3.0,
      ));
    }
    
    // Create a new animation controller for this particle group
    final controller = AnimationController(
      duration: const Duration(milliseconds: 1000),  // Slightly longer for spiral effect
      vsync: this,
    );

    // Create a curved animation for smoother motion
    final curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCirc,  // Smooth deceleration
    );

    // Create a new particle group and add it to the list
    final particleGroup = ParticleGroup(
      particles: particles,
      animationController: controller,
      isPlayer1: isPlayer1,
    );
    
    setState(() {
      _particleGroups.add(particleGroup);
    });

    // Start the animation and remove the group when done
    controller.forward().then((_) {
      setState(() {
        _particleGroups.remove(particleGroup);
      });
      controller.dispose();
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

      _createSparkEffect(isPlayer1, tapPosition);

      double totalScore = (player1Score + player2Score).toDouble();
      double newRatio = totalScore > 0 
          ? player1Score.toDouble() / totalScore  // Using player1Score instead of player2Score
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
          // Particle effects overlay
          Stack(
            children: _particleGroups.map((group) => AnimatedBuilder(
              animation: group.animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: SparkPainter(
                    particles: group.particles,
                    progress: group.animation.value,
                  ),
                  size: Size.infinite,
                );
              },
            )).toList(),
          ),
          // Timer overlay (left-center) - For P1 (Blue area)
          Positioned(
            left: screenSize.width * 0.04,
            top: screenSize.height * 0.5 + 10,
            child: GameInfoDisplay(
              icon: isTimeMode ? Icons.timer : Icons.flag,
              value: isTimeMode 
                ? (isGameStarted 
                    ? _formatTime(remainingSeconds)
                    : countdownSeconds.toString())
                : '${scoreLimit - max(player1Score, player2Score)}',
              color: Colors.blue[400]!,
              isAnimating: isGameStarted,
            ),
          ),
          // Timer overlay (left-center) - For P2 (Red area)
          Positioned(
            left: screenSize.width * 0.04,
            bottom: screenSize.height * 0.5 + 10,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(pi),
              child: GameInfoDisplay(
                icon: isTimeMode ? Icons.timer : Icons.flag,
                value: isTimeMode 
                  ? (isGameStarted 
                      ? _formatTime(remainingSeconds)
                      : countdownSeconds.toString())
                  : '${scoreLimit - max(player1Score, player2Score)}',
                color: Colors.red[400]!,
                isAnimating: isGameStarted,
              ),
            ),
          ),
          // P1 Score (right-center, Blue area)
          Positioned(
            right: screenSize.width * 0.04,
            top: screenSize.height * 0.5 + 10,
            child: ScoreDisplay(
              score: player1Score,
              color: Colors.blue[400]!,
              isAnimating: true,
            ),
          ),
          // P2 Score (right-center, Red area)
          Positioned(
            right: screenSize.width * 0.04,
            bottom: screenSize.height * 0.5 + 10,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(pi),
              child: ScoreDisplay(
                score: player2Score,
                color: Colors.red[400]!,
                isAnimating: true,
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
                    onTapDown: isSinglePlayer ? null : (details) {
                      _updateScore(false, details.globalPosition);
                      // Scale up the opponent's area when clicked
                      _player2ClickController.forward(from: 0.0).then((_) {
                        _player2ClickController.reverse();
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.transparent,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _colorAnimation,
                          builder: (context, child) {
                            // Inverse scale for top player (smaller when bottom player scores more)
                            final dynamicScale = 1.0 + (0.5 - _colorAnimation.value).clamp(-0.3, 0.3);
                            return Transform.scale(
                              scale: dynamicScale,
                              child: PlayerIcon(
                                isRobot: isSinglePlayer,
                                isTopPlayer: true,
                                iconSize: iconSize,
                                scaleAnimation: _player2ClickScale,
                                color: Colors.red[400]!,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                // Center divider
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                // Player 1 (bottom)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      _updateScore(true, details.globalPosition);
                      // Scale up the opponent's area when clicked
                      _player1ClickController.forward(from: 0.0).then((_) {
                        _player1ClickController.reverse();
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.transparent,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _colorAnimation,
                          builder: (context, child) {
                            // Direct scale for bottom player (larger when scoring more)
                            final dynamicScale = 1.0 + (_colorAnimation.value - 0.5).clamp(-0.3, 0.3);
                            return Transform.scale(
                              scale: dynamicScale,
                              child: PlayerIcon(
                                isRobot: false,
                                isTopPlayer: false,
                                iconSize: iconSize,
                                scaleAnimation: _player1ClickScale,
                                color: Colors.blue[400]!,
                              ),
                            );
                          },
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

enum ParticleType {
  circle,
}

class SparkParticle {
  Offset position;
  final double angle;
  final double velocity;
  final Color color;
  final ParticleType type;
  final double size;
  final double spiralFactor;  // Controls how much spiral effect is applied

  SparkParticle({
    required this.position,
    required this.angle,
    required this.velocity,
    required this.color,
    required this.type,
    required this.size,
  }) : spiralFactor = 1.5;  // Fixed spiral factor for consistent effect

  void update(double progress) {
    // Combine circular expansion with spiral motion
    final radius = velocity * 100 * progress;
    final spiralAngle = angle + (progress * pi * spiralFactor);  // Spiral rotation
    final dx = cos(spiralAngle) * radius;
    final dy = sin(spiralAngle) * radius;
    position = position.translate(dx * 0.015, dy * 0.015);
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
      
      // Enhanced fade out effect
      final opacity = (1 - progress) * 0.9;  // Slightly increased opacity
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill
        ..strokeWidth = 2.0;

      // Draw expanding circle with slight trail effect
      final trailPaint = Paint()
        ..color = particle.color.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      // Draw main particle
      canvas.drawCircle(
        particle.position, 
        particle.size * (1 - progress * 0.3),  // Reduced size reduction
        paint
      );

      // Draw subtle trail
      canvas.drawCircle(
        particle.position,
        particle.size * (1 + progress * 0.5),
        trailPaint
      );

      // Draw connecting lines between adjacent particles if they're close enough
      if (particles.indexOf(particle) > 0) {
        final prevParticle = particles[particles.indexOf(particle) - 1];
        final distance = (particle.position - prevParticle.position).distance;
        
        if (distance < 60) {  // Increased connection distance
          canvas.drawLine(
            prevParticle.position,
            particle.position,
            paint..strokeWidth = 0.5  // Thinner lines
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(SparkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class ParticleGroup {
  final List<SparkParticle> particles;
  final AnimationController animationController;
  final Animation<double> animation;
  final bool isPlayer1;

  ParticleGroup({
    required this.particles,
    required AnimationController animationController,
    required this.isPlayer1,
  }) : this.animationController = animationController,
       this.animation = animationController;
}

class PlayerIcon extends StatelessWidget {
  final bool isRobot;
  final bool isTopPlayer;
  final double iconSize;
  final Animation<double> scaleAnimation;
  final Color color;

  const PlayerIcon({
    Key? key,
    required this.isRobot,
    required this.isTopPlayer,
    required this.iconSize,
    required this.scaleAnimation,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: Container(
        width: iconSize * 2,
        height: iconSize * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.15),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background glow
              Container(
                width: iconSize * 1.2,
                height: iconSize * 1.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                ),
              ),
              // Click icon
              RotatedBox(
                quarterTurns: (isTopPlayer && !isRobot) ? 2 : 0,
                child: Icon(
                  isRobot 
                    ? Icons.smart_toy_rounded 
                    : Icons.touch_app_rounded,
                  size: iconSize,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameInfoDisplay extends StatefulWidget {
  final IconData icon;
  final String value;
  final Color color;
  final bool isAnimating;

  const GameInfoDisplay({
    Key? key,
    required this.icon,
    required this.value,
    required this.color,
    required this.isAnimating,
  }) : super(key: key);

  @override
  _GameInfoDisplayState createState() => _GameInfoDisplayState();
}

class _GameInfoDisplayState extends State<GameInfoDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    if (widget.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GameInfoDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.padding(context) * 0.6,
        vertical: AppDimensions.padding(context) * 0.4,
      ),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: widget.color.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Icon(
              widget.icon,
              color: Colors.white.withOpacity(0.95),
              size: 22,
            ),
          ),
          SizedBox(width: 8),
          Text(
            widget.value,
            style: GameStyles.timerText(context).copyWith(
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w600,
              fontSize: AppDimensions.headingFontSize(context) * 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreDisplay extends StatefulWidget {
  final int score;
  final Color color;
  final bool isAnimating;

  const ScoreDisplay({
    Key? key,
    required this.score,
    required this.color,
    required this.isAnimating,
  }) : super(key: key);

  @override
  _ScoreDisplayState createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  int _lastScore = 0;

  @override
  void initState() {
    super.initState();
    _lastScore = widget.score;
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != _lastScore) {
      _bounceController.forward(from: 0.0);
      _lastScore = widget.score;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.padding(context) * 0.8,
        vertical: AppDimensions.padding(context) * 0.5,
      ),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: widget.color.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: ScaleTransition(
        scale: _bounceAnimation,
        child: Text(
          widget.score.toString(),
          style: GameStyles.scoreText(context).copyWith(
            color: Colors.white.withOpacity(0.95),
            fontSize: AppDimensions.headingFontSize(context) * 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
} 