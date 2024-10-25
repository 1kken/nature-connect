const String draftTable = 'draft';

const String draftIdColumn = 'draft_id';
const String captionColumn = 'caption';
const String withMediaColumn = 'with_media';

const List<String> draftColumns = [
  draftIdColumn,
  captionColumn,
  withMediaColumn,
];

// SQLite data types
const String draftIdType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
const String captionType = 'TEXT';
const String withMediaType = 'INTEGER'; // 0 for false, 1 for true

class Draft {
  final int? draftId; // Local draft ID
  final String caption;
  final bool withMedia;

  const Draft({
    this.draftId,
    required this.caption,
    required this.withMedia,
  });

  // Convert from JSON (or Map) for SQLite
  static Draft fromJson(Map<String, Object?> json) => Draft(
        draftId: json[draftIdColumn] as int?,
        caption: json[captionColumn] as String,
        withMedia: (json[withMediaColumn] as int) == 1,
      );

  // Convert to JSON (or Map) for SQLite
  static Map<String, Object?> toJson(Draft draft) => {
        draftIdColumn: draft.draftId,
        captionColumn: draft.caption,
        withMediaColumn: draft.withMedia ? 1 : 0,
      };

  // Create a copy of Draft with optional modifications
  Draft copyWith({
    int? draftId,
    String? caption,
    bool? withMedia,
  }) {
    return Draft(
      draftId: draftId ?? this.draftId,
      caption: caption ?? this.caption,
      withMedia: withMedia ?? this.withMedia,
    );
  }
}
 