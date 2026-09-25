import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickbattle/constants/app_colors.dart';

/// Modern arcade chrome — Bangers titles, Exo 2 UI, neon red/cyan/yellow.
class ArcadeChrome {
  static const Color yellow = AppColors.arcadeYellow;
  static const Color yellowDark = AppColors.arcadeYellowDark;
  static const Color red = AppColors.neonRed;
  static const Color blue = AppColors.neonBlue;
  static const Color panel = Color(0xFF0E0E12);
  static const Color panelBorder = Color(0xFF2C2C36);

  static TextStyle display({
    double size = 36,
    Color color = Colors.white,
    Color? outline,
  }) {
    return GoogleFonts.bangers(
      fontSize: size,
      color: color,
      letterSpacing: 1.5,
      height: 1.0,
      shadows: [
        Shadow(
          color: outline ?? Colors.black,
          offset: const Offset(2.5, 2.5),
          blurRadius: 0,
        ),
        if (outline != null)
          Shadow(color: outline.withOpacity(0.45), blurRadius: 12),
      ],
    );
  }

  static TextStyle ui({
    double size = 14,
    FontWeight weight = FontWeight.w800,
    Color color = Colors.white,
    double letterSpacing = 1.2,
  }) {
    return GoogleFonts.exo2(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.15,
    );
  }

  static TextStyle sectionLabel({Color color = yellow}) => ui(
        size: 12,
        color: color,
        letterSpacing: 2.2,
      );

  static BoxDecoration panelBox({Color? accent}) => BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent ?? panelBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: (accent ?? yellow).withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      );

  static ButtonStyle yellowButton() => ElevatedButton.styleFrom(
        backgroundColor: yellow,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
        textStyle: ui(size: 18, color: Colors.black, letterSpacing: 2),
      );
}

class ArcadePill extends StatelessWidget {
  final String label;
  final Color color;

  const ArcadePill({Key? key, required this.label, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Text(
        label.toUpperCase(),
        style: ArcadeChrome.ui(
          size: 11,
          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

class HazardStrip extends StatelessWidget {
  final Color color;
  final double height;

  const HazardStrip({Key? key, required this.color, this.height = 10})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.hasBoundedHeight && constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : height;
        return ClipRect(
          child: CustomPaint(
            size: Size(w.isFinite ? w : 0, h),
            painter: _HazardPainter(color),
          ),
        );
      },
    );
  }
}

class _HazardPainter extends CustomPainter {
  final Color color;
  _HazardPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = color);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final stripe = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.butt;
    for (double x = -size.height; x < size.width + size.height; x += 12) {
      canvas.drawLine(
        Offset(x, size.height + 1),
        Offset(x + size.height, -1),
        stripe,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HazardPainter old) => old.color != color;
}

class ArcadeTagline extends StatelessWidget {
  final String text;
  const ArcadeTagline({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const h = 28.0;
    return SizedBox(
      height: h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(
            child: HazardStrip(color: ArcadeChrome.red, height: h),
          ),
          ColoredBox(
            color: ArcadeChrome.yellow,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: Text(
                  text.toUpperCase(),
                  style: ArcadeChrome.ui(
                    size: 11,
                    color: Colors.black,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
            child: HazardStrip(color: ArcadeChrome.blue, height: h),
          ),
        ],
      ),
    );
  }
}

/// Halftone + lightning vs backdrop (diagonal red | blue).
class ArcadeVsBackdrop extends StatelessWidget {
  const ArcadeVsBackdrop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _VsBackdropPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _VsBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pathRed = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.58, 0)
      ..lineTo(size.width * 0.42, size.height)
      ..lineTo(0, size.height)
      ..close();
    final pathBlue = Path()
      ..moveTo(size.width * 0.58, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.42, size.height)
      ..close();

    canvas.drawPath(
      pathRed,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF3D5A), Color(0xFF9B0020)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      pathBlue,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF2AD0FF), Color(0xFF005A8A)],
        ).createShader(Offset.zero & size),
    );

    // Halftone dots
    final dot = Paint()..color = Colors.black.withOpacity(0.12);
    const step = 14.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        final r = ((x + y) % 28 < 14) ? 1.6 : 1.1;
        canvas.drawCircle(Offset(x, y), r, dot);
      }
    }

    // Lightning bolts (simple zigzags)
    final bolt = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;
    void drawBolt(double cx, double cy, double s) {
      final p = Path()
        ..moveTo(cx, cy)
        ..lineTo(cx + 8 * s, cy + 18 * s)
        ..lineTo(cx - 2 * s, cy + 18 * s)
        ..lineTo(cx + 10 * s, cy + 42 * s);
      canvas.drawPath(p, bolt);
    }

    drawBolt(size.width * 0.18, size.height * 0.22, 1);
    drawBolt(size.width * 0.78, size.height * 0.55, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ArcadeDifficultyRail extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String label;

  const ArcadeDifficultyRail({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tint = Color.lerp(ArcadeChrome.blue, ArcadeChrome.red, (value - 1) / 9)!;

    return Column(
      children: [
        Text(
          '$value  ·  ${label.toUpperCase()}',
          style: ArcadeChrome.display(size: 28, color: tint),
        ),
        const SizedBox(height: 12),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF08080C),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: [
              BoxShadow(
                color: tint.withOpacity(0.25),
                blurRadius: 12,
              ),
            ],
          ),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 14,
              trackShape: const _ArcadeGradientTrack(),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: ArcadeChrome.yellow,
              overlayColor: ArcadeChrome.yellow.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 13,
                elevation: 3,
              ),
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (v) => onChanged(v.round().clamp(1, 10)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EASY',
              style: ArcadeChrome.ui(size: 11, color: ArcadeChrome.blue),
            ),
            Text(
              'HARD',
              style: ArcadeChrome.ui(size: 11, color: ArcadeChrome.red),
            ),
          ],
        ),
      ],
    );
  }
}

class _ArcadeGradientTrack extends SliderTrackShape with BaseSliderTrackShape {
  const _ArcadeGradientTrack();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final rrect = RRect.fromRectAndRadius(
      trackRect,
      Radius.circular(trackRect.height / 2),
    );
    context.canvas.drawRRect(rrect, Paint()..color = const Color(0xFF1A1A22));
    context.canvas.drawRRect(
      rrect,
      Paint()
        ..shader = const LinearGradient(
          colors: [ArcadeChrome.blue, ArcadeChrome.yellow, ArcadeChrome.red],
        ).createShader(trackRect),
    );
    final tick = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.5;
    for (int i = 1; i < 10; i++) {
      final x = trackRect.left + trackRect.width * (i / 10);
      context.canvas.drawLine(
        Offset(x, trackRect.top + 3),
        Offset(x, trackRect.bottom - 3),
        tick,
      );
    }
  }
}

class ArcadeBackHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final String? pill;

  const ArcadeBackHeader({
    Key? key,
    required this.title,
    required this.onBack,
    this.pill,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 12, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          if (pill != null) ...[
            ArcadePill(label: pill!, color: ArcadeChrome.yellow),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title.toUpperCase(),
              textAlign: pill != null ? TextAlign.left : TextAlign.center,
              style: ArcadeChrome.display(size: 22, color: ArcadeChrome.yellow),
            ),
          ),
          if (pill == null) const SizedBox(width: 48),
        ],
      ),
    );
  }
}
