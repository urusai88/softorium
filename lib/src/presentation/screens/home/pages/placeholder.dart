import 'package:flutter/cupertino.dart';

import '../../../constants.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: pagePadding,
      child: Text(loremIpsum),
    );
  }
}
