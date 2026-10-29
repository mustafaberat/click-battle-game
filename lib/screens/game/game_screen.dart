import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/analytics/analytics.dart';
import 'package:clickbattle/screens/game/game_over_popup.dart';
import 'package:clickbattle/components/game_divider.dart';
import 'package:clickbattle/components/arcade_chrome.dart';
import 'package:clickbattle/services/app_manager.dart';
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
  late AppManager _appManager;
  
  // Game mode variables
  late final bool isTimeMode;
  late final bool isSinglePlayer;
  late final int timeLimit;
  late final int scoreLimit;
  late final int difficulty;
  late final bool isRematch;
  int remainingSeconds = 0;
  DateTime? _matchStartedAt;
  bool _analyticsEndLogged = false;
  Timer? gameTimer;
  Timer? countdownTimer;
  Timer? _robotTimer;

  // Animation controllers
  late AnimationController _colorAnimationController;
  late Animation<double> _colorAnimation;

  // Add pulse animation controller for divider
  late AnimationController _dividerPulseController;
  late Animation<double> _dividerPulseAnimation;

  // Particle groups for multiple simultaneous animations
  final List<ParticleGroup> _particleGroups = [];

  // Replace pulse controllers with click controllers
  late final AnimationController _player1ClickController;
  late final AnimationController _player2ClickController;
  late final Animation<double> _player1ClickScale;
  late final Animation<double> _player2ClickScale;

  @override
  void initState() {
    super.initState();
    
    _appManager = Provider.of<AppManager>(context, listen: false);
    
    // Initialize game mode
    isTimeMode = widget.gameArgs['mode'] == 'GameMode.timeLimit';
    isSinglePlayer = widget.gameArgs['playerMode'] == 'PlayerMode.singlePlayer';
    timeLimit = widget.gameArgs['timeLimit'] ?? 60;
    scoreLimit = widget.gameArgs['scoreLimit'] ?? 100;
    difficulty = widget.gameArgs['difficulty'] ?? 2;
    isRematch = widget.gameArgs['rematch'] == true;
    remainingSeconds = timeLimit;

    // Start countdown
    startCountdown();
    
    // Color transition — soft, continuous (avoid integer flex jumps)
    _colorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 520),
      vsync: this,
    );
    _colorAnimation = Tween<double>(begin: 0.5, end: 0.5).animate(
      CurvedAnimation(
        parent: _colorAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Initialize divider pulse animation
    _dividerPulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _dividerPulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_dividerPulseController);

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
          _matchStartedAt = DateTime.now();
          countdownTimer?.cancel();
          _logGameStart();
          
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

  /// Taps/sec curve: 1→1 … 8→8, 9→12, 10→16 (near-impossible).
  double get _robotTapsPerSecond {
    if (difficulty >= 10) return 16;
    if (difficulty >= 9) return 12;
    return difficulty.clamp(1, 8).toDouble();
  }

  void _startRobotClicks() {
    final intervalMs = (1000 / _robotTapsPerSecond).round().clamp(40, 1000);
    final random = Random();

    _robotTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!gameEnded && isGameStarted) {
        final h = MediaQuery.of(context).size.height;
        final w = MediaQuery.of(context).size.width;
        // Robot always taps its FIXED half (top 50%) — never the visual strip only
        final robotClickPosition = Offset(
          random.nextDouble() * w,
          random.nextDouble() * (h * 0.5 - 40).clamp(20, h * 0.5) + 12,
        );
        _updateScore(false, robotClickPosition);

        if (difficulty >= 9 && random.nextDouble() < 0.22) {
          Future.delayed(const Duration(milliseconds: 40), () {
            if (!mounted || gameEnded || !isGameStarted) return;
            _updateScore(
              false,
              Offset(
                random.nextDouble() * w,
                random.nextDouble() * (h * 0.5 - 40).clamp(20, h * 0.5) + 12,
              ),
            );
          });
        }
      } else {
        _robotTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    if (!_analyticsEndLogged) {
      _logMatchFinished(quit: true);
    }
    gameTimer?.cancel();
    countdownTimer?.cancel();
    _robotTimer?.cancel();
    _colorAnimationController.dispose();
    _dividerPulseController.dispose();
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
    _logMatchFinished(quit: false);
  }

  void _logGameStart() {
    AnalyticsService.instance.logGameStart(
      isSinglePlayer: isSinglePlayer,
      isTimeMode: isTimeMode,
      timeLimit: timeLimit,
      scoreLimit: scoreLimit,
      difficulty: difficulty,
      rematch: isRematch,
    );
  }

  void _logMatchFinished({required bool quit}) {
    if (_analyticsEndLogged) return;
    _analyticsEndLogged = true;
    final durationSec = _matchStartedAt == null
        ? 0
        : DateTime.now().difference(_matchStartedAt!).inSeconds;
    if (quit) {
      AnalyticsService.instance.logGameQuit(
        isSinglePlayer: isSinglePlayer,
        isTimeMode: isTimeMode,
        timeLimit: timeLimit,
        scoreLimit: scoreLimit,
        difficulty: difficulty,
        player1Score: player1Score,
        player2Score: player2Score,
        durationSec: durationSec,
        duringCountdown: !isGameStarted,
      );
    } else {
      AnalyticsService.instance.logGameEnd(
        isSinglePlayer: isSinglePlayer,
        isTimeMode: isTimeMode,
        timeLimit: timeLimit,
        scoreLimit: scoreLimit,
        difficulty: difficulty,
        player1Score: player1Score,
        player2Score: player2Score,
        durationSec: durationSec,
      );
    }
  }

  void _createSparkEffect(bool isPlayer1, Offset position) {
    final List<SparkParticle> particles = [];
    final mainColor =
        isPlayer1 ? _appManager.player1Color : _appManager.player2Color;

    // Short, restrained tap spark (no energy trails)
    for (int i = 0; i < 6; i++) {
      particles.add(SparkParticle(
        position: position,
        angle: i * pi / 3,
        velocity: 1.4,
        color: i.isEven ? _appManager.white : mainColor,
        type: ParticleType.circle,
        size: 2.2,
      ));
    }

    final controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
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
      double oldRatio = colorRatio;
      double newRatio = totalScore > 0 
          ? player1Score.toDouble() / totalScore
          : 0.5;
      
      double maxChange = 0.08;
      newRatio = colorRatio + (newRatio - colorRatio).clamp(-maxChange, maxChange);
      
      // Check if there's a change in who's leading or a significant lead change
      bool significantChange = (oldRatio < 0.5 && newRatio > 0.5) || 
                              (oldRatio > 0.5 && newRatio < 0.5) || 
                              (newRatio - oldRatio).abs() > 0.05;
      
      if (significantChange) {
        // Pulse the divider to emphasize territory change
        _dividerPulseController.forward(from: 0.0);
      }
      
      _colorAnimation = Tween<double>(
        begin: _colorAnimationController.isAnimating
            ? _colorAnimation.value
            : colorRatio,
        end: newRatio,
      ).animate(CurvedAnimation(
        parent: _colorAnimationController,
        curve: Curves.easeOutCubic,
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
    _appManager = Provider.of<AppManager>(context);
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.075;
    final blue = _appManager.player1Color;
    final red = _appManager.player2Color;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // VISUAL territory — continuous heights (soft, no integer flex snap)
          AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;
                  const lineH = 3.0;
                  final topH = ((1 - _colorAnimation.value) * (h - lineH))
                      .clamp(h * 0.08, h * 0.92);
                  final bottomH = h - lineH - topH;
                  return Column(
                    children: [
                      SizedBox(
                        height: topH,
                        width: double.infinity,
                        child: _NeonArena(color: red, alignTop: true),
                      ),
                      Container(
                        height: lineH,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              red.withOpacity(0.25),
                              ArcadeChrome.yellow,
                              blue.withOpacity(0.25),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ArcadeChrome.yellow.withOpacity(0.45),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: bottomH,
                        width: double.infinity,
                        child: _NeonArena(color: blue, alignTop: false),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // Short tap sparks only
          ..._particleGroups.map(
            (group) => AnimatedBuilder(
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
            ),
          ),
          // Mirrored HUD — always at geometric mid (fixed halves)
          Positioned(
            left: screenSize.width * 0.05,
            top: screenSize.height * 0.5 + 14,
            child: GameInfoDisplay(
              icon: isTimeMode ? Icons.timer : Icons.flag,
              value: isTimeMode
                  ? (isGameStarted
                      ? _formatTime(remainingSeconds)
                      : countdownSeconds.toString())
                  : '${scoreLimit - max(player1Score, player2Score)}',
              color: blue,
              isAnimating: isGameStarted,
            ),
          ),
          Positioned(
            left: screenSize.width * 0.05,
            bottom: screenSize.height * 0.5 + 14,
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
                color: red,
                isAnimating: isGameStarted,
              ),
            ),
          ),
          Positioned(
            right: screenSize.width * 0.06,
            top: screenSize.height * 0.5 + 10,
            child: ScoreDisplay(
              score: player1Score,
              color: Colors.white,
              isAnimating: true,
            ),
          ),
          Positioned(
            right: screenSize.width * 0.06,
            bottom: screenSize.height * 0.5 + 10,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(pi),
              child: ScoreDisplay(
                score: player2Score,
                color: Colors.white,
                isAnimating: true,
              ),
            ),
          ),
          // HIT ZONES — always 50/50. Visual territory must NEVER shrink taps.
          AbsorbPointer(
            absorbing: !isGameStarted,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: isSinglePlayer
                        ? null
                        : (details) {
                            _updateScore(false, details.globalPosition);
                            _player2ClickController
                                .forward(from: 0.0)
                                .then((_) => _player2ClickController.reverse());
                          },
                    child: Center(
                      child: PlayerIcon(
                        isRobot: isSinglePlayer,
                        isTopPlayer: true,
                        iconSize: iconSize,
                        scaleAnimation: _player2ClickScale,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Geometric mid — pulse only (visual frontier is elsewhere)
                GameDivider(
                  ratio: 0.5,
                  pulseAnimation: _dividerPulseAnimation,
                  player1Color: blue,
                  player2Color: red,
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      _updateScore(true, details.globalPosition);
                      _player1ClickController
                          .forward(from: 0.0)
                          .then((_) => _player1ClickController.reverse());
                    },
                    child: Center(
                      child: PlayerIcon(
                        isRobot: false,
                        isTopPlayer: false,
                        iconSize: iconSize,
                        scaleAnimation: _player1ClickScale,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isGameStarted)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Text(
                  countdownSeconds > 0
                      ? countdownSeconds.toString()
                      : 'GO!',
                  style: ArcadeChrome.display(
                    size: 72,
                    color: countdownSeconds > 0
                        ? Colors.white
                        : ArcadeChrome.yellow,
                    outline: ArcadeChrome.red,
                  ),
                ),
              ),
            ),
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
    final radius = velocity * 48 * progress;
    final dx = cos(angle) * radius;
    final dy = sin(angle) * radius;
    position = position.translate(dx * 0.02, dy * 0.02);
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
      final opacity = (1 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.position,
        particle.size * (1 - progress * 0.5),
        paint,
      );
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

class _NeonArena extends StatelessWidget {
  final Color color;
  final bool alignTop;

  const _NeonArena({required this.color, required this.alignTop});

  @override
  Widget build(BuildContext context) {
    final deep = Color.lerp(color, const Color(0xFF050508), 0.42)!;
    final edge = Color.lerp(color, Colors.white, 0.12)!;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: alignTop ? Alignment.topCenter : Alignment.bottomCenter,
              end: alignTop ? Alignment.bottomCenter : Alignment.topCenter,
              colors: [deep, color, edge],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.05,
              colors: [
                color.withOpacity(0.35),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Soft side vignette so it doesn't read as a flat paint fill
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withOpacity(0.28),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.28),
              ],
              stops: const [0.0, 0.18, 0.82, 1.0],
            ),
          ),
        ),
      ],
    );
  }
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
    final appManager = Provider.of<AppManager>(context);

    return ScaleTransition(
      scale: scaleAnimation,
      child: Container(
        width: iconSize * 2.1,
        height: iconSize * 2.1,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.35),
          border: Border.all(color: ArcadeChrome.yellow, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: ArcadeChrome.yellow.withOpacity(0.25),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: RotatedBox(
            quarterTurns: (isTopPlayer && !isRobot) ? 2 : 0,
            child: Icon(
              isRobot ? Icons.smart_toy_rounded : appManager.fingerIcon,
              size: iconSize,
              color: Colors.white.withOpacity(0.95),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ArcadeChrome.yellow.withOpacity(0.7), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          ScaleTransition(
            scale: widget.isAnimating
                ? _pulseAnimation
                : const AlwaysStoppedAnimation(1.0),
            child: Text(
              widget.value,
              style: ArcadeChrome.ui(
                size: 14,
                letterSpacing: 0.8,
              ),
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
    return ScaleTransition(
      scale: _bounceAnimation,
      child: Text(
        widget.score.toString(),
        style: ArcadeChrome.display(
          size: 44,
          color: widget.color,
          outline: Colors.black,
        ),
      ),
    );
  }
} 