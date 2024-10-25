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
  Future<void> addDraft(Draft draft) async {
    await SqliteDb.db.createDraft(draft);
  }

  // Delete a draft by ID
  Future<void> deleteDraft(int draftId) async {
    await SqliteDb.db.deleteDraft(draftId);
  }
}
