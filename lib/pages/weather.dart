import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  bool _hasInternet = false; // Tracks the internet connection status
  late StreamSubscription<InternetStatus> listener;

  @override
  void initState() {
    super.initState();
    listener =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
        setState(() {
            _hasInternet = true;
        });
          break;
        case InternetStatus.disconnected:
          setState(() {
            _hasInternet = false;
          });
          break;
      }
    });
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Page')),
      body: Center(
        child: _hasInternet
            ? const Text("This is weather") // Display content if connected
            : const Text("No internet connection",
                style: TextStyle(
                    color: Colors.red)), // Show a warning if no internet
      ),
    );
  }

}
