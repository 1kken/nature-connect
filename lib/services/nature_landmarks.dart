import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nature_connect/pages/rate_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NatureLandmarksService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Marker>> fetchLandmarks(BuildContext context) async {
    final response = await _supabase.from('nature_landmarks').select('*');

    if (response.isEmpty) {
      print('Error fetching landmarks: $response');
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
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                    heightFactor: 0.5,
                    child: RatePage(landMarkId: id),
                  );
                },
              );
            },
            child: Image.asset(markerIconPath),
          ),
        ),
      );
    }

    return markers;
  }
}
