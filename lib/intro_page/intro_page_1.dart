import 'package:flutter/material.dart';

class IntroPageOne extends StatelessWidget {
  const IntroPageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Replace with your desired background color
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Image.asset(
              "images/silent-mode-illustration-concept-design-vector.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Text(
            "Welcome to BeaconGuard",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.all(16.0),
              child: Text(
                "BeaconGuard is your personal companion that helps you stay undisturbed when you're near Beacons.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
