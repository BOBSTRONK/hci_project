import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:BeaconGuard/screen/beacon_scanned_page.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart' as bb;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Stream<RangingResult> _beaconStream;
  late StreamSubscription<RangingResult> _streamRanging;
  bb.BeaconBroadcast beaconBroadcast = bb.BeaconBroadcast();
  bool? isGranted;
  bool isInitialized = false;
  double? _deviceHeight, _deviceWidth;
  AnimationController? _animationController;

  @override
  Widget build(BuildContext context) {
    Timer timerForScanningBeacon =
        Timer.periodic(Duration(seconds: 10), (Timer t) {
      _dashBoardNotifier?.startScanningBeaconPeriodically();
    });
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DashBoardNotifer>(
          create: (BuildContext context) => DashBoardNotifer(),
        ),
        ChangeNotifierProvider<BeaconRepositoryNotifier>(
            create: (BuildContext context) => BeaconRepositoryNotifier())
      ],
      child: _build(context),
    );
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
      DetectedToSilentMode(_beaconRepositoryNotifier!.savedBeacons);
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Beacon Guard'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _onButtonPressed(),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
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
                      becomeBeacon();
                    },
                  ),
                ),
              ),
              Container(
                child: Image.asset(
                  "images/connected.gif",
                  width: _deviceWidth! * 0.5,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: 15.0, left: 15.0, right: 15.0, bottom: 28.0),
                child: Text(
                  "The phone has successfully switched into \"Do Not Disturb\" mode due to a trusted nearby beacon.",
                  style: TextStyle(
                      fontSize: 16.0, color: Color.fromRGBO(111, 110, 110, 1)),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 0.0, left: 15.0, bottom: 10.0),
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
              _dashBoardNotifier!.buildTime(),
            ],
          ),
        ),
      );
    });
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
