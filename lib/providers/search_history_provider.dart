import 'package:nature_connect/model/search_history.dart';
import 'package:nature_connect/sqlite_db.dart';



class SearchHistoryProvider {
  // Singleton pattern (optional)
  static final SearchHistoryProvider _instance = SearchHistoryProvider._internal();

  factory SearchHistoryProvider() {
    return _instance;
  }

  SearchHistoryProvider._internal();

  // Get all search history entries
  Future<List<SearchHistory>> getSearchHistory() async {
    return await SqliteDb.db.getSearchHistory();
  }

  // Check if a search query exists
  Future<bool> isSearchHistoryExists(String query) async {
    return await SqliteDb.db.isSearchHistoryExists(query);
  }

  // Add a search query to the history if it doesn't exist
  Future<void> addSearchHistory(String query) async {
    bool exists = await isSearchHistoryExists(query);
    if (!exists) {
      await SqliteDb.db.createSearchHistory(SearchHistory(id: null, query: query));
    }
  }

  // Delete a search history entry by ID
  Future<void> deleteSearchHistory(int id) async {
    await SqliteDb.db.deleteSearchHistory(id);
  }
}
