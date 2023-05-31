import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

import '../model/beacon_model.dart';

enum Status { connected, selfBeacon, scanning }

class DashBoardNotifer extends ChangeNotifier {
  DashBoardNotifer() {
    _startScanningBeacon();
  }

  bool loading = false;
  List<Beacon> scannedBeacons = <Beacon>[];
  bool isPaused = false;
  bool? isGranted;
  String status = "scanning";
  Duration duration = Duration();
  Timer? timer;
  List<bool> isCheckd = <bool>[];
  late Stream _beaconStream;
  late StreamSubscription<RangingResult> _streamRanging;

  Future<void> InitBeaconPermission() async {
    try {
      // if you want to manage manual checking about the required permissions
      //await flutterBeacon.initializeScanning;

      //if you want to include automatic checking permission
      await flutterBeacon.initializeAndCheckScanning;
    } on Exception catch (e) {
      // failed to initialize
    }
  }

  Future<void> SetToSilentMode(
      List<BeaconModel> savedBeacons, BuildContext context) async {
    List<BeaconModel> ScanningBeacons = <BeaconModel>[];
    scannedBeacons.forEach((element) {
      ScanningBeacons.add(
          BeaconModel.fromJson(element!.toJson as Map<String, dynamic>));
    });
    ScanningBeacons.forEach((element) async {
      for (var i = 0; i < savedBeacons.length; i++) {
        if (element == savedBeacons[i]) {
          await _getPermissionStatus(context);
          if (isGranted!) {
            await SoundMode.setSoundMode(RingerModeStatus.silent);
            FlutterDnd.setInterruptionFilter(
                FlutterDnd.INTERRUPTION_FILTER_NONE);
          }
        }
      }
    });
    status = "connected";
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
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(20)),
            child: Text(
              time,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 72),
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
    final seconds = duration.inSeconds + addSeconds;
    duration = Duration(seconds: seconds);
    notifyListeners();
  }

  //reset timer
  void reset() {
    duration = Duration();
    notifyListeners();
  }

  //stop the timer
  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }
    timer?.cancel();
    notifyListeners();
  }

  //get the permission status of the application
  Future<void> _getPermissionStatus(BuildContext context) async {
    isGranted = await PermissionHandler.permissionsGranted;
    if (!isGranted!) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return detectedNoPermissionDialog(context);
          });
    }
  }

  // if the application has no permission, and a beacon in the database is detected
  Widget detectedNoPermissionDialog(BuildContext context) {
    return AlertDialog(
      title: Text("Info"),
      content: Text(
          "We detected a trusted Beacon nearby, but your device hasn't granted permission to the app for enabling Silent mode. If you'd like, we can open the Do Not Disturb Access settings for you to grant access"),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.red),
            )),
        TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PermissionHandler.openDoNotDisturbSetting();
            },
            child: Text("OK!")),
      ],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _streamRanging.cancel();
  }

  void pauseScanning_15() {
    _streamRanging.pause();
    Timer.periodic(Duration(seconds: 15), (timer) {
      _streamRanging.resume();
      timer.cancel();
    });
  }


  void startScanningBeaconPeriodically(){
    _streamRanging.pause();
    Timer.periodic(Duration(seconds: 10), (timers) {
       _streamRanging.resume();
       timers.cancel();
     });
  }

  Future<void>_startScanningBeacon() async {
    loading = true;
    final regions = <Region>[];
    List<Beacon> BeaconScanned = <Beacon>[];

    if (Platform.isIOS) {
      // iOS platform, at least set identifier and proximityUUID for region scanning
      regions.add(Region(
          identifier: 'Apple Airlocate',
          proximityUUID: 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0'));
    } else {
      // android platform, it can ranging out of beacon that filter all of Proximity UUID
      regions.add(Region(identifier: 'com.beacon'));
    }
    _beaconStream = flutterBeacon.ranging(regions);

    // to start ranging beacons
      _streamRanging =
          flutterBeacon.ranging(regions).listen((RangingResult result) {
        // result contains a region and list of beacons found
        // list can be empty if no matching beacons were found in range
        print("result of beacons: ${result.beacons}");
        print("Regions: ${result.region}");
        BeaconScanned = result.beacons;
        scannedBeacons = BeaconScanned;
        loading = false;
        notifyListeners();
      });
  }
}
