import 'package:flutter/widgets.dart';

enum AnimationType {
  start,
  end,
}

class AnimationSnapshot {
  final Matrix4? matrix;
  final double? opacity;
  final Alignment? alignment;
  AnimationSnapshot({
    this.matrix,
    this.opacity,
    this.alignment,
  });

  Map<String, dynamic> toJson() => {
        'matrix': matrix,
        'opacity': opacity,
        'alignment': alignment,
      };
  @override
  String toString() => toJson().toString();
}

/// Toast animation config
class AnimationConfig {
  static const slideIn = AnimationConfig(
    alignStart: Alignment(0, 1),
    alignEnd: Alignment(0, 0),
    curve: Curves.easeIn,
  );
  static const slideOut = AnimationConfig(
    alignStart: Alignment(0, 0),
    alignEnd: Alignment(0, 1),
    curve: Curves.easeOut,
  );

  static const fadeIn = AnimationConfig(
    opacityStart: 0,
    opacityEnd: 1,
    curve: Curves.easeIn,
  );
  static const fadeOut = AnimationConfig(
    opacityStart: 1,
    opacityEnd: 0,
    curve: Curves.easeOut,
  );

  static final zoomIn = AnimationConfig(
    matrixStart: Matrix4.identity()..scale(0.5),
    matrixEnd: Matrix4.identity(),
    curve: Curves.easeIn,
  );
  static final zoomOut = ~zoomIn;

  static final fadeAndZoomIn = AnimationConfig(
    opacityStart: 0,
    opacityEnd: 1,
    matrixStart: Matrix4.identity()..scale(0.7),
    matrixEnd: Matrix4.identity(),
    curve: Curves.easeIn,
  );

  static final fadeAndZoomOut = ~fadeAndZoomIn;

  const AnimationConfig({
    this.alignStart,
    this.alignEnd,
    this.opacityStart,
    this.opacityEnd,
    this.matrixStart,
    this.matrixEnd,
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
            (matrixStart != null && matrixEnd != null) ||
                (matrixStart == null && matrixEnd == null),
            'Matrix animation need start and end non null');

  final Alignment? alignStart;
  final Alignment? alignEnd;

  final double? opacityStart;
  final double? opacityEnd;

  final Matrix4? matrixStart;
  final Matrix4? matrixEnd;

  final Duration? duration;
  final Curve? curve;

  bool get hasAlign => alignStart != null;
  bool get hasOpacity => opacityStart != null;
  bool get hasMatrix => matrixStart != null;

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
        matrix: matrixStart,
        alignment: alignStart,
        opacity: opacityStart,
      );
    }
    if (value == 1) {
      return AnimationSnapshot(
        matrix: matrixEnd,
        alignment: alignEnd,
        opacity: opacityEnd,
      );
    }
    Matrix4? matrix4;
    if (hasMatrix) {
      matrix4 = Matrix4.fromList(List.generate(
        16,
        (idx) => combineValue(matrixStart![idx], matrixEnd![idx], value),
      ));
    }
    double? opacity;
    if (hasOpacity) {
      opacity = combineValue(opacityStart!, opacityEnd!, value);
    }
    Alignment? alignment;
    if (hasAlign) {
      alignment = Alignment(
        combineValue(alignStart!.x, alignEnd!.x, value),
        combineValue(alignStart!.y, alignEnd!.y, value),
      );
    }

    return AnimationSnapshot(
      matrix: matrix4,
      alignment: alignment,
      opacity: opacity,
    );
  }

  double combineValue(double start, double end, double value) {
    return start + (end - start) * value;
  }

  /// Combine two config
  operator |(AnimationConfig other) {
    return AnimationConfig(
      alignStart: alignStart ?? other.alignStart,
      alignEnd: alignEnd ?? other.alignEnd,
      opacityStart: opacityStart ?? other.opacityStart,
      opacityEnd: opacityEnd ?? other.opacityEnd,
      matrixStart: matrixStart ?? other.matrixStart,
      matrixEnd: matrixEnd ?? other.matrixEnd,
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
      matrixStart: matrixEnd,
      matrixEnd: matrixStart,
      duration: duration,
      curve: curve?.flipped,
    );
  }

  Map<String, dynamic> toJson() => {
        'alignStart': alignStart,
        'alignEnd': alignEnd,
        'opacityStart': opacityStart,
        'opacityEnd': opacityEnd,
        'matrixStart': matrixStart,
        'matrixEnd': matrixEnd,
        'duration': duration,
        'curve': curve,
      };

  @override
  String toString() => toJson().toString();
}
