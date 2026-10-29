import 'package:flutter/material.dart';
import 'package:clickbattle/constants/app_images.dart';

/// Glowing electric lightning frontier between the two arena halves.
class GameDivider extends StatelessWidget {
  final double ratio;
  final Animation<double>? pulseAnimation;
  final Color player1Color;
  final Color player2Color;
  final double height;

  const GameDivider({
    Key? key,
    required this.ratio,
    this.pulseAnimation,
    required this.player1Color,
    required this.player2Color,
    this.height = 28,
  }) : super(key: key);

  static const Animation<double> _rest = AlwaysStoppedAnimation<double>(0.0);

  @override
  Widget build(BuildContext context) {
    final pulse = pulseAnimation ?? _rest;
    // Opacity via Image.opacity (no saveLayer); scale via AnimatedBuilder with
    // the image as a cached child, so the pulse never rebuilds the image.
    final opacity = pulse.drive(Tween<double>(begin: 0.85, end: 1.0));
    return SizedBox(
      height: height,
      width: double.infinity,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: pulse,
          builder: (context, child) => Transform.scale(
            scaleY: 1.0 + 0.25 * pulse.value.clamp(0.0, 1.0),
            child: child,
          ),
          child: Image.asset(
            AppImages.lightningDivider,
            fit: BoxFit.fill,
            opacity: opacity,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }
}
