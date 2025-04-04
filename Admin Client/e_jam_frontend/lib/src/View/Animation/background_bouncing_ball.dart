import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const double ballWidth = 160, ballHeight = 160;

class BouncingBall extends StatefulWidget {
  const BouncingBall({Key? key}) : super(key: key);

  @override
  State<BouncingBall> createState() => _BouncingBallState();
}

class _BouncingBallState extends State<BouncingBall> {
  static const int minimumSpeed = 20,
      speedIncrement = 10,
      speedDecrement = 5,
      speedLimit = 90,
      duration = 140;
  static double x = 90, y = 30, xSpeed = 20, ySpeed = 20;
  Timer? timer;

  @override
  initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(milliseconds: duration), (Timer t) => update());
  }

  update() async {
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
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: duration.toInt()),
      left: x,
      top: y,
      child: const BallShape(),
    );
  }
}

class BallShape extends StatelessWidget {
  const BallShape({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ThemeModel theme, child) {
      List<Color> color = theme.isDark ? gradientColorDark : gradientColorLight;
      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2.5),
        child: Container(
          width: ballWidth,
          height: ballHeight,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color[0].withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 7,
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
      );
    });
  }
}
