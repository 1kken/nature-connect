import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nature_connect/custom_widgets/make_post_widget.dart';
import 'package:nature_connect/custom_widgets/post_widget.dart';
import 'package:nature_connect/model/post.dart';
import 'package:nature_connect/pages/newsfeed.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TimelinePage extends StatefulWidget {
  final String? userId;
  const TimelinePage({this.userId,super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  String? _userId;

  late SupabaseStreamBuilder _stream;

//_stream builder
  Future<void> streamBuilder() async {
    if (_userId == null) {
      if (mounted) {
        context.go('/');
      }
      return;
    }
    setState(() {
      _stream = supabase
          .from('post')
          .stream(primaryKey: ['id']).eq('user_id', _userId!);
    });
  }

  @override
  void initState() {
    _userId = widget.userId ?? supabase.auth.currentUser?.id;
    streamBuilder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
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
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostWidget(
                    key: ValueKey(post['id']),
                    post: Post.fromMap(post),
                  );
                },
              );
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ), // Rounded corners for the dialog
                  child:
                      const MakePostWidget(), // Custom widget for creating a post
                );
              },
            );
          },
          child: const Icon(Icons.add),
        ));
  }
}
