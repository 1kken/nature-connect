import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:nature_connect/custom_widgets/no_internet_widget.dart';
import 'package:nature_connect/custom_widgets/post_widget.dart';
import 'package:nature_connect/internet_notifer.dart';
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
  final _stream = supabase.from('post').stream(primaryKey: ['id']);
  String? _username; // To store the authenticated user's username
  String? _avatarUrl; // To store the authenticated user's avatar URL
  bool _hasConnection = false; // Tracks the internet connection status
  bool _isLoading = true;
  StreamSubscription<InternetStatus>? _internetSubscription;

  @override
  void initState() {
    super.initState();
    debugPrint("Initializing NewsfeedPage");

    // Initialize the InternetStatusNotifier and subscribe to status changes
    InternetStatusNotifier().initialize();

    // Listen for internet status changes and update accordingly
    _internetSubscription =
        InternetStatusNotifier().onStatusChange.listen((status) {
      if (mounted) {
        _updateConnectionStatus(status);
      }
    });
  }

  Future<void> _updateConnectionStatus(InternetStatus status) async {
    bool hasInternet = await checkInternet();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasConnection = status == InternetStatus.connected && hasInternet;
        if (_hasConnection) {
          fetchUserProfile();
        }
      });
    }
  }

  Future<bool> checkInternet() async {
    return await InternetConnection().hasInternetAccess;
  }

  @override
  void dispose() {
    _internetSubscription?.cancel();
    super.dispose();
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : !_hasConnection
              ? const NoInternetWidget(showGoToDraftsButton: true)
              : Column(
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
                                child: Text(
                                    'An error occurred while loading posts'));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final posts = snapshot.data as List;
                          return ListView.separated(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              return PostWidget(
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
