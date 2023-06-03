import 'package:flutter/material.dart';
import 'package:BeaconGuard/screen/beacon_scanned_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/beacon_model.dart';
import '../service/beacon_repository.dart';
import '../service/beacon_scan_page_notifier.dart';

class BeaconList extends StatefulWidget {
  const BeaconList({super.key});

  @override
  State<BeaconList> createState() => _BeaconListState();
}

class _BeaconListState extends State<BeaconList> {
  BeaconRepositoryNotifier? _beaconRepositoryNotifier;
  bool isEditing = false;
  late List<BeaconModel> ListOfTrustedBeacons;
  List<bool> _isChecked = <bool>[];
  List<int> indexes = [];

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
    return Builder(
      builder: (context) {
        _beaconRepositoryNotifier = context.watch<BeaconRepositoryNotifier>();
        Widget? body;
        body = buildListOfBeacons();

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Beacon List'),
            actions: [
              IconButton(
                icon: Icon(isEditing ? Icons.done : Icons.edit),
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing; // Toggle the editing state
                  });
                },
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }

  Widget buildListOfBeacons() {
    ListOfTrustedBeacons = _beaconRepositoryNotifier!.savedBeacons;
    _isChecked = List.filled(ListOfTrustedBeacons.length, false);

    if (ListOfTrustedBeacons.isEmpty) {
      return const Center(
        child: Text("No trusted beacons.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 25,
                fontWeight: FontWeight.w600)),
      );
    }

    return Column(
      children: [
        Flexible(
          child: ListView.builder(
            itemCount: ListOfTrustedBeacons.length,
            itemBuilder: (BuildContext context, int index) {
              if (isEditing) {
                return _editCheckBox(index, ListOfTrustedBeacons);
              } else {
                return Card(
                  child: ListTile(
                    leading: Image.asset("images/Beacon+Synergy.png"),
                    title: Text(ListOfTrustedBeacons[index].proximityUUID),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Major:${ListOfTrustedBeacons[index].major.toString()}"),
                        Text(
                            "Minor:${ListOfTrustedBeacons[index].minor.toString()}"),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
        if (isEditing)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(
                onPressed: () =>
                    _onButtonPressed(indexes, ListOfTrustedBeacons),
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.grey,
                ),
              ),
            ),
          )
      ],
    );
  }

  // Widget _buildScanningBeaconUi() {
  //   Widget? body;
  //   body = buildListOfBeacons();

  //   return StatefulBuilder(
  //     builder: (BuildContext context, StateSetter setState) {
  //       return Container(
  //         child: body,
  //       );
  //     },
  //   );
  // }

  Widget _editCheckBox(
    int index,
    List<BeaconModel> beaconList,
  ) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          children: [
            SizedBox(
              height: 2.5,
            ),
            CheckboxListTile(
              onChanged: (value) {
                setState(() {
                  _isChecked[index] = value!;
                  if (value) {
                    indexes.add(index);
                  } else {
                    indexes.remove(index);
                  }
                });
              },
              value: _isChecked[index],
              secondary: const CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage("images/Beacon+Synergy.png"),
              ),
              title: Text(beaconList[index].proximityUUID),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Major: ${beaconList[index].major.toString()}"),
                  Text("Minor: ${beaconList[index].minor.toString()}"),
                ],
              ),
            ),
            const Divider(
              color: Colors.grey,
              height: 0.8,
              thickness: 1,
            ),
          ],
        );
      },
    );
  }

  void _onButtonPressed(List<int> indexes, List<BeaconModel> beaconList) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: const Color(0xFF737373),
            height: 115,
            child: Container(
              child: _buildBottomNavigationMenu(indexes, beaconList),
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

  /*Future<void> addBeaconToTrustList(
      List<BeaconModel> beacons, List<bool> checkList) async {
    List<BeaconModel?> selectedBeacons = List.generate(checkList.length,
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
  }*/

  Column _buildBottomNavigationMenu(
      List<int> indexes, List<BeaconModel> beaconList) {
    return Column(
      children: <Widget>[
        Expanded(
          child: indexes.isNotEmpty
              ? ListView.builder(
                  itemCount: indexes.length,
                  itemBuilder: (context, index) {
                    int currentIndex = indexes[index];
                    return ListTile(
                      title: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        // Delete function using the current index
                        ref
                            .doc(beaconList[currentIndex].id.toString())
                            .delete();

                        setState(() {
                          // Remove the index from the list
                          indexes.removeAt(index);
                          isEditing = false;
                          beaconList.removeAt(currentIndex);
                        });

                        Navigator.pop(context);
                      },
                    );
                  },
                )
              : const ListTile(
                  title: Text(
                    'Delete',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
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
