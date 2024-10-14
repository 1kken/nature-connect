class MarketplaceMedia {
  // Attributes
  final int id;
  final int marketplaceItemId;
  final int index;
  final String userId;
  final String storageUrl;
  final String mimeType;
  final DateTime createdAt;

  // Constructor
  MarketplaceMedia({
    required this.id,
    required this.marketplaceItemId,
    required this.index,
    required this.userId,
    required this.storageUrl,
    required this.mimeType,
    required this.createdAt,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marketplaceItemId': marketplaceItemId,
      'index': index,
      'userId': userId,
      'storageUrl': storageUrl,
      'mimeType': mimeType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert from Map
  factory MarketplaceMedia.fromMap(Map<String, dynamic> map) {
    return MarketplaceMedia(
      id: map['id'] ?? 0,
      marketplaceItemId: map['marketplaceItemId'] ?? 0,
      index: map['index'] ?? 0,
      userId: map['userId'] ?? '',
      storageUrl: map['storage_url'] ?? '',
      mimeType: map['mimeType'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

}