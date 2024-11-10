import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Stream<Position> getLocationStream({LocationAccuracy accuracy = LocationAccuracy.high, Duration interval = const Duration(seconds: 15)}) async* {
    while (true) {
      try {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
        yield position;
      } catch (e) {
        print('Error getting location: $e');
      }
      await Future.delayed(interval);
    }
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled. Please enable the services');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied, we cannot request permissions.');
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print(position);
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }
}