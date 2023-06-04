import 'package:BeaconGuard/model/beacon_model.dart';
import 'package:BeaconGuard/model/history_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';


class BeaconRepositoryNotifier extends ChangeNotifier {
    BeaconRepositoryNotifier() {
    getBeaconsDetails();
    getHistoryFromDataBase();
  }
  final _db = FirebaseFirestore.instance;
  List<BeaconModel> savedBeacons = <BeaconModel>[];
  List<History> savedHisotry = <History>[];
 
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

   void addHistoryDataBase(History history,BuildContext context) async {
    // addding item into the collection called Beacons, if the collection
    // is not created yet, then it will create it and then do the adding operation.
    await _db
        .collection("History")
        .add(history.toJson())
        .whenComplete((){
          print("add ${history.duration} to the history database");
        })
        .catchError((error, stackTrace) {
      print(error);
    });
  }

  Future<void> updateHistoryDesc(History history)async{
    await _db.collection("History").doc(history.id).update(history.toJson());
    await getHistoryFromDataBase();
    notifyListeners();
  }

  Future<List<BeaconModel>> getBeaconsDetails()async{
    final snapshot = await _db.collection("Beacons").get();
    final beaconList = snapshot.docs.map((e) => BeaconModel.fromSnapShot(e)).toList();
    savedBeacons=beaconList;
    notifyListeners();
    return beaconList;
  }

    Future<List<History>> getHistoryFromDataBase()async{
    final snapshot = await _db.collection("History").get();
    final historyList = snapshot.docs.map((e) => History.fromSnapShot(e)).toList();
    savedHisotry=historyList;
    notifyListeners();
    return historyList;
  }
}
