import 'dart:math';
import 'dart:ui';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late AnimationController _colorController;
  final Random _random = Random();
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = 'Hi';
  bool loaded=false;

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(debugLogging: true);
    setState(() {
      loaded=true;
    });
  }

  void _startListening() async {
    print('111111111111111111111');
    await _speechToText.listen(onResult: _onSpeechResult);
    print('22222222222222222222222');
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    print(result.recognizedWords);
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

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
    _initSpeech();
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
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                blurness(10),
                blurness(9),
                blurness(8),
                blurness(7),
              ],
            ),
          ),
          // New Positioned widget to place controls at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 50, // Adjust this value to control distance from bottom
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _lastWords,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16), // Spacing between text and icon
                IconButton(
                  onPressed: _startListening,
                  icon: const Icon(Icons.mic, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget blurness(double intencity) {
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
          filter: ImageFilter.blur(sigmaY: intencity, sigmaX: intencity),
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