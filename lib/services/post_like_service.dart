import 'package:supabase_flutter/supabase_flutter.dart';

class PostLikeService {
  final _supabase = Supabase.instance.client;

  // Method to like a post
  Future<void> likePost(String postId, String? userId) async {
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    // Check if the user already liked the post
    final existingLike = await _supabase
        .from('post_like')
        .select()
        .eq('post_id', postId);
    if (existingLike.isNotEmpty){
      await unlikePost(postId, userId);
      return;
    }

    //like the insert to post_like table
    await _supabase.from('post_like').insert({
      'post_id': postId,
      'user_id': userId,
    });

    //increment like_count from post table using rpc call
    await _supabase.rpc('increment_like_count', params: {'post_id': postId});
  }

  // Method to unlike a post
  Future<void> unlikePost(String postId, String userId) async {
    // Check if the user already liked the post
    final existingLike = await _supabase
        .from('post_like')
        .select()
        .eq('post_id', postId)
        .single();
    if (existingLike.isEmpty) return;

    //unlike the delete from post_like table
    await _supabase.from('post_like').delete().eq('id', existingLike['id']);

    //decrement like_count from post table using rpc call
    await _supabase.rpc('decrement_like_count', params: {'post_id': postId});
  }

  //if already like return true
  Future<bool> isPostLiked(String postId, String? userId) async {
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    final existingLike = await _supabase
        .from('post_like')
        .select()
        .eq('post_id', postId);
    return existingLike.isNotEmpty;
  }
}
