import 'package:nature_connect/model/draft.dart';
import 'package:nature_connect/sqlite_db.dart';

class DraftProvider {
  // Singleton pattern (optional)
  static final DraftProvider _instance = DraftProvider._internal();

  factory DraftProvider() {
    return _instance;
  }

  DraftProvider._internal();

  // Get all drafts
  Future<List<Draft>> getDrafts() async {
    return await SqliteDb.db.getDrafts();
  }

  // Add a new draft
  Future<int> addDraft(Draft draft) async {
    int id = await SqliteDb.db.createDraft(draft);
    return id;
  }

  // Delete a draft by ID
  Future<void> deleteDraft(int draftId) async {
    await SqliteDb.db.deleteDraft(draftId);
    await SqliteDb.db.deleteDraftMedia(draftId);
  }
}
