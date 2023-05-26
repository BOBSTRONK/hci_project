import 'package:flutter/material.dart';

class IntroPageTwo extends StatelessWidget {
  const IntroPageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(230, 231, 253, 100),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Image.asset(
              "images/All-There’s-to-Know-About-Beacon-Technology-for-Mobile-Apps.png",
              fit: BoxFit.cover,
            ),
          ),
          Text(
            "Discover Beacons",
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
                "BeaconGuard detects Beacons around you. As you move closer to a beacon, BeaconGuard will sense it and trigger your phone's \"Do Not Disturb\" mode.",
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
