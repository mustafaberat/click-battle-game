import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clickbattle/constants/app_colors.dart';
import 'package:clickbattle/constants/app_images.dart';

/// Arcade Strip Comic chrome — Bangers titles, Exo 2 UI, hard ink outlines.
class ArcadeChrome {
  static const Color yellow = AppColors.comicYellow;
  static const Color yellowDark = AppColors.comicYellowDark;
  static const Color red = AppColors.comicRed;
  static const Color blue = AppColors.comicBlue;
  static const Color panel = AppColors.comicPanel;
  static const Color panelBorder = AppColors.inkBlack;
  static const Color navy = AppColors.comicNavy;
  static const Color ink = AppColors.inkBlack;

  /// CJK / emoji. ElevatedButton DefaultTextStyle replace ettiği için
  /// tema fallback'i yetmez; stillerin kendi listesi olmalı.
  static const List<String> fontFallback = [
    'Hiragino Sans GB',
    'Hiragino Sans',
    'PingFang SC',
    'Noto Sans CJK SC',
    'Apple SD Gothic Neo',
    'Apple Color Emoji',
    'Noto Color Emoji',
  ];

  static TextStyle display({
    double size = 36,
    Color color = Colors.white,
    Color? outline,
    double outlineWidth = 2.5,
  }) {
    return TextStyle(
      fontFamily: 'Bangers',
      fontFamilyFallback: fontFallback,
      fontSize: size,
      color: color,
      letterSpacing: 1.5,
      height: 1.0,
      // outlineWidth <= 0 renders a crisp, shadow-free number (e.g. dark
      // ink on a yellow tile, where an ink drop shadow smears the glyphs).
      shadows: outlineWidth <= 0
          ? const []
          : [
              Shadow(
                color: outline ?? Colors.black,
                offset: Offset(outlineWidth, outlineWidth),
                blurRadius: 0,
              ),
              Shadow(
                color: outline ?? Colors.black,
                offset: Offset(-outlineWidth * 0.35, outlineWidth * 0.35),
                blurRadius: 0,
              ),
            ],
    );
  }

  static TextStyle ui({
    double size = 14,
    FontWeight weight = FontWeight.w800,
    Color color = Colors.white,
    double letterSpacing = 1.2,
  }) {
    return TextStyle(
      fontFamily: 'Exo2',
      fontFamilyFallback: fontFallback,
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
        border: Border.all(color: accent ?? ink, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: ink,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      );

  static ButtonStyle yellowButton() => ElevatedButton.styleFrom(
        backgroundColor: yellow,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: ink, width: 3.5),
        ),
        textStyle: ui(size: 18, color: Colors.black, letterSpacing: 2),
      );
}

/// Chunky comic CTA: 3–4px ink outline + hard drop shadow that collapses on press.
class ComicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final Color foregroundColor;
  final double height;
  final double radius;
  final double shadowOffset;
  final double outlineWidth;
  final EdgeInsetsGeometry padding;

  const ComicButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.color = ArcadeChrome.yellow,
    this.foregroundColor = Colors.black,
    this.height = 56,
    this.radius = 14,
    this.shadowOffset = 5,
    this.outlineWidth = 3.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  }) : super(key: key);

  @override
  State<ComicButton> createState() => _ComicButtonState();
}

class _ComicButtonState extends State<ComicButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || widget.onPressed == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final dy = _pressed ? widget.shadowOffset : 0.0;
    return SizedBox(
      height: widget.height + widget.shadowOffset,
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.onPressed == null ? null : (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: widget.onPressed == null
            ? null
            : (_) {
                _setPressed(false);
                widget.onPressed!();
              },
        child: Padding(
          padding: EdgeInsets.only(top: dy, bottom: widget.shadowOffset - dy),
          child: Stack(
            children: [
              if (!_pressed)
                Positioned(
                  left: 0,
                  right: 0,
                  top: widget.shadowOffset,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: ArcadeChrome.ink,
                      borderRadius: BorderRadius.circular(widget.radius),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: widget.height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.onPressed == null
                        ? widget.color.withOpacity(0.45)
                        : widget.color,
                    borderRadius: BorderRadius.circular(widget.radius),
                    border: Border.all(
                      color: ArcadeChrome.ink,
                      width: widget.outlineWidth,
                    ),
                  ),
                  child: Padding(
                    padding: widget.padding,
                    child: DefaultTextStyle(
                      style: ArcadeChrome.ui(
                        size: 16,
                        color: widget.foregroundColor,
                        letterSpacing: 1.4,
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          color: widget.foregroundColor,
                          size: 22,
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: widget.child,
                          ),
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
    );
  }
}

/// Navy comic card with optional slanted yellow sticker label.
class ComicPanel extends StatelessWidget {
  final String? label;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;
  final EdgeInsetsGeometry margin;

  const ComicPanel({
    Key? key,
    this.label,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(14, 22, 14, 14),
    this.accent,
    this.margin = const EdgeInsets.only(bottom: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            margin: label != null
                ? const EdgeInsets.only(top: 10)
                : EdgeInsets.zero,
            padding: padding,
            decoration: ArcadeChrome.panelBox(accent: accent),
            child: child,
          ),
          if (label != null)
            Positioned(
              left: 12,
              top: 0,
              child: Transform.rotate(
                angle: -0.08,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ArcadeChrome.yellow,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ArcadeChrome.ink, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: ArcadeChrome.ink,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    label!.toUpperCase(),
                    style: ArcadeChrome.ui(
                      size: 11,
                      color: Colors.black,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Halftone dot field on navy (or a tinted wash). Speed lines optional.
class HalftoneBackground extends StatelessWidget {
  final Color color;
  final Color? wash;
  final bool speedLines;
  final double dotOpacity;

  const HalftoneBackground({
    Key? key,
    this.color = ArcadeChrome.navy,
    this.wash,
    this.speedLines = false,
    this.dotOpacity = 0.22,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String tile;
    if (color == ArcadeChrome.red) {
      tile = AppImages.halftoneRed;
    } else if (color == ArcadeChrome.blue) {
      tile = AppImages.halftoneBlue;
    } else if (color == ArcadeChrome.navy) {
      tile = AppImages.halftoneNavy;
    } else {
      tile = AppImages.halftoneDots;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        image: DecorationImage(
          image: AssetImage(tile),
          repeat: ImageRepeat.repeat,
          alignment: Alignment.topLeft,
          filterQuality: FilterQuality.medium,
        ),
      ),
      child: wash == null
          ? const SizedBox.expand()
          : ColoredBox(color: wash!, child: const SizedBox.expand()),
    );
  }
}

/// Navy halftone backdrop behind the raster home hero art.
class ComicHeroBackdrop extends StatelessWidget {
  final Animation<double>? handT;
  final Animation<double>? glintT;

  const ComicHeroBackdrop({Key? key, this.handT, this.glintT})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const HalftoneBackground();
  }
}

/// Classic comic lightning bolt path, origin at the top center of the bolt.
Path lightningPath(Offset top, double height, double width) {
  final cx = top.dx;
  final y = top.dy;
  final w = width;
  final h = height;
  return Path()
    ..moveTo(cx + w * 0.18, y)
    ..lineTo(cx - w * 0.22, y + h * 0.40)
    ..lineTo(cx + w * 0.02, y + h * 0.40)
    ..lineTo(cx - w * 0.38, y + h)
    ..lineTo(cx + w * 0.28, y + h * 0.56)
    ..lineTo(cx + w * 0.04, y + h * 0.56)
    ..close();
}

class LightningBolt extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const LightningBolt({
    Key? key,
    this.width = 22,
    this.height = 32,
    this.color = ArcadeChrome.yellow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _MiniBoltPainter(color),
    );
  }
}

class _MiniBoltPainter extends CustomPainter {
  final Color color;
  _MiniBoltPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = lightningPath(
      Offset(size.width * 0.5, 1),
      size.height - 2,
      size.width,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = ArcadeChrome.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _MiniBoltPainter old) => old.color != color;
}

/// Halftone-washed arena half used in-game and How to Play.
class ComicArena extends StatelessWidget {
  final Color color;
  final bool alignTop;

  const ComicArena({Key? key, required this.color, required this.alignTop})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String tile;
    if (color == ArcadeChrome.red) {
      tile = AppImages.halftoneRed;
    } else if (color == ArcadeChrome.blue) {
      tile = AppImages.halftoneBlue;
    } else {
      tile = AppImages.halftoneDots;
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            image: DecorationImage(
              image: AssetImage(tile),
              repeat: ImageRepeat.repeat,
              alignment: Alignment.topLeft,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: alignTop ? Alignment.topCenter : Alignment.bottomCenter,
              end: alignTop ? Alignment.bottomCenter : Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.18), Colors.transparent],
              stops: const [0.0, 0.6],
            ),
          ),
        ),
      ],
    );
  }
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
        border: Border.all(color: ArcadeChrome.ink, width: 2.5),
        boxShadow: const [
          BoxShadow(
              color: ArcadeChrome.ink, offset: Offset(2, 2), blurRadius: 0),
        ],
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

/// Legacy diagonal vs backdrop — kept so older call sites still compile.
class ArcadeVsBackdrop extends StatelessWidget {
  const ArcadeVsBackdrop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ComicHeroBackdrop();
  }
}

/// 10-segment blue→red rail with a lightning thumb. Values are 1–10.
class ArcadeDifficultyRail extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String label;
  final String easyLabel;
  final String hardLabel;

  const ArcadeDifficultyRail({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.easyLabel = 'EASY',
    this.hardLabel = 'HARD',
  }) : super(key: key);

  @override
  State<ArcadeDifficultyRail> createState() => _ArcadeDifficultyRailState();
}

class _ArcadeDifficultyRailState extends State<ArcadeDifficultyRail>
    with SingleTickerProviderStateMixin {
  late AnimationController _hot;

  @override
  void initState() {
    super.initState();
    _hot = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _syncHot();
  }

  @override
  void didUpdateWidget(covariant ArcadeDifficultyRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _syncHot();
  }

  void _syncHot() {
    if (widget.value >= 8) {
      _hot.repeat(reverse: true);
    } else {
      _hot.stop();
      _hot.value = 0;
    }
  }

  @override
  void dispose() {
    _hot.dispose();
    super.dispose();
  }

  void _setFromLocal(double dx, double width) {
    final t = (dx / width).clamp(0.0, 1.0);
    final next = (t * 9).round() + 1;
    if (next != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tint = Color.lerp(
      ArcadeChrome.blue,
      ArcadeChrome.red,
      (widget.value - 1) / 9,
    )!;

    return Column(
      children: [
        Text(
          '${widget.value}  -  ${widget.label.toUpperCase()}',
          style: ArcadeChrome.display(size: 26, color: tint),
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _hot,
          builder: (context, _) {
            final glow = widget.value >= 8 ? 0.35 + _hot.value * 0.45 : 0.0;
            return LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) => _setFromLocal(d.localPosition.dx, w),
                  onHorizontalDragUpdate: (d) =>
                      _setFromLocal(d.localPosition.dx, w),
                  child: SizedBox(
                    height: 44,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A142E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Color.lerp(
                                      ArcadeChrome.ink,
                                      ArcadeChrome.red,
                                      glow,
                                    ) ??
                                    ArcadeChrome.ink,
                                width: 3,
                              ),
                              boxShadow: [
                                if (glow > 0)
                                  BoxShadow(
                                    color: ArcadeChrome.red.withOpacity(glow),
                                    blurRadius: 10,
                                  ),
                              ],
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              children: List.generate(10, (i) {
                                final t = i / 9;
                                final color = Color.lerp(
                                  ArcadeChrome.blue,
                                  ArcadeChrome.red,
                                  t,
                                )!;
                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.black.withOpacity(0.35),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment(
                            ((widget.value - 1) / 9) * 2 - 1,
                            0,
                          ),
                          child: const LightningBolt(width: 26, height: 36),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.easyLabel.toUpperCase(),
              style: ArcadeChrome.ui(size: 11, color: ArcadeChrome.blue),
            ),
            Text(
              widget.hardLabel.toUpperCase(),
              style: ArcadeChrome.ui(size: 11, color: ArcadeChrome.red),
            ),
          ],
        ),
      ],
    );
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
              style: ArcadeChrome.display(size: 26, color: ArcadeChrome.yellow),
            ),
          ),
          if (pill == null) const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// Yellow comic timer / info chip. Turns red + shakes when [urgent].
class ComicTimerChip extends StatefulWidget {
  final IconData icon;
  final String value;
  final bool urgent;
  final bool pulse;

  const ComicTimerChip({
    Key? key,
    required this.icon,
    required this.value,
    this.urgent = false,
    this.pulse = false,
  }) : super(key: key);

  @override
  State<ComicTimerChip> createState() => _ComicTimerChipState();
}

class _ComicTimerChipState extends State<ComicTimerChip>
    with TickerProviderStateMixin {
  late final AnimationController _shake;
  late final AnimationController _breathe;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
    );
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.urgent) _shake.repeat(reverse: true);
    if (widget.pulse) _breathe.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant ComicTimerChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.urgent && !_shake.isAnimating) {
      _shake.repeat(reverse: true);
    } else if (!widget.urgent && _shake.isAnimating) {
      _shake.stop();
      _shake.value = 0;
    }
    if (widget.pulse && !_breathe.isAnimating) {
      _breathe.repeat(reverse: true);
    } else if (!widget.pulse && _breathe.isAnimating) {
      _breathe.stop();
      _breathe.value = 0;
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.urgent ? ArcadeChrome.red : ArcadeChrome.yellow;
    final fg = widget.urgent ? Colors.white : Colors.black;
    return AnimatedBuilder(
      animation: Listenable.merge([_shake, _breathe]),
      builder: (context, child) {
        final dx = widget.urgent ? (_shake.value - 0.5) * 8 : 0.0;
        final scale = widget.pulse ? 1 + _breathe.value * 0.04 : 1.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ArcadeChrome.ink, width: 3),
          boxShadow: const [
            BoxShadow(
              color: ArcadeChrome.ink,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: fg, size: 18),
            const SizedBox(width: 6),
            Text(
              widget.value,
              style: ArcadeChrome.ui(size: 16, color: fg, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}
