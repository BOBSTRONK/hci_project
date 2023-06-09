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





//   import 'dart:async';
// import 'dart:io';

// import 'package:BeaconGuard/service/dashboard_notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:BeaconGuard/screen/beacon_scanned_page.dart';
// import 'package:flutter_beacon/flutter_beacon.dart';
// import 'package:beacon_broadcast/beacon_broadcast.dart' as bb;
// import 'package:provider/provider.dart';
// import 'package:sound_mode/permission_handler.dart';
// import 'package:sound_mode/sound_mode.dart';
// import 'package:sound_mode/utils/ringer_mode_statuses.dart';

// import '../model/beacon_model.dart';
// import '../service/beacon_repository.dart';
// import '../service/beacon_scan_page_notifier.dart';

// class Dashboard extends StatefulWidget {
//   const Dashboard({super.key});

//   @override
//   State<Dashboard> createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> {
//   late Stream<RangingResult> _beaconStream;
//   late StreamSubscription<RangingResult> _streamRanging;
//   DashBoardNotifer? _dashBoardNotifier;
//   BeaconRepositoryNotifier? _beaconRepositoryNotifier;
//   bb.BeaconBroadcast beaconBroadcast = bb.BeaconBroadcast();
//   bool? isGranted;
//   bool isInitialized = false;
//   Duration duration = Duration();
//   Timer? timer;
//   late final myDashBoardNotifier;
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider<DashBoardNotifer>(
//           create: (BuildContext context) => DashBoardNotifer(),
//         ),
//         ChangeNotifierProvider<BeaconRepositoryNotifier>(
//             create: (BuildContext context) => BeaconRepositoryNotifier()),
//         Provider<DashBoardNotifer>(create: (context) => DashBoardNotifer())
//       ],
//       child: _build(context),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   Widget _build(BuildContext context) {
//     return Builder(builder: (context) {
//       _dashBoardNotifier = context.watch<DashBoardNotifer>();
//       _beaconRepositoryNotifier = context.watch<BeaconRepositoryNotifier>();
//       Widget? body;
//       WidgetsBinding.instance!.addPostFrameCallback((_) {
//         DetectedToSilentMode(_beaconRepositoryNotifier!.savedBeacons);
//       });
//       if (_dashBoardNotifier!.status == "connected") {
//         body = ConnectedView();
//       } else if (_dashBoardNotifier!.status == "scanning") {
//         body = ScanningView();
//       }
//       return Scaffold(
//           appBar: AppBar(
//             automaticallyImplyLeading: false,
//             title: Text('Dashboard'),
//             actions: [
//               IconButton(
//                 icon: Icon(Icons.add),
//                 onPressed: () => _onButtonPressed(),
//               ),
//             ],
//           ),
//           body: body);
//     });
//   }

//   Widget ConnectedView() {
//     return Padding(
//       padding: EdgeInsets.all(10),
//       child: Column(
//         children: [
//           Container(
//             height: 100,
//             child: Card(
//               elevation: 2, // Adjust the elevation for the shadow effect
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: ListTile(
//                 contentPadding:
//                     EdgeInsets.zero, // Remove the default content padding
//                 title: Center(
//                   // Align the content at the center
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(width: 10),
//                       Image.asset(
//                         "images/beaconIcon.jpeg",
//                         width: 58,
//                         height: 58,
//                       ),
//                       SizedBox(
//                           width:
//                               10), // Add spacing between the leading icon and title
//                       Expanded(
//                         child: Text(
//                           'Click to Enable Phone As Beacon',
//                           //Click to Enable to Connect to Beacon
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Icon(Icons.phone_android),
//                       //Icon(Icons.bluetooth),
//                       SizedBox(width: 10),
//                     ],
//                   ),
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 onTap: () {
//                   becomeBeacon();
//                 },
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           Container(
//             child: Image.asset("images/connected.gif"),
//           ),
//           Text("Swithced into No Disturb mode due to trust Beacon in nearby"),
//           SizedBox(
//             height: 15,
//           ),
//           buildTime(),
//         ],
//       ),
//     );
//   }

//   Widget ScanningView() {
//     return Padding(
//       padding: EdgeInsets.all(10),
//       child: Column(
//         children: [
//           Container(
//             height: 100,
//             child: Card(
//               elevation: 2, // Adjust the elevation for the shadow effect
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: ListTile(
//                 contentPadding:
//                     EdgeInsets.zero, // Remove the default content padding
//                 title: Center(
//                   // Align the content at the center
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(width: 10),
//                       Image.asset(
//                         "images/beaconIcon.jpeg",
//                         width: 58,
//                         height: 58,
//                       ),
//                       SizedBox(
//                           width:
//                               10), // Add spacing between the leading icon and title
//                       Expanded(
//                         child: Text(
//                           'Click to Enable Phone As Beacon',
//                           //Click to Enable to Connect to Beacon
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Icon(Icons.phone_android),
//                       //Icon(Icons.bluetooth),
//                       SizedBox(width: 10),
//                     ],
//                   ),
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 onTap: () {
//                   becomeBeacon();
//                 },
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           Container(
//             child: Image.asset("images/connected.gif"),
//           ),
//           Text("Swithced into No Disturb mode due to trust Beacon in nearby"),
//           SizedBox(
//             height: 15,
//           ),
//         ],
//       ),
//     );
//   }

//   //start the timer
//   void startTimer() {
//     timer = Timer.periodic(Duration(seconds: 1), (_) {
//       addTime();
//     });
//   }

//   Widget buildTime() {
//     // 9 --> 09, 11-->11
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     final hours = twoDigits(duration.inHours);
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         buildTimeCard(time: hours, header: "Hours"),
//         const SizedBox(
//           width: 8,
//         ),
//         buildTimeCard(time: minutes, header: "Minutes"),
//         const SizedBox(
//           width: 8,
//         ),
//         buildTimeCard(time: seconds, header: "Seconds"),
//       ],
//     );
//   }

//   Widget buildTimeCard({required String time, required String header}) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//                 color: Colors.black, borderRadius: BorderRadius.circular(20)),
//             child: Text(
//               time,
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   fontSize: 72),
//             )),
//         const SizedBox(
//           height: 10,
//         ),
//         Text(header),
//       ],
//     );
//   }

//   void addTime() {
//     final addSeconds = 1;
//     setState(() {
//       final seconds = duration.inSeconds + addSeconds;
//       duration = Duration(seconds: seconds);
//     });
//   }

//   //reset timer
//   void reset() {
//     duration = Duration();
//   }

//   //stop the timer
//   void stopTimer({bool resets = true}) {
//     if (resets) {
//       reset();
//     }
//     timer?.cancel();
//   }

//   void DetectedToSilentMode(List<BeaconModel> savedBeacons) {
//     _dashBoardNotifier!.SetToSilentMode(savedBeacons, context);
//   }

//   void _onButtonPressed() {
//     showModalBottomSheet(
//         context: context,
//         builder: (context) {
//           return Container(
//             color: const Color(0xFF737373),
//             height: 60,
//             child: Container(
//               child: _buildBottomNavigationMenu(),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).canvasColor,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(10),
//                   topRight: Radius.circular(10),
//                 ),
//               ),
//             ),
//           );
//         });
//   }

//   Column _buildBottomNavigationMenu() {
//     return Column(
//       children: <Widget>[
//         ListTile(
//           leading: Icon(Icons.add),
//           title: Text('Add Beacon'),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => BeaconScannedPage()),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Future<void> becomeBeacon() async {
//     bb.BeaconStatus transmissionSupportStatus =
//         await beaconBroadcast.checkTransmissionSupported();
//     switch (transmissionSupportStatus) {
//       case bb.BeaconStatus.supported:
//         // You're good to go, you can advertise as a beacon
//         beaconBroadcast
//             .setUUID("39ED98FF-2900-441A-802F-9C398FC199D2")
//             .setMajorId(1)
//             .setMinorId(100)
//             .start();
//         print("i am a beacon now");
//         break;
//       case bb.BeaconStatus.notSupportedMinSdk:
//         // Your Android system version is too low (min. is 21)
//         break;
//       case bb.BeaconStatus.notSupportedBle:
//         // Your device doesn't support BLE
//         break;
//       case bb.BeaconStatus.notSupportedCannotGetAdvertiser:
// //         // Either your chipset or driver is incompatible
// //         break;
// //     }
// //   }
// // }


// import 'dart:collection';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// class Person with ChangeNotifier {
//   Person({this.name, this.age});

//   final String name;
//   int age;

//   void increaseAge() {
//     this.age++;
//     notifyListeners();
//   }
// }

// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => Person(name: "Yohan", age: 25),
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatelessWidget {
//   const MyHomePage({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Selector<Person, String>(
//       selector: (BuildContext context, Person person) => person.name,
//       builder: (context, String name, child) {
//         return Scaffold(
//           appBar: AppBar(
//             title: Text("${name} -- ${Provider.of<Person>(context).age} yrs old"),
//           ),
//           body: child,
//         );
//       },
//       child: Center(
//         child: Text('Hi this represents a huge widget! Like a scrollview with 500 children!'),
//       ),
//     );
//   }
// }
