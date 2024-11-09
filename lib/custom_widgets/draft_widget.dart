import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:nature_connect/custom_widgets/media_carousel_path.dart';
import 'package:nature_connect/model/draft.dart';
import 'package:nature_connect/model/draft_media.dart';
import 'package:nature_connect/providers/draft_media_provider.dart';
import 'package:nature_connect/services/post_service.dart';

class DraftWidget extends StatefulWidget {
  final Draft draft;
  final VoidCallback onDelete;
  const DraftWidget({required this.draft, super.key, required this.onDelete});

  @override
  State<DraftWidget> createState() => _DraftWidgetState();
}

class _DraftWidgetState extends State<DraftWidget> {
  bool _isCaptionExpanded = false; // State for "See More" functionality
  List<String> mediaPaths = [];
  bool _hasConnection = false; // Tracks the internet connection status
  StreamSubscription<InternetStatus>? _internetSubscription;
  @override
  void initState() {
    super.initState();

    // Load media paths
    _loadMediaPaths();

    // Listen for internet status changes and update accordingly
    _internetSubscription =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          if (mounted) {
            setState(() {
              _updateConnectionStatus(status);
            });
          }
          break;
        case InternetStatus.disconnected:
          if (mounted) {
            setState(() {
              _hasConnection = false;
            });
          }
        default:
          if (mounted) {
            setState(() {
              _hasConnection = false;
            });
          }
          break;
      }
    });
  }

  @override
  void dispose() {
    _internetSubscription?.cancel();
    super.dispose();
  }

  Future<void> _updateConnectionStatus(InternetStatus status) async {
    bool hasInternet = await checkInternet();
    if (mounted) {
      setState(() {
        _hasConnection = status == InternetStatus.connected && hasInternet;
      });
    }
  }

  Future<bool> checkInternet() async {
    return await InternetConnection().hasInternetAccess;
  }

  Future<void> _loadMediaPaths() async {
    List<DraftMedia> draftMedias =
        await DraftMediaProvider().getDraftMedia(widget.draft.draftId!);
    setState(() {
      mediaPaths = draftMedias.map((e) => e.path).toList();
    });
  }

  Future<void> _uploadDraft() async {
    await PostService().createPostWithMedia(widget.draft.caption, mediaPaths);
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    bool isLongCaption = widget.draft.caption.length > 150;
    String displayedCaption = _isCaptionExpanded
        ? widget.draft.caption
        : widget.draft.caption.length > 150
            ? "${widget.draft.caption.substring(0, 150)}..." 
            : widget.draft.caption;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: const BorderSide(
          color: Colors.black54,
          width: 2.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    widget.onDelete();
                  } else if (value == 'upload') {
                    _uploadDraft();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  _hasConnection
                      ? const PopupMenuItem<String>(
                          value: 'upload',
                          child: Row(
                            children: [
                              Icon(Icons.upload, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Upload'),
                            ],
                          ),
                        )
                      : const PopupMenuItem<String>(
                          value: 'upload',
                          enabled: false,
                          child: Row(
                            children: [
                              Icon(Icons.upload, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Upload'),
                            ],
                          ),
                        ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Caption with "See More" toggle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayedCaption,
                  style: const TextStyle(fontSize: 14),
                ),
                if (isLongCaption) // Show "See More" or "See Less" if caption is too long
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCaptionExpanded = !_isCaptionExpanded;
                      });
                    },
                    child: Text(
                      _isCaptionExpanded ? 'See Less' : 'See More',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // // Media carousel or content if draft has media
            if (widget.draft.withMedia)
              MediaCarousel(
                mediaPaths: mediaPaths,
              ),
          ],
        ),
      ),
    );
  }
}
