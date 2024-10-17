import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nature_connect/custom_widgets/media_picker.dart';
import 'package:nature_connect/custom_widgets/media_carousel_path.dart';
import 'package:nature_connect/services/post_service.dart';
import 'package:go_router/go_router.dart'; // Required for navigation

class MakePostWidget extends StatefulWidget {
  const MakePostWidget({super.key});

  @override
  State<MakePostWidget> createState() => _MakePostWidgetState();
}

class _MakePostWidgetState extends State<MakePostWidget> {
  final TextEditingController _captionController = TextEditingController();
  final List<File> _mediaFiles = []; // Store the selected images or videos
  final PostService _postService = PostService();

  // Handle adding media files from the picker
  void addMediaFile(File file) {
    setState(() {
      _mediaFiles.add(file);
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    // Prepare list of media paths
    List<String> mediaPaths = _mediaFiles.map((file) => file.path).toList();

    try {
      await _postService.createPostWithMedia(
        _captionController.text,
        mediaPaths,
      );
      // After successful post, navigate back to home
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (!mounted) return; // Prevents error if widget is disposed

      // Show error using Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prepare list of media paths
    List<String> mediaPaths = _mediaFiles.map((file) => file.path).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context
                .go('/home'); // Navigate back to home when the arrow is pressed
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Post',
            icon: const Icon(Icons.post_add),
            onPressed: () {
              _createPost();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Caption text field with maxLines and scrolling support
              TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: UnderlineInputBorder(), // Removes the border
                ),
                maxLines: 8, // Maximum visible lines before scrolling
                keyboardType: TextInputType.multiline, // Multiline input
              ),
              const SizedBox(height: 20),

              // Display selected media if available
              mediaPaths.isEmpty
                  ? const Center(child: Text('No media selected'))
                  : SizedBox(
                      height: 250, // Adjust height for media carousel
                      child: MediaCarousel(mediaPaths: mediaPaths),
                    ),
              const SizedBox(height: 20),

              // Media picker to add more media
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [MediaPicker(addMediaFile: addMediaFile)]),
              const SizedBox(height: 20),
              // Post button at the bottom
            
            ],
          ),
        ),
      ),
    );
  }
}
