import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/constants/app_colors.dart';
import 'package:clickbattle/constants/app_images.dart';
import 'package:clickbattle/screens/game/game_over_popup.dart';
import 'package:clickbattle/components/game_divider.dart';
import 'package:clickbattle/components/arcade_chrome.dart';
import 'package:clickbattle/components/tap_burst_layer.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:math' show pi, Random, max;

class GameScreen extends StatefulWidget {
  final Map<String, dynamic> gameArgs;

  const GameScreen({Key? key, required this.gameArgs}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

/// A tap whose score is already counted, waiting for its FX on the next frame.
class _PendingTap {
  final Offset position;
  final int atMs;

  const _PendingTap(this.position, this.atMs);
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  /// Scores live in notifiers so a tap only rebuilds the score widgets,
  /// never the whole screen.
  final ValueNotifier<int> _p1Score = ValueNotifier<int>(0);
  final ValueNotifier<int> _p2Score = ValueNotifier<int>(0);
  final ValueNotifier<int> _remaining = ValueNotifier<int>(0);

  /// Logical territory target (0..1, share of player 1).
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
  Timer? gameTimer;
  Timer? countdownTimer;
  Timer? _robotTimer;

  /// Territory animation: one controller, value == displayed ratio. Each new
  /// target uses animateTo(), continuing from the current value (no new
  /// Tween/CurvedAnimation objects per tap, nothing restarts from 0).
  late final AnimationController _ratioController;

  late final AnimationController _dividerPulseController;
  late final Animation<double> _dividerPulseAnimation;

  final TapBurstController _bursts = TapBurstController();
  final Random _random = Random();

  // ---- Per-frame tap queue -------------------------------------------------
  /// Max FX spawned per frame; the rest carry over to the next frame.
  static const int _maxFxPerFrame = 4;

  /// FX older than this are dropped (the score was already counted).
  static const int _fxStaleMs = 100;

  final Queue<_PendingTap> _pendingFx = Queue<_PendingTap>();
  final Stopwatch _clock = Stopwatch()..start();
  int _tapsSinceFlush = 0;
  int? _frameCallbackId;

  late final AnimationController _player1ClickController;
  late final AnimationController _player2ClickController;
  late final Animation<double> _player1ClickScale;
  late final Animation<double> _player2ClickScale;

  int get player1Score => _p1Score.value;
  int get player2Score => _p2Score.value;

  @override
  void initState() {
    super.initState();

    _appManager = Provider.of<AppManager>(context, listen: false);

    isTimeMode = widget.gameArgs['mode'] == 'GameMode.timeLimit';
    isSinglePlayer = widget.gameArgs['playerMode'] == 'PlayerMode.singlePlayer';
    timeLimit = widget.gameArgs['timeLimit'] ?? 60;
    scoreLimit = widget.gameArgs['scoreLimit'] ?? 100;
    difficulty = widget.gameArgs['difficulty'] ?? 2;
    _remaining.value = timeLimit;

    startCountdown();

    _ratioController = AnimationController(
      vsync: this,
      value: 0.5,
      duration: const Duration(milliseconds: 520),
    );

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

          if (isTimeMode) {
            // Only the HUD listens to _remaining; no full-screen rebuild.
            gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (_remaining.value > 0) {
                _remaining.value--;
              } else {
                _endGame();
              }
            });
          }

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
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!gameEnded && isGameStarted) {
        final size = MediaQuery.of(context).size;
        final h = size.height;
        final w = size.width;
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
    if (_frameCallbackId != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackId!);
      _frameCallbackId = null;
    }
    _ratioController.dispose();
    _dividerPulseController.dispose();
    _bursts.dispose();
    _player1ClickController.dispose();
    _player2ClickController.dispose();
    _p1Score.dispose();
    _p2Score.dispose();
    _remaining.dispose();
    super.dispose();
  }

  void _endGame() {
    if (gameEnded || !mounted) return;
    gameTimer?.cancel();
    _robotTimer?.cancel();
    setState(() {
      gameEnded = true;
    });
  }

  /// Counts the tap immediately (exact score, instant score bounce) and queues
  /// its FX + territory update for the next frame.
  void _updateScore(bool isPlayer1, Offset tapPosition) {
    if (gameEnded || !isGameStarted) return;

    if (isPlayer1) {
      _p1Score.value++;
    } else {
      _p2Score.value++;
    }
    _tapsSinceFlush++;
    _pendingFx.addLast(_PendingTap(tapPosition, _clock.elapsedMilliseconds));
    _scheduleFlush();

    if (!isTimeMode &&
        (_p1Score.value >= scoreLimit || _p2Score.value >= scoreLimit)) {
      _endGame();
    }
  }

  void _scheduleFlush() {
    _frameCallbackId ??=
        SchedulerBinding.instance.scheduleFrameCallback(_flushTaps);
  }

  /// Runs once per frame: one territory update for all taps since the last
  /// frame, then up to [_maxFxPerFrame] FX (oldest first). Leftover FX carry
  /// to the next frame; FX older than [_fxStaleMs] are skipped (never score).
  void _flushTaps(Duration _) {
    _frameCallbackId = null;
    if (!mounted) return;

    if (_tapsSinceFlush > 0) {
      _applyTerritory(_tapsSinceFlush);
      _tapsSinceFlush = 0;
    }

    final now = _clock.elapsedMilliseconds;
    var spawned = 0;
    while (_pendingFx.isNotEmpty && spawned < _maxFxPerFrame) {
      final tap = _pendingFx.removeFirst();
      if (now - tap.atMs > _fxStaleMs) continue;
      _bursts.spawn(
        tap.position,
        ArcadeChrome.yellow,
        (_random.nextDouble() - 0.5) * 0.52,
      );
      spawned++;
    }

    if (_pendingFx.isNotEmpty) _scheduleFlush();
  }

  void _applyTerritory(int taps) {
    final p1 = _p1Score.value;
    final total = (p1 + _p2Score.value).toDouble();
    final target = total > 0 ? p1 / total : 0.5;
    final oldRatio = colorRatio;
    final maxChange = 0.08 * taps.clamp(1, 3);
    final newRatio =
        oldRatio + (target - oldRatio).clamp(-maxChange, maxChange);
    if (newRatio == oldRatio) return;

    final significantChange = (oldRatio < 0.5 && newRatio > 0.5) ||
        (oldRatio > 0.5 && newRatio < 0.5) ||
        (newRatio - oldRatio).abs() > 0.05;
    if (significantChange && !_dividerPulseController.isAnimating) {
      _dividerPulseController.forward(from: 0.0);
    }

    colorRatio = newRatio;
    _ratioController.animateTo(
      newRatio,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  bool get _timerUrgent =>
      isTimeMode &&
      isGameStarted &&
      _remaining.value <= 3 &&
      _remaining.value > 0;

  String get _hudValue {
    if (isTimeMode) {
      return isGameStarted
          ? _formatTime(_remaining.value)
          : countdownSeconds.toString();
    }
    return '${scoreLimit - max(_p1Score.value, _p2Score.value)}';
  }

  static double _topHeight(double ratio, double h) =>
      ((1 - ratio) * h).clamp(h * 0.08, h * 0.92);

  Widget _score(ValueNotifier<int> score, {bool flipped = false}) {
    Widget child = ValueListenableBuilder<int>(
      valueListenable: score,
      builder: (context, value, _) => ScoreDisplay(
        score: value,
        color: Colors.white,
        isAnimating: true,
      ),
    );
    if (flipped) {
      child = Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationZ(pi),
        child: child,
      );
    }
    return RepaintBoundary(child: child);
  }

  void _onPlayer1Tap(TapDownDetails details) {
    _updateScore(true, details.globalPosition);
    _player1ClickController
        .forward(from: 0.0)
        .then((_) => _player1ClickController.reverse());
  }

  void _onPlayer2Tap(TapDownDetails details) {
    _updateScore(false, details.globalPosition);
    _player2ClickController
        .forward(from: 0.0)
        .then((_) => _player2ClickController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    _appManager = Provider.of<AppManager>(context);
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.075;
    final blue = _appManager.player1Color;
    final red = _appManager.player2Color;

    return Scaffold(
      backgroundColor: AppColors.comicNavy,
      body: Stack(
        children: [
          // VISUAL territory — continuous heights. Arenas/overlay/divider are
          // built once and only re-laid-out while the ratio animates.
          RepaintBoundary(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final redArena = ComicArena(color: red, alignTop: true);
                final blueArena = ComicArena(color: blue, alignTop: false);
                final divider = RepaintBoundary(
                  child: GameDivider(
                    ratio: 0.5,
                    pulseAnimation: _dividerPulseAnimation,
                    player1Color: blue,
                    player2Color: red,
                    height: 100,
                  ),
                );
                const speedLines = Positioned.fill(
                  child: IgnorePointer(
                    child: Image(
                      image: AssetImage(AppImages.speedLines),
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                  ),
                );
                return AnimatedBuilder(
                  animation: _ratioController,
                  builder: (context, _) {
                    final topH = _topHeight(_ratioController.value, h);
                    return Stack(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: topH,
                              width: double.infinity,
                              child: redArena,
                            ),
                            SizedBox(
                              height: h - topH,
                              width: double.infinity,
                              child: blueArena,
                            ),
                          ],
                        ),
                        speedLines,
                        Positioned(
                          top: topH - 50,
                          left: 0,
                          right: 0,
                          child: divider,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          RepaintBoundary(child: TapBurstLayer(controller: _bursts)),
          Positioned(
            right: screenSize.width * 0.06,
            top: isSinglePlayer
                ? screenSize.height * 0.22
                : screenSize.height * 0.5 + 10,
            child: isSinglePlayer ? _score(_p2Score) : _score(_p1Score),
          ),
          Positioned(
            right: screenSize.width * 0.06,
            bottom: isSinglePlayer
                ? screenSize.height * 0.22
                : screenSize.height * 0.5 + 10,
            child: isSinglePlayer
                ? _score(_p1Score)
                : _score(_p2Score, flipped: true),
          ),
          // HIT ZONES — always 50/50. Visual territory must NEVER shrink taps.
          AbsorbPointer(
            absorbing: !isGameStarted,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: isSinglePlayer ? null : _onPlayer2Tap,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (!isSinglePlayer)
                          _BigBurst(
                            controller: _player2ClickController,
                            size: iconSize * 5,
                          ),
                        Center(
                          child: RepaintBoundary(
                            child: PlayerIcon(
                              isRobot: isSinglePlayer,
                              isTopPlayer: true,
                              iconSize: iconSize,
                              scaleAnimation: _player2ClickScale,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    key: const Key('player1HitZone'),
                    behavior: HitTestBehavior.opaque,
                    onTapDown: _onPlayer1Tap,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _BigBurst(
                          controller: _player1ClickController,
                          size: iconSize * 5,
                        ),
                        Center(
                          child: RepaintBoundary(
                            child: PlayerIcon(
                              isRobot: false,
                              isTopPlayer: false,
                              iconSize: iconSize,
                              scaleAnimation: _player1ClickScale,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Neutral HUD: one compact chip centred on the frontier, above
          // divider + FX, never intercepting taps.
          IgnorePointer(
            child: RepaintBoundary(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;
                  return AnimatedBuilder(
                    animation: Listenable.merge(
                      [_ratioController, _p1Score, _p2Score, _remaining],
                    ),
                    builder: (context, _) => Stack(
                      children: [
                        Positioned(
                          top: _topHeight(_ratioController.value, h),
                          left: 0,
                          right: 0,
                          child: FractionalTranslation(
                            translation: const Offset(0, -0.5),
                            child: Center(
                              child: ComicTimerChip(
                                key: const Key('gameHudChip'),
                                icon: isTimeMode ? Icons.timer : Icons.flag,
                                value: _hudValue,
                                urgent: _timerUrgent,
                                pulse: isGameStarted && isTimeMode,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
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

/// Big comic impact burst behind a player icon, driven by its tap controller.
/// Opacity goes through Image.opacity (no saveLayer) and scale through
/// ScaleTransition, so nothing rebuilds per frame.
class _BigBurst extends StatefulWidget {
  final AnimationController controller;
  final double size;

  const _BigBurst({required this.controller, required this.size});

  @override
  State<_BigBurst> createState() => _BigBurstState();
}

class _BigBurstState extends State<_BigBurst> {
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _bind();
  }

  @override
  void didUpdateWidget(covariant _BigBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) _bind();
  }

  void _bind() {
    // t * 1.4 clamped to 1  ==  Interval(0, 1/1.4).
    _opacity = widget.controller
        .drive(CurveTween(curve: const Interval(0.0, 1 / 1.4)));
    _scale = widget.controller.drive(Tween<double>(begin: 0.55, end: 1.15));
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: RepaintBoundary(
          child: ScaleTransition(
            scale: _scale,
            child: Image.asset(
              AppImages.burstBig,
              width: widget.size,
              height: widget.size,
              opacity: _opacity,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
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
