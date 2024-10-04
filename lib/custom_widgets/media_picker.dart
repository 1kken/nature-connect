// widgets/media_picker.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MediaPicker extends StatefulWidget {
  final Function(File) addMediaFile;

  const MediaPicker({required this.addMediaFile, super.key});

  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  final ImagePicker _picker = ImagePicker();

  // Function to pick multiple images
  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 25);

    if (pickedFiles.isNotEmpty) {
      for (var pickedFile in pickedFiles) {
        widget.addMediaFile(File(pickedFile.path));
      }
    }
  }

  // Function to pick a video
  Future<void> _pickVideo() async {
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      widget.addMediaFile(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.photo),
          label: const Text('Pick Images'),
        ),
        ElevatedButton.icon(
          onPressed: _pickVideo,
          icon: const Icon(Icons.videocam),
          label: const Text('Pick Video'),
        ),
      ],
    );
  }
}
