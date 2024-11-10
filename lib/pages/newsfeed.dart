import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nature_connect/custom_widgets/post_widget.dart';
import 'package:nature_connect/model/post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

final supabase = Supabase.instance.client;

class NewsfeedPage extends StatefulWidget {
  const NewsfeedPage({super.key});

  @override
  State<NewsfeedPage> createState() => _NewsfeedPageState();
}

class _NewsfeedPageState extends State<NewsfeedPage> {
  final _stream = supabase.from('post').stream(primaryKey: ['id']).order('created_at', ascending: false);
  String? _username; // To store the authenticated user's username
  String? _avatarUrl; // To store the authenticated user's avatar URL

  @override
  void initState() {
    if (mounted) {
      fetchUserProfile();
    }

    super.initState();
  }

  // Fetch authenticated user's profile data
  Future<void> fetchUserProfile() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      final response = await supabase
          .from('profiles')
          .select('username,avatar_url')
          .eq('id', currentUser.id)
          .single();
      if (mounted) {
        setState(() {
          _username = response['username'] as String?;
          _avatarUrl = response['avatar_url'] as String?;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // "What's on your mind" section
          GestureDetector(
            onTap: () {
              context.go('/makepost');
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  _avatarUrl != null
                      ? CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(_avatarUrl!),
                        )
                      : const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person),
                        ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _username != null
                          ? "What's on your mind, $_username?"
                          : "What's on your mind?",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          // List of posts from the stream
          Expanded(
            child: StreamBuilder(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('An error occurred while loading posts'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final posts = snapshot.data as List;
                return ListView.separated(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostWidget(
                      key: ValueKey(post['id']),
                      post: Post.fromMap(post),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 25),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
