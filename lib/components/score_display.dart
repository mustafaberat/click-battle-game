import 'package:flutter/material.dart';
import 'package:clickbattle/configs/config.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final Color color;
  final double rotationAngle;

  ScoreDisplay({
    required this.score,
    required this.color,
    required this.rotationAngle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationAngle,
      child: Text(
        '$score',
        style: TextStyle(
          fontSize: ClickBattleConfig.scoreDisplayFontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
