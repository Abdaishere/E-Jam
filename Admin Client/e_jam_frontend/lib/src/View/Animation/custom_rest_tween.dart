import 'package:flutter/widgets.dart';

class CustomRectTween extends RectTween {
  /// {@macro custom_rect_tween}
  CustomRectTween({
    required Rect begin,
    required Rect end,
  }) : super(begin: begin, end: end);

  @override
  Rect lerp(double t) => Rect.lerp(begin, end, Curves.easeOut.transform(t))!;
}
