import 'package:flutter/widgets.dart';

import '../widgets.dart';

class TapOutsideOverlay extends StatelessWidget {
  const TapOutsideOverlay({
    super.key,
    required this.keys,
    required this.onTapOutside,
  });

  /// Элементы, на которые допукается нажатие
  final List<GlobalKey> keys;
  final GestureTapCallback onTapOutside;

  @override
  Widget build(BuildContext context) {
    return ConditionallyTapGestureDetector(
      behavior: HitTestBehavior.opaque,
      when: (position) {
        final renderObjects = [
          for (final key in keys) key.currentContext?.findRenderObject(),
        ];
        final renderBoxes = renderObjects.whereType<RenderBox>();
        if (renderObjects.isEmpty) {
          return false;
        }
        for (final renderBox in renderBoxes) {
          final rect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
          if (rect.contains(position)) {
            return false;
          }
        }
        return true;
      },
      onTap: onTapOutside,
    );
  }
}
