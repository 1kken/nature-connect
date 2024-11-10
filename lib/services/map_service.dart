// main_map_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:nature_connect/custom_search_delegate.dart';
import 'package:nature_connect/services/get_location.dart';
import 'package:nature_connect/services/marker_manager.dart';
import 'package:nature_connect/services/tracking_manager.dart';
import 'package:nature_connect/services/search_location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nature_connect/services/nature_landmarks.dart';

class MapService extends StatefulWidget {
  @override
  _MapServiceState createState() => _MapServiceState();
}

class _MapServiceState extends State<MapService> {
  final LocationService _locationService = LocationService();
  final MarkerManager _markerManager = MarkerManager();
  final TrackingManager _trackingManager = TrackingManager();
  final SearchLocation _searchLocation = SearchLocation();
  final TextEditingController _searchController = TextEditingController();

  final NatureLandmarksService _natureLandmarksService =
      NatureLandmarksService();
  List<Marker> _landmarkMarkers = [];

  late MapController _mapController;
  LatLng? _currentLatLng;
  LatLng _currentCenter = LatLng(51.509364, -0.128928);
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initLocation();
    _loadLandmarks();
    _subscribeToLocationUpdates();
  }

  Future<void> _initLocation() async {
    Position? position = await _locationService.getCurrentLocation();
    if (position != null && mounted) {
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _currentCenter = _currentLatLng!;
      });
      if (_isMapReady) {
        _mapController.move(_currentLatLng!, 15.0);
      }
    }
  }

  Future<void> _loadLandmarks() async {
    List<Marker> markers = await _natureLandmarksService.fetchLandmarks(context);
    setState(() {
      _landmarkMarkers = markers;
    });
  }

  void _subscribeToLocationUpdates() {
    _positionStreamSubscription = _locationService
        .getLocationStream(
            accuracy: LocationAccuracy.high,
            interval: const Duration(seconds: 15))
        .listen((position) {
      if (mounted) {
        setState(() {
          _currentLatLng = LatLng(position.latitude, position.longitude);
          _trackingManager.addToTrackingPath(_currentLatLng!);
          _checkIfDestinationReached();
        });
      }
    });
  }

  void _addMarkerAtCenter() {
    setState(() {
      if (_markerManager.markerAdded) {
        _trackingManager.stopTracking();
      }
      _markerManager.toggleMarkerAdded();
    });
  }

  void _startNavigationToMarker() {
    if (_markerManager.markerAdded && _currentLatLng != null) {
      setState(() {
        _trackingManager.startTracking(_currentLatLng!);
        _markerManager.lockMarkerPosition(_currentCenter);
      });
    }
  }

  void _checkIfDestinationReached() async {
    if (_markerManager.lockedMarkerPosition != null && _currentLatLng != null) {
      final double distance = Geolocator.distanceBetween(
        _currentLatLng!.latitude,
        _currentLatLng!.longitude,
        _markerManager.lockedMarkerPosition!.latitude,
        _markerManager.lockedMarkerPosition!.longitude,
      );
      if (distance < 10) {
        // Assuming 10 meters is considered reaching the destination
        _trackingManager.stopTracking();
        String routeJson = _trackingManager.convertTrackingPathToJson();
        await _saveRouteToSupabase(routeJson);
      }
    }
  }

  Future<void> _saveRouteToSupabase(String routeJson) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      final response = await supabase.from('map_router').insert({
        'uid': user.id,
        'route': routeJson,
      });

      if (response.error != null) {
        print('Error saving route: ${response.error!.message}');
      } else {
        print('Route saved successfully');
      }
    }
  }

  Future<void> locateAddress(String address) async {
    var result = await _searchLocation.searchLocation(address);
    if (result != null) {
      print("Location found: $result");
      LatLng searchLatLng =
          LatLng(double.parse(result['lat']), double.parse(result['lon']));
      _mapController.move(searchLatLng, 12.0);
      // Additional actions such as updating a map widget
    } else {
      print("Location not found.");
    }
  }

  void scanSubscription(BuildContext context) {
    context.go('/home/scan');
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _currentLatLng == null
                    ? Center(child: CircularProgressIndicator())
                    : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentCenter,
                          initialZoom: 12.0,
                          onMapReady: () {
                            setState(() {
                              _isMapReady = true;
                            });
                            if (_currentLatLng != null) {
                              _mapController.move(_currentLatLng!, 12.0);
                            }
                          },
                          onPositionChanged: (position, hasGesture) {
                            if (hasGesture) {
                              setState(() {
                                _currentCenter = position.center;
                              });
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.natureconnect.app',
                          ),
                          MarkerLayer(
                            markers: [
                              ..._markerManager.getMarkers(
                                  _currentLatLng, _currentCenter),
                              ..._landmarkMarkers,
                            ],
                          ),
                          if (_trackingManager.trackingPath.isNotEmpty)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: _trackingManager.trackingPath,
                                  color: Colors.blue,
                                  strokeWidth: 4.0,
                                ),
                              ],
                            ),
                          RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                'OpenStreetMap contributors',
                                onTap: () => launchUrl(Uri.parse(
                                    'https://openstreetmap.org/copyright')),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              if (_markerManager.markerAdded)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: _trackingManager.startNavigation
                        ? null
                        : _startNavigationToMarker,
                    child: Text(_trackingManager.startNavigation
                        ? 'Walking...'
                        : 'Start'),
                  ),
                ),
            ],
          ),
          // Search bar positioned at the top
          Positioned(
            top: 10, // Adjust this as needed for padding
            left: 20,
            right: 20,
            child: buildSearchBar(),
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () {
                scanSubscription(context);
              },
              backgroundColor: Colors.green,
              child: Image.asset(
                'assets/images/scan.png',
                width: 50.0,
                height: 50.0,
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: null,
              onPressed: _addMarkerAtCenter,
              backgroundColor: Colors.green,
              child: Icon(_markerManager.markerAdded
                  ? Icons.clear
                  : Icons.add_location_alt),
            ),
          ),
        ],
      ),
    );
  }

  // Search bar widget
  Widget buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search location',
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              String address = _searchController.text;
              if (address.isNotEmpty) {
                locateAddress(address);
              }
            },
          ),
        ),
        onSubmitted: (address) {
          if (address.isNotEmpty) {
            locateAddress(address);
          }
        },
      ),
    );
  }
}
