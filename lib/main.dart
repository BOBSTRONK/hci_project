import 'package:flutter/material.dart';
import 'package:hci_project/screen/onboarding_screen.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: Color.fromARGB(255, 68, 134, 233)),
        textButtonTheme: TextButtonThemeData(style: ButtonStyle(foregroundColor: MaterialStateColor.resolveWith((states) => Color.fromARGB(255, 68, 134, 233)))),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(foregroundColor: MaterialStateColor.resolveWith((states) => Color.fromARGB(255, 68, 134, 233)))),
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Color.fromARGB(255, 68, 134, 233)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: OnBoardingScreen(),
    );
  }
}