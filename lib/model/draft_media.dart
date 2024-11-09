const String draftMediaTable = 'draft_media';

const String mediaIdColumn = 'id';
const String draftIdForeignKeyColumn = 'draft_id';
const String pathColumn = 'path';
const String mimeTypeColumn = 'mime_type';

const List<String> draftMediaColumns = [
  mediaIdColumn,
  draftIdForeignKeyColumn,
  pathColumn,
  mimeTypeColumn,
];

// SQLite data types
const String mediaIdType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
const String draftIdForeignKeyType = 'INTEGER'; // Foreign key to `draft_id` in Draft table
const String pathType = 'TEXT';
const String mimeTypeType = 'TEXT';

class DraftMedia {
  final int? id; // Local media ID
  final int draftId; // Foreign key to Draft
  final String path; // File path for the media
  final String mimeType; // MIME type of the media

  const DraftMedia({
    this.id,
    required this.draftId,
    required this.path,
    required this.mimeType,
  });

  // Convert from JSON (or Map) for SQLite
  static DraftMedia fromJson(Map<String, Object?> json) => DraftMedia(
        id: json[mediaIdColumn] as int?,
        draftId: json[draftIdForeignKeyColumn] as int,
        path: json[pathColumn] as String,
        mimeType: json[mimeTypeColumn] as String,
      );

  // Convert to JSON (or Map) for SQLite
  static Map<String, Object?> toJson(DraftMedia draftMedia) => {
        mediaIdColumn: draftMedia.id,
        draftIdForeignKeyColumn: draftMedia.draftId,
        pathColumn: draftMedia.path,
        mimeTypeColumn: draftMedia.mimeType,
      };

  // Create a copy of DraftMedia with optional modifications
  DraftMedia copyWith({
    int? id,
    int? draftId,
    String? path,
    String? mimeType,
  }) {
    return DraftMedia(
      id: id ?? this.id,
      draftId: draftId ?? this.draftId,
      path: path ?? this.path,
      mimeType: mimeType ?? this.mimeType,
    );
  }
}
