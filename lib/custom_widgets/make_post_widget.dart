// widgets/make_post_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nature_connect/custom_widgets/media_picker.dart';
import 'package:nature_connect/custom_widgets/media_carousel.dart';

class MakePostWidget extends StatefulWidget {
  const MakePostWidget({super.key});

  @override
  State<MakePostWidget> createState() => _MakePostWidgetState();
}

class _MakePostWidgetState extends State<MakePostWidget> {
  final TextEditingController _captionController = TextEditingController();
  List<File> _mediaFiles = []; // Store the selected images or videos


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
                ? const Text('No media selected')
                : Container(
                    height: 250, // Adjust height as needed
                    child: MediaCarousel(mediaPaths: mediaPaths),
                  ),
            const SizedBox(height: 10),
            MediaPicker(addMediaFile: addMediaFile),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  String caption = _captionController.text;
                  if (_mediaFiles.isNotEmpty) {
                    print('Caption: $caption');
                    print('Media files: ${_mediaFiles.map((file) => file.path)}');
                    // Proceed with uploading the caption and media files
                  } else {
                    print('No media selected');
                  }
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
