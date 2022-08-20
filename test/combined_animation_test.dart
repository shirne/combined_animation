import 'package:flutter_test/flutter_test.dart';

import 'package:combined_animation/combined_animation.dart';

void main() {
  test('config', () {
    AnimationConfig config = AnimationConfig.fadeIn | AnimationConfig.zoomIn;

    expect(config.opacityStart, 0);
    expect(config.opacityEnd, 1);
    expect(config.matrixStart?[0], 0.5);
    expect(config.matrixEnd?[0], 1.0);
  });

  test('snapshot', () {
    AnimationConfig config = AnimationConfig.slideIn |
        AnimationConfig.fadeIn |
        AnimationConfig.zoomIn;

    expect(config.snapshot(0).alignment?.y, 1);
    expect(config.snapshot(0.5).alignment?.y, 0.5);
    expect(config.snapshot(1).alignment?.y, 0);

    expect(config.snapshot(0).opacity, 0);
    expect(config.snapshot(0.5).opacity, 0.5);
    expect(config.snapshot(1).opacity, 1);

    expect(config.snapshot(0).matrix?[0], 0.5);
    expect(config.snapshot(0.5).matrix?[0], 0.75);
    expect(config.snapshot(1).matrix?[0], 1);
  });
}
