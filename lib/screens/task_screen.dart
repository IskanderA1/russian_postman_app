import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:russian_postman_app/model/task.dart';
import 'package:russian_postman_app/util/constants.dart';
import 'package:russian_postman_app/widgets/sidebar.dart';
import 'package:russian_postman_app/services/location.dart';

class TaskScreen extends StatefulWidget {
  final TaskModel taskModel;
  TaskScreen({Key key, @required this.taskModel}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  TaskModel _taskModel;

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _kCameraPosition = CameraPosition(
    target: LatLng(55.787519, 49.123687),
    zoom: 12,
  );

  Future<void> setStartCamera() async{
    Location location = Location();
    await location.getCurrentLocation();
    _kCameraPosition = CameraPosition(
      target: LatLng(location.latitude, location.longitude),
      zoom: 12,
    );
  }
  @override
  initState() {
    super.initState();
    setStartCamera();
    _taskModel = widget.taskModel;
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(
          "ID: ${_taskModel.taskID}"
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _kCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          SideBar(taskModel: _taskModel,searchByCord: searchByCord,),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainColor,
        onPressed:(){
          searchPlace();
        },
        child: Icon(Icons.navigation,
            color: Colors.white),
      ),

    );
  }

  Future<void> searchPlace() async {
    final GoogleMapController controller = await _controller.future;
    Location location = Location();
    await location.getCurrentLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        tilt: 59.440717697143555,
        zoom: 16)
    ));
  }
  Future<void> searchByCord(double lat, double lon) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, lon),
        tilt: 59.440717697143555,
        zoom: 16)
    ));
  }

}
