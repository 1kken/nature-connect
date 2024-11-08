import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:nature_connect/custom_widgets/marketplace_widget.dart';
import 'package:nature_connect/custom_widgets/no_internet_widget.dart';
import 'package:nature_connect/internet_notifer.dart';
import 'package:nature_connect/services/marketplace_item_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final _stream = MarketplaceItemService().getMarketplaceItemsStream();
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasConnection
              ? const NoInternetWidget(
                  showGoToDraftsButton: false,
                )
              : StreamBuilder(
                  stream: _stream,
                  builder: (context, snapshot) {
                    // Handle error case
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            'An error occurred while loading posts: ${snapshot.error.toString()}'),
                      );
                    }

                    // Show loading spinner while waiting for data
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Safely handle null data
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(child: Text('No items available.'));
                    }

                    final items = snapshot.data as List;

                    // Check if the list is empty
                    if (items.isEmpty) {
                      return const Center(child: Text('No items available.'));
                    }

                    return GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 1,
                      crossAxisSpacing: 1,
                      childAspectRatio:
                          0.80, // Adjust the item size in the grid
                      children: items
                          .map((item) => MarketplaceWidget(item: item))
                          .toList(),
                    );
                  },
                ),
      floatingActionButton: _hasConnection
          ? FloatingActionButton(
              onPressed: () {
                context.go('/makeitem');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
