import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/analytics/analytics.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'package:clickbattle/components/arcade_chrome.dart';
import 'package:clickbattle/screens/game/game_over_popup.dart';

/// In-game How to Play — no Next buttons; teach by tapping the arena.
/// Hit zone is always the bottom 50% (same rule as real match).
class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({Key? key}) : super(key: key);

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

enum _Phase { waitTap, focusLine, robotTap, freePlay, done }

class _HowToPlayScreenState extends State<HowToPlayScreen>
    with TickerProviderStateMixin {
  late AppManager _app;
  _Phase _phase = _Phase.waitTap;

  int _playerScore = 0;
  int _robotScore = 0;
  double _ratio = 0.5;
  int _totalTaps = 0;

  late AnimationController _linePulse;
  late AnimationController _hintPulse;
  late AnimationController _ratioCtrl;
  late Animation<double> _ratioAnim;
  Timer? _robotTimer;
  String _banner = '';

  static const int _endAtTaps = 5;

  @override
  void initState() {
    super.initState();
    _app = Provider.of<AppManager>(context, listen: false);
    AnalyticsService.instance.logTutorialBegin();
    _linePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _hintPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _ratioCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _ratioAnim = const AlwaysStoppedAnimation(0.5);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _banner = _app.getText('demoTapHint'));
    });
  }

  @override
  void dispose() {
    _robotTimer?.cancel();
    _linePulse.dispose();
    _hintPulse.dispose();
    _ratioCtrl.dispose();
    super.dispose();
  }

  void _onPlayerTap() {
    switch (_phase) {
      case _Phase.waitTap:
        _applyPlayerTap();
        setState(() {
          _phase = _Phase.focusLine;
          _banner = _app.getText('demoFocusLine');
        });
        _linePulse.repeat(reverse: true);
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (!mounted || _phase != _Phase.focusLine) return;
          _runRobotDemo();
        });
        break;
      case _Phase.focusLine:
      case _Phase.robotTap:
        break;
      case _Phase.freePlay:
        _applyPlayerTap();
        _checkEnd();
        break;
      case _Phase.done:
        break;
    }
  }

  void _applyPlayerTap() {
    setState(() {
      _playerScore++;
      _totalTaps++;
      _nudgeRatio();
    });
  }

  void _applyRobotTap() {
    setState(() {
      _robotScore++;
      _totalTaps++;
      _nudgeRatio();
    });
  }

  void _nudgeRatio() {
    final total = (_playerScore + _robotScore).toDouble();
    final target = total > 0 ? _playerScore / total : 0.5;
    final next = _ratio + (target - _ratio).clamp(-0.14, 0.14);
    final begin = _ratioCtrl.isAnimating ? _ratioAnim.value : _ratio;
    _ratioAnim = Tween<double>(begin: begin, end: next).animate(
      CurvedAnimation(parent: _ratioCtrl, curve: Curves.easeOutCubic),
    );
    _ratio = next;
    _ratioCtrl.forward(from: 0);
  }

  void _runRobotDemo() {
    _linePulse.stop();
    _linePulse.value = 1;
    setState(() {
      _phase = _Phase.robotTap;
      _banner = _app.getText('demoRobotTap');
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _applyRobotTap();
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        if (_totalTaps >= _endAtTaps) {
          _finish();
          return;
        }
        setState(() {
          _phase = _Phase.freePlay;
          _banner = _app.getText('demoKeepGoing');
        });
        _robotTimer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
          if (_phase != _Phase.freePlay) return;
          _applyRobotTap();
          _checkEnd();
        });
      });
    });
  }

  void _checkEnd() {
    if (_totalTaps >= _endAtTaps) _finish();
  }

  void _finish() {
    _robotTimer?.cancel();
    _linePulse.stop();
    setState(() => _phase = _Phase.done);
    AnalyticsService.instance.logTutorialComplete(
      playerScore: _playerScore,
      robotScore: _robotScore,
    );
  }

  void _restart() {
    AnalyticsService.instance.logTutorialReplay();
    _robotTimer?.cancel();
    setState(() {
      _phase = _Phase.waitTap;
      _playerScore = 0;
      _robotScore = 0;
      _ratio = 0.5;
      _ratioAnim = const AlwaysStoppedAnimation(0.5);
      _totalTaps = 0;
      _banner = _app.getText('demoTapHint');
    });
    _hintPulse.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    _app = Provider.of<AppManager>(context);
    final lineGlow = _phase == _Phase.focusLine;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_ratioAnim, _linePulse]),
            builder: (context, _) {
              final ratio = _ratioAnim.value;
              return LayoutBuilder(
                builder: (context, c) {
                  final totalH = c.maxHeight;
                  const lineH = 4.0;
                  final topH = ((1 - ratio) * (totalH - lineH))
                      .clamp(totalH * 0.18, totalH * 0.82);
                  final t = lineGlow ? _linePulse.value : 0.0;
                  return Column(
                    children: [
                      SizedBox(
                        height: topH,
                        width: double.infinity,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFB0002A), ArcadeChrome.red],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: lineH + t * 4,
                        decoration: BoxDecoration(
                          color: ArcadeChrome.yellow,
                          boxShadow: [
                            BoxShadow(
                              color: ArcadeChrome.yellow
                                  .withOpacity(0.35 + t * 0.55),
                              blurRadius: 8 + t * 16,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xFF005F8A), ArcadeChrome.blue],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _robotTimer?.cancel();
                      if (_phase != _Phase.done) {
                        AnalyticsService.instance.logTutorialSkip();
                      }
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                  const Spacer(),
                  Text('🤖  $_robotScore', style: ArcadeChrome.ui(size: 18)),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: Text('👆  $_playerScore', style: ArcadeChrome.ui(size: 18)),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: h * 0.5,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onPlayerTap,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          if (_phase != _Phase.done)
            Positioned(
              left: 20,
              right: 20,
              top: h * 0.42,
              child: IgnorePointer(
                child: ScaleTransition(
                  scale: (_phase == _Phase.waitTap || _phase == _Phase.freePlay)
                      ? Tween(begin: 0.96, end: 1.05).animate(_hintPulse)
                      : const AlwaysStoppedAnimation(1),
                  child: _CoachBanner(
                    emoji: _phase == _Phase.waitTap ||
                            _phase == _Phase.freePlay
                        ? '👆'
                        : _phase == _Phase.robotTap
                            ? '🤖'
                            : '⚡',
                    text: _banner,
                    color: _phase == _Phase.robotTap
                        ? ArcadeChrome.red
                        : _phase == _Phase.focusLine
                            ? ArcadeChrome.yellow
                            : ArcadeChrome.blue,
                  ),
                ),
              ),
            ),
          if (_phase == _Phase.robotTap)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: const Alignment(0, -0.25),
                  child: Text(
                    '🤖',
                    style: TextStyle(
                      fontSize: 56,
                      shadows: [
                        Shadow(
                          color: ArcadeChrome.red.withOpacity(0.8),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_phase == _Phase.done)
            GameOverPopup(
              player1Score: _playerScore,
              player2Score: _robotScore,
              isSinglePlayer: true,
              isTutorial: true,
              onTutorialReplay: _restart,
              onTutorialDone: () {
                AnalyticsService.instance.logTutorialGotIt();
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

class _CoachBanner extends StatelessWidget {
  final String emoji;
  final String text;
  final Color color;

  const _CoachBanner({
    required this.emoji,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.35), blurRadius: 16),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: ArcadeChrome.ui(size: 15, letterSpacing: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
