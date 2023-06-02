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
  BeaconRepositoryNotifier? _beaconRepositoryNotifier;
  bool isEditing = false;
  late List<BeaconModel> ListOfTrustedBeacons;
  List<bool> _isChecked = <bool>[];
  double? _deviceHeight, _deviceWidth;

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

  @override
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
    return ListView.builder(
      itemCount: ListOfTrustedBeacons.length,
      itemBuilder: (BuildContext context, int index) {
        if (isEditing) {
          return _editCheckBox(index, ListOfTrustedBeacons,);
        } else {
          return Card(
            child: ListTile(
              leading: Image.asset("images/Beacon+Synergy.png"),
              title: Text(ListOfTrustedBeacons[index].proximityUUID),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Major:${ListOfTrustedBeacons[index].major.toString()}"),
                  Text("Minor:${ListOfTrustedBeacons[index].minor.toString()}"),
                ],
              ),
            ),
          );
        }
      },
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
      int index, List<BeaconModel> beaconList,) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          children: [
            CheckboxListTile(
              onChanged: (value) {
                print(_isChecked);
                print("Checkbox onChanged: $value");
                setState(() {
                  _isChecked[index] = value!;
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
            Padding(
              padding: EdgeInsets.only(
                top: _deviceHeight! * 0.6,
                left: _deviceWidth! * 0.7,
              ),
              child: FloatingActionButton(
                onPressed: () => _onButtonPressed(),
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onButtonPressed() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: const Color(0xFF737373),
            height: 115,
            child: Container(
              child: _buildBottomNavigationMenu(),
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

  Column _buildBottomNavigationMenu() {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () {
            //delete function
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
