import 'package:flutter/material.dart';
import 'package:nature_connect/custom_widgets/make_post_widget.dart';
import 'package:nature_connect/custom_widgets/post_widget.dart';
import 'package:nature_connect/model/post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class NewsfeedPage extends StatefulWidget {
  const NewsfeedPage({super.key});
  @override
  State<NewsfeedPage> createState() => _NewsfeedPageState();
}

class _NewsfeedPageState extends State<NewsfeedPage> {
  final _stream = supabase.from('post').stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream: _stream, builder: (context,snapshot){
        if(snapshot.hasError){
          return const Center(child: Text('An error occurred while loading posts'));
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }
        final posts = snapshot.data as List;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context,index){
            final post = posts[index];
            return PostWidget(post: Post.fromMap(post),);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(onPressed: () {
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
    )
    );
  }
}
