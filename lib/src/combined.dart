import 'package:combined_animation/src/config.dart';
import 'package:flutter/cupertino.dart';

/// Combine state of [CombinedAnimation]
enum CombineState {
  beginIn,
  endIn,
  beginOut,
  endOut,
}

const _defaultDuration = Duration(milliseconds: 300);

/// A combined animation to show in or hide out a widget
class CombinedAnimation extends StatefulWidget {
  const CombinedAnimation({
    Key? key,
    required this.config,
    AnimationConfig? outConfig,
    required this.child,
    AnimationType state = AnimationType.start,
    this.onEndIn,
    this.onEndOut,
  })  : outConfig = outConfig ?? ~config,
        state = state == AnimationType.start
            ? CombineState.beginIn
            : CombineState.beginOut,
        super(key: key);

  /// Show in animation config
  final AnimationConfig config;

  /// Hide out animation config. defaults to flip [config]
  final AnimationConfig outConfig;

  /// State to pass in
  final CombineState state;

  /// Callback when show in animation is complete
  final VoidCallback? onEndIn;

  /// Callback when hide out animation is complete
  final VoidCallback? onEndOut;

  /// The child will be animate
  final Widget child;

  @override
  State<CombinedAnimation> createState() => _CombinedAnimationState();
}

class _CombinedAnimationState extends State<CombinedAnimation>
    with SingleTickerProviderStateMixin<CombinedAnimation> {
  late AnimationSnapshot snapshot;

  late final animation = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
    snapshot = widget.config.snapshot(0);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      animation
          .animateTo(
        1,
        duration: widget.config.duration ?? _defaultDuration,
        curve: widget.config.curve ?? Curves.easeIn,
      )
          .whenComplete(() {
        widget.onEndIn?.call();
      });
    });
    animation.addListener(_onAnimation);
  }

  @override
  void dispose() {
    animation.removeListener(_onAnimation);
    animation.dispose();
    super.dispose();
  }

  /// Update state and animate to hide out
  @override
  void didUpdateWidget(covariant CombinedAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == CombineState.beginOut &&
        widget.state.index > oldWidget.state.index) {
      animation
          .animateTo(
        0,
        duration: widget.config.duration ?? _defaultDuration,
        curve: widget.config.curve ?? Curves.easeOut,
      )
          .whenComplete(() {
        widget.onEndOut?.call();
      });
    }
  }

  void _onAnimation() {
    setState(() {
      snapshot = widget.config.snapshot(animation.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    if (widget.config.hasMatrix) {
      child = Transform(
        transform: snapshot.transform!,
        alignment: Alignment.center,
        child: widget.child,
      );
    }
    if (widget.config.hasOpacity) {
      child = Opacity(
        opacity: snapshot.opacity!,
        child: child,
      );
    }

    if (widget.config.hasAlign) {
      child = Align(
        alignment: snapshot.alignment!,
        child: child,
      );
    }

    return child;
  }
}
