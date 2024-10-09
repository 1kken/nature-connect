import 'package:flutter/material.dart';
import 'package:nature_connect/custom_widgets/make_item_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final _stream = supabase.from('marketplace_item').stream(primaryKey: ['id']);
  
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
        final items = snapshot.data as List;
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context,index){
            final item = items[index];
            return Text(item['title'].toString());
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
                const MakeItemWidget(), // Custom widget for creating a post
          );
        },
      );
    },
    child: const Icon(Icons.add),
    )
    );
  }
  }

