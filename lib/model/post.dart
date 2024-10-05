/*
  POST MODEL

  This is what every post shouldve
 */

class Post {
  final String id;
  final String userId;
  final String caption;
  final int likeCount;
  final DateTime createdAt;
  final bool withMediaContent;

  Post(
      {required this.id,
      required this.userId,
      required this.caption,
      required this.likeCount,
      required this.createdAt,
      required this.withMediaContent});

  // Convert a Supabase Record to a post object
  factory Post.fromMap(Map<String, dynamic> data) {
    return Post(
      id: data['id'].toString(),
      userId: data['user_id'],
      caption: data['caption'],
      likeCount: data['like_count'],
      createdAt: DateTime.parse(data['created_at']),
      withMediaContent: data['with_media_content'],
    );
  }

  // Convert a Post object to Supabase Record
    Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'caption': caption,
      'like_count': likeCount,
      'created_at': createdAt.toIso8601String(),
      'with_media_content': withMediaContent,
    };
  }
  
}
