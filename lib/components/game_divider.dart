import 'package:flutter/material.dart';
import 'package:clickbattle/components/arcade_chrome.dart';

/// Zigzag yellow lightning frontier between the two arena halves.
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
        child: CustomPaint(
          painter: LightningDividerPainter(
            pulse: pulse,
            leading: ratio >= 0.5 ? player1Color : player2Color,
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

class LightningDividerPainter extends CustomPainter {
  final double pulse;
  final Color leading;

  LightningDividerPainter({required this.pulse, required this.leading});

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height * 0.5;
    final amp = 8.0 * (1.0 + pulse * 0.55);
    const teeth = 9;
    final path = Path();
    for (int i = 0; i <= teeth; i++) {
      final x = size.width * (i / teeth);
      final y = mid + ((i.isEven) ? -amp : amp);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final ink = Paint()
      ..color = ArcadeChrome.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = ArcadeChrome.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, ink);
    canvas.drawPath(path, fill);

    // Sparks along the bolt
    final spark = Paint()..color = Colors.white.withOpacity(0.55 * pulse);
    for (int i = 1; i < teeth; i += 2) {
      final x = size.width * (i / teeth);
      canvas.drawCircle(Offset(x, mid), 1.8 * pulse, spark);
    }

    // Tiny side bolts
    final tick = Paint()
      ..color = ArcadeChrome.yellow
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.18, mid - amp - 4),
      Offset(size.width * 0.22, mid - amp - 10),
      tick,
    );
    canvas.drawLine(
      Offset(size.width * 0.78, mid + amp + 3),
      Offset(size.width * 0.84, mid + amp + 9),
      tick,
    );
  }

  @override
  bool shouldRepaint(covariant LightningDividerPainter old) =>
      old.pulse != pulse || old.leading != leading;
}
