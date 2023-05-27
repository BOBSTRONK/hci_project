  // Widget buildListOfBeacons(List<Beacon> beacons) {
  //   _isChecked = List.filled(_beaconPageNotifier!.scannedBeacons.length, false);
  //   return ListView.separated(
  //       padding: const EdgeInsets.only(top: 20, right: 16),
  //       separatorBuilder: (_, __) => const Divider(),
  //       itemCount: _beaconPageNotifier!.scannedBeacons.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         return GestureDetector(
  //           onTap: () {
  //             _beaconPageNotifier!.pauseScanning();
  //           },
  //           child: Card(
  //             child: CheckboxListTile(
  //               onChanged: (value){
  //                 setState(() {
  //                   _isChecked[index] = value!;
  //                 });
  //               },
  //               value: _isChecked[index],
  //               secondary: const CircleAvatar(
  //                 backgroundColor: Colors.transparent,
  //                 backgroundImage: AssetImage("images/Beacon+Synergy.png"),
  //               ),
  //               title: Text(beacons[index].proximityUUID),
  //               subtitle: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text("Major:${beacons[index].major.toString()}"),
  //                   Text("Minor:${beacons[index].minor.toString()}"),
  //                   Text("Distance:${beacons[index].accuracy} M")
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       });
  // }