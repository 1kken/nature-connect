import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nature_connect/custom_widgets/comment_widget.dart';
import 'package:nature_connect/model/comment.dart';
import 'package:nature_connect/model/post.dart';
import 'package:nature_connect/services/comment_service.dart';
import 'package:nature_connect/services/post_service.dart';

class CommentSection extends StatefulWidget {
  final String postId;
  const CommentSection({required this.postId, super.key});
  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  bool _loading = false;

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

  //post the comment
  Future<void> postComment(String postId, String content) async {
    try {
      setState(() {
        _loading = true;
      });
      await CommentService().createComment(postId, content);
      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post comment: $e'),
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
            GoRouter.of(context).go('/home');
          },
        ),
      ),
      body: Column(
        children: [
          // Expanded widget to make ListView take remaining space
          Expanded(
            child: StreamBuilder(
              stream: CommentService().streamCommentsByPostId(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('An error occurred ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final comments = snapshot.data as List<Comment>;

                // If no comments, show a message
                if (comments.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }

                // Display the list of comments
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return CommentWidget(comment: comment);
                  },
                );
              },
            ),
          ),
          // Text input for new comments
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Text field for entering comments
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 75, // Limit the height for the TextField
                    ),
                    child: SingleChildScrollView(
                      // Ensure TextFormField is scrollable after hitting the max height
                      scrollDirection: Axis.vertical,
                      reverse:
                          true, // Keeps the cursor at the bottom as it grows
                      child: TextFormField(
                        controller: _commentController,
                        maxLines:
                            null, // Allows the field to have any number of lines
                        maxLength: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Submit button to post the comment
                _loading
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          postComment(widget.postId, _commentController.text);
                          _commentController.clear();
                        }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
