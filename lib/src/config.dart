import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// How to create a snapshot
enum AnimationType {
  start,
  end,
}

/// A snapshot of an animation config
class AnimationSnapshot {
  final Matrix4? transform;
  final double? opacity;
  final AlignmentGeometry? alignment;
  AnimationSnapshot({
    this.transform,
    this.opacity,
    this.alignment,
  });

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
    alignStart: Alignment(0, -3),
    alignEnd: Alignment(0, 0),
    curve: Curves.easeOutQuad,
  );

  /// From center to out top
  static const slideOut = AnimationConfig(
    alignStart: Alignment(0, 0),
    alignEnd: Alignment(0, -3),
    curve: Curves.easeOutQuad,
  );

  static const slideDown = AnimationConfig(
    sizeStart: Size.zero,
    sizeEnd: Size.infinite,
    curve: Curves.easeOutQuad,
  );

  /// From center to out top
  static const slideUp = AnimationConfig(
    sizeStart: Size.infinite,
    sizeEnd: Size.zero,
    curve: Curves.easeOutQuad,
  );

  /// From out top to center with fade in
  static const slideAndFadeIn = AnimationConfig(
    alignStart: Alignment(0, -3),
    alignEnd: Alignment(0, 0),
    opacityStart: 0,
    opacityEnd: 1,
    curve: Curves.easeOutQuad,
  );

  /// From center to out top with fade out
  static const slideAndFadeOut = AnimationConfig(
    alignStart: Alignment(0, 0),
    alignEnd: Alignment(0, -3),
    opacityStart: 1,
    opacityEnd: 0,
    curve: Curves.easeOutQuad,
  );

  /// Fade in
  static const fadeIn = AnimationConfig(
    opacityStart: 0,
    opacityEnd: 1,
    curve: Curves.easeOutQuad,
  );

  /// Fade out
  static const fadeOut = AnimationConfig(
    opacityStart: 1,
    opacityEnd: 0,
    curve: Curves.easeOutQuad,
  );

  /// Zoom in
  static final zoomIn = AnimationConfig(
    transformStart: Matrix4.identity()..scale(0.0),
    transformEnd: Matrix4.identity(),
    curve: Curves.easeOutQuad,
  );

  /// Zoom out
  static final zoomOut = ~zoomIn;

  /// Zoom in with fade in
  static final fadeAndZoomIn = AnimationConfig(
    opacityStart: 0,
    opacityEnd: 1,
    transformStart: Matrix4.identity()..scale(0.5),
    transformEnd: Matrix4.identity(),
    curve: Curves.easeOutQuad,
  );

  /// Zoom out with fade out
  static final fadeAndZoomOut = ~fadeAndZoomIn;

  static final vFlipIn = AnimationConfig(
    transformStart: Matrix4.identity()..rotateX(math.pi / 2),
    transformEnd: Matrix4.identity(),
    curve: Curves.easeOutQuad,
  );

  static final vFlipOut = ~vFlipIn;

  static final hFlipIn = AnimationConfig(
    transformStart: Matrix4.identity()..rotateY(math.pi / 2),
    transformEnd: Matrix4.identity(),
    curve: Curves.easeOutQuad,
  );

  static final hFlipOut = ~hFlipIn;

  /// All paired params must be provided or null.
  const AnimationConfig({
    this.alignStart,
    this.alignEnd,
    this.opacityStart,
    this.opacityEnd,
    this.transformStart,
    this.transformEnd,
    this.sizeStart,
    this.sizeEnd,
    this.duration,
    this.curve,
  })  : assert(
            (alignStart != null && alignEnd != null) ||
                (alignStart == null && alignEnd == null),
            'Align animation need start and end non null'),
        assert(
            (opacityStart != null && opacityEnd != null) ||
                (opacityStart == null && opacityEnd == null),
            'Opacity animation need start and end non null'),
        assert(
            (transformStart != null && transformEnd != null) ||
                (transformStart == null && transformEnd == null),
            'Transform animation need start and end non null'),
        assert(
            (sizeStart != null && sizeEnd != null) ||
                (sizeStart == null && sizeEnd == null),
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
          alignStart: align,
          alignEnd: align == null ? null : Alignment.center,
          opacityStart: opacity,
          opacityEnd: opacity == null ? null : 1,
          transformStart: transform,
          transformEnd: transform == null ? null : Matrix4.identity(),
          sizeStart: size,
          sizeEnd: size == null ? null : Size.infinite,
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
          alignStart: align == null ? null : Alignment.center,
          alignEnd: align,
          opacityStart: opacity == null ? null : 1,
          opacityEnd: opacity,
          transformStart: transform == null ? null : Matrix4.identity(),
          transformEnd: transform,
          sizeStart: size == null ? null : Size.infinite,
          sizeEnd: size,
          duration: duration,
          curve: curve,
        );

  /// alignment
  final AlignmentGeometry? alignStart;
  final AlignmentGeometry? alignEnd;

  /// opacity
  final double? opacityStart;
  final double? opacityEnd;

  /// transform
  final Matrix4? transformStart;
  final Matrix4? transformEnd;

  /// size
  final Size? sizeStart;
  final Size? sizeEnd;

  final Duration? duration;
  final Curve? curve;

  bool get hasAlign => alignStart != null;
  bool get hasOpacity => opacityStart != null;
  bool get hasMatrix => transformStart != null;
  bool get hasSize => sizeStart != null;

  /// Generate a snapshot of current animation [value]
  AnimationSnapshot snapshot(double value) {
    if (value == 0) {
      return AnimationSnapshot(
        transform: transformStart,
        alignment: alignStart,
        opacity: opacityStart,
      );
    }
    if (value == 1) {
      return AnimationSnapshot(
        transform: transformEnd,
        alignment: alignEnd,
        opacity: opacityEnd,
      );
    }
    Matrix4? matrix4;
    if (hasMatrix) {
      matrix4 = Matrix4.fromList(List.generate(
        16,
        (idx) => _lerpValue(transformStart![idx], transformEnd![idx], value),
      ));
    }
    double? opacity;
    if (hasOpacity) {
      opacity = _lerpValue(opacityStart!, opacityEnd!, value);
    }
    AlignmentGeometry? alignment;
    if (hasAlign) {
      alignment = AlignmentGeometry.lerp(alignStart!, alignEnd!, value);
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
    AlignmentGeometry? alignStart,
    AlignmentGeometry? alignEnd,
    double? opacityStart,
    double? opacityEnd,
    Matrix4? transformStart,
    Matrix4? transformEnd,
    Size? sizeStart,
    Size? sizeEnd,
    Duration? duration,
    Curve? curve,
  }) =>
      AnimationConfig(
        alignStart: alignStart ?? this.alignStart,
        alignEnd: alignEnd ?? this.alignEnd,
        opacityStart: opacityStart ?? this.opacityStart,
        opacityEnd: opacityEnd ?? this.opacityEnd,
        transformStart: transformStart ?? this.transformStart,
        transformEnd: transformEnd ?? this.transformEnd,
        sizeStart: sizeStart ?? this.sizeStart,
        sizeEnd: sizeEnd ?? this.sizeEnd,
        duration: duration ?? this.duration,
        curve: curve ?? this.curve,
      );

  double _lerpValue(double start, double end, double value) {
    return start + (end - start) * value;
  }

  /// Combine two config
  operator |(AnimationConfig other) {
    return AnimationConfig(
      alignStart: alignStart ?? other.alignStart,
      alignEnd: alignEnd ?? other.alignEnd,
      opacityStart: opacityStart ?? other.opacityStart,
      opacityEnd: opacityEnd ?? other.opacityEnd,
      transformStart: transformStart ?? other.transformStart,
      transformEnd: transformEnd ?? other.transformEnd,
      sizeStart: sizeStart ?? other.sizeStart,
      sizeEnd: sizeEnd ?? other.sizeEnd,
      duration: (duration?.compareTo(other.duration ?? Duration.zero) ?? 0) > 0
          ? duration
          : other.duration,
      curve: curve,
    );
  }

  /// Flip config
  operator ~() {
    return AnimationConfig(
      alignStart: alignEnd,
      alignEnd: alignStart,
      opacityStart: opacityEnd,
      opacityEnd: opacityStart,
      transformStart: transformEnd,
      transformEnd: transformStart,
      sizeStart: sizeEnd,
      sizeEnd: sizeStart,
      duration: duration,
      curve: curve?.flipped,
    );
  }

  /// To json
  Map<String, dynamic> toJson() => {
        'alignStart': alignStart,
        'alignEnd': alignEnd,
        'opacityStart': opacityStart,
        'opacityEnd': opacityEnd,
        'transformStart': transformStart,
        'transformEnd': transformEnd,
        'sizeStart': sizeStart,
        'sizeEnd': sizeEnd,
        'duration': duration,
        'curve': curve,
      };

  @override
  String toString() => toJson().toString();
}
