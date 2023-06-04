import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'history_model.g.dart';

@JsonSerializable(explicitToJson: true)
class History {
  History(
      {required this.startTime,
      required this.endTime,
      required this.duration,
      this.description,
      this.id});

  String? id;
  DateTime startTime;
  DateTime endTime;
  int duration;
  String? description;

  factory History.fromJson(Map<String, dynamic> json) =>
      _$HistoryFromJson(json);

  factory History.fromSnapShot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return History(
        startTime: DateTime.parse(data!["startTime"]),
        endTime: DateTime.parse(data["endTime"]),
        duration: data["duration"],
        id: document.id,
        description: data["description"],);

  }
 
  Map<String, dynamic> toJson() => _$HistoryToJson(this);

}
