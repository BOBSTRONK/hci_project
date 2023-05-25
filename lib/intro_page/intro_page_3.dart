import 'package:flutter/material.dart';

class IntroPageThree extends StatelessWidget {
  const IntroPageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Image.asset(
              "images/VCG41N1442752963.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Text("Enable Phone As Beacon",
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
                "Turn your phone into a beacon so that when others detect it, their phones automatically switch to silent mode.",
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
