import 'package:nature_connect/model/draft.dart';
import 'package:nature_connect/model/draft_media.dart';
import 'package:nature_connect/model/search_history.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteDb {
  SqliteDb._();

  static final SqliteDb db = SqliteDb._();
  static Database? _database;

  // Database getter
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  // Initialize database
  initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'nature_connect.db'),
      onCreate: createDb(),
      version: 1,
    );
  }

  // Create DB
  createDb() {
    return (Database db, int version) async {
      // Create search history table
      await db.execute('''
        CREATE TABLE $historyTable (
          $idHistoryColumn $idType,
          $queryColumn $queryType
        )
        ''');

      // Create draft table with the new schema
      await db.execute('''
        CREATE TABLE $draftTable (
          $draftIdColumn $draftIdType,
          $captionColumn $captionType,
          $withMediaColumn $withMediaType
        )
        ''');

      // Create draft media table with the new schema
      await db.execute('''
      CREATE TABLE $draftMediaTable (
        $mediaIdColumn $mediaIdType,
        $draftIdForeignKeyColumn $draftIdForeignKeyType,
        $pathColumn $pathType,
        $mimeTypeColumn $mimeTypeType,
        FOREIGN KEY ($draftIdForeignKeyColumn) REFERENCES $draftTable($draftIdColumn) ON DELETE CASCADE
      )
      ''');
    };
  }

  //****************************SEARCH HISTORY******************************** */
  // CREATE
  Future<void> createSearchHistory(SearchHistory searchHistory) async {
    final db = await database;
    await db.insert(historyTable, {
      idHistoryColumn: searchHistory.id,
      queryColumn: searchHistory.query,
    });
  }

  // READ
  Future<List<SearchHistory>> getSearchHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(historyTable, orderBy: '$idHistoryColumn DESC');
    return List.generate(maps.length, (i) => SearchHistory.fromJson(maps[i]));
  }

  // DELETE
  Future<void> deleteSearchHistory(int id) async {
    final db = await database;
    await db
        .delete(historyTable, where: '$idHistoryColumn = ?', whereArgs: [id]);
  }

  // If exists
  Future<bool> isSearchHistoryExists(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        .query(historyTable, where: '$queryColumn = ?', whereArgs: [query]);
    return maps.isNotEmpty;
  }

  //****************************DRAFT MODEL******************************** */
  // CREATE
  Future<int> createDraft(Draft draft) async {
    final db = await database;
    int id = await db.insert(draftTable, {
      draftIdColumn: draft.draftId,
      captionColumn: draft.caption,
      withMediaColumn: draft.withMedia ? 1 : 0,
    });
    return id;
  }

  // READ
  Future<List<Draft>> getDrafts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(draftTable, orderBy: '$draftIdColumn DESC');
    return List.generate(maps.length, (i) => Draft.fromJson(maps[i]));
  }

  // DELETE
  Future<void> deleteDraft(int draftId) async {
    final db = await database;
    await db
        .delete(draftTable, where: '$draftIdColumn = ?', whereArgs: [draftId]);
  }

  //****************************DRAFT MEDIA MODEL******************************** */
// CREATE
  Future<void> createDraftMedia(DraftMedia draftMedia) async {
    final db = await database;
    await db.insert(draftMediaTable, {
      mediaIdColumn: draftMedia.id,
      draftIdForeignKeyColumn: draftMedia.draftId,
      pathColumn: draftMedia.path,
      mimeTypeColumn: draftMedia.mimeType,
    });
  }

// READ all media associated with a specific draft ID
  Future<List<DraftMedia>> getDraftMedia(int draftId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      draftMediaTable,
      where: '$draftIdForeignKeyColumn = ?',
      whereArgs: [draftId],
      orderBy: '$mediaIdColumn DESC',
    );
    return List.generate(maps.length, (i) => DraftMedia.fromJson(maps[i]));
  }

// DELETE all media associated with a specific draft ID
  Future<void> deleteDraftMedia(int draftId) async {
    final db = await database;
    await db.delete(
      draftMediaTable,
      where: '$draftIdForeignKeyColumn = ?',
      whereArgs: [draftId],
    );
  }

// DELETE a specific media entry by media ID
  Future<void> deleteMediaById(int mediaId) async {
    final db = await database;
    await db.delete(
      draftMediaTable,
      where: '$mediaIdColumn = ?',
      whereArgs: [mediaId],
    );
  }
}
