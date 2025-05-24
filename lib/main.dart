import 'package:contact/data/datasources/contact_database.dart';
import 'package:contact/presentation/pages/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> forceAppUpdate() async {
  WidgetsBinding.instance.addPostFrameCallback(
    (_) async => await WidgetsBinding.instance.performReassemble(),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ContactDatabase.instance.database; // DB 초기화
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 투명색
        // systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.white,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const ContactPage(),
    );
  }
}
