import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shader_example/shader_painter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  List<String> shaders = [
    "shaders/star_nest.frag",
    "shaders/galaxy_of_universes.frag",
    ];

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _startTime = 0;

  double get _elapsedTimeInSeconds =>
      (_startTime - DateTime.now().millisecondsSinceEpoch) / 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: FutureBuilder<FragmentShader>(
              future: _load(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _startTime = DateTime.now().millisecondsSinceEpoch;
                  final shader = snapshot.data!;
                  shader
                    ..setFloat(1, MediaQuery.of(context).size.width) //width
                    ..setFloat(2, MediaQuery.of(context).size.height); //height

                  return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        shader.setFloat(0, _elapsedTimeInSeconds);
                        return CustomPaint(
                          painter: ShaderPainter(shader),
                        );
                      });
                } else {
                  return const CircularProgressIndicator();
                }
              }),
        ),
      ),
    );
  }

  Future<FragmentShader> _load() async {
    FragmentProgram program =
        await FragmentProgram.fromAsset(shaders[1]);
    return program.fragmentShader();
  }
}
