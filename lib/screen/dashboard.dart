import 'dart:async';
import 'dart:io';

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
  bool phoneBecomeBeacon = false;
  double? _deviceHeight, _deviceWidth;
  Duration duration = Duration();
  Timer? timer;
  late final myDashBoardNotifier;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DashBoardNotifer>(
          create: (BuildContext context) => DashBoardNotifer(),
        ),
        ChangeNotifierProvider<BeaconRepositoryNotifier>(
            create: (BuildContext context) => BeaconRepositoryNotifier()),
      ],
      child: _build(context),
    );
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

  Widget _build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Builder(builder: (context) {
      _dashBoardNotifier = context.watch<DashBoardNotifer>();
      _beaconRepositoryNotifier = context.watch<BeaconRepositoryNotifier>();
      Widget? body;
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        DetectedToSilentMode(_beaconRepositoryNotifier!.savedBeacons);
      });
      if (!phoneBecomeBeacon) {
        if (_dashBoardNotifier!.status == "connected") {
          body = ConnectedView();
        } else if (_dashBoardNotifier!.status == "scanning") {
          body = ScanningView();
        }
      } else {
        body = BecomeBeaconView();
      }

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Beacon Guard'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => BeaconScannedPage(),
            ),
          ],
        ),
        //try to use selector to only listen to the status
        body: body,
      );
    });
  }

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
                  phoneBecomeBeacon = true;
                  becomeBeacon();
                },
              ),
            ),
          ),
          SizedBox(
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
          buildTime(),
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
                  phoneBecomeBeacon = true;
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
                  phoneBecomeBeacon = false;
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
          SizedBox(height: 40,),
          const Padding(
            padding: EdgeInsets.only(top: 20, right: 15, left: 15, bottom: 35),
            child: Text(
              "The phone acts as a beacon, it automatically triggers silent mode on other users' phones when detected.",
              style: TextStyle(
                  fontSize: 16, color: Color.fromRGBO(111, 110, 110, 1)),
            ),
          ),
        ],
      ),
    );
  }

  //start the timer
  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      addTime();
    });
  }

  Widget buildTime() {
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

  void addTime() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }

  //reset timer
  void reset() {
    duration = Duration();
  }

  //stop the timer
  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }
    timer?.cancel();
  }

  void DetectedToSilentMode(List<BeaconModel> savedBeacons) {
    _dashBoardNotifier!.SetToSilentMode(savedBeacons, context);
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
