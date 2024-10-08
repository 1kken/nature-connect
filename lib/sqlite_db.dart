import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:nature_connect/model/search_history.dart';


class SqliteDb {
  SqliteDb._();


  static final SqliteDb db = SqliteDb._();

  static Database? _database;

  //datbase getter
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  //initialize database
  initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'nature_connect.db'),
      onCreate: createDb(),
      version: 1,
    );
  }

  //create db future
  createDb() {
    return (Database db, int version) async {
      //create the serach history table using the class
      await db.execute(
        '''
        CREATE TABLE $historyTable (
          $idHistoryColumn $idType,
          $queryColumn $queryType
        )
        '''
      );
    };
  }

  //****************************SEARCH HISTORY******************************** */
  //CREATE
  Future<void> createSearchHistory(SearchHistory searchHistory) async {
    final db = await database;
     await db.insert(historyTable, SearchHistory.toJson(searchHistory));
  }

  //READ
  Future<List<SearchHistory>> getSearchHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(historyTable,orderBy: '$idHistoryColumn DESC');
    return List.generate(maps.length, (index) => SearchHistory.fromJson(maps[index]));
  }

  //DELETE
  Future<void> deleteSearchHistory(int id) async {
    final db = await database;
    await db.delete(historyTable, where: '$idHistoryColumn = ?', whereArgs: [id]);
  }

  //If exists
  Future<bool> isSearchHistoryExists(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(historyTable, where: '$queryColumn = ?', whereArgs: [query]);
    return maps.isNotEmpty;
  }

  //****************************SEARCH HISTORY******************************** */

}