import 'package:flutter/material.dart';
import 'package:clickbattle/configs/config.dart';

class ClickArea extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final double angle;

  ClickArea({
    required this.onTap,
    required this.color,
    this.angle = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          color: color,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: angle,
                child: Icon(
                  ClickBattleConfig.fingerIcon,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
