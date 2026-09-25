import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/services/app_manager.dart';

/// Thin frontier line between equal neon arenas.
class GameDivider extends StatelessWidget {
  final double ratio;
  final Animation<double>? pulseAnimation;
  final Color player1Color;
  final Color player2Color;

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
    final leading = ratio >= 0.5 ? player1Color : player2Color;

    final line = Container(
      height: 2,
      width: double.infinity,
      decoration: BoxDecoration(
        color: appManager.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: leading.withOpacity(0.4),
            blurRadius: 5,
          ),
        ],
      ),
    );

    if (pulseAnimation == null) return line;

    return AnimatedBuilder(
      animation: pulseAnimation!,
      builder: (context, child) {
        final t = ((pulseAnimation!.value - 1.0) / 0.5).clamp(0.0, 1.0);
        return Transform.scale(
          scaleY: 1.0 + t * 0.8,
          child: child,
        );
      },
      child: line,
    );
  }
}
