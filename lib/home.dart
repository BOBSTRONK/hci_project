import 'dart:async';
import 'dart:io';

import 'package:BeaconGuard/screen/beacon_scanned_page.dart';
import 'package:flutter/material.dart';
import 'screen/chat.dart';
import 'screen/dashboard.dart';
import 'screen/beaconList.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart' as bb;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentTab = 0;
  double? _deviceWidth;
  final List<Widget> screens = [Dashboard(), Chat()];
  late Stream<RangingResult> _beaconStream;
  late StreamSubscription<RangingResult> _streamRanging;
  bb.BeaconBroadcast beaconBroadcast = bb.BeaconBroadcast();

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = Dashboard();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MaterialButton(
                    minWidth: _deviceWidth! / 3,
                    onPressed: () {
                      setState(() {
                        currentScreen = Dashboard();
                        currentTab = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth,
                          color:
                              currentTab == 0 ? Colors.blueAccent : Colors.grey,
                        ),
                        Text(
                          'BLE',
                          style: TextStyle(
                            color: currentTab == 0
                                ? Colors.blueAccent
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: _deviceWidth! / 3,
                    onPressed: () {
                      setState(() {
                        currentScreen = Chat();
                        currentTab = 1;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          color:
                              currentTab == 1 ? Colors.blueAccent : Colors.grey,
                        ),
                        Text(
                          'History',
                          style: TextStyle(
                            color: currentTab == 1
                                ? Colors.blueAccent
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: _deviceWidth! / 3,
                    onPressed: () {
                      setState(() {
                        currentScreen = BeaconList();
                        currentTab = 2;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list_alt,
                          color:
                              currentTab == 2 ? Colors.blueAccent : Colors.grey,
                        ),
                        Text(
                          'Beacon List',
                          style: TextStyle(
                            color: currentTab == 2
                                ? Colors.blueAccent
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildBottomNavigationMenu() {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.bluetooth),
          title: Text('Enable Phone As Beacon'),
          onTap: () {
            becomeBeacon();
          },
        )
      ],
    );
  }

  Future<void> becomeBeacon() async {
    bb.BeaconStatus transmissionSupportStatus =
        await beaconBroadcast.checkTransmissionSupported();
    switch (transmissionSupportStatus) {
      case bb.BeaconStatus.supported:
        // You're good to go, you can advertise as a beacon
        beaconBroadcast
            .setUUID("39ED98FF-2900-441A-802F-9C398FC199D2")
            .setMajorId(1)
            .setMinorId(100)
            .start();
        print("i am a beacon now");
        break;
      case bb.BeaconStatus.notSupportedMinSdk:
        // Your Android system version is too low (min. is 21)
        break;
      case bb.BeaconStatus.notSupportedBle:
        // Your device doesn't support BLE
        break;
      case bb.BeaconStatus.notSupportedCannotGetAdvertiser:
        // Either your chipset or driver is incompatible
        break;
    }
  }
}
