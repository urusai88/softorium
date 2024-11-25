import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../presentation.dart';

class NavigationItem {
  const NavigationItem({
    required this.iconAsset,
  });

  final ImageProvider iconAsset;
}

class NavigationBar extends StatelessWidget {
  const NavigationBar({
    super.key,
    required this.currentPage,
    required this.onPageTap,
    required this.items,
  });

  final int currentPage;
  final ValueChanged<int> onPageTap;
  final List<NavigationItem> items;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      for (var i = 0; i < items.length; ++i)
        NavigationTile(
          iconAsset: items[i].iconAsset,
          current: i == currentPage,
          onTap: () => onPageTap(i),
        ),
    ];
    for (var i = children.length - 1; i > 0; --i) {
      children.insert(i, const Gap(10));
    }
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}

class NavigationTile extends StatelessWidget {
  const NavigationTile({
    super.key,
    required this.iconAsset,
    this.current = false,
    this.onTap,
  });

  final ImageProvider iconAsset;
  final bool current;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const currentColor = Color(0xFFBEB7EB);
    const color = Color(0xFFF4F4F5);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MyAnimatedColor(
        duration: animationDuration,
        color: current ? currentColor : color,
        builder: (context, value, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value,
            ),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ImageIcon(
            iconAsset,
            size: 24,
            color: const Color(0xFF2B2C2D),
          ),
        ),
      ),
    );
  }
}
