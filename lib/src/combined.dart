import 'package:combined_animation/src/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Combine state of [CombinedAnimation]
enum CombineState {
  init,
  beginIn,
  endIn,
  beginOut,
  endOut,
  term,
}

const _defaultDuration = Duration(milliseconds: 300);

/// A combined animation to show in or hide out a widget
class CombinedAnimation extends StatefulWidget {
  const CombinedAnimation({
    Key? key,
    required this.config,
    AnimationConfig? outConfig,
    required this.child,
    AnimationType? state = AnimationType.start,
    this.slideDuration,
    this.onEndIn,
    this.onEndOut,
    this.onRemove,
    this.autoSlide = true,
    this.isControlled = false,
  })  : outConfig = outConfig ?? ~config,
        state = state == AnimationType.start
            ? CombineState.beginIn
            : state == AnimationType.end
                ? CombineState.beginOut
                : CombineState.init,
        super(key: key);

  /// Show in animation config
  final AnimationConfig config;

  /// Hide out animation config. defaults to flip [config]
  final AnimationConfig outConfig;

  /// State to pass in
  final CombineState state;

  /// Callback when show in animation is complete
  final void Function(CombinedAnimationController)? onEndIn;

  /// Callback when hide out animation is complete
  final Widget? Function(Size?)? onEndOut;

  /// Callback when size is Zero
  final VoidCallback? onRemove;

  /// The child will be animate
  final Widget child;

  /// Whether should auto slide up
  final bool autoSlide;

  /// If is controlled, State will not update state from widget
  final bool isControlled;

  final Duration? slideDuration;

  @override
  State<CombinedAnimation> createState() => _CombinedAnimationState();
}

class CombinedAnimationController {
  const CombinedAnimationController._(this._state);

  final _CombinedAnimationState _state;

  bool get isEntered => _state.state == CombineState.endIn;

  bool get isLeaved => _state.state.index >= CombineState.endOut.index;

  void init() {
    _state.init();
  }

  void stop() {
    _state.stop();
  }

  void enter({Duration? duration}) {
    _state.enter(duration: duration);
  }

  void leave({Duration? duration}) {
    _state.leave(duration: duration);
  }
}

class _CombinedAnimationState extends State<CombinedAnimation>
    with SingleTickerProviderStateMixin<CombinedAnimation> {
  late AnimationSnapshot snapshot;

  CombineState state = CombineState.init;

  late final animation = AnimationController(vsync: this);

  Widget? quitChild;
  Size? size;

  bool get isEnter =>
      state.index >= CombineState.beginIn.index &&
      state.index >= CombineState.endIn.index;
  bool get isLeave =>
      state.index >= CombineState.beginOut.index &&
      state.index >= CombineState.endOut.index;

  @override
  void initState() {
    super.initState();
    snapshot = widget.config.snapshot(0);
    state = widget.state;
    if (state == CombineState.beginIn) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        enter();
      });
    }
    animation.addListener(_onAnimation);
  }

  void init() {
    stop();
    state = CombineState.init;
    setState(() {
      snapshot = widget.config.snapshot(0);
    });
  }

  void stop({bool canceled = true}) {
    if (animation.isAnimating) {
      animation.stop(canceled: canceled);
    }
  }

  void enter({Duration? duration}) {
    if (!mounted) return;
    if (state.index < CombineState.endOut.index &&
        state.index > CombineState.beginIn.index) {
      return;
    }
    state = CombineState.beginIn;
    animation
        .animateTo(
      1,
      duration: duration ?? widget.config.duration ?? _defaultDuration,
      curve: widget.config.curve ?? Curves.easeIn,
    )
        .whenComplete(() {
      size = context.size;
      state = CombineState.endIn;
      widget.onEndIn?.call(CombinedAnimationController._(this));
    });
  }

  void leave({Duration? duration}) {
    if (!mounted) return;
    if (state.index >= CombineState.beginOut.index) return;
    state = CombineState.beginOut;
    animation
        .animateTo(
      0,
      duration: duration ?? widget.outConfig.duration ?? _defaultDuration,
      curve: widget.outConfig.curve ?? Curves.easeOut,
    )
        .whenComplete(() {
      state = CombineState.endOut;
      size = context.size;
      quitChild = widget.onEndOut?.call(context.size);

      WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
        state = CombineState.term;
        if (size == null) {
          widget.onRemove?.call();
        } else {
          size = null;
          setState(() {});
          Future.delayed(_defaultDuration)
              .then((value) => widget.onRemove?.call());
        }
      });
    });
  }

  @override
  void dispose() {
    animation.removeListener(_onAnimation);
    animation.dispose();
    super.dispose();
  }

  /// Update state. maybe animate to hide out or reset or restart
  @override
  void didUpdateWidget(covariant CombinedAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isControlled) return;
    if (widget.state == CombineState.beginOut && state == CombineState.endIn) {
      leave();
    } else if (widget.state == CombineState.beginIn) {
      enter();
    } else if (!animation.isAnimating) {
      state = widget.state;
    }
  }

  void _onAnimation() {
    setState(() {
      snapshot = state.index > CombineState.endIn.index
          ? widget.outConfig.snapshot(1 - animation.value)
          : widget.config.snapshot(animation.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (state.index >= CombineState.endOut.index &&
        widget.autoSlide &&
        (quitChild != null ||
            !(widget.config.hasSize || widget.outConfig.hasSize))) {
      print(
          '$quitChild $state ${widget.slideDuration ?? _defaultDuration} $size');
      return quitChild ??
          AnimatedSize(
            duration: widget.slideDuration ?? _defaultDuration,
            child: SizedBox(
              width: size?.width ?? 0,
              height: size?.height ?? 0,
            ),
          );
    }
    Widget child = widget.child;

    if (widget.config.hasMatrix || widget.outConfig.hasMatrix) {
      child = Transform(
        transform: snapshot.transform ?? Matrix4.identity(),
        alignment: Alignment.center,
        child: widget.child,
      );
    }
    if (widget.config.hasSize || widget.outConfig.hasSize) {
      child = AnimatedSize(
        duration:
            (isEnter ? widget.config.duration : widget.outConfig.duration) ??
                _defaultDuration,
        child: child,
      );
    }
    if (widget.config.hasOpacity || widget.outConfig.hasOpacity) {
      child = Opacity(
        opacity: snapshot.opacity ?? 1,
        child: child,
      );
    }

    if (widget.config.hasAlign || widget.outConfig.hasAlign) {
      child = Align(
        alignment: snapshot.alignment ?? Alignment.center,
        child: child,
      );
    }

    return child;
  }
}
