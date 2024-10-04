// widgets/make_post_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nature_connect/custom_widgets/media_picker.dart';
import 'package:nature_connect/custom_widgets/media_carousel_path.dart';
import 'package:nature_connect/services/post_service.dart';

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
    } catch (e) {
      if(!mounted) return; // Prevents error if widget is disposed
      
      //Snackbar to show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

  }

  

  @override
  Widget build(BuildContext context) {
    // Prepare list of media paths
    List<String> mediaPaths = _mediaFiles.map((file) => file.path).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView( // Added to prevent overflow
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: Text(
                'Create Post',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
              ),
              maxLines: null, // Allow multiple lines
            ),
            const SizedBox(height: 10),
            mediaPaths.isEmpty
                ? const Center( child: Text('No media selected'))
                : SizedBox(
                    height: 250, // Adjust height as needed
                    child: MediaCarousel(mediaPaths: mediaPaths),
                  ),
            const SizedBox(height: 10),
            MediaPicker(addMediaFile: addMediaFile),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _createPost();
                  Navigator.pop(context); // Close dialog after posting
                },
                child: const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
