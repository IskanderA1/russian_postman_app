import 'package:geolocator/geolocator.dart';

class LocationService {
  double longitude;
  double latitude;


  Future<void> getCurrentLocation() async {
    try {
      Position position = await getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      print(e);
    }
  }
}