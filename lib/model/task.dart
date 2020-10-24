import 'package:flutter/cupertino.dart';

class TaskModel {

  TaskModel({@required this.taskID, @required this.taskDescription, this.address, this.lat, this.lon,
    @required this.type});
  String taskID;
  String taskDescription;
  String address;
  double lat;
  double lon;
  int type;

  TaskModel.fromJson(Map<String, dynamic> json)
      : taskID = json["taskID"],
        taskDescription = json["taskDescription"],
        address = json["address"],
        lat = json["lat"],
        lon = json["lon"],
        type = json["type"];


}