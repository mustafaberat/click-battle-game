import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:clickbattle/components/arcade_chrome.dart';

/// Pooled comic burst + floating "+1" overlay. Caps simultaneous FX at [maxBursts].
class TapBurstController extends ChangeNotifier {
  static const int maxBursts = 12;
  static const double lifetime = 0.40;

  final List<_Burst> _pool = List<_Burst>.generate(
    maxBursts,
    (_) => _Burst(),
  );

  int _cursor = 0;

  int get liveCount {
    var n = 0;
    for (final b in _pool) {
      if (b.active) n++;
    }
    return n;
  }

  void spawn(Offset origin, Color color, double angle) {
    var slotIndex = _cursor;
    for (int i = 0; i < maxBursts; i++) {
      final idx = (_cursor + i) % maxBursts;
      if (!_pool[idx].active) {
        slotIndex = idx;
        break;
      }
      if (_pool[idx].born > _pool[slotIndex].born) {
        slotIndex = idx;
      }
    }
    _cursor = (slotIndex + 1) % maxBursts;
    final slot = _pool[slotIndex];
    slot.active = true;
    slot.origin = origin;
    slot.color = color;
    slot.angle = angle;
    slot.born = 0;
    notifyListeners();
  }

  /// Advance pooled bursts by [dt] seconds. Returns true if anything is live.
  bool tick(double dt) {
    var any = false;
    for (final b in _pool) {
      if (!b.active) continue;
      b.born += dt;
      if (b.born >= lifetime) {
        b.active = false;
      } else {
        any = true;
      }
    }
    return any;
  }
}

class _Burst {
  Offset origin = Offset.zero;
  Color color = ArcadeChrome.yellow;
  double angle = 0;
  double born = 0;
  bool active = false;
}

class TapBurstLayer extends StatefulWidget {
  final TapBurstController controller;

  const TapBurstLayer({Key? key, required this.controller}) : super(key: key);

  @override
  State<TapBurstLayer> createState() => _TapBurstLayerState();
}

class _TapBurstLayerState extends State<TapBurstLayer>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  Duration _last = Duration.zero;
  late final _BurstPainter _painter = _BurstPainter(widget.controller._pool);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSpawn);
  }

  @override
  void didUpdateWidget(covariant TapBurstLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onSpawn);
      widget.controller.addListener(_onSpawn);
      _painter.pool = widget.controller._pool;
    }
  }

  void _onSpawn() {
    _ticker ??= createTicker(_onTick)..start();
    if (!(_ticker!.isActive)) {
      _last = Duration.zero;
      _ticker!.start();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 0.016
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final live = widget.controller.tick(dt.clamp(0.0, 0.05));
    if (mounted) setState(() {});
    if (!live) {
      _ticker?.stop();
      _last = Duration.zero;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSpawn);
    _ticker?.dispose();
    _painter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _painter,
        size: Size.infinite,
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  List<_Burst> pool;
  final Paint _fill = Paint()..style = PaintingStyle.fill;
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeJoin = StrokeJoin.round;
  final TextPainter _label = TextPainter(textDirection: TextDirection.ltr);

  _BurstPainter(this.pool);

  static final Path starPath = _buildStar();

  static Path _buildStar() {
    const n = 8;
    final p = Path();
    for (int i = 0; i < n * 2; i++) {
      final r = i.isEven ? 22.0 : 10.0;
      final a = -math.pi / 2 + i * math.pi / n;
      final x = math.cos(a) * r;
      final y = math.sin(a) * r;
      if (i == 0) {
        p.moveTo(x, y);
      } else {
        p.lineTo(x, y);
      }
    }
    p.close();
    return p;
  }

  void dispose() {
    _label.dispose();
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in pool) {
      if (!b.active) continue;
      final t = (b.born / TapBurstController.lifetime).clamp(0.0, 1.0);
      final fade = 1.0 - t;
      final scale = 0.65 + t * 0.7;

      canvas.save();
      canvas.translate(b.origin.dx, b.origin.dy);
      canvas.scale(scale);
      _fill.color = const Color(0xFFFFF4A3).withOpacity(fade);
      canvas.drawPath(starPath, _fill);
      _stroke.color = ArcadeChrome.ink.withOpacity(fade);
      canvas.drawPath(starPath, _stroke);
      canvas.restore();

      final dy = -48 * t;
      final dx = math.sin(b.angle) * 10 * t;
      canvas.save();
      canvas.translate(b.origin.dx + dx, b.origin.dy + dy);
      canvas.rotate(b.angle);
      _label
        ..text = TextSpan(
          text: '+1',
          style: ArcadeChrome.display(
            size: 28,
            color: ArcadeChrome.yellow.withOpacity(fade),
            outline: ArcadeChrome.ink.withOpacity(fade),
          ),
        )
        ..layout();
      _label.paint(canvas, Offset(-_label.width / 2, -_label.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
