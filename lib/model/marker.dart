import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerModel{
  MarkerModel(this.markerType, this.lat, this.lon);


  int markerType;
  double lat;
  double lon;
}