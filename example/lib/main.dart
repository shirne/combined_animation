import 'dart:math';

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
  final configs = [
    AnimationConfig.slideIn,
    AnimationConfig.zoomIn,
    AnimationConfig.fadeIn,
    AnimationConfig.fadeAndZoomIn,
  ];
  final random = Random(0);
  final removes = [];

  void _incrementCounter() {
    setState(() {
      widgets.add(Container(
        width: 100.0 + random.nextInt(100),
        height: 20.0 + random.nextInt(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.primaries[widgets.length % 18],
              Colors.primaries[(widgets.length + 1) % 18],
              Colors.primaries[(widgets.length + 2) % 18],
            ],
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
      ));
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
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 16),
                  child: CombinedAnimation(
                    config: configs[index % configs.length],
                    state: removes.contains(index)
                        ? AnimationType.end
                        : AnimationType.start,
                    onEndOut: () {
                      removes.remove(index);
                      widgets.removeAt(index);
                      setState(() {});
                    },
                    child: widgets[index],
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    onPressed: () {
                      if (removes.contains(index)) return;
                      setState(() {
                        removes.add(index);
                      });
                    },
                    icon: const Icon(Icons.remove),
                  ),
                )
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
