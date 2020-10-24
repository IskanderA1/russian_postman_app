import 'dart:async';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:russian_postman_app/model/marker.dart';
import 'package:russian_postman_app/model/task.dart';
import 'package:russian_postman_app/util/constants.dart';
import 'package:russian_postman_app/widgets/sidebar.dart';
import 'package:russian_postman_app/services/location_service.dart';

class TaskScreen extends StatefulWidget {
  final TaskModel taskModel;
  TaskScreen({Key key, @required this.taskModel}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  TaskModel _taskModel;
  final Map<String, Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<MarkerModel> _listMarkers;
  List<LatLng> _latLngList;
  bool trackLocationEnable = false;

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _kCameraPosition = CameraPosition(
    target: LatLng(55.787519, 49.123687),
    zoom: 12,
  );


  @override
  initState() {
    super.initState();
    setStartCamera();
    _taskModel = widget.taskModel;
    _listMarkers = List<MarkerModel>();
    _latLngList = List<LatLng>();
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
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

            polylines: _polylines,
            markers: _markers.values.toSet(),
          ),
          SideBar(taskModel: _taskModel,searchByCord: searchByCord,createMarker: _createMarker, trackLocationUpdate: _trackLocationUpdate, setAddressLocation: _setAddressLocation,clearRoad: _clearRoad),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:() async {
          await searchPlace();
        },
        child:Icon(Icons.navigation,
            color: Colors.white),
        backgroundColor: mainColor,
      ),
    );
  }

  Future<void> setStartCamera() async{
    LocationService location = LocationService();
    await location.getCurrentLocation();
    _kCameraPosition = CameraPosition(
      target: LatLng(location.latitude, location.longitude),
      zoom: 12,
    );
  }

  Future<void> _clearRoad() async{
    setState(() {
      _latLngList.clear();
      _taskModel.road.clear();
      _polylines.clear();
    });
  }
  Future<void> _trackLocationUpdate() async{
    setState(() {
      trackLocationEnable? trackLocationEnable=false:trackLocationEnable=true;
    });
    if(trackLocationEnable){
      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }
      _locationSubscription = _locationTracker.onLocationChanged().listen((newLocalData) {
        if (_controller != null) {
          _trackRoad(newLocalData.latitude,newLocalData.longitude);
          _searchByCordAndSetMarker(newLocalData.latitude, newLocalData.longitude);
        }
      });
    }else{
      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }
      if(_latLngList != null&&_latLngList.isNotEmpty){
        setState(() {
          _taskModel.road = _latLngList;
        });

      }
      print("roadLengthTask = ${_taskModel.road.length==null?0:_taskModel.road.length}");
    }
  }

  Future<void> _trackRoad(double lat, double lon) async {
    setState(() {
      _latLngList.add(LatLng(lat, lon));
    });
    print("_latLngList = ${_latLngList.length}");
    _polylines.add(Polyline(
      polylineId: PolylineId(lat.toString()),
      visible: true,
      points: _latLngList,
      color: mainColor,
      width: 5,
    ));
  }

  Future<void> searchPlace() async {
    final GoogleMapController controller = await _controller.future;
    LocationService location = LocationService();
    await location.getCurrentLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        tilt: 59.440717697143555,
        zoom: 16)
    ));
    await _createMarker(1,location.latitude,location.longitude);
  }
  Future<LatLng> _setAddressLocation() async {
    final GoogleMapController controller = await _controller.future;
    LocationService location = LocationService();
    await location.getCurrentLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        tilt: 59.440717697143555,
        zoom: 16)
    ));
    await _createMarker(2,location.latitude,location.longitude);
    return LatLng(location.latitude, location.longitude);
  }
  Future<void> searchByCord(double lat, double lon) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, lon),
        tilt: 59.440717697143555,
        zoom: 16)
    ));
  }
  Future<void> _searchByCordAndSetMarker(double lat, double lon) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, lon),
        tilt: 59.440717697143555,
        zoom: 16)
    ));
    _createMarker(1,lat,lon);
  }



  Future<void> _createMarker(int markerType, double markerLat,double markerLon) async {
    await _updateListMarker(markerType, markerLat, markerLon);
    print(_listMarkers.length.toString());
    setState(() {
      _markers.clear();
      for (MarkerModel markerModel in _listMarkers) {
        final marker = Marker(
          onTap:(){},
          markerId: MarkerId(markerModel.markerType.toString()),
          position: LatLng(markerModel.lat, markerModel.lon),
          infoWindow: InfoWindow(
            title: markerModel.markerType==1?"Я":"Адресат",

          ),
        );
        _markers[markerModel.markerType.toString()] = marker;
      }
    });
  }

  Future<void> _updateListMarker(int markerType, double markerLat,double markerLon) async {
    if(_listMarkers.length>0){
      for(MarkerModel markerModel in _listMarkers){
        if(markerModel.markerType == markerType){
          setState(() {
            markerModel.lat = markerLat;
            markerModel.lon = markerLon;
          });
        }else{
          setState(() {
            _listMarkers.add(MarkerModel(markerType, markerLat, markerLon));
          });
          return;
        }
      }
    }else{
      setState(() {
        _listMarkers.add(MarkerModel(markerType, markerLat, markerLon));
      });
    }
  }

}
