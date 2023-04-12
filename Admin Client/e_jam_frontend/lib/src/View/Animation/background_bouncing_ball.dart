import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class BouncingBall extends StatefulWidget {
  const BouncingBall({Key? key, required this.color}) : super(key: key);

  final List<Color> color;
  @override
  State<BouncingBall> createState() => _BouncingBallState();
}

class _BouncingBallState extends State<BouncingBall> {
  get color => widget.color;

  final double ballWidth = 160, ballHeight = 150;
  double x = 90, y = 30, xSpeed = 20, ySpeed = 20, speed = 150;
  final int minimumSpeed = 10,
      speedIncrement = 20,
      speedDecrement = 5,
      speedLimit = 100;

  @override
  initState() {
    super.initState();
    update();
  }

  update() {
    Timer.periodic(Duration(milliseconds: speed.toInt()), (timer) {
      final double screenWidth = MediaQuery.of(context).size.width;
      final double screenHeight = MediaQuery.of(context).size.height;
      x += xSpeed;
      y += ySpeed;

      if (x + ballWidth >= screenWidth) {
        xSpeed += xSpeed < minimumSpeed
            ? Random().nextInt(speedIncrement)
            : -Random().nextInt(speedDecrement);

        xSpeed += xSpeed > speedLimit ? -Random().nextInt(speedDecrement) : 0;

        xSpeed = -xSpeed;
        x = screenWidth - ballWidth;
      } else if (x <= 0) {
        xSpeed += xSpeed < minimumSpeed
            ? Random().nextInt(speedIncrement)
            : -Random().nextInt(speedDecrement);

        xSpeed += xSpeed > speedLimit ? -Random().nextInt(speedDecrement) : 0;
        xSpeed = -xSpeed;
        x = 0;
      }

      if (y + ballHeight >= screenHeight) {
        ySpeed += ySpeed < minimumSpeed
            ? Random().nextInt(speedIncrement)
            : -Random().nextInt(speedDecrement);

        ySpeed += ySpeed > speedLimit ? -Random().nextInt(speedDecrement) : 0;
        ySpeed = -ySpeed;
        y = screenHeight - ballHeight;
      } else if (y <= 0) {
        ySpeed += ySpeed < minimumSpeed
            ? Random().nextInt(speedIncrement)
            : -Random().nextInt(speedDecrement);

        ySpeed += ySpeed > speedLimit ? -Random().nextInt(speedDecrement) : 0;

        ySpeed = -ySpeed;
        y = 0;
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: speed.toInt()),
      left: x,
      top: y,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2.5),
        child: Container(
          width: ballWidth,
          height: ballHeight,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color[0].withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, 3),
                blurStyle: BlurStyle.outer,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: color,
              transform: const GradientRotation(3),
            ),
          ),
        ),
      ),
    );
  }
}
