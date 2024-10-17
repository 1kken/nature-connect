import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nature_connect/custom_widgets/media_carousel_path.dart';
import 'package:nature_connect/custom_widgets/media_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nature_connect/services/marketplace_item_service.dart';

class MakeItemWidget extends StatefulWidget {
  const MakeItemWidget({super.key});

  @override
  State<MakeItemWidget> createState() => _MakeItemWidgetState();
}

class _MakeItemWidgetState extends State<MakeItemWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final List<File> _mediaFiles = []; // Store the selected images
  final MarketplaceItemService _marketplaceItemService = MarketplaceItemService(); // Marketplace Item service
  final _userId = Supabase.instance.client.auth.currentUser?.id; // Get the current user ID
  final int mediaLimit = 5; // Limit for media files

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // Handle adding media files from the picker
  void addMediaFile(File file) {
    if (_mediaFiles.length >= mediaLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only upload up to 5 media files.')),
      );
    } else {
      setState(() {
        _mediaFiles.add(file);
      });
    }
  }

  Future<void> _createItem() async {
    if (_mediaFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select media for the item')),
      );
      return;
    }
    final String title = _titleController.text;
    final String caption = _captionController.text;
    final double price = double.tryParse(_priceController.text) ?? 0.0; // Default to 0.0 if invalid
    final int stock = int.tryParse(_stockController.text) ?? 0; // Default to 0 if invalid

    if (_userId == null) {
      return;
    }

    try {
      // Create item with media
      await _marketplaceItemService.insertMarketplaceItemWithMedia(
        _userId,
        title,
        caption,
        price,
        stock,
        _mediaFiles.map((file) => file.path).toList(),
      );

      if (!mounted) {
        return;
      }

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marketplace Item created successfully!')),
      );
      context.go('/home');
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prepare list of media paths
    List<String> mediaPaths = _mediaFiles.map((file) => file.path).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check), // Icon for posting
            onPressed: _createItem, // Create item when tapped
            tooltip: 'Post',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (mediaPaths.isNotEmpty)
                SizedBox(
                  height: 250, // Adjust height for media carousel
                  child: MediaCarousel(mediaPaths: mediaPaths),
                ),
              if (mediaPaths.isNotEmpty)
                const SizedBox(height: 20),

              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _captionController,
                decoration: const InputDecoration(
                  labelText: 'Caption',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              // Media Picker without a video option
              Center(
                child: MediaPicker(addMediaFile: addMediaFile, withVideo: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
