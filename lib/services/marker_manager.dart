// marker_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MarkerManager {
  bool markerAdded = false;
  LatLng? lockedMarkerPosition;

  void toggleMarkerAdded() {
    markerAdded = !markerAdded;
    if (!markerAdded) {
      lockedMarkerPosition = null; // Reset locked position if marker is removed
    }
  }

  void lockMarkerPosition(LatLng currentCenter) {
    if (markerAdded) {
      lockedMarkerPosition = currentCenter;
    }
  }

  List<Marker> getMarkers(LatLng? currentLatLng, LatLng? currentCenter) {
    List<Marker> markers = [];
    if (currentLatLng != null) {
      markers.add(
        Marker(
          point: currentLatLng,
          width: 80,
          height: 80,
          child: Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }
    if (markerAdded && lockedMarkerPosition == null && currentCenter != null) {
      markers.add(
        Marker(
          point: currentCenter,
          width: 80,
          height: 80,
          child: Icon(
            Icons.location_pin,
            color: Colors.green,
            size: 40,
          ),
        ),
      );
    }
    if (lockedMarkerPosition != null) {
      markers.add(
        Marker(
          point: lockedMarkerPosition!,
          width: 80,
          height: 80,
          child: Icon(
            Icons.location_pin,
            color: Colors.green,
            size: 40,
          ),
        ),
      );
    }
    return markers;
  }
}