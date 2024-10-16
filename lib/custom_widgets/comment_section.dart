import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nature_connect/model/post.dart';
import 'package:nature_connect/services/post_service.dart';

class CommentSection extends StatefulWidget {
  final String postId;
  const CommentSection({required this.postId, super.key});
  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();

  Post? post;

  //get post by id
  Future<void> fetchPost(String postId) async {
    try {
      final postfetched = await PostService().getPostById(postId);
      setState(() {
        post = postfetched;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch post: $e'),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchPost(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/newsfeed');
          },
        ),
      ),
      body: Column(
        children: [
          // Expanded widget to make ListView take remaining space
          Expanded(
            //add a listview and 3 dummy comments
            child: ListView(
              children: const [
                ListTile(
                  leading: CircleAvatar(
                    child: Text('A'),
                  ),
                  title: Text('Alice'),
                  subtitle: Text('This is a comment'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    child: Text('B'),
                  ),
                  title: Text('Bob'),
                  subtitle: Text('This is another comment'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    child: Text('C'),
                  ),
                  title: Text('Charlie'),
                  subtitle: Text('This is yet another comment'),
                ),
              ],
            ),
          ),
          // Text input for new comments
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Text field for entering comments
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Submit button to post the comment
                IconButton(icon: const Icon(Icons.send), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
