import 'package:BeaconGuard/model/beacon_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';


class BeaconRepositoryNotifier extends ChangeNotifier {
    BeaconRepositoryNotifier() {
    getBeaconsDetails();
  }
  final _db = FirebaseFirestore.instance;
  List<BeaconModel> savedBeacons = <BeaconModel>[];
 
  void addBeaconToDataBase(BeaconModel beacon,BuildContext context) async {
    // addding item into the collection called Beacons, if the collection
    // is not created yet, then it will create it and then do the adding operation.
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

  Future<List<BeaconModel>> getBeaconsDetails()async{
    final snapshot = await _db.collection("Beacons").get();
    final beaconList = snapshot.docs.map((e) => BeaconModel.fromSnapShot(e)).toList();
    savedBeacons=beaconList;
    notifyListeners();
    return beaconList;
  }
}
