import 'package:flutter/material.dart';
import 'package:nature_connect/model/media_content.dart';
import 'package:nature_connect/services/media_content_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class MediaCarouselNetwork extends StatefulWidget {
  final String postId;
  final bool withMediaContent; // New field to indicate if the post has media

  const MediaCarouselNetwork({
    required this.postId,
    required this.withMediaContent,
    super.key,
  });

  @override
  State<MediaCarouselNetwork> createState() => _MediaCarouselNetworkState();
}

class _MediaCarouselNetworkState extends State<MediaCarouselNetwork> {
  final List<VideoPlayerController> _videoControllers = [];
  final List<ChewieController> _chewieControllers = [];
  late final Stream<List<MediaContent>> _mediaStream;

  @override
  void initState() {
    super.initState();
    _mediaStream = MediaContentService().getMediaContentStream(widget.postId); // Initialize stream
  }

  @override
  void dispose() {
    // Dispose video controllers
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    for (var chewieController in _chewieControllers) {
      chewieController.dispose();
    }
    super.dispose();
  }

  Widget _buildMediaWidget(MediaContent mediaContent) {
    if (mediaContent.mimeType.startsWith('image/')) {
      return Container(
        color: Colors.black,
        child: Image.network(
          mediaContent.storageUrl,
          fit: BoxFit.fitWidth,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Text('Error loading image'));
          },
        ),
      );
    } else if (mediaContent.mimeType.startsWith('video/')) {
      final videoController = VideoPlayerController.networkUrl(Uri.parse(mediaContent.storageUrl));
      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: false,
        looping: false,
        aspectRatio: 16 / 9,
        errorBuilder: (context, errorMessage) {
          return const Center(child: Text('Error loading video'));
        },
      );

      _videoControllers.add(videoController);
      _chewieControllers.add(chewieController);

      return Container(
        color: Colors.black,
        child: Chewie(controller: chewieController),
      );
    } else {
      return const Center(child: Text('Unsupported media type'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // If `withMediaContent` is false, just return blank (no media content expected)
    if (!widget.withMediaContent) {
      return const SizedBox.shrink(); // No media to show, return blank
    }

    // If `withMediaContent` is true, show loading indicator until media is fetched
    return StreamBuilder<List<MediaContent>>(
      stream: _mediaStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading spinner while media is being fetched
          return Container(
            height: 200.0,
            color: Colors.black12,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load media content: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // If no media is available (even though `withMediaContent` is true), return blank
          return const SizedBox.shrink();
        } else {
          // Use the media content data directly in a carousel
          return CarouselSlider(
            items: snapshot.data!.map((mediaContent) {
              return _buildMediaWidget(mediaContent);
            }).toList(),
            options: CarouselOptions(
              height: 200.0,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              autoPlay: false,
              aspectRatio: 16 / 9,
            ),
          );
        }
      },
    );
  }
}
