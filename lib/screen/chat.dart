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
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BeaconScannedPage()),
                );
              },
          ),
        ],
      ),
      body: Center(
          child: Text(
        'History Screen',
        style: TextStyle(fontSize: 40),
      )),
    );
  }

  void _onButtonPressed() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: const Color(0xFF737373),
            height: 60,
            child: Container(
              child: _buildBottomNavigationMenu(),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          );
        });
  }

  Column _buildBottomNavigationMenu() {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Beacon'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BeaconScannedPage()),
            );
          },
        ),
      ],
    );
  }
}
