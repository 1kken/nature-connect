// tracking_manager.dart
import 'package:latlong2/latlong.dart';
import 'dart:convert';

class TrackingManager {
  bool startNavigation = false;
  List<LatLng> trackingPath = [];

  void startTracking(LatLng currentLatLng) {
    startNavigation = true;
    trackingPath = [currentLatLng];
  }

  void stopTracking() {
    startNavigation = false;
    trackingPath.clear();
  }

  void addToTrackingPath(LatLng currentLatLng) {
    if (startNavigation) {
      trackingPath.add(currentLatLng);
    }
  }

  String convertTrackingPathToJson() {
    List<Map<String, double>> path = trackingPath
        .map((latLng) => {'latitude': latLng.latitude, 'longitude': latLng.longitude})
        .toList();
    return jsonEncode(path);
  }
}