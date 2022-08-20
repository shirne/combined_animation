import 'package:combined_animation/src/config.dart';
import 'package:flutter/cupertino.dart';

enum CombineState {
  beginIn,
  endIn,
  beginOut,
  endOut,
}

class CombinedAnimation extends StatefulWidget {
  const CombinedAnimation({
    Key? key,
    required this.config,
    AnimationConfig? outConfig,
    required this.child,
    AnimationType state = AnimationType.start,
  })  : outConfig = outConfig ?? ~config,
        state = state == AnimationType.start
            ? CombineState.beginIn
            : CombineState.beginOut,
        super(key: key);

  final AnimationConfig config;
  final AnimationConfig outConfig;

  final CombineState state;

  final Widget child;

  @override
  State<CombinedAnimation> createState() => _CombinedAnimationState();
}

class _CombinedAnimationState extends State<CombinedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationSnapshot snapshot;

  late final animation = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
    snapshot = widget.config.snapshot(0);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      animation.animateTo(
        1,
        duration: widget.config.duration,
        curve: widget.config.curve ?? Curves.easeIn,
      );
    });
    animation.addListener(_onAnimation);
  }

  @override
  void didUpdateWidget(covariant CombinedAnimation oldWidget) {
    if (widget.state == CombineState.beginOut &&
        widget.state.index > oldWidget.state.index) {
      animation.animateTo(
        1,
        duration: widget.config.duration,
        curve: widget.config.curve ?? Curves.easeOut,
      );
    }
    super.didUpdateWidget(oldWidget);
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
      Transform(
        transform: snapshot.matrix!,
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
