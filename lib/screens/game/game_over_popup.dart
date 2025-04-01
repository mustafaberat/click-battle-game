import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/screens/game/game_styles.dart';
import 'package:clickbattle/screens/game/game_screen.dart';
import 'package:clickbattle/services/localization_service.dart';
import 'package:clickbattle/services/ad_service.dart';
import 'dart:async';

class GameOverPopup extends StatefulWidget {
  final int player1Score;
  final int player2Score;
  final bool isSinglePlayer;
  final Map<String, dynamic> gameArgs;

  const GameOverPopup({
    Key? key,
    required this.player1Score,
    required this.player2Score,
    required this.isSinglePlayer,
    required this.gameArgs,
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

  @override
  void initState() {
    super.initState();

    // Game Over text animation
    _gameOverController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _gameOverScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _gameOverController,
        curve: Curves.elasticOut,
      ),
    );

    // Result animation
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _resultOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _resultController,
        curve: Curves.easeInOut,
      ),
    );

    // Buttons animation
    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonsController,
        curve: Curves.easeIn,
      ),
    );
    _buttonsScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonsController,
        curve: Curves.elasticOut,
      ),
    );

    // Start staged animations
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Start with Game Over text
    await Future.delayed(const Duration(milliseconds: 500));
    _gameOverController.forward();

    // Show result after delay
    await Future.delayed(const Duration(milliseconds: 1000));
    _resultController.forward();

    // Wait for score display to complete
    await Future.delayed(const Duration(milliseconds: 1500));

    // Show buttons
    setState(() {
      _showButtons = true;
    });
    _buttonsController.forward();

    // Enable interaction after all animations
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Handle showing ad and returning to home
  Future<void> _showAdAndReturnHome() async {
    if (_isNavigating) return;
    
    setState(() {
      _isNavigating = true;
    });
    
    // Get the ad service instance and show interstitial ad
    final adService = AdService();
    
    // Show the ad and wait for it to close (with a timeout)
    await adService.showInterstitialAd(timeoutSeconds: 8);
    
    // Return to home screen after ad is dismissed or times out
    if (mounted) {
      Navigator.pop(context);
    }
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
    final localizationService = Provider.of<LocalizationService>(context);

    final bool isTie = widget.player1Score == widget.player2Score;
    final bool isPlayer1Winner = widget.player1Score > widget.player2Score;

    final Color winnerColor = isTie
        ? Colors.orangeAccent[400]!
        : (isPlayer1Winner ? Colors.blue[400]! : Colors.red[400]!);

    final String winnerText = isTie
        ? localizationService.getText('tie')
        : '${localizationService.getText('winner')}: ${widget.isSinglePlayer ? localizationService.getText(isPlayer1Winner ? 'player1' : 'robot') : localizationService.getText(isPlayer1Winner ? 'player1' : 'player2')}';

    // Calculate safe font sizes for small screens
    final double gameOverFontSize =
        (MediaQuery.of(context).size.width * 0.07).clamp(20.0, 28.0);
    final double winnerFontSize =
        (MediaQuery.of(context).size.width * 0.05).clamp(16.0, 20.0);
    final double scoreFontSize =
        (MediaQuery.of(context).size.width * 0.1).clamp(28.0, 40.0);
    final double labelFontSize =
        (MediaQuery.of(context).size.width * 0.035).clamp(12.0, 16.0);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: BoxConstraints(maxWidth: 400),
            margin: EdgeInsets.symmetric(vertical: 24),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Color(0xFF2A2D3E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: winnerColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Game Over Text
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ScaleTransition(
                    scale: _gameOverScale,
                    child: Text(
                      localizationService.getText('gameOver'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: gameOverFontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),

                // Winner Display with Animation
                FadeTransition(
                  opacity: _resultOpacity,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 280),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: winnerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: winnerColor,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          winnerText,
                          style: TextStyle(
                            color: winnerColor,
                            fontSize: winnerFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Score Display with Animation
                FadeTransition(
                  opacity: _resultOpacity,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 280),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: _buildScoreColumn(
                              localizationService.getText('player1'),
                              widget.player1Score,
                              Colors.blue[400]!,
                              scoreFontSize,
                              labelFontSize,
                            ),
                          ),
                        ),
                        Container(
                          height: 80,
                          width: 1,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.white24,
                        ),
                        Expanded(
                          child: Center(
                            child: _buildScoreColumn(
                              widget.isSinglePlayer
                                  ? localizationService.getText('robot')
                                  : localizationService.getText('player2'),
                              widget.player2Score,
                              Colors.red[400]!,
                              scoreFontSize,
                              labelFontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Buttons with Animation
                if (_showButtons)
                  ScaleTransition(
                    scale: _buttonsScale,
                    child: FadeTransition(
                      opacity: _buttonsOpacity,
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(maxWidth: 280),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          GameScreen(gameArgs: widget.gameArgs),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: winnerColor,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow_rounded,
                                        color: Colors.white, size: 26),
                                    SizedBox(width: 8),
                                    Text(
                                      localizationService.getText('playAgain'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isNavigating 
                                  ? null 
                                  : _showAdAndReturnHome,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.1),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  disabledBackgroundColor: 
                                      Colors.white.withOpacity(0.05),
                                  disabledForegroundColor: 
                                      Colors.white.withOpacity(0.3),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isNavigating
                                          ? Icons.hourglass_empty
                                          : Icons.home_rounded,
                                      color: Colors.white,
                                      size: 26
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      localizationService.getText('backToHome'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreColumn(String label, int score, Color color,
      double scoreFontSize, double labelFontSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: labelFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Text(
          score.toString(),
          style: TextStyle(
            color: color,
            fontSize: scoreFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
