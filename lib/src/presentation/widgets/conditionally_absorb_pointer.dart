import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef ConditionallyAbsorbPointerCallback = bool Function(Offset position);

class ConditionallyAbsorbPointer extends SingleChildRenderObjectWidget {
  const ConditionallyAbsorbPointer({
    super.key,
    required this.callback,
    required this.onAbsorbed,
  });

  final ConditionallyAbsorbPointerCallback callback;
  final VoidCallback onAbsorbed;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderConditionallyAbsorbPointer(
        callback: callback,
        onAbsorbed: onAbsorbed,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderConditionallyAbsorbPointer renderObject,
  ) =>
      renderObject
        ..callback = callback
        ..onAbsorbed = onAbsorbed;
}

class RenderConditionallyAbsorbPointer
    extends RenderProxyBoxWithHitTestBehavior {
  RenderConditionallyAbsorbPointer({
    RenderBox? child,
    required ConditionallyAbsorbPointerCallback callback,
    required VoidCallback onAbsorbed,
  })  : _callback = callback,
        _onAbsorbed = onAbsorbed,
        super(behavior: HitTestBehavior.translucent) {
    _recognizer.onTap = _onAbsorbed;
  }

  late final _recognizer = TapGestureRecognizer(debugOwner: this);

  ConditionallyAbsorbPointerCallback get callback => _callback;
  ConditionallyAbsorbPointerCallback _callback;

  set callback(ConditionallyAbsorbPointerCallback value) {
    if (value != _callback) {
      _callback = value;
    }
  }

  VoidCallback get onAbsorbed => _onAbsorbed;
  VoidCallback _onAbsorbed;

  set onAbsorbed(VoidCallback value) {
    if (value != _onAbsorbed) {
      _onAbsorbed = value;
      _recognizer.onTap = _onAbsorbed;
    }
  }

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
    if (!size.contains(position)) {
      return false;
    }
    if (callback(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}
