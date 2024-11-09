

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nature_connect/custom_widgets/marketplace_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
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
            childAspectRatio: 0.80, // Adjust the item size in the grid
            children:
                items.map((item) => MarketplaceWidget(item: item)).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/makeitem');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
