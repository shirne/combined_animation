import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A snapshot of an animation config
class AnimationSnapshot {
  AnimationSnapshot({
    this.transform,
    this.opacity,
    this.alignment,
  });

  final Matrix4? transform;
  final double? opacity;
  final AlignmentGeometry? alignment;

  Map<String, dynamic> toJson() => {
        'transform': transform,
        'opacity': opacity,
        'alignment': alignment,
      };
  @override
  String toString() => toJson().toString();
}

/// Animation config
class AnimationConfig {
  /// From out top to center
  static const slideIn = AnimationConfig(
    startAlign: Alignment(0, -3),
    endAlign: Alignment(0, 0),
    curve: Curves.easeOutQuad,
  );

  /// From center to out top
  static const slideOut = AnimationConfig(
    startAlign: Alignment(0, 0),
    endAlign: Alignment(0, -3),
    curve: Curves.easeOutQuad,
  );

  static const slideDown = AnimationConfig(
    startSize: Size.zero,
    endSize: Size.infinite,
    curve: Curves.easeOutQuad,
  );

  /// From center to out top
  static const slideUp = AnimationConfig(
    startSize: Size.infinite,
    endSize: Size.zero,
    curve: Curves.easeOutQuad,
  );

  /// From out top to center with fade in
  static const slideAndFadeIn = AnimationConfig(
    startAlign: Alignment(0, -3),
    endAlign: Alignment(0, 0),
    startOpacity: 0,
    endOpacity: 1,
    curve: Curves.easeOutQuad,
  );

  /// From center to out top with fade out
  static const slideAndFadeOut = AnimationConfig(
    startAlign: Alignment(0, 0),
    endAlign: Alignment(0, -3),
    startOpacity: 1,
    endOpacity: 0,
    curve: Curves.easeOutQuad,
  );

  /// Fade in
  static const fadeIn = AnimationConfig(
    startOpacity: 0,
    endOpacity: 1,
    curve: Curves.easeOutQuad,
  );

  /// Fade out
  static const fadeOut = AnimationConfig(
    startOpacity: 1,
    endOpacity: 0,
    curve: Curves.easeOutQuad,
  );

  /// Zoom in
  static final zoomIn = AnimationConfig(
    startTransform: Matrix4.identity()..scale(0.0),
    endTransform: Matrix4.identity(),
    curve: Curves.easeOutQuad,
  );

  /// Zoom out
  static final zoomOut = ~zoomIn;

  /// Zoom in with fade in
  static final fadeAndZoomIn = AnimationConfig(
    startOpacity: 0,
    endOpacity: 1,
    startTransform: Matrix4.identity()..scale(0.5),
    endTransform: Matrix4.identity(),
    curve: Curves.easeOutQuad,
  );

  /// Zoom out with fade out
  static final fadeAndZoomOut = ~fadeAndZoomIn;

  static final vFlipIn = AnimationConfig(
    startTransform: Matrix4.identity()..rotateX(math.pi / 2),
    endTransform: Matrix4.identity(),
    curve: Curves.easeOutQuad,
  );

  static final vFlipOut = ~vFlipIn;

  static final hFlipIn = AnimationConfig(
    startTransform: Matrix4.identity()..rotateY(math.pi / 2),
    endTransform: Matrix4.identity(),
    curve: Curves.easeOutQuad,
  );

  static final hFlipOut = ~hFlipIn;

  /// All paired params must be provided or null.
  const AnimationConfig({
    this.startAlign,
    this.endAlign,
    this.startOpacity,
    this.endOpacity,
    this.startTransform,
    this.endTransform,
    this.startSize,
    this.endSize,
    this.duration,
    this.curve,
  })  : assert(
            (startAlign != null && endAlign != null) ||
                (startAlign == null && endAlign == null),
            'Align animation need start and end non null'),
        assert(
            (startOpacity != null && endOpacity != null) ||
                (startOpacity == null && endOpacity == null),
            'Opacity animation need start and end non null'),
        assert(
            (startTransform != null && endTransform != null) ||
                (startTransform == null && endTransform == null),
            'Transform animation need start and end non null'),
        assert(
            (startSize != null && endSize != null) ||
                (startSize == null && endSize == null),
            'Transform animation need start and end non null');

  /// Quick create an enter config
  AnimationConfig.enter({
    AlignmentGeometry? align,
    double? opacity,
    Matrix4? transform,
    Size? size,
    Duration? duration,
    Curve? curve,
  }) : this(
          startAlign: align,
          endAlign: align == null ? null : Alignment.center,
          startOpacity: opacity,
          endOpacity: opacity == null ? null : 1,
          startTransform: transform,
          endTransform: transform == null ? null : Matrix4.identity(),
          startSize: size,
          endSize: size == null ? null : Size.infinite,
          duration: duration,
          curve: curve,
        );

  /// Quick create a leave config
  AnimationConfig.leave({
    AlignmentGeometry? align,
    double? opacity,
    Matrix4? transform,
    Size? size,
    Duration? duration,
    Curve? curve,
  }) : this(
          startAlign: align == null ? null : Alignment.center,
          endAlign: align,
          startOpacity: opacity == null ? null : 1,
          endOpacity: opacity,
          startTransform: transform == null ? null : Matrix4.identity(),
          endTransform: transform,
          startSize: size == null ? null : Size.infinite,
          endSize: size,
          duration: duration,
          curve: curve,
        );

  /// alignment
  final AlignmentGeometry? startAlign;
  final AlignmentGeometry? endAlign;

  /// opacity
  final double? startOpacity;
  final double? endOpacity;

  /// transform
  final Matrix4? startTransform;
  final Matrix4? endTransform;

  /// size
  final Size? startSize;
  final Size? endSize;

  final Duration? duration;
  final Curve? curve;

  bool get hasAlign => startAlign != null;
  bool get hasOpacity => startOpacity != null;
  bool get hasMatrix => startTransform != null;
  bool get hasSize => startSize != null;

  /// Generate a snapshot of current animation [value]
  AnimationSnapshot snapshot(double value) {
    if (value == 0) {
      return AnimationSnapshot(
        transform: startTransform,
        alignment: startAlign,
        opacity: startOpacity,
      );
    }
    if (value == 1) {
      return AnimationSnapshot(
        transform: endTransform,
        alignment: endAlign,
        opacity: endOpacity,
      );
    }
    Matrix4? matrix4;
    if (hasMatrix) {
      matrix4 = Matrix4.fromList(List.generate(
        16,
        (idx) => _lerpValue(startTransform![idx], endTransform![idx], value),
      ));
    }
    double? opacity;
    if (hasOpacity) {
      opacity = _lerpValue(startOpacity!, endOpacity!, value);
    }
    AlignmentGeometry? alignment;
    if (hasAlign) {
      alignment = AlignmentGeometry.lerp(startAlign!, endAlign!, value);
    }

    return AnimationSnapshot(
      transform: matrix4,
      alignment: alignment,
      opacity: opacity,
    );
  }

  /// Creates a copy of this config
  /// but with the given fields replaced with the new values.
  AnimationConfig copyWith({
    AlignmentGeometry? startAlign,
    AlignmentGeometry? endAlign,
    double? startOpacity,
    double? endOpacity,
    Matrix4? startTransform,
    Matrix4? endTransform,
    Size? startSize,
    Size? endSize,
    Duration? duration,
    Curve? curve,
  }) =>
      AnimationConfig(
        startAlign: startAlign ?? this.startAlign,
        endAlign: endAlign ?? this.endAlign,
        startOpacity: startOpacity ?? this.startOpacity,
        endOpacity: endOpacity ?? this.endOpacity,
        startTransform: startTransform ?? this.startTransform,
        endTransform: endTransform ?? this.endTransform,
        startSize: startSize ?? this.startSize,
        endSize: endSize ?? this.endSize,
        duration: duration ?? this.duration,
        curve: curve ?? this.curve,
      );

  double _lerpValue(double start, double end, double value) {
    return start + (end - start) * value;
  }

  /// Combine two config
  operator |(AnimationConfig other) {
    return AnimationConfig(
      startAlign: startAlign ?? other.startAlign,
      endAlign: endAlign ?? other.endAlign,
      startOpacity: startOpacity ?? other.startOpacity,
      endOpacity: endOpacity ?? other.endOpacity,
      startTransform: startTransform ?? other.startTransform,
      endTransform: endTransform ?? other.endTransform,
      startSize: startSize ?? other.startSize,
      endSize: endSize ?? other.endSize,
      duration: (duration?.compareTo(other.duration ?? Duration.zero) ?? 0) > 0
          ? duration
          : other.duration,
      curve: curve,
    );
  }

  /// Flip config
  operator ~() {
    return AnimationConfig(
      startAlign: endAlign,
      endAlign: startAlign,
      startOpacity: endOpacity,
      endOpacity: startOpacity,
      startTransform: endTransform,
      endTransform: startTransform,
      startSize: endSize,
      endSize: startSize,
      duration: duration,
      curve: curve?.flipped,
    );
  }

  /// To json
  Map<String, dynamic> toJson() => {
        'startAlign': startAlign,
        'endAlign': endAlign,
        'startOpacity': startOpacity,
        'endOpacity': endOpacity,
        'startTransform': startTransform,
        'endTransform': endTransform,
        'startSize': startSize,
        'endSize': endSize,
        'duration': duration,
        'curve': curve,
      };

  @override
  String toString() => toJson().toString();
}
