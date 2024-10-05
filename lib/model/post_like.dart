class PostLike {
  final int id;
  final int postId;
  final String userId;
  final DateTime createdAt;

  PostLike({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  //fromMap method
  factory PostLike.fromMap(Map<String, dynamic> map) {
    return PostLike(
      id: map['id'],
      postId: map['post_id'],
      userId: map['user_id'].toString(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  //toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}