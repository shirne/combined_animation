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
    alignStart: Alignment(0, -2),
    alignEnd: Alignment(0, 0),
    curve: Curves.easeOutQuad,
  );

  /// From center to out top
  static const slideOut = AnimationConfig(
    alignStart: Alignment(0, 0),
    alignEnd: Alignment(0, -2),
    curve: Curves.easeOutQuad,
  );

  /// From out top to center with fade in
  static const slideAndFadeIn = AnimationConfig(
    alignStart: Alignment(0, -2),
    alignEnd: Alignment(0, 0),
    opacityStart: 0,
    opacityEnd: 1,
    curve: Curves.easeOutQuad,
  );

  /// From center to out top with fade out
  static const slideAndFadeOut = AnimationConfig(
    alignStart: Alignment(0, 0),
    alignEnd: Alignment(0, -2),
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

  /// All paired params must be provided or null.
  const AnimationConfig({
    this.alignStart,
    this.alignEnd,
    this.opacityStart,
    this.opacityEnd,
    this.transformStart,
    this.transformEnd,
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
            'Transform animation need start and end non null');

  /// alignment
  final AlignmentGeometry? alignStart;
  final AlignmentGeometry? alignEnd;

  final double? opacityStart;
  final double? opacityEnd;

  final Matrix4? transformStart;
  final Matrix4? transformEnd;

  final Duration? duration;
  final Curve? curve;

  bool get hasAlign => alignStart != null;
  bool get hasOpacity => opacityStart != null;
  bool get hasMatrix => transformStart != null;

  /// Generate a snapshot of current animation [value]
  AnimationSnapshot snapshot(
    double value, [
    AnimationType type = AnimationType.start,
  ]) {
    if (type == AnimationType.end) {
      value = value - 1;
    }
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
      duration: duration,
      curve: curve, // No need for flip, value will be flip
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
        'duration': duration,
        'curve': curve,
      };

  @override
  String toString() => toJson().toString();
}
