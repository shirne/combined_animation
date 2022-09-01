// ignore_for_file: avoid_print

import 'dart:math' as math;

import 'package:combined_animation/combined_animation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Animation Demo Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final widgets = <Widget>[];
  final configs = <AnimationConfig>[];
  final keys = <ValueKey<int>>[];
  final configList = [
    AnimationConfig.slideIn,
    AnimationConfig.slideAndFadeIn,
    AnimationConfig.zoomIn,
    AnimationConfig.fadeIn,
    AnimationConfig.fadeAndZoomIn,
    AnimationConfig.vFlipIn,
    AnimationConfig.hFlipIn,
    AnimationConfig.zoomIn.copyWith(curve: Curves.bounceOut),
    AnimationConfig.fadeAndZoomIn.copyWith(curve: Curves.bounceOut),
    AnimationConfig.vFlipIn.copyWith(curve: Curves.bounceOut),
    AnimationConfig.hFlipIn.copyWith(curve: Curves.bounceOut),
    AnimationConfig.fadeIn.copyWith(
      startTransform: Matrix4.identity()..rotateZ(math.pi / 2),
      endTransform: Matrix4.identity(),
      curve: Curves.bounceOut,
    )
  ];

  final controller = ScrollController();

  /// generate a new animation item
  void _incrementCounter() {
    setState(() {
      final index = widgets.length;
      widgets.add(Container(
        width: 100.0,
        height: 40.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.primaries[index % 18],
              Colors.primaries[(index + 1) % 18],
              Colors.primaries[(index + 2) % 18],
            ],
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
      ));
      configs.add(configList[index % configList.length]);
      keys.add(ValueKey(index == 0 ? 0 : keys.last.value + 1));
    });
    WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const StateDemoWidget(),
            const ControlDemoWidget(),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: widgets.length,
                padding: const EdgeInsets.only(bottom: 80),
                findChildIndexCallback: (key) {
                  final index = keys.indexOf(key as ValueKey<int>);
                  return index > -1 ? index : null;
                },
                itemBuilder: (context, index) {
                  return AnimateItem(
                    key: keys[index],
                    animate: configs[index],
                    onDismiss: () {
                      setState(() {
                        widgets.removeAt(index);
                        configs.removeAt(index);
                        keys.removeAt(index);
                      });
                    },
                    child: widgets[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'AddItem',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Generate an Anitate Widget control by button
class AnimateItem extends StatefulWidget {
  const AnimateItem({
    Key? key,
    required this.child,
    required this.animate,
    this.onDismiss,
    this.height = 60.0,
  }) : super(key: key);

  final Widget child;

  final VoidCallback? onDismiss;

  final double height;

  final AnimationConfig animate;

  @override
  State<AnimateItem> createState() => _AnimateItemState();
}

class _AnimateItemState extends State<AnimateItem> {
  bool isDissmissing = false;
  bool isLeave = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ConstrainedBox(
          constraints: isDissmissing
              ? BoxConstraints.loose(Size.infinite)
              : BoxConstraints.tight(Size.fromHeight(widget.height)),
          child: Center(
            child: CombinedAnimation(
              state: isLeave ? AnimationType.end : AnimationType.start,
              onLeaved: () {
                setState(() {
                  isDissmissing = true;
                });
              },
              onDismiss: widget.onDismiss,
              config: widget.animate,
              child: widget.child,
            ),
          ),
        ),
        if (!isLeave)
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                label: const Text('delete'),
                onPressed: () {
                  if (isLeave) return;
                  setState(() {
                    isLeave = true;
                  });
                },
                icon: const Icon(Icons.remove),
              ),
            ),
          ),
      ],
    );
  }
}

class StateDemoWidget extends StatefulWidget {
  const StateDemoWidget({Key? key}) : super(key: key);

  @override
  State<StateDemoWidget> createState() => _StateDemoWidgetState();
}

class _StateDemoWidgetState extends State<StateDemoWidget> {
  AnimationType? state = AnimationType.start;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          height: 60,
          child: CombinedAnimation(
            state: state,
            config: AnimationConfig.vFlipIn,
            child: Container(
              width: 100.0,
              height: 40.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.primaries[0][200]!,
                    Colors.primaries[1][200]!,
                    Colors.primaries[2][200]!,
                  ],
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 8,
          top: 0,
          bottom: 0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Control by state',
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
              ),
              label: Text(
                state == null
                    ? 'Show'
                    : state == AnimationType.start
                        ? 'Hide'
                        : 'Reset',
              ),
              onPressed: () {
                final cState = (state?.index ?? -1) + 1;

                setState(() {
                  state = cState > 1 ? null : AnimationType.values[cState];
                });
              },
              icon: const Icon(Icons.animation),
            ),
          ),
        ),
      ],
    );
  }
}

/// control animation by controller
class ControlDemoWidget extends StatefulWidget {
  const ControlDemoWidget({Key? key}) : super(key: key);

  @override
  State<ControlDemoWidget> createState() => _ControlDemoWidgetState();
}

class _ControlDemoWidgetState extends State<ControlDemoWidget> {
  /// control by controller
  late CombinedAnimationController caController = CombinedAnimationController()
    ..addListener(() {
      print(
          '${caController.state} ${caController.isEntered} ${caController.isLeaved}');
      setState(() {});
    });

  @override
  void dispose() {
    caController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          height: 60,
          child: CombinedAnimation(
            config: AnimationConfig.vFlipIn,
            controller: caController,
            isControlled: true,
            child: Container(
              width: 100.0,
              height: 40.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.primaries[9][200]!,
                    Colors.primaries[10][200]!,
                    Colors.primaries[11][200]!,
                  ],
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 8,
          top: 0,
          bottom: 0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Control by controller',
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
              ),
              label: Text((caController.isLeaved)
                  ? 'Reset'
                  : (caController.isEntered)
                      ? 'Hide'
                      : 'Show'),
              onPressed: () {
                print(caController.isEntered);
                if (caController.isEntered) {
                  caController.leave();
                } else if (caController.isLeaved) {
                  caController.init();
                  setState(() {});
                } else {
                  caController.enter();
                }
              },
              icon: const Icon(Icons.animation),
            ),
          ),
        ),
      ],
    );
  }
}
