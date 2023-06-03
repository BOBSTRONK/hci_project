import 'package:flutter/material.dart';
import 'package:BeaconGuard/screen/beacon_scanned_page.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('History'),
      ),
      body: Center(
          child: Text(
        'History Screen',
        style: TextStyle(fontSize: 40),
      )),
    );
  }
}
