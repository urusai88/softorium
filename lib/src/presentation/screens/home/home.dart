import 'dart:math';

import 'package:flutter/material.dart' hide NavigationBar;
import 'package:gap/gap.dart';

import '../../../presentation.dart';
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

  @override
  Widget build(BuildContext context) {
    const estimatedNavBarHeight = 64.0;
    const navBarVerticalPaddings = 12.0;
    final body = Stack(
      fit: StackFit.expand,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: pagePadding + const EdgeInsets.symmetric(vertical: 30),
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
            const Gap(navBarVerticalPaddings),
          ],
        ),
      ],
    );

    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
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
        child: SafeArea(child: body),
      ),
      bottomNavigationBar: UnconstrainedBox(
        child: Padding(
          padding: const EdgeInsets.only(bottom: navBarVerticalPaddings),
          child: NavigationBar(
            currentPage: _page,
            onPageTap: (p) => _pageController.jumpToPage(p),
            items: const [
              NavigationItem(iconAsset: MyAssets.iconNavHome),
              NavigationItem(iconAsset: MyAssets.iconNavCards),
              NavigationItem(iconAsset: MyAssets.iconNavChart),
              NavigationItem(iconAsset: MyAssets.iconNavNotification),
            ],
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
