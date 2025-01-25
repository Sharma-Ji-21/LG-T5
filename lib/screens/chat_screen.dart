import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ChatScreen());
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late AnimationController _colorController;

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 750),
    )..repeat();
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
            Center(
              child: Text(
                'Hi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  // fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  glow(double blurrr) {
    return Stack(
      children: [
        Center(
          child: AnimatedBuilder(
            animation: _colorController,
            builder: (context, child) {
              final time = _colorController.value * 2 * pi;
              return Container(
                width: 350,
                height: 10,
                child: Container(
                  color: Colors.white,
                  width: 300,
                  height: 10,
                  child: Row(
                    children: [
                      Expanded(
                        flex: ((sin(time) + 1) * 2.5).round().clamp(1, 10),
                        child: Container(
                          height: 10,
                          color: Colors.blue,
                        ),
                      ),
                      Expanded(
                        flex: ((cos(time + pi / 2) + 1) * 2.5).round().clamp(1, 10),
                        child: Container(
                            height: 10,
                            color: Colors.red),
                      ),
                      Expanded(
                        flex: ((tan(time + pi).clamp(-1, 1) + 1) * 2.5).round().clamp(1, 10),
                        child: Container(
                            height: 10,
                            color: Colors.yellow),
                      ),
                      Expanded(
                        flex: ((1 / sin(time + 3 * pi / 2)).clamp(-1, 1).abs() + 1)
                            .round()
                            .clamp(1, 10),
                        child: Container(
                            height: 10,
                            color: Colors.green),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        BackdropFilter(
            filter: ImageFilter.blur(sigmaY: blurrr, sigmaX: blurrr),
            child:Container(height: 400,width: 300, color: Colors.transparent))
      ],
    );
  }
}