import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late AnimationController _colorController;
  final Random _random = Random();

  // Initialize the keyframes immediately
  List<List<int>> _currentKeyframes = List.generate(
      6,
          (_) => List.generate(4, (_) => Random().nextInt(8) + 1)
  );
  List<List<int>> _nextKeyframes = List.generate(
      6,
          (_) => List.generate(4, (_) => Random().nextInt(8) + 1)
  );

  List<List<int>> _generateRandomKeyframes() {
    return List.generate(6, (_) {
      return List.generate(4, (_) => _random.nextInt(8) + 1);
    });
  }

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentKeyframes = _nextKeyframes;
          _nextKeyframes = _generateRandomKeyframes();
        });
        _colorController.forward(from: 0);
      }
    });

    _colorController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            glow(10),
            glow(9),
            glow(8),
            glow(7),
            const Center(
              child: Text(
                'Hi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget glow(double blurrr) {
    return Stack(
      children: [
        Center(
          child: AnimatedBuilder(
            animation: _colorController,
            builder: (context, child) {
              final progress = _colorController.value;
              final currentFrame = _currentKeyframes[
              (progress * _currentKeyframes.length).floor() % _currentKeyframes.length
              ];
              final nextFrame = _nextKeyframes[
              (progress * _nextKeyframes.length).floor() % _nextKeyframes.length
              ];

              final interpolatedFrame = List.generate(4, (i) {
                return (currentFrame[i] + (nextFrame[i] - currentFrame[i]) * progress).round();
              });

              return SizedBox(
                width: 350,
                height: 10,
                child: Row(
                  children: [
                    Expanded(
                      flex: interpolatedFrame[0],
                      child: Container(
                        height: 10,
                        color: Colors.blue,
                      ),
                    ),
                    Expanded(
                      flex: interpolatedFrame[1],
                      child: Container(
                        height: 10,
                        color: Colors.red,
                      ),
                    ),
                    Expanded(
                      flex: interpolatedFrame[2],
                      child: Container(
                        height: 10,
                        color: Colors.yellow,
                      ),
                    ),
                    Expanded(
                      flex: interpolatedFrame[3],
                      child: Container(
                        height: 10,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaY: blurrr, sigmaX: blurrr),
          child: Container(
            height: 400,
            width: 300,
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }
}