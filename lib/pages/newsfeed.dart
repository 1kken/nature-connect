import 'package:flutter/material.dart';
import 'package:nature_connect/custom_widgets/make_post_widget.dart';

class NewsfeedPage extends StatefulWidget {
  const NewsfeedPage({super.key});

  @override
  State<NewsfeedPage> createState() => _NewsfeedPageState();
}

class _NewsfeedPageState extends State<NewsfeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
