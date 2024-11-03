import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart' as pp;

import 'src/data.dart';
import 'src/presentation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  Intl.defaultLocale = 'ru_RU';

  final dir = await pp.getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [TodoSchema],
    directory: dir.path,
  );
  runApp(MyApp(isar: isar));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.isar,
  });

  final Isar isar;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}
