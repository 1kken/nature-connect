import 'package:supabase_flutter/supabase_flutter.dart';

class MediaContentService {
  static final _supabase = Supabase.instance.client;
  static final _user = Supabase.instance.client.auth.currentUser;

  //CREATE
  static Future<void> insertMediaContent(String postId,String userId,String storageUrl, int index) async {
    final userId = _user?.id;
    if (userId == null) {
      return;
    }

    final data = {
      'user_id': userId,
      'post_id': postId,
      'index': index,
      'storage_url': storageUrl,
    };

    await _supabase.from('media_content').insert(data);
  }

  //READ
  Future<List<Map<String, dynamic>>> getMediaContent(String postId) async {
    final response = await _supabase.from('media_content').select().eq('post_id', postId);
    return response;
  }
}