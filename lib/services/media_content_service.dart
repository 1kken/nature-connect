import 'package:nature_connect/model/media_content.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MediaContentService {
  final _supabase = Supabase.instance.client;
  final _user = Supabase.instance.client.auth.currentUser;

  //CREATE
   Future<void> insertMediaContent(String postId,String userId,String storageUrl, int index, String mimeType) async {
    final userId = _user?.id;
    if (userId == null) {
      return;
    }

    final data = {
      'user_id': userId,
      'post_id': postId,
      'index': index,
      'storage_url': storageUrl,
      'mime_type': mimeType,
    };

    await _supabase.from('media_content').insert(data);
  }

  //READ
  Future<List<MediaContent>> getMediaContent(String postId) async {
    List<MediaContent> mediaContent = [];
    final response = await _supabase.from('media_content').select().eq('post_id', postId);
    for (var record in response) {
      mediaContent.add(MediaContent.fromMap(record));
    }
    return mediaContent;
  }
}