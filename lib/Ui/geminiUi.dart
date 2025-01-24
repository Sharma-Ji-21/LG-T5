import 'package:flutter/material.dart';
import 'dart:math';
import '../screens/chat_screen.dart';

class GeminiUi extends StatefulWidget {
  const GeminiUi({super.key});

  @override
  State<GeminiUi> createState() => _GeminiUiState();
}

class _GeminiUiState extends State<GeminiUi> with TickerProviderStateMixin {
  late AnimationController animationController1;
  late AnimationController animationController2;
  late AnimationController animationController3;
  late AnimationController animationController4;
  late Animation<double> scaleAnimation;
  late Animation<double> flowerRotationAnimation;
  late Animation<double> longImageRotationAnimation;
  late Animation<double> hexagonRotationAnimation;

  final List<String> animationImages = [
    'assets/geminiAnimation/geminiFlower.png',
    'assets/geminiAnimation/geminiLong.png',
    'assets/geminiAnimation/geminiHexagon.png'
  ];
  int currentImageIndex = 0;

  @override
  void initState() {
    animationController1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    animationController2 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));

    animationController3 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));

    animationController4 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));

    scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController1, curve: Curves.easeOutCubic));

    flowerRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController2, curve: Curves.linear));

    longImageRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController3, curve: Curves.linear));

    hexagonRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController4, curve: Curves.linear));

    super.initState();
  }

  bool isTransformed = false;
  bool showImage = false;

  void startNextAnimation() {
    if (currentImageIndex < animationImages.length - 1) {
      if (currentImageIndex == 0) {
        animationController2.forward().then((_) {
          setState(() {
            currentImageIndex++;
          });
          animationController3.forward().then((_) {
            setState(() {
              currentImageIndex++;
            });
            animationController4.forward();
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!showImage) {
          animationController1.forward().then((_) {
            setState(() {
              isTransformed = true;
              showImage = true;
            });
            startNextAnimation();
          });
        }
      },
      onDoubleTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
      },
      child: Container(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: scaleAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                if (!showImage)
                  Transform.scale(
                    scale: scaleAnimation.value,
                    child: Container(
                      height: 250.0,
                      width: 250.0,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius:
                            BorderRadius.circular(!isTransformed ? 1000 : 0),
                      ),
                    ),
                  ),
                if (showImage) ...[
                  if (currentImageIndex == 0)
                    AnimatedBuilder(
                      animation: flowerRotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle:
                              (flowerRotationAnimation.value + 100) * pi / 1.0,
                          child: Image.asset(
                            animationImages[currentImageIndex],
                            height: 250.0,
                            width: 250.0,
                          ),
                        );
                      },
                    ),
                  if (currentImageIndex == 1)
                    AnimatedBuilder(
                      animation: longImageRotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: (longImageRotationAnimation.value + 100) *
                              pi /
                              1.0,
                          child: Image.asset(
                            animationImages[currentImageIndex],
                            height: 250.0,
                            width: 250.0,
                          ),
                        );
                      },
                    ),
                  if (currentImageIndex == 2)
                    AnimatedBuilder(
                      animation: hexagonRotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle:
                              (hexagonRotationAnimation.value + 100) * pi / 1.0,
                          child: Image.asset(
                            animationImages[currentImageIndex],
                            height: 250.0,
                            width: 250.0,
                          ),
                        );
                      },
                    ),
                ],
                Transform.rotate(
                  angle: (scaleAnimation.value + 100) * pi / 1.0,
                  child: Image.asset(
                    'assets/geminiAnimation/star.png',
                    height: 35.0,
                    width: 35.0,
                    color: Colors.grey
                        .withBlue((100 + scaleAnimation.value).round() + 155)
                        .withGreen((100 + scaleAnimation.value).round() + 155)
                        .withRed((100 + scaleAnimation.value).round() + 155),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController1.dispose();
    animationController2.dispose();
    animationController3.dispose();
    animationController4.dispose();
    super.dispose();
  }
}