import 'package:BeaconGuard/service/dashboard_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final fireStore =
      FirebaseFirestore.instance.collection("Beacons").snapshots();
  CollectionReference ref = FirebaseFirestore.instance.collection("Beacons");

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
                    if (isEditing) {
                      if (scannedBeaconForBeaconScannedPage.isNotEmpty) {
                        return Column(
                          children: [
                            const Padding(
                              padding:
                                  EdgeInsets.only(top: 15, bottom: 5, left: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Scanned Beacons",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 18),
                                ),
                              ),
                            ),
                            Container(
                              height:
                                  240, // Set a fixed height for the container
                              child: buildListOfBeaconsEdit(
                                  scannedBeaconForBeaconScannedPage,
                                  _beaconRepositoryNotifier!.savedBeacons),
                            )
                          ],
                        );
                      } else {
                        return Column(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 15, bottom: 10, left: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Scanned Beacons",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 18),
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
                    } else {
                      if (scannedBeaconForBeaconScannedPage.isNotEmpty) {
                        return Column(
                          children: [
                            const Padding(
                              padding:
                                  EdgeInsets.only(top: 15, bottom: 5, left: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Scanned Beacons",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 18),
                                ),
                              ),
                            ),
                            Container(
                              height:
                                  240, // Set a fixed height for the container
                              child: buildListOfBeacons(
                                  scannedBeaconForBeaconScannedPage,
                                  _beaconRepositoryNotifier!.savedBeacons),
                            )
                          ],
                        );
                      } else {
                        return Column(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 15, bottom: 10, left: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Scanned Beacons",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 18),
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
                  if (isEditing) {
                    if (savedBeacons.isEmpty) {
                      return Column(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(left: 10, bottom: 10),
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
                            padding: EdgeInsets.only(left: 10, bottom: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Trusted Beacons",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 18),
                              ),
                            ),
                          ),
                          Container(
                            height: 240, // Set a fixed height for the container
                            child: ListView.builder(
                              itemCount: savedBeacons.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  child: ListTile(
                                    onTap: () {
                                      _onButtonPressed(index, savedBeacons);
                                    },
                                    trailing: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Icon(Icons.delete_outline),
                                    ),
                                    leading: Image.asset(
                                        "images/Beacon+Synergy.png"),
                                    title:
                                        Text(savedBeacons[index].proximityUUID),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Major: ${savedBeacons[index].major.toString()}"),
                                        Text(
                                            "Minor: ${savedBeacons[index].minor.toString()}"),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      );
                    }
                  } else {
                    if (savedBeacons.isEmpty) {
                      return Column(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(left: 10, bottom: 10),
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
                            padding: EdgeInsets.only(left: 10, bottom: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Trusted Beacons",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 18),
                              ),
                            ),
                          ),
                          Container(
                            height: 240, // Set a fixed height for the container
                            child: ListView.builder(
                              itemCount: savedBeacons.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  child: ListTile(
                                    leading: Image.asset(
                                        "images/Beacon+Synergy.png"),
                                    title:
                                        Text(savedBeacons[index].proximityUUID),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Major: ${savedBeacons[index].major.toString()}"),
                                        Text(
                                            "Minor: ${savedBeacons[index].minor.toString()}"),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      );
                    }
                  }
                },
              ))
            ]),
          );
        },
      );
    });
  }

  Widget buildListOfBeaconsEdit(
      List<BeaconModel> beacons, List<BeaconModel> savedbeacons) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 20, right: 16, left: 10),
          shrinkWrap: true,
          itemCount: beacons.length,
          itemBuilder: (BuildContext context, int index) {
            var result = compareTwoBeaconList(savedbeacons, index, beacons);
            return Visibility(
              visible: !result,
              child: GestureDetector(
                onTap: () {
                  _dashBoardNotifer!.pauseScanning_15();
                },
                child: Card(
                  child: ListTile(
                    onTap: () {
                      _onButtonPressedAdd(index, beacons);
                    },
                    leading: Image.asset("images/Beacon+Synergy.png"),
                    title: Text(beacons[index].proximityUUID),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Major:${beacons[index].major.toString()}"),
                        Text("Minor:${beacons[index].minor.toString()}"),
                        Text("Distance:${beacons[index].accuracy} M")
                      ],
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Icon(
                        Icons.add_circle_outline,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildListOfBeacons(
      List<BeaconModel> beacons, List<BeaconModel> savedbeacons) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 20, right: 16, left: 10),
          shrinkWrap: true,
          itemCount: beacons.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                _dashBoardNotifer!.pauseScanning_15();
              },
              child: Card(
                child: ListTile(
                  leading: Image.asset("images/Beacon+Synergy.png"),
                  title: Text(beacons[index].proximityUUID),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Major:${beacons[index].major.toString()}"),
                      Text("Minor:${beacons[index].minor.toString()}"),
                      Text("Distance:${beacons[index].accuracy} M")
                    ],
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Visibility(
                      visible:
                          compareTwoBeaconList(savedbeacons, index, beacons),
                      child: Icon(
                        Icons.star,
                        color: Colors.yellow,
                      ),
                    ),
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
      List<BeaconModel> beacons, int index) async {
    _beaconRepositoryNotifier!.addBeaconToDataBase(beacons[index], context);
  }

  void _onButtonPressed(int index, List<BeaconModel> beaconList) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: const Color(0xFF737373),
            height: 115,
            child: Container(
              child: _buildBottomNavigationMenu(index, beaconList),
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

  Column _buildBottomNavigationMenu(int index, List<BeaconModel> beaconList) {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () {
            // Delete function using the current index
            ref.doc(beaconList[index].id.toString()).delete();
            setState(() {
              beaconList.removeAt(index);
              isEditing = false;
            });

            Navigator.pop(context);
          },
        ),
        const Divider(
          color: Colors.grey,
          height: 0.8,
          thickness: 1,
        ),
        ListTile(
          title: const Text('Cancel'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  bool compareTwoBeaconList(List<BeaconModel> savedBeacons, int index,
      List<BeaconModel> scannedBeacons) {
    bool result = false;
    for (var i = 0; i < savedBeacons.length; i++) {
      if (scannedBeacons[index] == savedBeacons[i]) {
        result = true;
      }
    }
    return result;
  }

  void _onButtonPressedAdd(int index, List<BeaconModel> beaconList) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: const Color(0xFF737373),
            height: 115,
            child: Container(
              child: _buildBottomNavigationMenuAdd(index, beaconList),
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

  Column _buildBottomNavigationMenuAdd(
      int index, List<BeaconModel> beaconList) {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text(
            'Add',
            style: TextStyle(color: Colors.blueAccent),
          ),
          onTap: () {
            // Delete function using the current index
            addBeaconToTrustList(beaconList, index);
            setState(() {
              _beaconRepositoryNotifier!.savedBeacons.add(beaconList[index]);
              beaconList.removeAt(index);
              isEditing = false;
            });
            Navigator.pop(context);
          },
        ),
        const Divider(
          color: Colors.grey,
          height: 0.8,
          thickness: 1,
        ),
        ListTile(
          title: const Text('Cancel'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}