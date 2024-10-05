class MediaContent {
  final String id;
  final String userId;
  final String postId;
  final int index;
  final String storageUrl;
  final DateTime createdAt;
  final String mimeType;

  MediaContent({
    required this.id,
    required this.userId,
    required this.postId,
    required this.index,
    required this.storageUrl,
    required this.createdAt,
    required this.mimeType,
  });

  // Convert Record to a MediaContent Object
  factory MediaContent.fromMap(Map<String, dynamic> data) {
    return MediaContent(
      id: data['id'].toString(),
      userId: data['user_id'].toString(),
      postId: data['post_id'].toString(),
      index: data['index'] is int ? data['index'] : int.parse(data['index']), // Ensure index is an int
      storageUrl: data['storage_url'].toString(),
      createdAt: DateTime.parse(data['created_at'].toString()), // Correctly parse the DateTime
      mimeType: data['mime_type'].toString(), // Ensure you're using the correct key ('mime_type')
    );
  }

  // Convert MediaContent Object to Record
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'index': index,
      'storage_url': storageUrl,
      'created_at': createdAt.toIso8601String(),
      'mime_type': mimeType,
    };
  }
}
