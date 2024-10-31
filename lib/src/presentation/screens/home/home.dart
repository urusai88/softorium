import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../constants.dart';
import '../../widgets.dart';
import 'pages/placeholder.dart';
import 'pages/todo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String get _name => 'Джамшутушка';

  late final PageController _pageController;

  var _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _jumpToPage(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    const estimatedNavBarHeight = 64.0;
    const navBarVerticalPaddings = 12.0;
    final body = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1, -.35),
          end: Alignment(1, .35),
          colors: [
            Color(0xFFF9F3FC),
            Color(0xFFFAF1E7),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      pagePadding + const EdgeInsets.symmetric(vertical: 31),
                  child: UserView(
                    name: _name,
                    avatar: MyAssets.woman,
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (p) => setState(() => _page = p),
                    children: const [
                      TodoPage(),
                      PlaceholderPage(),
                      PlaceholderPage(),
                      PlaceholderPage(),
                    ],
                  ),
                ),
                const Gap(estimatedNavBarHeight + navBarVerticalPaddings * 2),
                Builder(
                  builder: (context) {
                    return SizedBox(
                      height: max(
                        MediaQuery.viewInsetsOf(context).vertical -
                            64 -
                            navBarVerticalPaddings,
                        0,
                      ),
                    );
                  },
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: navBarVerticalPaddings,
                ),
                child: NavigationBar(
                  items: [
                    NavigationTile(
                      iconAsset: MyAssets.iconNavHome,
                      current: _page == 0,
                      onTap: () => _jumpToPage(0),
                    ),
                    NavigationTile(
                      iconAsset: MyAssets.iconNavCards,
                      current: _page == 1,
                      onTap: () => _jumpToPage(1),
                    ),
                    NavigationTile(
                      iconAsset: MyAssets.iconNavChart,
                      current: _page == 2,
                      onTap: () => _jumpToPage(2),
                    ),
                    NavigationTile(
                      iconAsset: MyAssets.iconNavNotification,
                      current: _page == 3,
                      onTap: () => _jumpToPage(3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: body,
    );
  }
}

class NavigationBar extends StatelessWidget {
  const NavigationBar({
    super.key,
    required this.items,
  });

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final children = List.of(items);
    for (var i = children.length - 1; i > 0; --i) {
      children.insert(i, const Gap(10));
    }
    return Container(
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

class UserView extends StatelessWidget {
  const UserView({
    super.key,
    required this.name,
    required this.avatar,
  });

  final String name;
  final ImageProvider avatar;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Привет, $name',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          child: Image(
            width: 40,
            height: 40,
            image: avatar,
          ),
        ),
      ],
    );
  }
}
