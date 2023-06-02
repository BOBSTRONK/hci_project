import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

import '../model/beacon_model.dart';
import 'beacon_repository.dart';

enum Status { connected, selfBeacon, scanning }

class DashBoardNotifer extends ChangeNotifier {
  DashBoardNotifer(this.context) {
    _startScanningBeacon();
    periodicallyScan();
  }

  bool loading = false;
  List<List<BeaconModel>> scannedBeacons = <List<BeaconModel>>[];
  BeaconRepositoryNotifier beaconRepositoryNotifier =
      BeaconRepositoryNotifier();
  BuildContext context;
  bool isPaused = false;
  bool? isGranted;
  // 0 = scanning， 1 = connected ，2 = selfBeacon
  int _status = 0;
  bool flag1 = false;
  bool flag2 = false;
  Duration duration = Duration();
  Timer? timer_1;
  Timer? timer_2;
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

  void periodicallyScan() {
    timer_1 = Timer.periodic(Duration(seconds: 10), (timer) {
      SetToSilentMode(beaconRepositoryNotifier.savedBeacons, context);
    });
  }

  Future<void> SetToSilentMode(
      List<BeaconModel> savedBeacons, BuildContext context) async {
    if (await checkScanned(savedBeacons, context)) {
      status = 1;
    } else {
      status = 0;
    }
    notifyListeners();
  }

  int get status => _status;

  set status(int newValue) {
    if (_status != newValue) {
      ("i start timer here");
      startTimer();
    } else if (_status == 0 && _status !=newValue) {
      print("the duration in seconds: ${duration.inSeconds}");
    }
    print("here is the status in the ${_status}");
    _status = newValue;
  }

  Future<bool> checkScanned(
      List<BeaconModel> savedBeacons, BuildContext context) async {
    bool result = false;
    for (int i = 0; i < scannedBeacons.length; i++) {
      if (compareTwoBeaconList(savedBeacons, scannedBeacons[i])) {
        await _getPermissionStatus(context);
        if (isGranted!) {
          await SoundMode.setSoundMode(RingerModeStatus.silent);
          FlutterDnd.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_NONE);
        }
        result = true;
      }
    }
    return result;
  }

  bool compareTwoBeaconList(
      List<BeaconModel> savedBeacons, List<BeaconModel> scannedBeacons) {
    bool result = false;
    scannedBeacons.forEach((element) {
      for (var i = 0; i < savedBeacons.length; i++) {
        if (element == savedBeacons[i]) {
          result = true;
        }
      }
    });
    return result;
  }

  //start the timer
  void startTimer() {
    timer_2 = Timer.periodic(Duration(seconds: 1), (_) {
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
    final seconds = duration.inSeconds + addSeconds;
    duration = Duration(seconds: seconds);
    notifyListeners();
  }


  //stop the timer
  void stopTimer() {
    duration = Duration();
    timer_2!.cancel();
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
    Timer(const Duration(seconds: 15), () {
      _streamRanging.resume();
    });
  }

  void startScanningBeaconPeriodically() {
    _streamRanging.pause();
    Timer(Duration(seconds: 15), () {
      _streamRanging.resume();
    });
  }

  Future<void> _startScanningBeacon() async {
    loading = true;
    final regions = <Region>[];
    int counter = 0;
    final BeaconScanned = List.filled(20, <BeaconModel>[]);

    List<BeaconModel> bucket = <BeaconModel>[];
    List<BeaconModel> bucket2 = <BeaconModel>[];

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
      // print("result of beacons: ${result.beacons}");
      // print("Regions: ${result.region}");

      List<BeaconModel> bucket = <BeaconModel>[];

      result.beacons.forEach((element) {
        bucket
            .add(BeaconModel.fromJson(element.toJson as Map<String, dynamic>));
      });
      
      
      BeaconScanned[counter] = List.from(bucket);
      counter = (counter + 1) % 20;
      print(counter);
      print(BeaconScanned);

      scannedBeacons = BeaconScanned;
      bucket.clear();
      loading = false;

      notifyListeners();
    });
  }
}
