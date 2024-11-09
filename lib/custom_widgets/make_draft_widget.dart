import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:nature_connect/custom_widgets/media_picker.dart';
import 'package:nature_connect/custom_widgets/media_carousel_path.dart';
import 'package:nature_connect/model/draft.dart';
import 'package:nature_connect/model/draft_media.dart';
import 'package:nature_connect/providers/draft_media_provider.dart';
import 'package:nature_connect/providers/draft_provider.dart';
import 'package:go_router/go_router.dart';

class MakeDraftWidget extends StatefulWidget {
  const MakeDraftWidget({super.key});

  @override
  State<MakeDraftWidget> createState() => _MakeDraftWidgetState();
}

class _MakeDraftWidgetState extends State<MakeDraftWidget> {
  final TextEditingController _captionController = TextEditingController();
  final List<File> _mediaFiles = []; // Store selected images or videos
  final DraftProvider _draftProvider = DraftProvider();


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

  Future<void> _saveDraft() async {
    // Prepare list of media paths
    List<String> mediaPaths = _mediaFiles.map((file) => file.path).toList();

    debugPrint('Saving draft with caption: ${mediaPaths[0]}');

    try {
      //data to Draft object
      final draft = Draft( 
        caption: _captionController.text,
        withMedia: mediaPaths.isNotEmpty,
      );

      //save draft
      int id = await _draftProvider.addDraft(draft);

      //save media drafts using provider
      for (String path in mediaPaths) {
        //make a dradft media object
        final draftMedia = DraftMedia(
          draftId: id,
          path: path,
          mimeType: lookupMimeType(path)!
        );
        //save using provider
        await DraftMediaProvider().addDraftMedia(draftMedia);
      }
      
      if (mounted) {
        context.go('/profile');
      }
    } catch (e) {
      if (!mounted) return; // Prevent error if widget is disposed

      // Show error using Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save draft: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> mediaPaths = _mediaFiles.map((file) => file.path).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Draft'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/drafts/true');
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Save Draft',
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveDraft();
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
              TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: UnderlineInputBorder(),
                ),
                maxLines: 8,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),
              mediaPaths.isEmpty
                  ? const Center(child: Text('No media selected'))
                  : SizedBox(
                      height: 250,
                      child: MediaCarousel(mediaPaths: mediaPaths),
                    ),
              const SizedBox(height: 20),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [MediaPicker(addMediaFile: addMediaFile)]),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
