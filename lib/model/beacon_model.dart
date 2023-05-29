import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'beacon_model.g.dart';

@JsonSerializable(explicitToJson: true)
class BeaconModel {
  BeaconModel(
      {required this.proximityUUID,
      required this.major,
      required this.minor,
      required this.accuracy,
      required this.macAddress,
      this.rssi,
      this.proximity,
      this.txPower,
      this.id});

  String? id;
  String proximityUUID;
  int major;
  int minor;
  int? rssi;
  double accuracy;
  String? proximity;
  int? txPower;
  String macAddress;

  factory BeaconModel.fromJson(Map<String, dynamic> json) =>
      _$BeaconModelFromJson(json);

  factory BeaconModel.fromSnapShot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return BeaconModel(
        proximityUUID: data!["proximityUUID"],
        major: data["major"],
        minor: data["minor"],
        accuracy: data["accuracy"],
        macAddress: data["macAddress"],
        id: document.id,
        rssi: data["rssi"],
        proximity: data["proximity"],
        txPower: data["txPower"]);
  }

  @override
  bool operator ==(Object other) {
    return other is BeaconModel &&
        other.proximityUUID == proximityUUID &&
        other.major == major;
  }

  Map<String, dynamic> toJson() => _$BeaconModelToJson(this);

  @override
  // TODO: implement hashCode
  int get hashCode => Object.hash(proximityUUID, major);
}
