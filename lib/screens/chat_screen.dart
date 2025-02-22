import 'dart:math';
import 'dart:ui';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/multi_ssh_service.dart';
import 'package:flutter_tts/flutter_tts.dart';  // Add this package for text-to-speech

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
  bool loaded = false;
  FlutterTts _flutterTts = FlutterTts();  // TTS engine
  List<String> _commandHistory = [];  // Store command history
  bool _isProcessingCommand = false;  // Flag to prevent multiple commands processing

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(debugLogging: true);
    await _initTts();
    setState(() {
      loaded = true;
    });
    // Initial greeting for visually impaired users
    _speak("Voice assistant ready. Say 'help' for available commands.");
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);  // Slower speech for better understanding
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _startListening() async {
    if (!_isProcessingCommand) {
      await _speechToText.listen(onResult: _onSpeechResult);
      _speak("Listening...");
      setState(() {});
    } else {
      _speak("Still processing previous command. Please wait.");
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    print(result.recognizedWords);
    setState(() {
      _lastWords = result.recognizedWords;
      _commandHistory.add(result.recognizedWords);
      if (_commandHistory.length > 10) {  // Keep only last 10 commands
        _commandHistory.removeAt(0);
      }
    });

    // Process the command after recognition
    _processVoiceCommand(result.recognizedWords);
  }

  Future<void> _processVoiceCommand(String command) async {
    setState(() {
      _isProcessingCommand = true;
    });

    final lowercaseCommand = command.toLowerCase();
    final sshService = Provider.of<MultiSSHService>(context, listen: false);

    try {
      // Help command
      if (lowercaseCommand.contains('help')) {
        _speak("Available commands include: run KML, clean KML, go to profile, go home, connect, disconnect, and help. For specific KML files, say 'run' followed by the KML name.");
      }

      // Navigation commands
      else if (lowercaseCommand.contains('go to profile') || lowercaseCommand.contains('open profile')) {
        _speak("Opening profile screen");
        Navigator.pushNamed(context, '/profile');
      }
      else if (lowercaseCommand.contains('go home') || lowercaseCommand.contains('go to home')) {
        _speak("Going to home screen");
        Navigator.pushNamed(context, '/home');
      }

      // SSH commands - only if connected
      else if (sshService.isConnected) {
        // Run KML command
        if (lowercaseCommand.startsWith('run ')) {
          final kmlName = command.substring(4).trim();
          _speak("Running KML file: $kmlName");
          await sshService.runKML(kmlName);
        }

        // Clean KML command
        else if (lowercaseCommand.contains('clean kml')) {
          _speak("Cleaning KML files");
          await sshService.cleanKML();
        }

        // Relaunch command
        else if (lowercaseCommand.contains('relaunch')) {
          _speak("Relaunching Liquid Galaxy");
          // You'll need to get these values from somewhere - maybe a settings page
          await sshService.relaunchLG('lg', 'password');
        }

        // Fly to location
        else if (lowercaseCommand.contains('fly to zoo')) {
          _speak("Flying to zoo location");
          await sshService.flytoZoo();
        }

        // Disconnect command
        else if (lowercaseCommand.contains('disconnect')) {
          _speak("Disconnecting from server");
          await sshService.disconnectAll();
        }
      }

      // Connection command - if not connected
      else if (lowercaseCommand.contains('connect') && !sshService.isConnected) {
        _speak("Please go to profile page to connect");
        Navigator.pushNamed(context, '/profile');
      }

      // Command not recognized
      else {
        _speak("Command not recognized. Say 'help' for available commands.");
      }
    } catch (e) {
      _speak("Error executing command: ${e.toString()}");
    } finally {
      setState(() {
        _isProcessingCommand = false;
      });
    }
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
          // Content area with last command and history
          Positioned(
            left: 20,
            right: 20,
            top: 80,
            bottom: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Voice Assistant",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Last Command:",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _lastWords,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Command History:",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _commandHistory.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  _commandHistory[_commandHistory.length - 1 - index],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Controls at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<MultiSSHService>(
                  builder: (context, sshService, child) => Text(
                    sshService.isConnected
                        ? "Connected - Say your command"
                        : "Not Connected - Say 'connect' or 'go to profile'",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
                    icon: Icon(
                        _speechToText.isNotListening ? Icons.mic : Icons.stop,
                        color: Colors.white,
                        size: 32
                    ),
                    padding: EdgeInsets.all(16),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  _speechToText.isNotListening ? "Tap to speak" : "Listening...",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
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
    _speechToText.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}