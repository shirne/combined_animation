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
  final random = math.Random(0);
  final removes = <int>{};
  final removed = <int>{};

  final controller = ScrollController();

  int firstState = 1;

  CombinedAnimationController? caController;

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

  Widget _setStateDemo(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          height: 60,
          child: CombinedAnimation(
            state: firstState == 2
                ? AnimationType.end
                : firstState == 1
                    ? AnimationType.start
                    : null,
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
              label: Text(firstState == 0
                  ? 'Show'
                  : firstState == 1
                      ? 'Hide'
                      : 'Reset'),
              onPressed: () {
                final cState = firstState + 1;

                setState(() {
                  firstState = cState > 2 ? 0 : cState;
                });
              },
              icon: const Icon(Icons.animation),
            ),
          ),
        ),
      ],
    );
  }

  Widget _setControlDemo(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          height: 60,
          child: CombinedAnimation(
            config: AnimationConfig.vFlipIn,
            onEntered: (c) {
              caController = c;
              setState(() {});
            },
            onLeaved: (s) {
              setState(() {});
              return null;
            },
            onDissmiss: () {
              setState(() {});
            },
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
              label: Text((caController?.isLeaved ?? false)
                  ? 'Reset'
                  : (caController?.isEntered ?? false)
                      ? 'Hide'
                      : 'Show'),
              onPressed: () {
                if (caController?.isEntered ?? false) {
                  caController?.leave();
                } else if (caController?.isLeaved ?? false) {
                  caController?.init();
                  setState(() {});
                } else {
                  caController?.enter();
                }
              },
              icon: const Icon(Icons.animation),
            ),
          ),
        ),
      ],
    );
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
            _setStateDemo(context),
            _setControlDemo(context),
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
                  return Stack(
                    key: keys[index],
                    children: [
                      ConstrainedBox(
                        constraints: removed.contains(index)
                            ? BoxConstraints.loose(Size.infinite)
                            : BoxConstraints.tight(const Size.fromHeight(60)),
                        child: Center(
                          child: CombinedAnimation(
                            state: removes.contains(index)
                                ? AnimationType.end
                                : AnimationType.start,
                            onLeaved: (s) {
                              removed.add(index);
                              setState(() {});
                              return null;
                            },
                            onDissmiss: () {
                              removes.remove(index);
                              widgets.removeAt(index);
                              configs.removeAt(index);
                              keys.removeAt(index);
                              removed.remove(index);
                              setState(() {});
                            },
                            config: configs[index],
                            child: widgets[index],
                          ),
                        ),
                      ),
                      if (!removes.contains(index))
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
                                if (removes.contains(index)) return;
                                setState(() {
                                  removes.add(index);
                                });
                              },
                              icon: const Icon(Icons.remove),
                            ),
                          ),
                        ),
                    ],
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
