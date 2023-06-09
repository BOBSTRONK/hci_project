import 'dart:async';
import 'dart:io';

import 'package:BeaconGuard/screen/beaconList.dart';
import 'package:BeaconGuard/service/dashboard_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:BeaconGuard/screen/beacon_scanned_page.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart' as bb;
import 'package:provider/provider.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

import '../model/beacon_model.dart';
import '../service/beacon_repository.dart';
import '../service/beacon_scan_page_notifier.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Stream<RangingResult> _beaconStream;
  late StreamSubscription<RangingResult> _streamRanging;
  DashBoardNotifer? _dashBoardNotifier;
  BeaconRepositoryNotifier? _beaconRepositoryNotifier;
  bb.BeaconBroadcast beaconBroadcast = bb.BeaconBroadcast();
  bool? isGranted;
  bool isInitialized = false;
  bool isBecomeBeacon = false;
  int? state;
  double? _deviceHeight, _deviceWidth;
  Timer? timer;
  late final myDashBoardNotifier;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _dashBoardNotifier = context.watch<DashBoardNotifer>();
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Beacon Guard'),
          /*actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BeaconScannedPage()),
                );
              },
            ),
          ],*/
        ),
        body: Column(
          children: [
            Material(
              child: Selector<DashBoardNotifer, int>(
                selector: (context, dashBoardNotifier) =>
                    dashBoardNotifier.status,
                builder: (_, status, child) {
                  if (isBecomeBeacon) {
                    return BecomeBeaconView();
                  } else {
                    if (status == 1) {
                      status = 1;
                      //startTimer();
                      print("the status is ${status}");
                      return ConnectedView();
                    } else if (status == 0) {
                      print("the status is ${status}");
                      return ScanningView();
                    } else {
                      return Container();
                    }
                  }
                },
              ),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // Widget _build(BuildContext context) {
  //   _deviceHeight = MediaQuery.of(context).size.height;
  //   _deviceWidth = MediaQuery.of(context).size.width;
  //   return Builder(builder: (context) {
  //     _dashBoardNotifier = context.watch<DashBoardNotifer>();
  //     _beaconRepositoryNotifier = context.watch<BeaconRepositoryNotifier>();
  //     Widget? body;
  //     WidgetsBinding.instance!.addPostFrameCallback((_) {
  //       DetectedToSilentMode(_beaconRepositoryNotifier!.savedBeacons);
  //     });
  //     if (!phoneBecomeBeacon!) {
  //       if (_dashBoardNotifier!.status == "connected") {
  //         body = ConnectedView();
  //       } else if (_dashBoardNotifier!.status == "scanning") {
  //         body = ScanningView();
  //       }
  //     } else {
  //       body = BecomeBeaconView();
  //     }

  //     return Scaffold(
  //       backgroundColor: Colors.white,
  //       appBar: AppBar(
  //         automaticallyImplyLeading: false,
  //         title: Text('Beacon Guard'),
  //         actions: [
  //           IconButton(
  //             icon: Icon(Icons.add),
  //             onPressed: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => BeaconScannedPage()),
  //             );
  //           },
  //           ),
  //         ],
  //       ),
  //       //try to use selector to only listen to the status
  //       body: body,
  //     );
  //   });
  // }

  Widget ConnectedView() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            height: 100,
            child: Card(
              elevation: 2, // Adjust the elevation for the shadow effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding:
                    EdgeInsets.zero, // Remove the default content padding
                title: Center(
                  // Align the content at the center
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      Image.asset(
                        "images/beaconIcon.jpeg",
                        width: 58,
                        height: 58,
                      ),
                      SizedBox(
                          width:
                              10), // Add spacing between the leading icon and title
                      Expanded(
                        child: Text(
                          'Click to Enable Phone As Beacon',
                          //Click to Enable to Connect to Beacon
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.phone_android),
                      //Icon(Icons.bluetooth),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onTap: () {
                  isBecomeBeacon = true;
                  _dashBoardNotifier!.becomeBeacon();
                },
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            child: Image.asset(
              "images/connected.gif",
              width: _deviceWidth! * 0.5,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 15, right: 15, left: 15, bottom: 28),
            child: Text(
              "The phone has successfully switched into \"Do Not Disturb\" mode due to a trusted nearby beacon",
              style: TextStyle(
                  fontSize: 16, color: Color.fromRGBO(111, 110, 110, 1)),
            ),
          ),
          const Padding(
              padding: EdgeInsets.only(left: 15.0, bottom: 10.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Time Connected",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
          Consumer<DashBoardNotifer>(builder: (context, dashboard_notifier, _) {
            return buildTime(dashboard_notifier.duration);
          })
        ],
      ),
    );
  }

  Widget ScanningView() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Card(
              elevation: 2, // Adjust the elevation for the shadow effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding:
                    EdgeInsets.zero, // Remove the default content padding
                title: Center(
                  // Align the content at the center
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      Image.asset(
                        "images/beaconIcon.jpeg",
                        width: 58,
                        height: 58,
                      ),
                      const SizedBox(
                          width:
                              10), // Add spacing between the leading icon and title
                      const Expanded(
                        child: Text(
                          'Click to Enable Phone As Beacon',
                          //Click to Enable to Connect to Beacon
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.phone_android),
                      //Icon(Icons.bluetooth),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onTap: () {
                  isBecomeBeacon = true;
                  becomeBeacon();
                },
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Image.asset(
            "images/scanning.gif",
            width: _deviceWidth! * 0.65,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 15, right: 15, left: 15, bottom: 28),
            child: Text(
              "Scanning for trusted beacons near you.",
              style: TextStyle(
                  fontSize: 16, color: Color.fromRGBO(111, 110, 110, 1)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.0, bottom: 10.0, right: 15),
            child: Column(
              children: const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Time Connected",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "When you are connected to a beacon, the time scheduler will be displayed here.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget BecomeBeaconView() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            height: 100,
            child: Card(
              elevation: 2, // Adjust the elevation for the shadow effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding:
                    EdgeInsets.zero, // Remove the default content padding
                title: Center(
                  // Align the content at the center
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20),
                      Icon(Icons.bluetooth),
                      SizedBox(
                          width:
                              10), // Add spacing between the leading icon and title
                      Expanded(
                        child: Text(
                          'Click to Scan Beacon',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 10),
                      Image.asset(
                        "images/beaconIcon.jpeg",
                        width: 58,
                        height: 58,
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onTap: () {
                  isBecomeBeacon = false;
                  _dashBoardNotifier!.stopBroadcast();
                },
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Image.asset(
              "images/becomeBeacon.gif",
              width: _deviceWidth! * 0.85,
            ),
          ),
          SizedBox(
            height: 40,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20, right: 15, left: 15, bottom: 28),
            child: Text(
              "The phone acts as a beacon, it automatically triggers silent mode on other users' phones when detected.",
              style: TextStyle(
                  fontSize: 16, color: Color.fromRGBO(111, 110, 110, 1)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.0, bottom: 10.0, right: 15),
            child: Column(
              children: const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Share and let Other Users to Connect",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                  height: 5,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Your UUID: 39ED98FF-2900-441A-802F-9C398FC199D2 ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Your MajorId: 1 ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Your MinorId: 100 ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                  height: 15,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Remainder: Background execution limits in Android 8 restrict beacon transmission to around 10 minutes before it automatically stops. The current version of the Application does not support Foreground Services to bypass this limitation.",
                    style: TextStyle(
                      color: Color.fromARGB(255, 111, 110, 110),
                      fontSize: 14.0,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTime(Duration duration) {
    // 9 --> 09, 11-->11
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildTimeCard(time: hours, header: "Hours"),
        const SizedBox(
          width: 8,
        ),
        buildTimeCard(time: minutes, header: "Minutes"),
        const SizedBox(
          width: 8,
        ),
        buildTimeCard(time: seconds, header: "Seconds"),
      ],
    );
  }

  Widget buildTimeCard({required String time, required String header}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 3,
                  offset: Offset(3, 5), // changes the shadow position
                ),
              ],
            ),
            child: Text(
              time,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 45),
            )),
        const SizedBox(
          height: 10,
        ),
        Text(header),
      ],
    );
  }

  void DetectedToSilentMode(List<BeaconModel> savedBeacons) {
    _dashBoardNotifier!.SetToSilentMode(savedBeacons, context);
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
