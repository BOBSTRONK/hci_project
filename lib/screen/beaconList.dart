import 'package:flutter/material.dart';
import 'package:BeaconGuard/screen/beacon_scanned_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

import '../model/beacon_model.dart';
import '../service/beacon_repository.dart';
import '../service/beacon_scan_page_notifier.dart';

class BeaconList extends StatefulWidget {
  const BeaconList({super.key});

  @override
  State<BeaconList> createState() => _BeaconListState();
}

class _BeaconListState extends State<BeaconList> {
  BeaconPageNotifier? _beaconPageNotifier;
  BeaconRepositoryNotifier? _beaconRepositoryNotifier;
  double? _deviceHeight, _deviceWidth;

  List<bool> _isChecked = <bool>[];
  bool? isGranted;
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
      child: _build(),
    );
  }

  Widget _build() {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Builder(
      builder: (context) {
        _beaconPageNotifier = context.watch<BeaconPageNotifier>();
        _beaconPageNotifier?.startScanningBeacon();
        _beaconRepositoryNotifier = context.watch<BeaconRepositoryNotifier>();
        return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Beacon List'),
              actions: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BeaconScannedPage()),
                    );
                  },
                ),
              ],
            ),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Scanned Beacons',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _deviceHeight! * 0.45,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 14.0, right: 14.0),
                        child: _buildScanningBeaconUi()),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Trusted Beacons',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14.0, right: 14.0),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Text("ciao")),
                    ),
                  ),
                ]));
      },
    );
  }

  Widget buildListOfBeacons(List<Beacon> beacons) {
    _isChecked = List.filled(_beaconPageNotifier!.scannedBeacons.length, false);
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return ListView.separated(
          shrinkWrap: true,
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

  Widget _buildScanningBeaconUi() {
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
        return Container(
          child: body,
        );
      },
    );
  }
}
