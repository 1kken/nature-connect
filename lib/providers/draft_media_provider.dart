import 'package:nature_connect/model/draft_media.dart';
import 'package:nature_connect/sqlite_db.dart';

class DraftMediaProvider {
  // Singleton pattern (optional)
  static final DraftMediaProvider _instance = DraftMediaProvider._internal();

  factory DraftMediaProvider() {
    return _instance;
  }

  DraftMediaProvider._internal();

  // Get all media entries for a specific draft ID
  Future<List<DraftMedia>> getDraftMedia(int draftId) async {
    return await SqliteDb.db.getDraftMedia(draftId);
  }

  // Add a new draft media entry
  Future<int> addDraftMedia(DraftMedia draftMedia) async {
    await SqliteDb.db.createDraftMedia(draftMedia);
    return draftMedia.id ?? 0; // Return media ID, if it was provided
  }

  // Delete all media associated with a specific draft ID
  Future<void> deleteDraftMedia(int draftId) async {
    await SqliteDb.db.deleteDraftMedia(draftId);
  }

  // Delete a specific media entry by media ID
  Future<void> deleteMediaById(int mediaId) async {
    await SqliteDb.db.deleteMediaById(mediaId);
  }
}
