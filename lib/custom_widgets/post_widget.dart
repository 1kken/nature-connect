import 'package:flutter/material.dart';

import 'package:nature_connect/custom_widgets/media_carousel_network.dart';
import 'package:nature_connect/model/post.dart';
import 'package:nature_connect/model/profile.dart';
import 'package:nature_connect/services/post_like_service.dart';
import 'package:nature_connect/services/profile_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  const PostWidget({required this.post, super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isLiked = false;
  bool _isCaptionExpanded = false; // State for "See More"
  final _currentUserId = Supabase.instance.client.auth.currentUser?.id;
  Profile? profile;
  final postLikeService = PostLikeService();

  Future<void> isLikedSetter() async {
    final isLiked =
        await PostLikeService().isPostLiked(widget.post.id, _currentUserId);
    setState(() {
      _isLiked = isLiked;
    });
  }

  // Fetch the user who created the post using post.user_id
  Future<void> fetchProfile(String userId) async {
    try {
      // Use service for fetching profile
      final fetchedProfile =
          await ProfileServices().fetchProfileById(widget.post.userId);
      setState(() {
        profile = fetchedProfile;
      });
    } catch (e) {
      // Snack bar for error
      if (!mounted) return; // Prevents error if widget is disposed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String preprocessDate(DateTime date) {
    final String formattedDate = '${date.day}-${date.month}-${date.year}';
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
    isLikedSetter();
    fetchProfile(widget.post.userId);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the caption exceeds 150 characters
    bool isLongCaption = widget.post.caption.length > 150;
    String displayedCaption = _isCaptionExpanded
        ? widget.post.caption // Full caption when expanded
        : widget.post.caption.length > 150
            ? "${widget.post.caption.substring(0, 150)}..." // Truncated caption with "..."
            : widget.post.caption; // If caption is short, show full caption

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Adjust the border radius as needed
              side: const BorderSide(
                color: Colors.transparent, // Set the border color here
                width: 2.0, // Set the border width here
              ),
            ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: profile?.avatarUrl != null
                    ? NetworkImage(profile!.avatarUrl!)
                    : null,
                child:
                    profile == null ? const CircularProgressIndicator() : null,
              ),
              title: Text(profile?.username ?? 'Loading...'),
              subtitle: Text(
                preprocessDate(widget.post.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ), // Assuming post has createdAt
              onTap: () {
                context.go('/profile/${widget.post.userId}');
              },
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
                        _isCaptionExpanded =
                            !_isCaptionExpanded; // Toggle expanded/collapsed
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
            // Media carousel or content
            MediaCarouselNetwork(
                postId: widget.post.id,
                withMediaContent: widget.post.withMediaContent),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _isLiked
                    ? TextButton.icon(
                        icon: const Icon(Icons.favorite),
                        label: Text(widget.post.likeCount.toString()),
                        onPressed: () {
                          postLikeService.likePost(
                              widget.post.id, _currentUserId);
                          setState(() {
                            _isLiked = false;
                          });
                        },
                      )
                    : TextButton.icon(
                        icon: const Icon(Icons.favorite_border),
                        label: Text(widget.post.likeCount.toString()),
                        onPressed: () {
                          postLikeService.likePost(
                              widget.post.id, _currentUserId);
                          setState(() {
                            _isLiked = true;
                          });
                        },
                      ),
                TextButton.icon(
                  icon: const Icon(Icons.comment),
                  label: const Text('Comment'),
                  onPressed: () {
                    context.go('/comments/${widget.post.id}');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
