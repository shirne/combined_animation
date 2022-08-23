import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:combined_animation/combined_animation.dart';

void main() {
  test('config', () {
    final AnimationConfig config =
        AnimationConfig.fadeIn | AnimationConfig.zoomIn;

    expect(config.startOpacity, 0);
    expect(config.endOpacity, 1);
    expect(config.startTransform?[0], 0.5);
    expect(config.endTransform?[0], 1.0);
  });

  test('snapshot', () {
    final AnimationConfig config = AnimationConfig.slideIn |
        AnimationConfig.fadeIn |
        AnimationConfig.zoomIn;

    final align = config.snapshot(0).alignment as Alignment?;
    expect(align?.y, 1);
    expect(align?.y, 0.5);
    expect(align?.y, 0);

    expect(config.snapshot(0).opacity, 0);
    expect(config.snapshot(0.5).opacity, 0.5);
    expect(config.snapshot(1).opacity, 1);

    expect(config.snapshot(0).transform?[0], 0.5);
    expect(config.snapshot(0.5).transform?[0], 0.75);
    expect(config.snapshot(1).transform?[0], 1);
  });
}
