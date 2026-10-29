import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/constants/app_colors.dart';
import 'package:clickbattle/screens/game/game_over_popup.dart';
import 'package:clickbattle/components/game_divider.dart';
import 'package:clickbattle/components/arcade_chrome.dart';
import 'package:clickbattle/components/tap_burst_layer.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'dart:async';
import 'dart:math' show pi, Random, max;

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
  int remainingSeconds = 0;
  Timer? gameTimer;
  Timer? countdownTimer;
  Timer? _robotTimer;

  // Animation controllers
  late AnimationController _colorAnimationController;
  late Animation<double> _colorAnimation;

  // Add pulse animation controller for divider
  late AnimationController _dividerPulseController;
  late Animation<double> _dividerPulseAnimation;

  final TapBurstController _bursts = TapBurstController();
  final Random _random = Random();

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
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
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
    gameTimer?.cancel();
    countdownTimer?.cancel();
    _robotTimer?.cancel();
    _colorAnimationController.dispose();
    _dividerPulseController.dispose();
    _bursts.dispose();
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
    _bursts.spawn(
      position,
      isPlayer1 ? ArcadeChrome.yellow : ArcadeChrome.yellow,
      (_random.nextDouble() - 0.5) * 0.52,
    );
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
      double newRatio =
          totalScore > 0 ? player1Score.toDouble() / totalScore : 0.5;

      double maxChange = 0.08;
      newRatio =
          colorRatio + (newRatio - colorRatio).clamp(-maxChange, maxChange);

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

      if (!isTimeMode &&
          (player1Score >= scoreLimit || player2Score >= scoreLimit)) {
        _endGame();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  bool get _timerUrgent =>
      isTimeMode && isGameStarted && remainingSeconds <= 3 && remainingSeconds > 0;

  String get _hudValue {
    if (isTimeMode) {
      return isGameStarted
          ? _formatTime(remainingSeconds)
          : countdownSeconds.toString();
    }
    return '${scoreLimit - max(player1Score, player2Score)}';
  }

  @override
  Widget build(BuildContext context) {
    _appManager = Provider.of<AppManager>(context);
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.075;
    final blue = _appManager.player1Color;
    final red = _appManager.player2Color;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.comicNavy,
      body: Stack(
        children: [
          // VISUAL territory — continuous heights (soft, no integer flex snap)
          AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;
                  final topH = ((1 - _colorAnimation.value) * h)
                      .clamp(h * 0.08, h * 0.92);
                  final bottomH = h - topH;
                  return Stack(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: topH,
                            width: double.infinity,
                            child: ComicArena(color: red, alignTop: true),
                          ),
                          SizedBox(
                            height: bottomH,
                            width: double.infinity,
                            child: ComicArena(color: blue, alignTop: false),
                          ),
                        ],
                      ),
                      Positioned(
                        top: topH - 14,
                        left: 0,
                        right: 0,
                        child: GameDivider(
                          ratio: _colorAnimation.value,
                          pulseAnimation: _dividerPulseAnimation,
                          player1Color: blue,
                          player2Color: red,
                          height: 28,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          TapBurstLayer(controller: _bursts),
          // HUD
          if (isSinglePlayer)
            Positioned(
              top: topPad + 10,
              left: 0,
              right: 0,
              child: Center(
                child: ComicTimerChip(
                  icon: isTimeMode ? Icons.timer : Icons.flag,
                  value: _hudValue,
                  urgent: _timerUrgent,
                  pulse: isGameStarted && isTimeMode,
                ),
              ),
            )
          else ...[
            Positioned(
              left: screenSize.width * 0.05,
              top: screenSize.height * 0.5 + 14,
              child: ComicTimerChip(
                icon: isTimeMode ? Icons.timer : Icons.flag,
                value: _hudValue,
                urgent: _timerUrgent,
                pulse: isGameStarted && isTimeMode,
              ),
            ),
            Positioned(
              left: screenSize.width * 0.05,
              bottom: screenSize.height * 0.5 + 14,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(pi),
                child: ComicTimerChip(
                  icon: isTimeMode ? Icons.timer : Icons.flag,
                  value: _hudValue,
                  urgent: _timerUrgent,
                  pulse: isGameStarted && isTimeMode,
                ),
              ),
            ),
          ],
          Positioned(
            right: screenSize.width * 0.06,
            top: isSinglePlayer
                ? screenSize.height * 0.22
                : screenSize.height * 0.5 + 10,
            child: isSinglePlayer
                ? ScoreDisplay(
                    score: player2Score,
                    color: Colors.white,
                    isAnimating: true,
                  )
                : ScoreDisplay(
                    score: player1Score,
                    color: Colors.white,
                    isAnimating: true,
                  ),
          ),
          Positioned(
            right: screenSize.width * 0.06,
            bottom: isSinglePlayer
                ? screenSize.height * 0.22
                : screenSize.height * 0.5 + 10,
            child: isSinglePlayer
                ? ScoreDisplay(
                    score: player1Score,
                    color: Colors.white,
                    isAnimating: true,
                  )
                : Transform(
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
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      _updateScore(true, details.globalPosition);
                      _player1ClickController
                          .forward(from: 0.0)
                          .then((_) => _player1ClickController.reverse());
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const IgnorePointer(child: _TapRings()),
                        Center(
                          child: PlayerIcon(
                            isRobot: false,
                            isTopPlayer: false,
                            iconSize: iconSize,
                            scaleAnimation: _player1ClickScale,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isGameStarted)
            Container(
              color: Colors.black.withOpacity(0.55),
              child: Center(
                child: Text(
                  countdownSeconds > 0 ? countdownSeconds.toString() : 'GO!',
                  style: ArcadeChrome.display(
                    size: 72,
                    color: countdownSeconds > 0
                        ? Colors.white
                        : ArcadeChrome.yellow,
                    outline: ArcadeChrome.red,
                    outlineWidth: 4,
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

class _TapRings extends StatelessWidget {
  const _TapRings();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _RingPainter(), size: Size.infinite);
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.55);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.18);
    canvas.drawCircle(c, 48, paint);
    canvas.drawCircle(c, 78, paint);
    canvas.drawCircle(c, 112, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    final ring = isRobot ? ArcadeChrome.red : ArcadeChrome.yellow;

    return ScaleTransition(
      scale: scaleAnimation,
      child: Container(
        width: iconSize * 2.2,
        height: iconSize * 2.2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: ring, width: 4),
          boxShadow: const [
            BoxShadow(
              color: ArcadeChrome.ink,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: RotatedBox(
            quarterTurns: (isTopPlayer && !isRobot) ? 2 : 0,
            child: Icon(
              isRobot ? Icons.smart_toy_rounded : appManager.fingerIcon,
              size: iconSize,
              color: isRobot ? ArcadeChrome.red : ArcadeChrome.blue,
            ),
          ),
        ),
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

class _ScoreDisplayState extends State<ScoreDisplay>
    with SingleTickerProviderStateMixin {
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
          size: 52,
          color: widget.color,
          outline: Colors.black,
          outlineWidth: 3,
        ),
      ),
    );
  }
}
