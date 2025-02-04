import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/screens/game/game_styles.dart';
import 'package:clickbattle/screens/game/game_screen.dart';
import 'package:clickbattle/services/localization_service.dart';
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

class _GameOverPopupState extends State<GameOverPopup> with TickerProviderStateMixin {
  late AnimationController _gameOverController;
  late AnimationController _resultController;
  late AnimationController _buttonsController;
  late Animation<double> _gameOverScale;
  late Animation<double> _resultOpacity;
  late Animation<double> _buttonsOpacity;
  late Animation<double> _buttonsScale;
  bool _isPlayAgainHovered = false;
  bool _isHomeHovered = false;
  bool _canInteract = false;
  bool _showButtons = false;

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
    setState(() {
      _canInteract = true;
    });
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
    final bool isWinner = widget.player1Score > widget.player2Score;
    final Color winnerColor = isWinner ? Colors.blue[500]! : Colors.red[500]!;
    final screenSize = MediaQuery.of(context).size;
    final localizationService = Provider.of<LocalizationService>(context);
    
    return AbsorbPointer(
      absorbing: !_canInteract,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF1A1A1A),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.padding(context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Over Text with Scale Animation
                ScaleTransition(
                  scale: _gameOverScale,
                  child: Container(
                    width: screenSize.width * 0.9,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        localizationService.getText('gameOver'),
                        style: GameStyles.gameOverText(context).copyWith(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: winnerColor.withOpacity(0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.spacing(context) * 3),
                
                // Results with Fade Animation
                FadeTransition(
                  opacity: _resultOpacity,
                  child: Column(
                    children: [
                      Container(
                        width: screenSize.width * 0.9,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.isSinglePlayer && !isWinner) Icon(Icons.smart_toy, color: Colors.red[500], size: 32),
                              if (widget.isSinglePlayer && !isWinner) SizedBox(width: 8),
                              Text(
                                '${localizationService.getText('winner')}: ' +
                                (widget.player1Score > widget.player2Score 
                                  ? (widget.isSinglePlayer ? localizationService.getText('you') : localizationService.getText('player1'))
                                  : widget.player2Score > widget.player1Score
                                    ? (widget.isSinglePlayer ? localizationService.getText('robot') : localizationService.getText('player2'))
                                    : localizationService.getText('tie')),
                                style: GameStyles.winnerText(context).copyWith(
                                  color: Colors.white,
                                  fontSize: 32,
                                  shadows: [
                                    Shadow(
                                      color: winnerColor.withOpacity(0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              if (isWinner) SizedBox(width: 8),
                              if (isWinner) Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimensions.spacing(context) * 3),
                      Container(
                        width: screenSize.width * 0.9,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding(context) * 0.75,
                          vertical: AppDimensions.padding(context) * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context) * 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      widget.isSinglePlayer 
                                        ? localizationService.getText('you')
                                        : localizationService.getText('player1'),
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${widget.player1Score}',
                                      style: TextStyle(
                                        color: Colors.blue[400],
                                        fontSize: 56,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 80,
                              width: 2,
                              color: Colors.white12,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      widget.isSinglePlayer 
                                        ? localizationService.getText('robot')
                                        : localizationService.getText('player2'),
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${widget.player2Score}',
                                      style: TextStyle(
                                        color: Colors.red[400],
                                        fontSize: 56,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (_showButtons) ...[
                  SizedBox(height: AppDimensions.spacing(context) * 4),
                  // Buttons with Scale and Fade Animation
                  ScaleTransition(
                    scale: _buttonsScale,
                    child: FadeTransition(
                      opacity: _buttonsOpacity,
                      child: Column(
                        children: [
                          _buildButton(
                            text: localizationService.getText('playAgain'),
                            icon: Icons.replay_rounded,
                            isHovered: _isPlayAgainHovered,
                            onHover: (value) => setState(() => _isPlayAgainHovered = value),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GameScreen(gameArgs: widget.gameArgs),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: AppDimensions.spacing(context)),
                          _buildButton(
                            text: localizationService.getText('backToHome'),
                            icon: Icons.home_rounded,
                            isHovered: _isHomeHovered,
                            onHover: (value) => setState(() => _isHomeHovered = value),
                            onTap: () {
                              Navigator.popUntil(context, (route) => route.isFirst);
                            },
                            isPrimary: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required bool isHovered,
    required Function(bool) onHover,
    required Function() onTap,
    bool isPrimary = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: MouseRegion(
        onEnter: (_) => onHover(true),
        onExit: (_) => onHover(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity(),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) => isPrimary ? (isHovered ? Colors.blue[500]! : Colors.blue[400]!) : Colors.white12,
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              elevation: MaterialStateProperty.all(isPrimary ? (isHovered ? 12 : 6) : 0),
            ),
            onPressed: onTap,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 