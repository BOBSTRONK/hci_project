// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beacon_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeaconModel _$BeaconModelFromJson(Map<String, dynamic> json) => BeaconModel(
      proximityUUID: json['proximityUUID'] as String,
      major: json['major'] as int,
      minor: json['minor'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      macAddress: json['macAddress'] as String,
      rssi: json['rssi'] as int?,
      proximity: json['proximity'] as String?,
      txPower: json['txPower'] as int?,
    );

Map<String, dynamic> _$BeaconModelToJson(BeaconModel instance) =>
    <String, dynamic>{
      'proximityUUID': instance.proximityUUID,
      'major': instance.major,
      'minor': instance.minor,
      'rssi': instance.rssi,
      'accuracy': instance.accuracy,
      'proximity': instance.proximity,
      'txPower': instance.txPower,
      'macAddress': instance.macAddress,
    };
