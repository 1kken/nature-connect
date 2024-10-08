import 'package:flutter/material.dart';
import 'package:nature_connect/custom_widgets/post_widget.dart';
import 'package:nature_connect/model/post.dart';
import 'package:nature_connect/model/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    // Clear search text
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context); // Refresh suggestions
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Back button
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search delegate
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isNotEmpty) {
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Profiles'),
                Tab(text: 'Posts'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Profile Tab
                  FutureBuilder<List<Profile>>(
                    future: searchProfiles(query),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.data == null ||
                          snapshot.data!.isEmpty) {
                        return const Center(child: Text('No profiles found.'));
                      }

                      final profiles = snapshot.data!;
                      return ListView.builder(
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          final profile = profiles[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: profile.avatarUrl != null
                                  ? NetworkImage(profile.avatarUrl!)
                                  : null,
                            ),
                            title: Text(profile.username),
                          );
                        },
                      );
                    },
                  ),
                  // Post Tab
                  FutureBuilder<List<Post>>(
                    future: searchPosts(query),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.data == null ||
                          snapshot.data!.isEmpty) {
                        return const Center(child: Text('No posts found.'));
                      }

                      final posts = snapshot.data!;
                      return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return PostWidget(post: post);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return const Center(child: Text('Please enter a search query.'));
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text('Start typing to search.'));
  }

  // Method to search for profiles from Supabase
  Future<List<Profile>> searchProfiles(String query) async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .ilike('username', '%$query%'); // Search for profiles by username

    return (response as List)
        .map((profile) => Profile.fromMap(profile))
        .toList();
  }

  // Method to search for posts from Supabase
  Future<List<Post>> searchPosts(String query) async {
    final response = await Supabase.instance.client
        .from('post')
        .select('*, profiles(username, avatar_url)')
        .or('caption.ilike.$query');

    return (response as List).map((post) => Post.fromMap(post)).toList();
  }
}
