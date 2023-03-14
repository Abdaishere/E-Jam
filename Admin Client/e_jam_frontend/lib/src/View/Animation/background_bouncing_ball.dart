import 'dart:async';

import 'package:flutter/material.dart';

class BouncingBall extends StatefulWidget {
  const BouncingBall({Key? key, required this.color}) : super(key: key);

  final List<Color> color;
  @override
  State<BouncingBall> createState() => _BouncingBallState();
}

class _BouncingBallState extends State<BouncingBall> {
  get color => widget.color;

  double ballWidth = 140, ballHeight = 130;
  double x = 90, y = 30, xSpeed = 20, ySpeed = 20, speed = 150;

  @override
  initState() {
    super.initState();
    update();
  }

  update() {
    Timer.periodic(Duration(milliseconds: speed.toInt()), (timer) {
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;
      x += xSpeed;
      y += ySpeed;

      if (x + ballWidth >= screenWidth) {
        xSpeed = -xSpeed;
        x = screenWidth - ballWidth;
      } else if (x <= 0) {
        xSpeed = -xSpeed;
        x = 0;
      }

      if (y + ballHeight >= screenHeight) {
        ySpeed = -ySpeed;
        y = screenHeight - ballHeight;
      } else if (y <= 0) {
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
      child: Container(
        width: ballWidth,
        height: ballHeight,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color[0].withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 3),
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
    );
  }
}
