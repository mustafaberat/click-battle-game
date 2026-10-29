import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/components/arcade_chrome.dart';
import 'package:clickbattle/screens/game/game_screen.dart';
import 'package:clickbattle/services/app_manager.dart';

/// Shared arcade result panel — used by match Game Over and How to Play.
class GameOverPopup extends StatefulWidget {
  final int player1Score;
  final int player2Score;
  final bool isSinglePlayer;
  final Map<String, dynamic>? gameArgs;

  /// When true: tutorial end — no ads, custom actions.
  final bool isTutorial;
  final VoidCallback? onTutorialReplay;
  final VoidCallback? onTutorialDone;

  const GameOverPopup({
    Key? key,
    required this.player1Score,
    required this.player2Score,
    required this.isSinglePlayer,
    this.gameArgs,
    this.isTutorial = false,
    this.onTutorialReplay,
    this.onTutorialDone,
  }) : super(key: key);

  @override
  State<GameOverPopup> createState() => _GameOverPopupState();
}

class _GameOverPopupState extends State<GameOverPopup>
    with TickerProviderStateMixin {
  late AnimationController _gameOverController;
  late AnimationController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _gameOverScale;
  late Animation<double> _resultOpacity;
  late Animation<double> _buttonsOpacity;
  late Animation<double> _buttonsScale;
  bool _isNavigating = false;
  late AppManager _appManager;

  @override
  void initState() {
    super.initState();
    _appManager = Provider.of<AppManager>(context, listen: false);
    if (!widget.isTutorial) {
      // Widget tests have no ads plugin. Production still preloads here so
      // the interstitial-on-home-back path and its frequency stay unchanged.
      final binding = WidgetsBinding.instance.runtimeType.toString();
      if (!binding.contains('TestWidgets')) {
        _appManager.loadGameoverAd();
      }
    }

    // Single timeline started in initState so widget tests / screenshots that
    // pump a long duration actually tick (Timer-started tickers stay at 0).
    _gameOverController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _gameOverScale = Tween<double>(begin: 1.22, end: 1.0).animate(
      CurvedAnimation(
        parent: _gameOverController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _resultOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _gameOverController,
        curve: const Interval(0.28, 0.55, curve: Curves.easeOut),
      ),
    );

    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _gameOverController,
        curve: const Interval(0.62, 0.92, curve: Curves.easeIn),
      ),
    );
    _buttonsScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _gameOverController,
        curve: const Interval(0.62, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 90),
      vsync: this,
    );

    _gameOverController.addListener(() {
      if (_gameOverController.value >= 0.22 && _shakeController.isAnimating) {
        _shakeController
          ..stop()
          ..value = 0;
      }
    });

    _gameOverController.forward();
    _confettiController.forward();
    _shakeController.repeat(reverse: true);
  }

  Future<void> _showAdAndReturnHome() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    await _appManager.showGameoverAd(timeoutSeconds: 8);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _gameOverController.dispose();
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  String _headline({
    required bool isTie,
    required bool p1Wins,
  }) {
    if (widget.isTutorial) {
      return _appManager.getText(p1Wins || isTie ? 'demoYouWin' : 'demoRobotWins');
    }
    if (isTie) return _appManager.getText('tieHeadline');
    if (widget.isSinglePlayer) {
      return _appManager.getText(p1Wins ? 'youWin' : 'robotWins');
    }
    return _appManager.getText(p1Wins ? 'player1Wins' : 'player2Wins');
  }

  @override
  Widget build(BuildContext context) {
    _appManager = Provider.of<AppManager>(context);

    final isTie = widget.player1Score == widget.player2Score;
    final p1Wins = widget.player1Score > widget.player2Score;
    final winnerColor = isTie
        ? ArcadeChrome.yellow
        : (p1Wins ? ArcadeChrome.blue : ArcadeChrome.red);
    final headline = _headline(isTie: isTie, p1Wins: p1Wins);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.72),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, _) => CustomPaint(
              painter: _ConfettiPainter(_confettiController.value, p1Wins, isTie),
              size: Size.infinite,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final dx = (_shakeController.value - 0.5) * 10;
                  return Transform.translate(offset: Offset(dx, 0), child: child);
                },
                child: ScaleTransition(
                  scale: _gameOverScale,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: ComicPanel(
                      label: _appManager.getText('gameOver'),
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                      accent: winnerColor,
                      margin: EdgeInsets.zero,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            headline.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: ArcadeChrome.display(
                              size: 40,
                              color: ArcadeChrome.yellow,
                              outlineWidth: 3.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeTransition(
                            opacity: _resultOpacity,
                            child: _Trophy(
                              isTie: isTie,
                              p1Wins: p1Wins,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FadeTransition(
                            opacity: _resultOpacity,
                            child: _ScoreBand(
                              leftLabel: widget.isSinglePlayer
                                  ? _appManager.getText('you')
                                  : _appManager.getText('player1'),
                              rightLabel: widget.isSinglePlayer
                                  ? _appManager.getText('robot')
                                  : _appManager.getText('player2'),
                              leftScore: widget.player1Score,
                              rightScore: widget.player2Score,
                              vsLabel: _appManager.getText('vs'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeTransition(
                            opacity: _buttonsOpacity,
                            child: ScaleTransition(
                              scale: _buttonsScale,
                              child: widget.isTutorial
                                  ? _tutorialActions()
                                  : _matchActions(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _matchActions() {
    return Column(
      children: [
        ComicButton(
          height: 56,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    GameScreen(gameArgs: widget.gameArgs ?? const {}),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.replay_rounded, size: 24, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                _appManager.getText('playAgain').toUpperCase(),
                style: ArcadeChrome.ui(
                  size: 15,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ComicButton(
          color: ArcadeChrome.panel,
          foregroundColor: Colors.white,
          height: 52,
          onPressed: _isNavigating ? null : _showAdAndReturnHome,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isNavigating ? Icons.hourglass_empty : Icons.home_rounded,
                size: 22,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                _appManager.getText('backToHome').toUpperCase(),
                style: ArcadeChrome.ui(
                  size: 13,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tutorialActions() {
    return Column(
      children: [
        ComicButton(
          height: 56,
          onPressed: widget.onTutorialReplay,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.replay_rounded, size: 24, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                _appManager.getText('demoReplay').toUpperCase(),
                style: ArcadeChrome.ui(
                  size: 15,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ComicButton(
          color: ArcadeChrome.blue,
          foregroundColor: Colors.white,
          height: 52,
          onPressed: widget.onTutorialDone ?? () => Navigator.pop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, size: 22, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                _appManager.getText('gotIt').toUpperCase(),
                style: ArcadeChrome.ui(
                  size: 13,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Trophy extends StatelessWidget {
  final bool isTie;
  final bool p1Wins;

  const _Trophy({required this.isTie, required this.p1Wins});

  @override
  Widget build(BuildContext context) {
    final color = isTie
        ? ArcadeChrome.yellow
        : (p1Wins ? const Color(0xFFFFC107) : const Color(0xFF8A93A6));
    return SizedBox(
      width: 108,
      height: 96,
      child: CustomPaint(
        painter: _TrophyPainter(color: color, isTie: isTie),
      ),
    );
  }
}

class _TrophyPainter extends CustomPainter {
  final Color color;
  final bool isTie;

  _TrophyPainter({required this.color, required this.isTie});

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = ArcadeChrome.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = color;
    final dark = Paint()..color = Color.lerp(color, Colors.black, 0.28)!;
    final cx = size.width * 0.5;

    if (isTie) {
      final left = Path()
        ..moveTo(cx - 28, 28)
        ..quadraticBezierTo(cx - 46, 18, cx - 42, 46)
        ..quadraticBezierTo(cx - 18, 58, cx - 8, 44)
        ..quadraticBezierTo(cx - 22, 32, cx - 28, 28);
      final right = Path()
        ..moveTo(cx + 28, 28)
        ..quadraticBezierTo(cx + 46, 18, cx + 42, 46)
        ..quadraticBezierTo(cx + 18, 58, cx + 8, 44)
        ..quadraticBezierTo(cx + 22, 32, cx + 28, 28);
      canvas.drawPath(left, fill);
      canvas.drawPath(left, ink);
      canvas.drawPath(right, fill);
      canvas.drawPath(right, ink);
      return;
    }

    // Cup bowl
    final bowl = Path()
      ..moveTo(cx - 26, 18)
      ..lineTo(cx + 26, 18)
      ..quadraticBezierTo(cx + 30, 52, cx + 14, 64)
      ..lineTo(cx - 14, 64)
      ..quadraticBezierTo(cx - 30, 52, cx - 26, 18)
      ..close();
    canvas.drawPath(bowl, fill);
    canvas.drawPath(bowl, ink);

    // Handles
    final leftHandle = Path()
      ..moveTo(cx - 26, 26)
      ..quadraticBezierTo(cx - 48, 34, cx - 28, 54);
    final rightHandle = Path()
      ..moveTo(cx + 26, 26)
      ..quadraticBezierTo(cx + 48, 34, cx + 28, 54);
    final handleStroke = Paint()
      ..color = ArcadeChrome.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(leftHandle, handleStroke);
    canvas.drawPath(rightHandle, handleStroke);
    canvas.drawPath(
      leftHandle,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      rightHandle,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    // Stem + base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, 72), width: 12, height: 16),
        const Radius.circular(3),
      ),
      dark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, 72), width: 12, height: 16),
        const Radius.circular(3),
      ),
      ink,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, 86), width: 40, height: 10),
        const Radius.circular(4),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, 86), width: 40, height: 10),
        const Radius.circular(4),
      ),
      ink,
    );

    // Shine
    canvas.drawCircle(
      Offset(cx - 10, 30),
      4,
      Paint()..color = Colors.white.withOpacity(0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _TrophyPainter old) =>
      old.color != color || old.isTie != isTie;
}

class _ScoreBand extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final int leftScore;
  final int rightScore;
  final String vsLabel;

  const _ScoreBand({
    required this.leftLabel,
    required this.rightLabel,
    required this.leftScore,
    required this.rightScore,
    required this.vsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ArcadeChrome.ink, width: 3),
        ),
        child: Row(
          children: [
            Expanded(
              child: _bandCol(
                label: leftLabel,
                score: leftScore,
                color: ArcadeChrome.blue,
              ),
            ),
            Container(
              width: 44,
              height: 88,
              color: const Color(0xFF0A142E),
              alignment: Alignment.center,
              child: Text(
                vsLabel.toUpperCase(),
                style: ArcadeChrome.display(
                  size: 16,
                  color: ArcadeChrome.yellow,
                ),
              ),
            ),
            Expanded(
              child: _bandCol(
                label: rightLabel,
                score: rightScore,
                color: ArcadeChrome.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bandCol({
    required String label,
    required int score,
    required Color color,
  }) {
    return ColoredBox(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ArcadeChrome.ui(
                size: 11,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$score',
              style: ArcadeChrome.display(size: 36, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  final bool celebrate;
  final bool isTie;

  _ConfettiPainter(this.t, this.celebrate, this.isTie);

  static const _colors = [
    ArcadeChrome.yellow,
    ArcadeChrome.red,
    ArcadeChrome.blue,
    Color(0xFF7CFF6B),
    Color(0xFFFF8AD8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final n = celebrate || isTie ? 28 : 12;
    final paint = Paint();
    for (int i = 0; i < n; i++) {
      final seed = i * 17.13;
      final x = (seed * 13.7 % 1.0) * size.width;
      final fall = t * (size.height * (0.35 + (seed % 1) * 0.5));
      final y = -20 + fall;
      final w = 6.0 + (i % 3) * 2;
      paint.color = _colors[i % _colors.length].withOpacity(1 - t * 0.35);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 6 + i);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: w * 0.4),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }

    // Yellow rays behind the card
    final cx = size.width * 0.5;
    final cy = size.height * 0.42;
    final ray = Paint()
      ..color = ArcadeChrome.yellow.withOpacity(0.10 * (1 - t * 0.4))
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 10; i++) {
      final a = i * math.pi / 5 + t * 0.4;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + math.cos(a) * 180, cy + math.sin(a) * 180),
        ray,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
