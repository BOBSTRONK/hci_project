import 'package:BeaconGuard/model/beacon_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BeaconRepository extends ChangeNotifier {
  BeaconRepository({required this.context});

  final _db = FirebaseFirestore.instance;
  BuildContext context;
  void addBeaconToDataBase(BeaconModel beacon) async {
    // create a collection called beacon
    await _db
        .collection("Beacons")
        .add(beacon.toJson())
        .whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("The beacon has been successfuly added!"))))
        .catchError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("There is an error here, Something went wrong")));
    });
  }
}
