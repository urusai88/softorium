import 'dart:ui';

import 'package:flutter/animation.dart';

class MyColorTween extends Tween<Color> {
  MyColorTween({required Color super.begin, required Color super.end});

  @override
  Color lerp(double t) => lerpColors(begin!, end!, t);

  static Color lerpColors(Color a, Color b, double t) {
    final w1 = (1 - t) * a.opacity;
    final w2 = t * b.opacity;
    final n = w1 + w2;
    final w = n > 0.000001 ? w2 / n : 0.5;

    return Color.fromARGB(
      lerpDouble(a.alpha, b.alpha, t)!.toInt().clamp(0, 255),
      lerpDouble(a.red, b.red, w)!.toInt().clamp(0, 255),
      lerpDouble(a.green, b.green, w)!.toInt().clamp(0, 255),
      lerpDouble(a.blue, b.blue, w)!.toInt().clamp(0, 255),
    );
  }
}
