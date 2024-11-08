import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:nature_connect/custom_widgets/no_internet_widget.dart';
import 'package:nature_connect/internet_notifer.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  bool _isLoading = true;
  bool _hasConnection = false; // Tracks the internet connection status
  StreamSubscription<InternetStatus>? _internetSubscription;
   @override
  void initState() {
    super.initState();
    debugPrint("Initializing NewsfeedPage");

    // Initialize the InternetStatusNotifier and subscribe to status changes
    InternetStatusNotifier().initialize();

    // Listen for internet status changes and update accordingly
    _internetSubscription =
        InternetStatusNotifier().onStatusChange.listen((status) {
      if (mounted) {
        _updateConnectionStatus(status);
      }
    });
  }

  Future<void> _updateConnectionStatus(InternetStatus status) async {
    bool hasInternet = await checkInternet();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasConnection = status == InternetStatus.connected && hasInternet;
      });
    }
  }

  Future<bool> checkInternet() async {
    return await InternetConnection().hasInternetAccess;
  }

  @override
  void dispose() {
    _internetSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Page')),
      body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : !_hasConnection
                  ? const NoInternetWidget(
                      showGoToDraftsButton: false,
                    )
                  : const Center(
                      child: Text('Put here dets louie'),
                    )),
    );
  }
}
