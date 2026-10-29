import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/analytics/analytics.dart';
import 'package:clickbattle/components/arcade_chrome.dart';
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
  late AnimationController _resultController;
  late AnimationController _buttonsController;
  late Animation<double> _gameOverScale;
  late Animation<double> _resultOpacity;
  late Animation<double> _buttonsOpacity;
  late Animation<double> _buttonsScale;
  bool _showButtons = false;
  bool _isNavigating = false;
  late AppManager _appManager;

  @override
  void initState() {
    super.initState();
    _appManager = Provider.of<AppManager>(context, listen: false);
    if (!widget.isTutorial) {
      AnalyticsService.instance.logScreenView(AnalyticsScreens.gameOver);
      _appManager.loadGameoverAd();
    }

    _gameOverController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _gameOverScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _gameOverController, curve: Curves.elasticOut),
    );

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _resultOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeOut),
    );

    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeIn),
    );
    _buttonsScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeOutBack),
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    _gameOverController.forward();
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    _resultController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _showButtons = true);
    _buttonsController.forward();
  }

  Future<void> _showAdAndReturnHome() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    AnalyticsService.instance.logTapBackHome();
    await _appManager.showGameoverAd(timeoutSeconds: 8);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _gameOverController.dispose();
    _resultController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appManager = Provider.of<AppManager>(context);

    final isTie = widget.player1Score == widget.player2Score;
    final p1Wins = widget.player1Score > widget.player2Score;
    final winnerColor = isTie
        ? ArcadeChrome.yellow
        : (p1Wins ? ArcadeChrome.blue : ArcadeChrome.red);
    final winnerName = isTie
        ? _appManager.getText('tie')
        : '${_appManager.getText('winner')}: ${widget.isSinglePlayer ? _appManager.getText(p1Wins ? 'you' : 'robot') : _appManager.getText(p1Wins ? 'player1' : 'player2')}';

    final headline = widget.isTutorial
        ? _appManager.getText(p1Wins || isTie ? 'demoYouWin' : 'demoRobotWins')
        : _appManager.getText('gameOver');

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.78),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
            decoration: ArcadeChrome.panelBox(accent: winnerColor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _gameOverScale,
                  child: Text(
                    headline.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: ArcadeChrome.display(
                      size: 34,
                      color: ArcadeChrome.yellow,
                      outline: ArcadeChrome.red,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FadeTransition(
                  opacity: _resultOpacity,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: winnerColor, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isTie
                              ? Icons.handshake_rounded
                              : Icons.workspace_premium_rounded,
                          color: winnerColor,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            winnerName.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: ArcadeChrome.ui(
                              size: 14,
                              color: winnerColor,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: _resultOpacity,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12, width: 2),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ScoreCol(
                            label: widget.isSinglePlayer
                                ? _appManager.getText('you')
                                : _appManager.getText('player1'),
                            score: widget.player1Score,
                            color: ArcadeChrome.blue,
                            emoji: '👆',
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 72,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: ArcadeChrome.yellow,
                        ),
                        Expanded(
                          child: _ScoreCol(
                            label: widget.isSinglePlayer
                                ? _appManager.getText('robot')
                                : _appManager.getText('player2'),
                            score: widget.player2Score,
                            color: ArcadeChrome.red,
                            emoji: widget.isSinglePlayer ? '🤖' : '👆',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (_showButtons)
                  ScaleTransition(
                    scale: _buttonsScale,
                    child: FadeTransition(
                      opacity: _buttonsOpacity,
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
    );
  }

  Widget _matchActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              AnalyticsService.instance.logTapRematch();
              final args = Map<String, dynamic>.from(widget.gameArgs ?? {});
              args['rematch'] = true;
              Navigator.pushReplacementNamed(
                context,
                '/game',
                arguments: args,
              );
            },
            style: ArcadeChrome.yellowButton(),
            icon: const Icon(Icons.replay_rounded, size: 24),
            label: Text(
              _appManager.getText('playAgain').toUpperCase(),
              style: ArcadeChrome.ui(
                size: 15,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _isNavigating ? null : _showAdAndReturnHome,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: ArcadeChrome.blue, width: 2.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(
              _isNavigating ? Icons.hourglass_empty : Icons.home_rounded,
              size: 22,
            ),
            label: Text(
              _appManager.getText('backToHome').toUpperCase(),
              style: ArcadeChrome.ui(size: 13, letterSpacing: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tutorialActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: widget.onTutorialReplay,
            style: ArcadeChrome.yellowButton(),
            icon: const Icon(Icons.replay_rounded, size: 24),
            label: Text(
              _appManager.getText('demoReplay').toUpperCase(),
              style: ArcadeChrome.ui(
                size: 15,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: widget.onTutorialDone ?? () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: ArcadeChrome.blue, width: 2.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.check_rounded, size: 22),
            label: Text(
              _appManager.getText('gotIt').toUpperCase(),
              style: ArcadeChrome.ui(size: 13, letterSpacing: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreCol extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final String emoji;

  const _ScoreCol({
    required this.label,
    required this.score,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: ArcadeChrome.ui(
            size: 11,
            color: Colors.white60,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$score',
          style: ArcadeChrome.display(size: 40, color: color),
        ),
      ],
    );
  }
}
