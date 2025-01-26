import 'dart:ui';
import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ChatScreen());
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            brightness(10),
            brightness(9),
            brightness(8),
            brightness(7),
          ],
        ),
      ),
    );
  }

  brightness(double oqupacity) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: 350,
            height: 10,
            child: Row(
              children: [
                Expanded(child: Container(color: Colors.blue)),
                Expanded(child: Container(color: Colors.red)),
                Expanded(child: Container(color: Colors.yellow)),
                Expanded(child: Container(color: Colors.green)),
              ],
            ),
          ),
        ),
        BackdropFilter(
            filter: ImageFilter.blur(sigmaY: oqupacity, sigmaX: oqupacity),
            child: Container(height: 400, width: 300, color: Colors.transparent)
        )
      ],
    );
  }
}