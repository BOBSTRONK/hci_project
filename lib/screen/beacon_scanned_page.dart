import 'package:BeaconGuard/model/beacon_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

import '../service/beacon_repository.dart';
import '../service/beacon_scan_page_notifier.dart';

class BeaconScannedPage extends StatefulWidget {
  const BeaconScannedPage({Key? key}) : super(key: key);

  @override
  State<BeaconScannedPage> createState() => _BeaconScannedPageState();
}

class _BeaconScannedPageState extends State<BeaconScannedPage> {
  BeaconPageNotifier? _beaconPageNotifier;
  BeaconRepositoryNotifier? _beaconRepositoryNotifier;
  List<bool> _isChecked = <bool>[];
  bool? isGranted;

  Widget _buildUI() {
    return Builder(builder: (context) {
      _beaconPageNotifier = context.watch<BeaconPageNotifier>();
      _beaconRepositoryNotifier = context.watch<BeaconRepositoryNotifier>();
      Widget? body;
      if (_beaconPageNotifier!.loading == true) {
        body = Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        );
      } else if (_beaconPageNotifier!.scannedBeacons.isNotEmpty) {
        body = buildListOfBeacons(_beaconPageNotifier!.scannedBeacons);
      }
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          SetToSilentMode(_beaconPageNotifier!.scannedBeacons,
              _beaconRepositoryNotifier!.savedBeacons);
          return Scaffold(
            appBar: AppBar(
              title: Text("Scanned Beacons"),
            ),
            body: body,
            floatingActionButton: SizedBox(
                height: 60,
                child: ElevatedButton(
                  child: Text(
                    "Add Beacon to the trust beacon list",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return confirmationDialog(
                              _beaconPageNotifier!.scannedBeacons, _isChecked);
                        });
                  },
                )),
          );
        },
      );
    });
  }

  Widget confirmationDialog(List<Beacon> beacons, List<bool> checkList) {
    return AlertDialog(
      title: Text("Info"),
      content: Text(
          "This action adds the beacons to the trusted list, enabling your device to automatically switch to Silent Mode when it detects those beacons nearby."),
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
            onPressed: () {
              addBeaconToTrustList(beacons, checkList);
              Navigator.pop(context);
            },
            child: Text("Confirm")),
      ],
    );
  }

  Widget noPermissionDialog() {
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

  Widget buildListOfBeacons(List<Beacon> beacons) {
    _isChecked = List.filled(_beaconPageNotifier!.scannedBeacons.length, false);
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return ListView.separated(
          padding: const EdgeInsets.only(top: 20, right: 16),
          separatorBuilder: (_, __) => const Divider(),
          itemCount: _beaconPageNotifier!.scannedBeacons.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                _beaconPageNotifier!.pauseScanning();
              },
              child: Card(
                child: CheckboxListTile(
                  onChanged: (value) {
                    setState(() {
                      _isChecked[index] = value!;
                      _beaconPageNotifier!.pauseScanning();
                      print(_isChecked);
                      print(_beaconRepositoryNotifier!
                          .savedBeacons[0].proximityUUID);
                      print(beacons[0].toJson["proximityUUID"]);
                    });
                  },
                  value: _isChecked[index],
                  secondary: const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage("images/Beacon+Synergy.png"),
                  ),
                  title: Text(beacons[index].proximityUUID),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Major:${beacons[index].major.toString()}"),
                      Text("Minor:${beacons[index].minor.toString()}"),
                      Text("Distance:${beacons[index].accuracy} M")
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> addBeaconToTrustList(
      List<Beacon> beacons, List<bool> checkList) async {
    List<Beacon?> selectedBeacons = List.generate(checkList.length,
            (index) => checkList[index] ? beacons[index] : null)
        .where((element) => element != null)
        .toList();
    List<BeaconModel> beaconsToAdd = <BeaconModel>[];
    selectedBeacons.forEach((element) {
      beaconsToAdd
          .add(BeaconModel.fromJson(element!.toJson as Map<String, dynamic>));
    });
    beaconsToAdd.forEach((element) {
      _beaconRepositoryNotifier!.addBeaconToDataBase(element, context);
    });
  }

  Future<void> SetToSilentMode(List<Beacon> currentScannedBeacons,
      List<BeaconModel> savedBeacons) async {
    List<BeaconModel> scannedBeacons = <BeaconModel>[];
    currentScannedBeacons.forEach((element) {
      scannedBeacons
          .add(BeaconModel.fromJson(element!.toJson as Map<String, dynamic>));
    });
    scannedBeacons.forEach((element) async {
      for (var i = 0; i < savedBeacons.length; i++) {
        if (element == savedBeacons[i]) {
          await _getPermissionStatus();
          if(isGranted!){
            await SoundMode.setSoundMode(RingerModeStatus.silent);
          }
          
        }
      }
    });
  }

  Future<void> _getPermissionStatus() async {
    isGranted = await PermissionHandler.permissionsGranted;
    print(isGranted);
    if (!isGranted!) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return noPermissionDialog();
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BeaconPageNotifier>(
          create: (BuildContext context) => BeaconPageNotifier(),
        ),
        ChangeNotifierProvider<BeaconRepositoryNotifier>(
            create: (BuildContext context) => BeaconRepositoryNotifier())
      ],
      child: _buildUI(),
    );
  }
}
