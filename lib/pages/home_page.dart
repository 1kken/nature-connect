import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nature_connect/custom_search_delegate.dart';
import 'package:nature_connect/pages/location.dart';
import 'package:nature_connect/pages/marketplace.dart';
import 'package:nature_connect/pages/newsfeed.dart';
import 'package:nature_connect/pages/weather.dart';

// Import your page widgets

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Index of the currently selected tab.
  int _selectedIndex = 0;

  // List of widgets representing different pages for each tab.
  static const List<Widget> _pages = <Widget>[
    NewsfeedPage(),
    MarketplacePage(),
    LocationPage(),
    WeatherPage(),
  ];

  // Called when a new tab is tapped.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NatureConnect',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ), // AppBar title
        actions: [
          //search bar
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate());
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              context.go('/profile'); // Adjust as needed
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: 'NewsFeed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'MarketPlace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Location',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny),
            label: 'Weather',
          ),
        ],
        currentIndex: _selectedIndex, // Current tab
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        selectedItemColor:
            Theme.of(context).primaryColor, // Color of the selected tab
        onTap: _onItemTapped, // Handle tab selection
      ),
    );
  }
}
