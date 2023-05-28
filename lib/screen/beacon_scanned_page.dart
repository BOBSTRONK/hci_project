import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

import '../service/beacon_scan_page_notifier.dart';

class BeaconScannedPage extends StatefulWidget {
  const BeaconScannedPage({Key? key}) : super(key: key);

  @override
  State<BeaconScannedPage> createState() => _BeaconScannedPageState();
}

class _BeaconScannedPageState extends State<BeaconScannedPage> {
  BeaconPageNotifier? _beaconPageNotifier;
  List<bool> _isChecked = <bool>[];

  Widget _buildUI() {
    return Builder(builder: (context) {
      _beaconPageNotifier = context.watch<BeaconPageNotifier>();
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
      return Scaffold(
        appBar: AppBar(
          title: Text("Scanned Beacons"),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                print(_isChecked);
              },
              child: Text("not ok"),
            ),
            TextButton(
              onPressed: () {
                _beaconPageNotifier!.dispose();
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        ),
      );
    });
  }

  Widget buildListOfBeacons(List<Beacon> beacons) {
    _isChecked = List.filled(_beaconPageNotifier!.scannedBeacons.length, false);
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
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BeaconPageNotifier>(
      create: (BuildContext context) => BeaconPageNotifier(),
      child: _buildUI(),
    );
  }
}
