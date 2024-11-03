import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef WhenCallback = bool Function(Offset position);

class ConditionallyTapGestureDetector extends SingleChildRenderObjectWidget {
  const ConditionallyTapGestureDetector({
    super.key,
    this.behavior = HitTestBehavior.deferToChild,
    required this.when,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onTapCancel,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTap,
    this.onSecondaryTapCancel,
    this.onTertiaryTapDown,
    this.onTertiaryTapUp,
    this.onTertiaryTapCancel,
  });

  final HitTestBehavior behavior;
  final WhenCallback when;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCallback? onTap;
  final GestureTapCancelCallback? onTapCancel;
  final GestureTapCallback? onSecondaryTap;
  final GestureTapDownCallback? onSecondaryTapDown;
  final GestureTapUpCallback? onSecondaryTapUp;
  final GestureTapCancelCallback? onSecondaryTapCancel;
  final GestureTapDownCallback? onTertiaryTapDown;
  final GestureTapUpCallback? onTertiaryTapUp;
  final GestureTapCancelCallback? onTertiaryTapCancel;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final renderObject =
        RenderConditionallyTapGestureDetector(behavior: behavior, when: when);

    renderObject._recognizer
      ..onTapDown = onTapDown
      ..onTapUp = onTapUp
      ..onTap = onTap
      ..onTapCancel = onTapCancel
      ..onSecondaryTapDown = onSecondaryTapDown
      ..onSecondaryTapUp = onSecondaryTapUp
      ..onSecondaryTap = onSecondaryTap
      ..onSecondaryTapCancel = onSecondaryTapCancel
      ..onTertiaryTapDown = onTertiaryTapDown
      ..onTertiaryTapUp = onTertiaryTapUp
      ..onTertiaryTapCancel = onTertiaryTapCancel;

    return renderObject;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderConditionallyTapGestureDetector renderObject,
  ) {
    renderObject
      ..behavior = behavior
      ..when = when;
    renderObject._recognizer
      ..onTapDown = onTapDown
      ..onTapUp = onTapUp
      ..onTap = onTap
      ..onTapCancel = onTapCancel
      ..onSecondaryTapDown = onSecondaryTapDown
      ..onSecondaryTapUp = onSecondaryTapUp
      ..onSecondaryTap = onSecondaryTap
      ..onSecondaryTapCancel = onSecondaryTapCancel
      ..onTertiaryTapDown = onTertiaryTapDown
      ..onTertiaryTapUp = onTertiaryTapUp
      ..onTertiaryTapCancel = onTertiaryTapCancel;
  }
}

class RenderConditionallyTapGestureDetector
    extends RenderProxyBoxWithHitTestBehavior {
  RenderConditionallyTapGestureDetector({
    super.child,
    super.behavior,
    required this.when,
  });

  late final TapGestureRecognizer _recognizer =
      TapGestureRecognizer(debugOwner: this);

  WhenCallback when;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      _recognizer.addPointer(event);
      _recognizer.handleEvent(event);
    }
    super.handleEvent(event, entry);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!when(position)) {
      return false;
    }
    return super.hitTest(result, position: position);
  }
}
