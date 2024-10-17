import 'package:nature_connect/model/comment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentService {
  final _userId = Supabase.instance.client.auth.currentUser?.id;
  final _tableName = 'comment';
  final _client = Supabase.instance.client;

  //CREATE
  Future<void> createComment(String postId, String content) async {
    if(content.isEmpty){
      throw 'Comment cannot be empty';
    }

    if (_userId == null) {
      throw 'User not authenticated';
    }

    final comment = {
      'post_id': postId,
      'user_id': _userId,
      'content': content,
    };
    
    try {
      await _client.from(_tableName).insert(comment);
    } catch (e) {
      rethrow;
    }
  }

  //READ LIST
  Future<List<Comment>> getCommentsByPostId(String postId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: false);
      return response.map((e) => Comment.fromMap(e)).toList();
    } catch (e) {
      throw 'Failed to fetch comments: $e';
    }
  }

  //STREAM
  Stream<List<Comment>> streamCommentsByPostId(String postId) {
    return _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => Comment.fromMap(e)).toList());
  }
}
