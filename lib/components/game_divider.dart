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

  @override
  Widget build(BuildContext context) {
    Widget paintWith(double pulse) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: IgnorePointer(
          child: Opacity(
            opacity: 0.85 + 0.15 * pulse,
            child: Transform.scale(
              scaleY: 1.0 + 0.25 * pulse,
              child: Image.asset(
                AppImages.lightningDivider,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
          ),
        ),
      );
    }

    if (pulseAnimation == null) return paintWith(0);

    return AnimatedBuilder(
      animation: pulseAnimation!,
      builder: (context, _) => paintWith(pulseAnimation!.value.clamp(0.0, 1.0)),
    );
  }
}
