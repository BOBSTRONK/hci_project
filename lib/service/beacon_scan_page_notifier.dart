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

class BeaconPageNotifier extends ChangeNotifier {
  BeaconPageNotifier() {
    startScanningBeacon();
  }

  bool loading = false;
  List<BeaconModel> scannedBeacons = <BeaconModel>[];
  bool isPaused = false;
  bool? isGranted;
  String status = "scanning";
  Duration duration = Duration();
  Timer? timer;
  List<bool> isCheckd = <bool>[];
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

  void pauseScanning_60() {
    _streamRanging.pause();
    Timer.periodic(Duration(seconds: 60), (timer) {
      _streamRanging.resume();
      timer.cancel();
    });
  }

  Future<void> startScanningBeacon() async {
    loading = true;
    final regions = <Region>[];
    List<BeaconModel> BeaconScanned = <BeaconModel>[];

    if (Platform.isIOS) {
      // iOS platform, at least set identifier and proximityUUID for region scanning
      regions.add(Region(
          identifier: 'Apple Airlocate',
          proximityUUID: 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0'));
    } else {
      // android platform, it can ranging out of beacon that filter all of Proximity UUID
      regions.add(Region(identifier: 'com.beacon'));
    }

    // to start ranging beacons
    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
      // result contains a region and list of beacons found
      // list can be empty if no matching beacons were found in range
      List<BeaconModel> bucket = <BeaconModel>[];
      print("result of beacons: ${result.beacons}");
      print("Regions: ${result.region}");
      result.beacons.forEach((element) {
              bucket.add(BeaconModel.fromJson(element.toJson as Map<String,dynamic>));

      });

      BeaconScanned = List.from(bucket);
      scannedBeacons = BeaconScanned;
      loading = false;
      notifyListeners();
    });
  }
}
