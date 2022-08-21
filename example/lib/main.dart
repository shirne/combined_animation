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
    AnimationConfig.zoomIn,
    AnimationConfig.fadeIn,
    AnimationConfig.fadeAndZoomIn,
    AnimationConfig(
      transformStart: Matrix4.identity()..scale(0.0),
      transformEnd: Matrix4.identity(),
      curve: Curves.bounceOut,
    ),
    AnimationConfig(
      transformStart: Matrix4.identity()..scale(0.5),
      transformEnd: Matrix4.identity(),
      opacityStart: 0,
      opacityEnd: 1,
      curve: Curves.bounceOut,
    ),
    AnimationConfig(
      transformStart: Matrix4.identity()..rotateX(math.pi / 2),
      transformEnd: Matrix4.identity(),
      curve: Curves.bounceOut,
    ),
    AnimationConfig(
      transformStart: Matrix4.identity()..rotateZ(math.pi / 2),
      transformEnd: Matrix4.identity(),
      curve: Curves.bounceOut,
    ),
  ];
  final random = math.Random(0);
  final removes = <int>{};

  void _incrementCounter() {
    setState(() {
      final index = widgets.length;
      widgets.add(Container(
        width: 100.0 + random.nextInt(100),
        height: 20.0 + random.nextInt(30),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: widgets.length,
          findChildIndexCallback: (key) {
            final index = keys.indexOf(key as ValueKey<int>);
            return index > -1 ? index : null;
          },
          itemBuilder: (context, index) {
            return Stack(
              key: keys[index],
              children: [
                Container(
                  alignment: Alignment.center,
                  height: configs[index].hasAlign ? 60 : null,
                  padding: configs[index].hasAlign
                      ? null
                      : const EdgeInsets.symmetric(vertical: 8),
                  child: CombinedAnimation(
                    state: removes.contains(index)
                        ? AnimationType.end
                        : AnimationType.start,
                    onEndOut: () {
                      removes.remove(index);
                      widgets.removeAt(index);
                      configs.removeAt(index);
                      keys.removeAt(index);
                      setState(() {});
                    },
                    config: configs[index],
                    child: widgets[index],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'AddItem',
        child: const Icon(Icons.add),
      ),
    );
  }
}
