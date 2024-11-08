

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nature_connect/pages/drafts.dart';
import 'package:nature_connect/pages/settings.dart';
import 'package:nature_connect/pages/timeline.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
  // Index of the currently selected tab.
  int _selectedIndex = 1;
  final List<String> titles = ['Timeline','Settings','Drafts'];
  String _title = "Profile/Settings";

  // List of widgets representing different pages for each tab.
  static const List<Widget> _pages = <Widget>[
    TimelinePage(),
    SettingsPage(),
    DraftsPage(),
  ];

  // Called when a new tab is tapped.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      String selectedTitle = titles[index];
      _title = "Profile/$selectedTitle";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home'); // Navigate back to the home page
          },
        ),
        centerTitle: true, // Center the title
        title: Text(_title), // AppBar title
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Timeline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.drafts),
            label: 'Drafts',
          ),
        ],

        currentIndex: _selectedIndex, // Current tab
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        selectedItemColor: Theme.of(context).primaryColor, // Color of the selected tab
        onTap: _onItemTapped, // Handle tab selection
      ),
    );
  }
}
