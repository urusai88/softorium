import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef ConditionallyAbsorbPointerCallback = bool Function(Offset position);

class ConditionallyAbsorbPointer extends SingleChildRenderObjectWidget {
  const ConditionallyAbsorbPointer({
    super.key,
    required this.callback,
  });

  final ConditionallyAbsorbPointerCallback callback;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderConditionallyAbsorbPointer()..callback = callback;

  @override
  void updateRenderObject(
    BuildContext context,
    RenderConditionallyAbsorbPointer renderObject,
  ) =>
      renderObject..callback = callback;
}

class RenderConditionallyAbsorbPointer
    extends RenderProxyBoxWithHitTestBehavior {
  ConditionallyAbsorbPointerCallback? _callback;

  ConditionallyAbsorbPointerCallback get callback => _callback!;

  set callback(ConditionallyAbsorbPointerCallback value) {
    if (value != _callback) {
      _callback = value;
      markNeedsLayout();
    }
  }

  @override
  Size computeSizeForNoChild(BoxConstraints constraints) => constraints.biggest;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) {
      return false;
    }
    final hitTested = callback(position);
    if (hitTested) {
      return true;
    }
    final hitTarget =
        hitTestChildren(result, position: position) || hitTestSelf(position);
    if (hitTarget) {
      result.add(BoxHitTestEntry(this, position));
    }
    return hitTarget;
  }
}
