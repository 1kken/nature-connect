import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NatureLandmarksService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Marker>> fetchLandmarks() async {
    final response = await _supabase.from('nature_landmarks').select('*');

    if (response.isEmpty) {
      print('Error fetching landmarks: ${response}');
      return [];
    }

    List<Marker> markers = [];
    for (var landmark in response as List<dynamic>) {
      String name = landmark['name'];
      LatLng position = LatLng(
        landmark['lat'] as double,
        landmark['long'] as double,
      );
      String type = landmark['landmark'] as String;
      int id = landmark['id'] as int;

      // Choose marker icon based on landmark type
      String markerIconPath;
      switch (type) {
        case 'Camp':
          markerIconPath = 'assets/images/camp.png';
          break;
        case 'Restaurant':
          markerIconPath = 'assets/images/restaurant.png';
          break;
        case 'Attraction':
          markerIconPath = 'assets/images/attraction.png';
          break;
        default:
          markerIconPath = 'assets/images/camp.png';
          break;
      }

      markers.add(
        Marker(
          width: 50.0,
          height: 50.0,
          point: position,
          child: GestureDetector(
            onTap: () {
              print('Landmark ID: $id');
              // Additional action on tap, like showing a dialog with details
            },
            child: Image.asset(markerIconPath),
          ),
        ),
      );
    }

    return markers;
  }
}
