import 'package:flutter/material.dart';
import 'package:nature_connect/services/map_service.dart';


class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MapService(),
      ),
    );
  }
}