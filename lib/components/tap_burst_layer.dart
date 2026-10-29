import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:clickbattle/constants/app_images.dart';
import 'package:clickbattle/components/arcade_chrome.dart';

/// Pooled comic burst + floating "+1" overlay. Caps simultaneous FX at [maxBursts].
class TapBurstController extends ChangeNotifier {
  static const int maxBursts = 16;
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
    super.dispose();
  }

  static const double _starSize = 72;
  static const double _plusWidth = 44;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final b in widget.controller._pool) {
      if (!b.active) continue;
      final t = (b.born / TapBurstController.lifetime).clamp(0.0, 1.0);
      final fade = 1.0 - t;
      final o = b.origin;
      children.add(
        Positioned(
          left: o.dx - _starSize / 2,
          top: o.dy - _starSize / 2,
          child: Transform.scale(
            scale: 0.6 + 0.7 * t,
            child: Image.asset(
              AppImages.sparkStar,
              width: _starSize,
              height: _starSize,
              opacity: AlwaysStoppedAnimation<double>(fade),
              gaplessPlayback: true,
            ),
          ),
        ),
      );
      children.add(
        Positioned(
          left: o.dx - _plusWidth / 2 + math.sin(b.angle) * 10 * t,
          top: o.dy - 70 - 48 * t,
          child: Transform.rotate(
            angle: b.angle,
            child: Image.asset(
              AppImages.plus1,
              width: _plusWidth,
              opacity: AlwaysStoppedAnimation<double>(fade),
              gaplessPlayback: true,
            ),
          ),
        ),
      );
    }
    return IgnorePointer(
      child: SizedBox.expand(
        child: Stack(clipBehavior: Clip.none, children: children),
      ),
    );
  }
}
