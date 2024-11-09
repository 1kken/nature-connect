import 'package:flutter/material.dart';
import 'package:nature_connect/custom_widgets/media_carousel_path.dart';
import 'package:nature_connect/model/draft.dart';
import 'package:nature_connect/model/draft_media.dart';
import 'package:nature_connect/providers/draft_media_provider.dart';

class DraftWidget extends StatefulWidget {
  final Draft draft;
  const DraftWidget({required this.draft, super.key});

  @override
  State<DraftWidget> createState() => _DraftWidgetState();
}

class _DraftWidgetState extends State<DraftWidget> {
  bool _isCaptionExpanded = false; // State for "See More" functionality
  List<String> mediaPaths = [];

  // Format the draft creation date
  String preprocessDate(DateTime date) {
    final String formattedDate = '${date.day}-${date.month}-${date.year}';
    return formattedDate;
  }

  @override
  void initState() {
    _loadMediaPaths();
    super.initState();
  }
  Future<void> _loadMediaPaths() async {
    List<DraftMedia> draftMedias = await DraftMediaProvider().getDraftMedia(widget.draft.draftId!);
    setState(() {
      mediaPaths = draftMedias.map((e) => e.path).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    // Check if the caption exceeds 150 characters
    bool isLongCaption = widget.draft.caption.length > 150;
    String displayedCaption = _isCaptionExpanded
        ? widget.draft.caption // Full caption when expanded
        : widget.draft.caption.length > 150
            ? "${widget.draft.caption.substring(0, 150)}..." // Truncated caption with "..."
            : widget.draft.caption; // Full caption if it's short enough

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: const BorderSide(
          color: Colors.transparent,
          width: 2.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
