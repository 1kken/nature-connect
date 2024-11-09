import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:mime/mime.dart';
import 'dart:io';

class MediaCarousel extends StatefulWidget {
  final List<String> mediaPaths; // Can be URLs or local file paths

  const MediaCarousel({super.key, required this.mediaPaths});

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  final List<VideoPlayerController> _videoControllers = [];
  final List<ChewieController> _chewieControllers = [];

  @override
  void dispose() {
    // Dispose of the video controllers
    for (var controller in _chewieControllers) {
      controller.dispose();
    }
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildMediaWidget(String path) {
    final mimeType = lookupMimeType(path);
    if (mimeType != null) {
      //Check if the file is an image or not
      if (mimeType.startsWith('image/')) {
        //make image widget
        return ClipRRect(
          borderRadius:
              BorderRadius.circular(20), // Set the rounded corners radius
          child: Image.file(
            File(path),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Text('Error loading image'));
            },
          ),
        );
        //Check if the file is video or not
      } else if (mimeType.startsWith('video/')) {
        final videoController = VideoPlayerController.file(File(path));
        //make the Chewie Controller
        final chewieController = ChewieController(
          videoPlayerController: videoController,
          autoPlay: false,
          looping: false,
          errorBuilder: (context, errorMessage) {
            return const Center(child: Text('Error loading video'));
          },
        );

        //add to the list on carousell
        _videoControllers.add(videoController);
        _chewieControllers.add(chewieController);

        //make chewie or video Widget
        return Container(
          color: Colors.black,
          child: Chewie(controller: chewieController),
        );
      } else {
        return const Center(child: Text('Unsupported media type'));
      }
    } else {
      return const Center(child: Text('Unknown media type'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaPaths.isEmpty) {
      return const Center(child: Text('No media available'));
    }

    // Dynamically build the media widgets based on the mediaPaths
    final List<Widget> mediaWidgets = widget.mediaPaths.map((path) {
      return _buildMediaWidget(path);
    }).toList();

    //Display the carousell
    return CarouselSlider(
      items: mediaWidgets,
      options: CarouselOptions(
        height: 300.0,
        enlargeCenterPage: true,
        enlargeStrategy: CenterPageEnlargeStrategy.zoom,
        enableInfiniteScroll: false,
        autoPlay: false,
        aspectRatio: 16 / 9,
        viewportFraction: 1.0,
      ),
    );
  }
}
