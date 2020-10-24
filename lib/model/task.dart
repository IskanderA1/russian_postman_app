import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:russian_postman_app/model/situation.dart';

class TaskModel {

  TaskModel({@required this.taskID, @required this.taskDescription, this.city,this.street,this.house, this.lat, this.lon,
    @required this.type});
  String taskID;
  String taskDescription;
  String city;
  String street;
  String house;
  double lat;
  double lon;
  int type;
  List<LatLng> road = List<LatLng>();
  List<Situation> situations = List<Situation>();
 /* TaskModel.fromJson(Map<String, dynamic> json)
      : taskID = json["taskID"],
        taskDescription = json["taskDescription"],
        address = json["address"],
        lat = json["lat"],
        lon = json["lon"],
        type = json["type"];*/


}