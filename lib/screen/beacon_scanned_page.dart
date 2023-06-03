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
  //List<bool> _isChecked = <bool>[];
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
            /*floatingActionButton: FloatingActionButton(
              onPressed: () {
                /*showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return confirmationDialog(
                          _beaconPageNotifier!.scannedBeacons, _isChecked);
                    });*/
                addBeaconToTrustList(
                    _beaconPageNotifier!.scannedBeacons, _isChecked);
                Navigator.pop(context);
              },
              backgroundColor: Colors.white,
              child: Icon(
                Icons.add,
                color: Colors.grey,
              ),
            ),*/
          );
        },
      );
    });
  }

  Widget confirmationDialog(List<BeaconModel> beacons, int index) {
    return AlertDialog(
      title: Text("Info"),
      content: Text("Are you sure you want to add this beacon?"),
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
              addBeaconToTrustList(beacons, index);
              Navigator.pop(context);
            },
            child: Text("Confirm")),
      ],
    );
  }

  Widget buildListOfBeacons(List<BeaconModel> beacons) {
    //_isChecked = List.filled(_beaconPageNotifier!.scannedBeacons.length, false);
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return ListView.builder(
          itemCount: _beaconRepositoryNotifier!.savedBeacons.length,
          itemBuilder: (BuildContext context, int index) {
            bool isInCompareList = compareTwoBeaconList(
                    _beaconRepositoryNotifier!.savedBeacons,
                    _beaconPageNotifier!.scannedBeacons)
                .contains(beacons[index]);
            Widget icon;

            if (isInCompareList) {
              icon = Icon(
                Icons.check_circle_outline,
                color: Colors.blueGrey,
                size: 30,
              );
            } else {
              icon = Icon(
                Icons.add_circle,
                color: Colors.blueAccent,
                size: 30,
              );
            }
            return GestureDetector(
              onTap: () {
                _beaconPageNotifier!.pauseScanning_15();
              },
              child: Card(
                child: ListTile(
                  onTap: () {
                    if (isInCompareList) {
                      _beaconPageNotifier!.pauseScanning_15();
                      confirmationDialog(
                          _beaconPageNotifier!.scannedBeacons, index);
                    }
                  },
                  leading: Image.asset("images/Beacon+Synergy.png"),
                  trailing: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: icon,
                  ),
                  /*Checkbox(
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
                ),*/
                  //tileColor: _isChecked[index] ? Colors.green : null,
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
      List<BeaconModel> beacons, int index) async {
    beacons.add(
        BeaconModel.fromJson(beacons[index].toJson as Map<String, dynamic>));
    _beaconRepositoryNotifier!.addBeaconToDataBase(beacons[index], context);
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
  List<BeaconModel> compareTwoBeaconList(
      List<BeaconModel> savedBeacons, List<BeaconModel> scannedBeacons) {
    List<BeaconModel> result = [];
    scannedBeacons.forEach((element) {
      for (var i = 0; i < savedBeacons.length; i++) {
        if (element != savedBeacons[i]) {
          result.add(element);
        }
      }
    });
    return result;
  }
}
