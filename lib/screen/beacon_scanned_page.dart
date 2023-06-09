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

  //可以用selector，然后直接create a instance of dashBoardNotifier来使用pause
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        );
      } else if (_beaconPageNotifier!.scannedBeacons.isNotEmpty) {
        // var finalList = compareTwoBeaconList(
        //     _beaconPageNotifier!.scannedBeacons,
        //     _beaconRepositoryNotifier!.savedBeacons);
        body = buildListOfBeacons(_beaconPageNotifier!.scannedBeacons);
      } else {
        body = const Center(
          child: Text("No beacons have been found in close proximity.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 25,
                  fontWeight: FontWeight.w600)),
        );
      }

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Add Beacons"),
            ),
            body: body,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                /*showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return confirmationDialog(
                          _beaconPageNotifier!.scannedBeacons, _isChecked);
                    });*/
                addBeaconToTrustList(
                    _beaconPageNotifier!.scannedBeacons, _isChecked);
              },
              backgroundColor: Colors.white,
              child: Icon(
                Icons.add,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    });
  }

  // Widget confirmationDialog(List<Beacon> beacons, List<bool> checkList) {
  //   return AlertDialog(
  //     title: Text("Info"),
  //     content: Text(
  //         "This action adds the beacons to the trusted list, enabling your device to automatically switch to Silent Mode when it detects those beacons nearby."),
  //     actions: [
  //       TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //           child: Text(
  //             "Cancel",
  //             style: TextStyle(color: Colors.red),
  //           )),
  //       TextButton(
  //           onPressed: () {
  //             addBeaconToTrustList(beacons, checkList);
  //             Navigator.pop(context);
  //           },
  //           child: Text("Confirm")),
  //     ],
  //   );
  // }

  Widget buildListOfBeacons(List<BeaconModel> beacons) {
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
                _beaconPageNotifier!.pauseScanning_15();
              },
              child: Card(
                child: CheckboxListTile(
                  onChanged: (value) {
                    setState(() {
                      _isChecked[index] = value!;
                      _beaconPageNotifier!.pauseScanning_15();
                      print(_isChecked);
                      print(_beaconRepositoryNotifier!
                          .savedBeacons[0].proximityUUID);
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
      List<BeaconModel> beacons, List<bool> checkList) async {
    List<BeaconModel?> selectedBeacons = List.generate(checkList.length,
            (index) => checkList[index] ? beacons[index] : null)
        .where((element) => element != null)
        .toList();
    print(selectedBeacons);
    List<BeaconModel> beaconsToAdd = <BeaconModel>[];
    selectedBeacons.forEach((element) {
      beaconsToAdd
          .add(element!);
    });
    beaconsToAdd.forEach((element) {
      _beaconRepositoryNotifier!.addBeaconToDataBase(element, context);
    });
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

  //compare beacons, return a list of beacons without saved beacons
  List<Beacon> compareTwoBeaconList(
      List<Beacon> savedBeacons, List<BeaconModel> scannedBeacons) {
    List<Beacon> result = [];
    var scanned = scannedBeacons.cast<Beacon>();
    scanned.forEach((element) {
      for (var i = 0; i < savedBeacons.length; i++) {
        if (element != savedBeacons[i]) {
          result.add(element);
        }
      }
    });
    return result;
  }
}
