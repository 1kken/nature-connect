class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  // Convert a Comment into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // A factory method that creates a Comment from a Map. The keys must correspond to the names of the columns in the database.
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'].toString(),
      postId: map['post_id'].toString(),
      userId: map['user_id'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}