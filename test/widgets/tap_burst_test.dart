import 'package:clickbattle/components/tap_burst_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TapBurstController caps at 12 live bursts', () {
    final c = TapBurstController();
    for (int i = 0; i < 20; i++) {
      c.spawn(Offset(i.toDouble(), 0), Colors.yellow, 0.1);
    }
    expect(c.liveCount, TapBurstController.maxBursts);
  });

  test('bursts expire after lifetime', () {
    final c = TapBurstController();
    c.spawn(Offset.zero, Colors.yellow, 0);
    expect(c.tick(0.2), isTrue);
    expect(c.liveCount, 1);
    expect(c.tick(0.3), isFalse);
    expect(c.liveCount, 0);
  });
}
