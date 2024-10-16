import 'package:mime/mime.dart';
import 'package:nature_connect/model/post.dart';
import 'package:nature_connect/services/media_content_service.dart';
import 'package:nature_connect/services/media_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_compress/video_compress.dart';

class PostService {
  final _user = Supabase.instance.client.auth.currentUser;
  final _client = Supabase.instance.client;

  //helper function to compress video
  Future<String?> compressVideo(String videoPath) async {
    final info = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.LowQuality,
      deleteOrigin: false,
    );
    return info?.path;
  }

  //CREATE WITH MEDIA
  Future<void> createPostWithMedia(
      String caption, List<String> mediaPaths) async {
    final userId = _user?.id;
    if (userId == null) {
      return;
    }
    
    //Create post
    final postId = await _createPost(caption,mediaPaths.isNotEmpty);
    const  storagePath = 'post_media';

    //loop through the media paths
    for (var mediaPath in mediaPaths) {
      //check for mime type
      final mimeType = lookupMimeType(mediaPath);
      final index = mediaPaths.indexOf(mediaPath);

      if (mimeType == null) {
        continue;
      }
      //if image
      if (mimeType.startsWith('image/')) {

        //upload image
        final mediaStorageUrl = await MediaService.uploadMedia(mediaPath, postId, mimeType,storagePath);

        //insert media content
        await MediaContentService().insertMediaContent(postId, userId, mediaStorageUrl, index,mimeType);

      }
      if(mimeType.startsWith('video/')){
        //compress video
        final compressedPath = await compressVideo(mediaPath);

        //if theres an error
        if(compressedPath == null){
         throw Exception('Failed to compress video');
        }
        final mediaStorageUrl = await MediaService.uploadMedia(compressedPath, postId, mimeType,storagePath);

        await MediaContentService().insertMediaContent(postId, userId, mediaStorageUrl, index,mimeType);
      }
    }
  }

  //CREATE
  Future<String> _createPost(String caption,bool withMediaContent) async {
    final userId = _user?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    try {
      final post = await _client
          .from('post')
          .insert({'user_id': userId, 'caption': caption,'with_media_content':withMediaContent})
          .select()
          .single();
      return post['id'].toString();
    } catch (error) {
      throw Exception('Failed to create post: $error');
    }
  }

  //READ
  Future<List<Post>> getPosts() async {
    final response = await _client.from('post').select();

    final posts = response as List;
    return posts.map((e) => Post.fromMap(e)).toList();
  }

  //READ BY ID
  Future<Post> getPostById(String postId) async {
    try {
      final response = await _client.from('post').select().eq('id', postId).single();
      return Post.fromMap(response);
    } catch (error) {
      throw Exception('Failed to get post: $error');
    }
  }

  //READ BY USER
  Future<List<Post>> getPostsByUser(String userId) async {
    final response = await _client.from('post').select().eq('user_id', userId);

    final posts = response as List;
    return posts.map((e) => Post.fromMap(e)).toList();
  }

  //UPDATE
  Future<void> updatePost(String postId, String caption) async {
    final userId = _user?.id;
    if (userId == null) {
      return;
    }

    await _client
        .from('post')
        .update({'caption': caption})
        .eq('id', postId)
        .eq('user_id', userId);
  }

  //DELETE
  Future<void> deletePost(String postId) async {
    final userId = _user?.id;
    if (userId == null) {
      return;
    }

    await _client.from('post').delete().eq('id', postId).eq('user_id', userId);
  }
}
