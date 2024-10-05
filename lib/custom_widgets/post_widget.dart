import 'package:flutter/material.dart';
import 'package:nature_connect/custom_widgets/media_carousel_network.dart';
import 'package:nature_connect/model/post.dart';
import 'package:nature_connect/model/profile.dart';
import 'package:nature_connect/services/profile_services.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  const PostWidget({required this.post, super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  Profile? profile;

  // Fetch the user who created the post using post.user_id
  Future<void> fetchProfile(String userId) async {
    try {
      //use service for fetching profile
      final fetchedProfile = await ProfileServices().fetchProfile();
      setState(() {
        profile = fetchedProfile;
      });
    } catch (e) {
      //snack bar
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
    final String formattedDate =
        '${date.day}-${date.month}-${date.year}';
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
    fetchProfile(widget.post.userId);
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
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
               
              subtitle: Text(preprocessDate(widget.post.createdAt)), // Assuming post has createdAt
            ),
            const SizedBox(height: 10),
            Text(widget.post.caption), // Post content (e.g., caption)
            const SizedBox(height: 10),
            MediaCarouselNetwork(postId: widget.post.id),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.favorite),
                  label:  Text(widget.post.likeCount.toString()),
                  onPressed: () {
                    // Implement like functionality
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.comment),
                  label: const Text('Comment'),
                  onPressed: () {
                    // Implement comment functionality
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
