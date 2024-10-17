import 'dart:typed_data';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nature_connect/model/profile.dart';
import 'package:nature_connect/model/post.dart';
import 'package:nature_connect/pages/marketplace.dart';
import 'package:nature_connect/services/profile_services.dart';
import 'package:nature_connect/custom_widgets/post_widget.dart';

class ProfileV extends StatefulWidget {
  final String userId;
  const ProfileV({required this.userId, super.key});

  @override
  State<ProfileV> createState() => _ProfileVState();
}

class _ProfileVState extends State<ProfileV> {
  Profile? _profile; // Store the user's profile data
  late Stream<List<dynamic>> _stream; // For posts stream
  bool _isLoadingProfile = true;
  String? _imageUrl; // User's avatar URL
  Uint8List? imageData; // Image data if available from memory

  // Fetch the profile when the widget is initialized
  Future<void> fetchUserProfile() async {
    try {
      final profile = await ProfileServices().fetchProfileById(widget.userId);
      setState(() {
        _profile = profile;
        _imageUrl = profile.avatarUrl;
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProfile = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch profile: $e')),
      );
    }
  }

  // Fetch the user's posts
  Future<void> setupPostStream() async {
    setState(() {
      _stream = supabase
          .from('post')
          .stream(primaryKey: ['id'])
          .eq('user_id', widget.userId);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile(); // Fetch the profile
    setupPostStream(); // Set up the stream for the user's posts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_profile?.username ?? 'Loading...'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile header with avatar and basic info
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Centers vertically in its parent
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // User's avatar
                        CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.grey[300],
                          child: ClipOval(
                            child: _imageUrl != null && imageData == null
                                ? Image.network(
                                    _imageUrl!,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : imageData != null
                                    ? Image.memory(
                                        imageData!,
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 100,
                                        color: Colors.white,
                                      ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Username
                        Text(
                          _profile?.username ?? 'Unknown User',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Bio or additional info
                        Text(
                          _profile?.bio ?? 'No bio available',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // User's posts in a ListView
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Posts",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  StreamBuilder<List<dynamic>>(
                    stream: _stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Failed to load posts'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No posts available'));
                      }
                      final posts = snapshot.data!;
                      return ListView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable scrolling inside ListView
                        shrinkWrap:
                            true, // Important to let ListView fit inside SingleChildScrollView
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return PostWidget(post: Post.fromMap(post));
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
