import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/services/app_manager.dart';

class GameDivider extends StatelessWidget {
  final double ratio; // Value between 0-1, represents player1's ratio (blue)
  final Animation<double>? pulseAnimation;
  final Color player1Color; // Blue player
  final Color player2Color; // Red player

  const GameDivider({
    Key? key,
    required this.ratio,
    this.pulseAnimation,
    required this.player1Color,
    required this.player2Color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appManager = Provider.of<AppManager>(context);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background divider bar
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color.lerp(player2Color, player1Color, 0.5)!.withOpacity(0.3),
            boxShadow: [
              BoxShadow(
                color: ratio > 0.5 ? player1Color.withOpacity(0.3) : player2Color.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        // Progress indicator
        Container(
          height: 4,
          width: double.infinity,
          child: Row(
            children: [
              // Blue player's territory progress (reversed direction)
              Expanded(
                flex: (ratio * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        player1Color,
                        player1Color.withOpacity(0.7),
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                ),
              ),
              // Divider indicator with pulse animation
              pulseAnimation != null
                  ? ScaleTransition(
                      scale: pulseAnimation!,
                      child: _buildDividerIndicator(appManager),
                    )
                  : _buildDividerIndicator(appManager),
              // Red player's territory progress (reversed direction)
              Expanded(
                flex: ((1 - ratio) * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        player2Color.withOpacity(0.7),
                        player2Color,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Fewer border markings to indicate territory boundaries
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              5, // Reduced from 11 to 5 markings
              (index) => Container(
                width: 2,
                height: index == 2 ? 12 : 6, // Middle mark is taller
                decoration: BoxDecoration(
                  color: appManager.white.withOpacity(index == 2 ? 0.8 : 0.4),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDividerIndicator(AppManager appManager) {
    return Container(
      width: 4,
      height: 16,
      decoration: BoxDecoration(
        color: appManager.white,
        boxShadow: [
          BoxShadow(
            color: appManager.white.withOpacity(0.8),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
} 