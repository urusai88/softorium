import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// ignore_for_file: avoid_setters_without_getters

typedef AbsorbingCallback = bool Function(Offset position);

class ConditionallyAbsorbPointer extends SingleChildRenderObjectWidget {
  const ConditionallyAbsorbPointer({
    super.key,
    required this.absorbingCallback,
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

  final AbsorbingCallback absorbingCallback;
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
  RenderObject createRenderObject(BuildContext context) =>
      RenderConditionallyAbsorbPointer(
        callback: absorbingCallback,
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onTap: onTap,
        onTapCancel: onTapCancel,
        onSecondaryTapDown: onSecondaryTapDown,
        onSecondaryTapUp: onSecondaryTapUp,
        onSecondaryTap: onSecondaryTap,
        onSecondaryTapCancel: onSecondaryTapCancel,
        onTertiaryTapDown: onTertiaryTapDown,
        onTertiaryTapUp: onTertiaryTapUp,
        onTertiaryTapCancel: onTertiaryTapCancel,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderConditionallyAbsorbPointer renderObject,
  ) =>
      renderObject
        ..callback = absorbingCallback
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

class RenderConditionallyAbsorbPointer
    extends RenderProxyBoxWithHitTestBehavior {
  RenderConditionallyAbsorbPointer({
    super.child,
    required this.callback,
    GestureTapDownCallback? onTapDown,
    GestureTapUpCallback? onTapUp,
    GestureTapCallback? onTap,
    GestureTapCancelCallback? onTapCancel,
    GestureTapDownCallback? onSecondaryTapDown,
    GestureTapUpCallback? onSecondaryTapUp,
    GestureTapCallback? onSecondaryTap,
    GestureTapCancelCallback? onSecondaryTapCancel,
    GestureTapDownCallback? onTertiaryTapDown,
    GestureTapUpCallback? onTertiaryTapUp,
    GestureTapCancelCallback? onTertiaryTapCancel,
  }) : super(behavior: HitTestBehavior.opaque) {
    _recognizer
      ..onTapDown = onTapDown
      ..onTapUp = onTapUp
      ..onTap = onTap
      ..onTapCancel = onTapCancel
      ..onSecondaryTap = onSecondaryTap
      ..onSecondaryTapDown = onSecondaryTapDown
      ..onSecondaryTapUp = onSecondaryTapUp
      ..onSecondaryTapCancel = onSecondaryTapCancel
      ..onTertiaryTapDown = onTertiaryTapDown
      ..onTertiaryTapUp = onTertiaryTapUp
      ..onTertiaryTapCancel = onTertiaryTapCancel;
  }

  late final TapGestureRecognizer _recognizer =
      TapGestureRecognizer(debugOwner: this);

  AbsorbingCallback callback;

  set onTapDown(GestureTapDownCallback? value) => _recognizer.onTapDown = value;

  set onTapUp(GestureTapUpCallback? value) => _recognizer.onTapUp = value;

  set onTap(GestureTapCallback? value) => _recognizer.onTap = value;

  set onTapCancel(GestureTapCancelCallback? value) =>
      _recognizer.onTapCancel = value;

  set onSecondaryTapDown(GestureTapDownCallback? value) =>
      _recognizer.onSecondaryTapDown = value;

  set onSecondaryTapUp(GestureTapUpCallback? value) =>
      _recognizer.onSecondaryTapUp = value;

  set onSecondaryTap(GestureTapCallback? value) =>
      _recognizer.onSecondaryTap = value;

  set onSecondaryTapCancel(GestureTapCancelCallback? value) =>
      _recognizer.onSecondaryTapCancel = value;

  set onTertiaryTapDown(GestureTapDownCallback? value) =>
      _recognizer.onTertiaryTapDown = value;

  set onTertiaryTapUp(GestureTapUpCallback? value) =>
      _recognizer.onTertiaryTapUp = value;

  set onTertiaryTapCancel(GestureTapCancelCallback? value) =>
      _recognizer.onTertiaryTapCancel = value;

  @override
  Size computeSizeForNoChild(BoxConstraints constraints) => constraints.biggest;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _recognizer.addPointer(event);
      _recognizer.handleEvent(event);
    }
    super.handleEvent(event, entry);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position) && callback(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}
