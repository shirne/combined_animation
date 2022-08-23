import 'package:combined_animation/src/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Only allow user to start or stop
enum AnimationType {
  start,
  end,
}

/// Combine state of [CombinedAnimation]
enum CombineState {
  init,
  beginEnter,
  endEnter,
  beginLeave,
  endLeave,
  dismiss,
}

const _defaultDuration = Duration(milliseconds: 300);

/// A combined animation to show in or hide out a widget
class CombinedAnimation extends StatefulWidget {
  const CombinedAnimation({
    Key? key,
    required this.config,
    AnimationConfig? leaveConfig,
    required this.child,
    AnimationType? state = AnimationType.start,
    this.dismissDuration = _defaultDuration,
    this.dismissCurve = Curves.easeOut,
    this.onEntered,
    this.onLeaved,
    this.onDissmiss,
    this.autoSlide = true,
    this.isControlled = false,
  })  : leaveConfig = leaveConfig ?? ~config,
        state = state == AnimationType.start
            ? CombineState.beginEnter
            : state == AnimationType.end
                ? CombineState.beginLeave
                : CombineState.init,
        super(key: key);

  /// Enter animation config
  final AnimationConfig config;

  /// Leave animation config. defaults to flip [config]
  final AnimationConfig leaveConfig;

  /// State to pass in
  final CombineState state;

  /// Callback when show in animation is complete
  final void Function(CombinedAnimationController)? onEntered;

  /// Callback when hide out animation is complete
  final Widget? Function(Size?)? onLeaved;

  /// Callback when size is Zero
  final VoidCallback? onDissmiss;

  /// The child will be animate
  final Widget child;

  /// Whether should auto slide up
  final bool autoSlide;

  /// If is controlled, State will not update state from widget
  final bool isControlled;

  /// animation to dismiss
  final Duration dismissDuration;
  final Curve dismissCurve;

  @override
  State<CombinedAnimation> createState() => _CombinedAnimationState();
}

/// AnimationController to control Animation State
class CombinedAnimationController {
  const CombinedAnimationController._(this._state);

  final _CombinedAnimationState _state;

  bool get isEntered => _state.state == CombineState.endEnter;

  bool get isLeaved => _state.state.index >= CombineState.endLeave.index;

  /// reset
  void init() {
    _state.init();
  }

  /// stop animation
  void stop() {
    _state.stop();
  }

  /// start enter animation
  void enter({Duration? duration}) {
    _state.enter(duration: duration);
  }

  /// start leave animation
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
      state.index >= CombineState.beginEnter.index &&
      state.index <= CombineState.endEnter.index;

  bool get isLeave =>
      state.index >= CombineState.beginLeave.index &&
      state.index <= CombineState.endLeave.index;

  @override
  void initState() {
    super.initState();
    snapshot = widget.config.snapshot(0);
    state = widget.state;
    if (state == CombineState.beginEnter) {
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
    if (state.index < CombineState.endLeave.index &&
        state.index > CombineState.beginEnter.index) {
      return;
    }
    state = CombineState.beginEnter;
    animation
        .animateTo(
      1,
      duration: duration ?? widget.config.duration ?? _defaultDuration,
      curve: widget.config.curve ?? Curves.easeIn,
    )
        .whenComplete(() {
      size = context.size;
      state = CombineState.endEnter;
      widget.onEntered?.call(CombinedAnimationController._(this));
    });
  }

  void leave({Duration? duration}) {
    if (!mounted) return;
    if (state.index >= CombineState.beginLeave.index) return;
    state = CombineState.beginLeave;
    animation
        .animateTo(
      0,
      duration: duration ?? widget.leaveConfig.duration ?? _defaultDuration,
      curve: widget.leaveConfig.curve ?? Curves.easeOut,
    )
        .whenComplete(() {
      state = CombineState.endLeave;
      size = context.size;
      quitChild = widget.onLeaved?.call(context.size);

      WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
        if (size == null) {
          state = CombineState.dismiss;
          widget.onDissmiss?.call();
        } else {
          size = null;
          setState(() {});
          Future.delayed(Duration(
            milliseconds: widget.dismissDuration.inMilliseconds + 16,
          )).then((value) {
            state = CombineState.dismiss;
            widget.onDissmiss?.call();
          });
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
    if (widget.state == CombineState.beginLeave) {
      if (state == CombineState.endEnter) {
        leave();
      }
    } else if (widget.state == CombineState.beginEnter) {
      enter();
    } else if (widget.state == CombineState.init &&
        !animation.isAnimating &&
        state == CombineState.dismiss) {
      init();
    }
  }

  void _onAnimation() {
    setState(() {
      snapshot = state.index > CombineState.endEnter.index
          ? widget.leaveConfig.snapshot(1 - animation.value)
          : widget.config.snapshot(animation.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (state.index >= CombineState.endLeave.index &&
        widget.autoSlide &&
        (quitChild != null ||
            !(widget.config.hasSize || widget.leaveConfig.hasSize))) {
      return quitChild ??
          AnimatedSize(
            duration: widget.dismissDuration,
            curve: widget.dismissCurve,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: size?.width ?? 0,
              height: size?.height ?? 0,
            ),
          );
    }
    Widget child = widget.child;

    if (widget.config.hasMatrix || widget.leaveConfig.hasMatrix) {
      child = Transform(
        transform: snapshot.transform ?? Matrix4.identity(),
        alignment: Alignment.center,
        child: widget.child,
      );
    }
    if (widget.config.hasSize || widget.leaveConfig.hasSize) {
      child = AnimatedSize(
        duration:
            (isEnter ? widget.config.duration : widget.leaveConfig.duration) ??
                _defaultDuration,
        child: child,
      );
    }
    if (widget.config.hasOpacity || widget.leaveConfig.hasOpacity) {
      child = Opacity(
        opacity: snapshot.opacity ?? 1,
        child: child,
      );
    }

    if (widget.config.hasAlign || widget.leaveConfig.hasAlign) {
      child = Align(
        alignment: snapshot.alignment ?? Alignment.center,
        child: child,
      );
    }

    return child;
  }
}
