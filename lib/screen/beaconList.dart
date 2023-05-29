import 'package:flutter/material.dart';
import 'package:BeaconGuard/screen/beacon_scanned_page.dart';

class BeaconList extends StatefulWidget {
  const BeaconList({super.key});

  @override
  State<BeaconList> createState() => _BeaconListState();
}

class _BeaconListState extends State<BeaconList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Beacon List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _onButtonPressed(),
          ),
        ],
      ),
      body: Center(
          child: Text(
        'Beacon List Screen',
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
