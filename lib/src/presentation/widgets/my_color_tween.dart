import 'dart:ui';

import 'package:flutter/widgets.dart';

class MyColorTween extends Tween<Color> {
  MyColorTween({
    required Color super.begin,
    required Color super.end,
  });

  @override
  Color get begin => super.begin!;

  @override
  Color get end => super.end!;

  @override
  Color lerp(double t) => lerpColors(begin, end, t);

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

class MyAnimatedColor extends StatefulWidget {
  const MyAnimatedColor({
    super.key,
    required this.duration,
    required this.color,
    required this.builder,
    required this.child,
  });

  final Duration duration;
  final Color color;
  final ValueWidgetBuilder<Color> builder;
  final Widget child;

  @override
  State<MyAnimatedColor> createState() => _MyAnimatedColorState();
}

class _MyAnimatedColorState extends State<MyAnimatedColor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  );

  late final MyColorTween _colorTween = MyColorTween(
    begin: widget.color,
    end: widget.color,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MyAnimatedColor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (widget.color != oldWidget.color) {
      _colorTween.begin = _colorTween.evaluate(_controller);
      _colorTween.end = widget.color;
      _controller.stop();
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) =>
          widget.builder(context, _colorTween.evaluate(_controller), child),
      child: widget.child,
    );
  }
}
