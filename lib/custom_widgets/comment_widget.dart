import 'package:flutter/material.dart';
import 'package:nature_connect/model/comment.dart';
import 'package:nature_connect/model/profile.dart';
import 'package:nature_connect/services/profile_services.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  const CommentWidget({required this.comment, super.key});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  Profile? _user;
  bool _isExpanded = false; // Toggle state for "See More"

  @override
  void initState() {
    super.initState();
    // Fetch the user profile when the widget is initialized
    fetchUser(widget.comment.userId);
  }

  // Fetch user profile by ID
  Future<void> fetchUser(String userId) async {
    try {
      final userFetched = await ProfileServices().fetchProfileById(userId);
      setState(() {
        _user = userFetched;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Preprocess date function (unchanged)
  String preprocessDate(DateTime date) {
    final String formattedDate = '${date.day}-${date.month}-${date.year}';
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    // Check if the comment exceeds 400 characters
    bool isLongComment = widget.comment.content.length > 400;
    String displayedContent = _isExpanded
        ? widget.comment.content // Full comment when expanded
        : widget.comment.content.length > 400
            ? "${widget.comment.content.substring(0, 400)}..." // First 400 characters when collapsed
            : widget.comment.content; // If less than 400 characters, show full comment

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar (or fallback to person icon if no avatar URL)
          _user != null && _user!.avatarUrl!.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(_user!.avatarUrl!),
                  radius: 20, // Avatar size
                )
              : const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person), // Fallback icon
                ),
          const SizedBox(width: 10), // Space between avatar and comment content
          // Comment content and user details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and creation date row
                Row(
                  children: [
                    // Username (use "Unknown" if not loaded)
                    Text(
                      _user != null ? _user!.username : 'Unknown User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Creation date of the comment
                    Text(
                      preprocessDate(widget.comment.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Display the comment content
                Text(
                  displayedContent,
                  style: const TextStyle(fontSize: 14),
                ),
                // "See More" or "See Less" toggle button if comment exceeds 400 characters
                if (isLongComment)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded; // Toggle between full and truncated comment
                      });
                    },
                    child: Text(
                      _isExpanded ? 'See Less' : 'See More',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
