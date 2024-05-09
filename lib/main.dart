import 'package:flutter/material.dart';
import 'Pages/CreationForm.dart';
import 'Pages/Map.dart';
import 'package:flutter_translate/flutter_translate.dart';

import 'Pages/SplashScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profilio',
      routes: {
        "/": (context) => SplashScreen(),
        "/CanadianResumeForm": (context) => CanadianResumeForm(toggleTheme: toggleTheme),
        "/map": (context) => Map(),
      },
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,

    );
  }
}