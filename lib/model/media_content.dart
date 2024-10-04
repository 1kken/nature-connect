class MediaContent {
  final String id;
  final String userId;
  final String postId;
  final int index;
  final String storageUrl;
  final DateTime createdAt;
  final String mimeType;

  MediaContent({required this.id,required this.userId,required this.postId ,required this.index,required this.storageUrl,required this.createdAt,required this.mimeType});

  //Convert Record to a MediaContent Object
    factory MediaContent.fromMap(Map<String, dynamic> data) {
    return MediaContent(
      id: data['id'],
      userId: data['user_id'],
      postId: data['post_id'],
      index: data['index'],
      storageUrl: data['storage_url'],
      createdAt: data['created_at'],
      mimeType: data['mimeType'],
    );
  }

  //Convert MediaContent Object to Record
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'index': index,
      'storage_url': storageUrl,
      'created_at': createdAt.toIso8601String(),
      'mimeType': mimeType,
    };
  }
}