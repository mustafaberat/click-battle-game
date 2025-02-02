import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/screens/game/game_styles.dart';
import 'package:clickbattle/screens/game/game_screen.dart';
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
                        'Game Over!',
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
                                widget.player1Score > widget.player2Score 
                                  ? (widget.isSinglePlayer ? 'You Win!' : 'Player 1 Wins!')
                                  : widget.player2Score > widget.player1Score
                                    ? (widget.isSinglePlayer ? 'Robot Wins!' : 'Player 2 Wins!')
                                    : 'It\'s a Tie!',
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
                                      widget.isSinglePlayer ? 'You' : 'Player 1',
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
                                      widget.player1Score.toString(),
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
                                      widget.isSinglePlayer ? 'Robot' : 'Player 2',
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
                                      widget.player2Score.toString(),
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
                
                // Buttons with Scale and Fade Animation
                if (_showButtons) AnimatedBuilder(
                  animation: _buttonsController,
                  builder: (context, child) => Opacity(
                    opacity: _buttonsOpacity.value,
                    child: Transform.scale(
                      scale: _buttonsScale.value,
                      child: Container(
                        width: screenSize.width * 0.9,
                        margin: EdgeInsets.only(
                          top: AppDimensions.spacing(context) * 4,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Play Again Button
                            SizedBox(
                              width: double.infinity,
                              height: 70,
                              child: MouseRegion(
                                onEnter: (_) => setState(() => _isPlayAgainHovered = true),
                                onExit: (_) => setState(() => _isPlayAgainHovered = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: Matrix4.identity()
                                    ..scale(_isPlayAgainHovered ? 1.05 : 1.0),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                        (states) => _isPlayAgainHovered ? winnerColor : winnerColor.withOpacity(0.8),
                                      ),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      elevation: MaterialStateProperty.all(_isPlayAgainHovered ? 12 : 6),
                                    ),
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) => GameScreen(gameArgs: widget.gameArgs),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.replay_rounded, color: Colors.white, size: 32),
                                          SizedBox(width: 16),
                                          Text(
                                            'Play Again',
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
                            ),
                            SizedBox(height: AppDimensions.spacing(context) * 2),
                            // Home Button
                            SizedBox(
                              width: double.infinity,
                              height: 70,
                              child: MouseRegion(
                                onEnter: (_) => setState(() => _isHomeHovered = true),
                                onExit: (_) => setState(() => _isHomeHovered = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: Matrix4.identity()
                                    ..scale(_isHomeHovered ? 1.05 : 1.0),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                        (states) => _isHomeHovered ? const Color(0xFF3A3A3A) : const Color(0xFF2A2A2A),
                                      ),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      elevation: MaterialStateProperty.all(_isHomeHovered ? 12 : 6),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.home_rounded, color: Colors.white, size: 32),
                                          SizedBox(width: 16),
                                          Text(
                                            'Back to Home',
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
                            ),
                          ],
                        ),
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
} 