import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

import '../service/beacon_scan_page_notifier.dart';

class BeaconScannedPage extends StatefulWidget {
  const BeaconScannedPage({super.key});

  @override
  State<BeaconScannedPage> createState() => _BeaconScannedPageState();
}

class _BeaconScannedPageState extends State<BeaconScannedPage> {
  double? _deviceHeight, _deviceWidth;
  BeaconPageNotifier? _beaconPageNotifier;

  Widget _buildUI() {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
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
      return AlertDialog(
        title: Text("Scanned Beacons"),
        actions: [],
        content: SizedBox(
            width: _deviceWidth! * 0.7,
            height: _deviceHeight! * 0.7,
            child: body),
      );
    });
  }

  Widget buildListOfBeacons(List<Beacon> beacons) {
    return ListView.separated(
        padding: const EdgeInsets.only(top: 20, right: 16),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: _beaconPageNotifier!.scannedBeacons.length,
        itemBuilder: (BuildContext context, int index) {
          return _beaconItem(beacons[index]);
        });
  }

  Widget _beaconItem(Beacon beacon) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage("images/Beacon+Synergy.png"),
        ),
        title: Text(beacon.proximityUUID),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Major:${beacon.major.toString()}"),
                Text("Minor:${beacon.major.toString()}")
              ],
            )
          ],
        ),
      ),
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
