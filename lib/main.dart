import 'package:BeaconGuard/screen/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkOnboardingStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator if the onboarding status is being checked
          return CircularProgressIndicator();
        } else {
          // Onboarding not completed, show the onboarding page
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              appBarTheme: const AppBarTheme(backgroundColor: Color.fromARGB(255, 68, 134, 233)),
              textButtonTheme: TextButtonThemeData(style: ButtonStyle(foregroundColor: MaterialStateColor.resolveWith((states) => Color.fromARGB(255, 68, 134, 233)))),
              elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(foregroundColor: MaterialStateColor.resolveWith((states) => Color.fromARGB(255, 68, 134, 233)))),
              floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Color.fromARGB(255, 68, 134, 233)),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: snapshot.data == false ? OnBoardingScreen() : Home(), //need to check this
          );
        }
      },
    );
  }
}

Future<bool> checkOnboardingStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;
  return onboardingCompleted;
}