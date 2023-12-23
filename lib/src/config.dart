import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

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
  /// Slide in from `start` [Alignment]
  static AnimationConfig slideInFrom(Alignment start) => AnimationConfig(
        startAlign: start,
        endAlign: Alignment.center,
        curve: Curves.easeOutQuad,
      );

  /// Slide out to `end` [Alignment]
  static AnimationConfig slideOutTo(Alignment end) => AnimationConfig(
        startAlign: Alignment.center,
        endAlign: end,
        curve: Curves.easeOutQuad,
      );

  /// From out top to center
  @Deprecated('use expandIn')
  static AnimationConfig get slideIn => slideInFrom(const Alignment(0, -3));

  /// From center to out top
  @Deprecated('use expandIn')
  static AnimationConfig get slideOut => slideOutTo(const Alignment(0, -3));

  @Deprecated('use expandIn')
  static AnimationConfig get slideDown => expandIn;

  /// Expand in
  static const expandIn = AnimationConfig(
    startSize: Size.zero,
    endSize: Size.infinite,
    curve: Curves.easeOutQuad,
  );

  @Deprecated('use shrinkOut')
  static AnimationConfig get slideUp => shrinkOut;

  /// Shrink out
  static const shrinkOut = AnimationConfig(
    startSize: Size.infinite,
    endSize: Size.zero,
    curve: Curves.easeOutQuad,
  );

  /// Slide and fade in from `start` [Alignment]
  static AnimationConfig slideAndFadeInFrom(Alignment start) => AnimationConfig(
        startAlign: start,
        endAlign: Alignment.center,
        startOpacity: 0,
        endOpacity: 1,
        curve: Curves.easeOutQuad,
      );

  /// From out top to center with fade in
  @Deprecated('use slideAndFadeInFrom')
  static AnimationConfig get slideAndFadeIn => slideAndFadeInFrom(
        const Alignment(0, -3),
      );

  /// Slide and fade out from `end` [Alignment]
  static AnimationConfig slideAndFadeOutTo(Alignment end) => AnimationConfig(
        startAlign: Alignment.center,
        endAlign: end,
        startOpacity: 1,
        endOpacity: 0,
        curve: Curves.easeOutQuad,
      );

  /// From center to out top with fade out
  @Deprecated('use slideAndFadeOutTo')
  static AnimationConfig get slideAndFadeOut => slideAndFadeOutTo(
        const Alignment(0, -3),
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
  static final AnimationConfig zoomOut = ~zoomIn;

  /// Zoom in with fade in
  static final fadeAndZoomIn = AnimationConfig(
    startOpacity: 0,
    endOpacity: 1,
    startTransform: Matrix4.identity()..scale(0.5),
    endTransform: Matrix4.identity(),
    curve: Curves.easeOutQuad,
  );

  /// Zoom out with fade out
  static final AnimationConfig fadeAndZoomOut = ~fadeAndZoomIn;

  static final vFlipIn = AnimationConfig(
    startTransform: Matrix4.identity()..rotateX(math.pi / 2),
    endTransform: Matrix4.identity(),
    curve: Curves.easeOutQuad,
  );

  static final AnimationConfig vFlipOut = ~vFlipIn;

  static final hFlipIn = AnimationConfig(
    startTransform: Matrix4.identity()..rotateY(math.pi / 2),
    endTransform: Matrix4.identity(),
    curve: Curves.easeOutQuad,
  );

  static final AnimationConfig hFlipOut = ~hFlipIn;

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
          'Align animation need start and end non null',
        ),
        assert(
          (startOpacity != null && endOpacity != null) ||
              (startOpacity == null && endOpacity == null),
          'Opacity animation need start and end non null',
        ),
        assert(
          (startTransform != null && endTransform != null) ||
              (startTransform == null && endTransform == null),
          'Transform animation need start and end non null',
        ),
        assert(
          (startSize != null && endSize != null) ||
              (startSize == null && endSize == null),
          'Transform animation need start and end non null',
        );

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
      matrix4 = Matrix4.fromList(
        List.generate(
          16,
          (idx) => lerpDouble(startTransform![idx], endTransform![idx], value)!,
        ),
      );
    }
    double? opacity;
    if (hasOpacity) {
      opacity = lerpDouble(startOpacity, endOpacity, value) ?? 1;
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

  /// Combine two config
  AnimationConfig operator |(AnimationConfig other) {
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
  AnimationConfig operator ~() {
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
