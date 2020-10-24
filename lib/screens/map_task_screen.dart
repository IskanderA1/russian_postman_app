import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:russian_postman_app/model/task.dart';
import 'package:russian_postman_app/screens/task_screen.dart';
import 'package:russian_postman_app/services/location_service.dart';
import 'package:russian_postman_app/util/constants.dart';
import 'package:russian_postman_app/model/marker.dart';

class MapTaskScreen extends StatefulWidget {
  final List<TaskModel> placesList;
  const MapTaskScreen({Key key, this.placesList}) : super(key: key);
  @override
  _MapTaskScreenState createState() => _MapTaskScreenState();
}

class _MapTaskScreenState extends State<MapTaskScreen> {
  List<TaskModel> _addressList;
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _kCameraPosition = CameraPosition(
    target: LatLng(55.787519, 49.123687),
    zoom: 12,
  );
  final Map<String, Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<MarkerModel> _listMarkers;
  BitmapDescriptor redMark;
  BitmapDescriptor blueMark;

  @override
  void initState() {
    _listMarkers = List<MarkerModel>();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(18, 18)), 'assets/markers/red.png')
        .then((onValue) {
      setState(() {
        redMark = onValue;
      });
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(18, 18)), 'assets/markers/blue.png')
        .then((onValue) {
      setState(() {
        blueMark = onValue;
      });
    });
    _addressList = widget.placesList;
    if(_addressList.length>0){
      _createMarker();
      searchPlace(_addressList.first);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text("Задачи"),
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
            polylines: _polylines,
            markers: _markers.values.toSet(),
          )
        ],
      ),
    );
  }



  Future<void> setStartCamera() async {
    LocationService location = LocationService();
    await location.getCurrentLocation();
    _kCameraPosition = CameraPosition(
      target: LatLng(location.latitude, location.longitude),
      zoom: 12,
    );
  }

  Future<void> searchPlace(TaskModel taskModel) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(taskModel.lat, taskModel.lon),
        tilt: 59.440717697143555,
        zoom: 16)));

  }

  Future<void> _createMarker() async {
    setState(() {
      _markers.clear();
      for (TaskModel task in _addressList) {
        if(task.lat !=null){
          final marker = Marker(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return TaskScreen(taskModel: task);
              }));
            },
            markerId: MarkerId(task.taskID.toString()),
            position: LatLng(task.lat, task.lon),
            icon: redMark,
            infoWindow: InfoWindow(
              title: "ID: ${task.taskID}",
            ),
          );
          _markers[task.taskID.toString()] = marker;
        }
      }
    });
  }

}
