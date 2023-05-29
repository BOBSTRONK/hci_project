import 'package:json_annotation/json_annotation.dart';

part 'beacon_model.g.dart';
@JsonSerializable(explicitToJson: true)
class BeaconModel{
  BeaconModel({required this.proximityUUID,required this.major, required this.minor, required this.accuracy,required this.macAddress,this.rssi,this.proximity,this.txPower});

  String proximityUUID;
  int major;
  int minor;
  int? rssi;
  double accuracy;
  String? proximity;
  int? txPower;
  String macAddress;

  factory BeaconModel.fromJson(Map<String, dynamic> json) => _$BeaconModelFromJson(json);

  @override
  bool operator == (Object other){
    return other is BeaconModel && other.proximityUUID == proximityUUID && other.major== major;
  }
  
  Map<String,dynamic> toJson() => _$BeaconModelToJson(this);

  @override
  // TODO: implement hashCode
  int get hashCode => Object.hash(proximityUUID, major);
  
}
