import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'config.dart';

const _minFrameDelay = 16;

/// Only allow user to start or stop
enum AnimationType {
  start,
  end,
}

/// Combine state of [CombinedAnimation]
enum AnimationState {
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
    this.controller,
    this.onInit,
    this.onEntered,
    this.onLeaved,
    this.onDismiss,
    this.dismissBuilder,
    this.autoSlide = true,
    this.isControlled = false,
  })  : leaveConfig = leaveConfig ?? ~config,
        state = state == AnimationType.start
            ? AnimationState.beginEnter
            : state == AnimationType.end
                ? AnimationState.beginLeave
                : AnimationState.init,
        super(key: key);

  /// Enter animation config
  final AnimationConfig config;

  /// Leave animation config. defaults to flip [config]
  final AnimationConfig leaveConfig;

  /// State to pass in
  final AnimationState state;

  /// pass a controller to attach state
  final CombinedAnimationController? controller;

  /// Callback to build a size transation to dismiss
  final Widget? Function(Size?)? dismissBuilder;

  /// Callback when state inited
  final VoidCallback? onInit;

  /// Callback when show in animation is complete
  final VoidCallback? onEntered;

  /// Callback when leave animation is complete
  final VoidCallback? onLeaved;

  /// Callback when size is Zero
  final VoidCallback? onDismiss;

  /// The child will be animate
  final Widget child;

  /// Whether should auto slide up
  final bool autoSlide;

  /// If is controlled, State will not update state from widget
  final bool isControlled;

  /// animation duration to dismiss
  final Duration dismissDuration;

  /// animation curve to dismiss
  final Curve dismissCurve;

  @override
  State<CombinedAnimation> createState() => _CombinedAnimationState();
}

/// AnimationController to control Animation State
class CombinedAnimationController extends ChangeNotifier {
  CombinedAnimationController();

  _CombinedAnimationState? _state;
  bool _leaved = false;

  AnimationState get state => _state?.state ?? AnimationState.init;

  bool get isEntered => _state?.state == AnimationState.endEnter;

  bool get isLeaved =>
      (_state?.state.index ?? 0) >= AnimationState.endLeave.index;

  void _attach(_CombinedAnimationState state) {
    _state = state;
  }

  void _stateChanged() {
    if (_state != null) notifyListeners();
  }

  /// reset
  void init() {
    _state?.init();
  }

  /// stop animation
  void stop() {
    _state?.stop();
  }

  /// start enter animation
  void enter({Duration? duration}) {
    if (_leaved) {
      if (_state != null) {
        _leaved = false;
      }
      return;
    }
    _state?.enter(duration: duration);
  }

  /// start leave animation
  void leave({Duration? duration}) {
    if (_state == null) _leaved = true;
    _state?.leave(duration: duration);
  }

  @override
  void dispose() {
    super.dispose();
    _state = null;
  }
}

class _CombinedAnimationState extends State<CombinedAnimation>
    with SingleTickerProviderStateMixin<CombinedAnimation> {
  late AnimationSnapshot snapshot;

  AnimationState state = AnimationState.init;

  late final animation = AnimationController(vsync: this);

  Size? size;

  bool get isEnter =>
      state.index >= AnimationState.beginEnter.index &&
      state.index <= AnimationState.endEnter.index;

  bool get isLeave =>
      state.index >= AnimationState.beginLeave.index &&
      state.index <= AnimationState.endLeave.index;

  @override
  void initState() {
    super.initState();
    snapshot = widget.config.snapshot(0);
    state = widget.state;

    animation.addListener(_onAnimation);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (state == AnimationState.beginEnter) {
        enter();
      }
      widget.onInit?.call();
    });

    widget.controller?._attach(this);
  }

  void init() {
    stop();
    state = AnimationState.init;
    setState(() {
      snapshot = widget.config.snapshot(0);
    });
    widget.controller?._stateChanged();
  }

  void stop({bool canceled = true}) {
    if (animation.isAnimating) {
      animation.stop(canceled: canceled);
    }
  }

  void enter({Duration? duration}) {
    if (!mounted) return;
    if (state.index < AnimationState.endLeave.index &&
        state.index > AnimationState.beginEnter.index) {
      return;
    }
    state = AnimationState.beginEnter;
    widget.controller?._stateChanged();
    animation
        .animateTo(
      1,
      duration: duration ?? widget.config.duration ?? _defaultDuration,
      curve: widget.config.curve ?? Curves.easeIn,
    )
        .whenComplete(() {
      if (mounted) {
        size = context.size;
      }
      state = AnimationState.endEnter;
      widget.controller?._stateChanged();
      widget.onEntered?.call();
    });
  }

  void leave({Duration? duration}) {
    if (!mounted) return;
    if (state.index >= AnimationState.beginLeave.index) return;
    state = AnimationState.beginLeave;
    size = context.size;
    widget.controller?._stateChanged();
    animation
        .animateTo(
      0,
      duration: duration ?? widget.leaveConfig.duration ?? _defaultDuration,
      curve: widget.leaveConfig.curve ?? Curves.easeOut,
    )
        .whenComplete(() {
      state = AnimationState.endLeave;
      widget.controller?._stateChanged();
      widget.onLeaved?.call();

      WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
        if (size == null ||
            widget.dismissDuration.inMilliseconds < _minFrameDelay) {
          state = AnimationState.dismiss;
          widget.controller?._stateChanged();
          widget.onDismiss?.call();
        } else {
          size = null;
          if (mounted) {
            setState(() {});
          }

          Future.delayed(
            Duration(
              milliseconds:
                  widget.dismissDuration.inMilliseconds + _minFrameDelay,
            ),
          ).then((value) {
            state = AnimationState.dismiss;
            widget.controller?._stateChanged();
            widget.onDismiss?.call();
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
    widget.controller?._attach(this);
    if (widget.isControlled) return;
    if (widget.state == AnimationState.beginLeave) {
      if (state == AnimationState.endEnter) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          leave();
        });
      }
    } else if (widget.state == AnimationState.beginEnter) {
      enter();
    } else if (widget.state == AnimationState.init &&
        !animation.isAnimating &&
        state == AnimationState.dismiss) {
      init();
    }
  }

  void _onAnimation() {
    setState(() {
      snapshot = state.index > AnimationState.endEnter.index
          ? widget.leaveConfig.snapshot(1 - animation.value)
          : widget.config.snapshot(animation.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (state.index >= AnimationState.endLeave.index &&
        widget.autoSlide &&
        (widget.dismissBuilder != null ||
            !(widget.config.hasSize || widget.leaveConfig.hasSize))) {
      return widget.dismissBuilder?.call(size) ??
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
