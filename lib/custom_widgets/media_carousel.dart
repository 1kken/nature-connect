// media_carousel.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:mime/mime.dart';

class MediaCarousel extends StatefulWidget {
  final List<String> mediaPaths; // Can be URLs or local file paths

  const MediaCarousel({super.key, required this.mediaPaths});

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  final List<Widget> _mediaWidgets = [];
  final List<VideoPlayerController> _videoControllers = [];
  final List<ChewieController> _chewieControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

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

  void _initializeMedia() {
    for (String path in widget.mediaPaths) {
      final mimeType = lookupMimeType(path);
      if (mimeType != null) {
        if (mimeType.startsWith('image/')) {
          // Handle image
          _mediaWidgets.add(
            Container(
              color: Colors.black,
              child: Image.network(
                'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcS4_ghViGL1Pk1zvJjIfrW-1_W2WK1b_X11dDBNFVcf88i-Blqb',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Error loading image'));
                },
              ),
            ),
          );
        } else if (mimeType.startsWith('video/')) {
          debugPrint(_mediaWidgets.length.toString());
          // Handle video
          final videoController = VideoPlayerController.networkUrl(Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'));
          final chewieController = ChewieController(
            videoPlayerController: videoController,
            // aspectRatio: 16 / 9,
            autoPlay: false,
            looping: false,
            errorBuilder: (context, errorMessage) {
              return const Center(child: Text('Error loading video'));
            },
          );

          _videoControllers.add(videoController);
          _chewieControllers.add(chewieController);

          _mediaWidgets.add(
            Container(
              color: Colors.black,
              child: Chewie(controller: chewieController),
            ),
          );
        } else {
          // Unsupported media type
          _mediaWidgets.add(
            const Center(child: Text('Unsupported media type')),
          );
        }
      } else {
        // Could not determine MIME type
        _mediaWidgets.add(
          const Center(child: Text('Unknown media type')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mediaWidgets.isEmpty) {
      return const Center(child: Text('No media available'));
    }
    return CarouselSlider(items: 
    ['https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcS4_ghViGL1Pk1zvJjIfrW-1_W2WK1b_X11dDBNFVcf88i-Blqb.jpg',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'].map((i){
        if(lookupMimeType(i)!.startsWith('image/')){
          return Container(
              color: Colors.black,
              child: Image.network(
                'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcS4_ghViGL1Pk1zvJjIfrW-1_W2WK1b_X11dDBNFVcf88i-Blqb',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Error loading image'));
                },
              ),
            );
        }
          final videoController = VideoPlayerController.networkUrl(Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'));
          final chewieController = ChewieController(
            videoPlayerController: videoController,
            aspectRatio: 16 / 9,
            autoPlay: true,
            looping: true,
            errorBuilder: (context, errorMessage) {
              return const Center(child: Text('Error loading video'));
            },
          );
        return Chewie(controller: chewieController);
    }).toList(), options: CarouselOptions(height: 400,
      enlargeCenterPage: true,

    ));
    // return CarouselSlider(
    //   items: _mediaWidgets,
    //   options: CarouselOptions(
    //     height: 400.0,
    //     enlargeCenterPage: true,
    //     enableInfiniteScroll: false,
    //     autoPlay: false,
    //     aspectRatio: 16 / 9,
    //   ),
    // );
  }
}



