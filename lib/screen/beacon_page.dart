import 'package:BeaconGuard/service/dashboard_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

import '../model/beacon_model.dart';
import '../service/beacon_repository.dart';

class BeaconPage extends StatefulWidget {
  const BeaconPage({super.key});

  @override
  State<BeaconPage> createState() => _BeaconPageState();
}

class _BeaconPageState extends State<BeaconPage> {
  BeaconRepositoryNotifier? _beaconRepositoryNotifier;
  DashBoardNotifer? _dashBoardNotifer;
  bool isEditing = false;
  late List<BeaconModel> ListOfTrustedBeacons;
  List<bool> _isChecked = <bool>[];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BeaconRepositoryNotifier>(
            create: (BuildContext context) => BeaconRepositoryNotifier())
      ],
      child: _build(),
    );
  }

  Widget _build() {
    return Builder(builder: (context) {
      _beaconRepositoryNotifier = context.watch<BeaconRepositoryNotifier>();
      _dashBoardNotifer = context.watch<DashBoardNotifer>();
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setstate) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text("Beacon List"),
              actions: [
                IconButton(
                  icon: Icon(isEditing ? Icons.done : Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEditing = !isEditing;
                    });
                  },
                ),
              ],
            ),
            body: Column(children: [
              Expanded(
                child: Selector<DashBoardNotifer, List<BeaconModel>>(
                  selector: (context, dashBoardNotifier) =>
                      dashBoardNotifier.scannedBeaconForBeaconScannedPage,
                  builder: (_, scannedBeaconForBeaconScannedPage, child) {
                    if (scannedBeaconForBeaconScannedPage.isNotEmpty) {
                      return Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 15, bottom: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Scanned Beacons",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 18),
                              ),
                            ),
                          ),
                          buildListOfBeacons(scannedBeaconForBeaconScannedPage),
                        ],
                      );
                    } else {
                      return Column(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(top: 15, bottom: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Scanned Beacons",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 18),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                                "No beacons have been found in close proximity.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600)),
                          )
                        ],
                      );
                    }
                  },
                ),
              ),
              const Divider(
                thickness: 0.4,
                color: Colors.black,
                indent: 40,
                endIndent: 40,
                height: 30,
              ),
              Expanded(
                  child: Selector<BeaconRepositoryNotifier, List<BeaconModel>>(
                selector: (context, beaconRepositoryNotifier) =>
                    beaconRepositoryNotifier.savedBeacons,
                builder: (_, savedBeacons, child) {
                  if (savedBeacons.isEmpty) {
                    return Column(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Trusted Beacons",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18),
                            ),
                          ),
                        ),
                        Center(
                          child: Text("No trusted beacons.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only( bottom: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Trusted Beacons",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18),
                            ),
                          ),
                        ),
                        ListView.builder(
                            itemCount: savedBeacons.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                child: ListTile(
                                  leading:
                                      Image.asset("images/Beacon+Synergy.png"),
                                  title:
                                      Text(savedBeacons[index].proximityUUID),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Major:${savedBeacons[index].major.toString()}"),
                                      Text(
                                          "Minor:${savedBeacons[index].minor.toString()}"),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ],
                    );
                  }
                },
              ))
            ]),
          );
        },
      );
    });
  }

  Widget buildListOfBeacons(List<BeaconModel> beacons) {
    _isChecked = List.filled(beacons.length, false);
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return ListView.separated(
          padding: const EdgeInsets.only(top: 20, right: 16),
          separatorBuilder: (_, __) => const Divider(),
          shrinkWrap: true,
          itemCount: beacons.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                _dashBoardNotifer!.pauseScanning_15();
              },
              child: Card(
                child: CheckboxListTile(
                  onChanged: (value) {
                    setState(() {
                      _isChecked[index] = value!;
                      _dashBoardNotifer!.pauseScanning_15();
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

    //add beacon to the trusted beacon List
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
}
