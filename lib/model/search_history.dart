const String historyTable = 'search_history';

const String idHistoryColumn = 'id';
const String queryColumn = 'query';

const List<String> searchHistoryColumns = [
  idHistoryColumn,
  queryColumn,
];

const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
const String queryType = 'TEXT NOT NULL';


class SearchHistory {
  final int? id;
  final String query;

  const SearchHistory({
    required this.id,
    required this.query,
  });

  //form json
  static SearchHistory fromJson(Map<String, Object?> json) => SearchHistory(
    id: json[idHistoryColumn] as int,
    query: json[queryColumn] as String,
  );

  //to json
  static Map<String, Object?> toJson(SearchHistory searchHistory) => {
    idHistoryColumn: searchHistory.id,
    queryColumn: searchHistory.query,
  };

  //copywith
  SearchHistory copyWith({
    int? id,
    String? query,
  }) {
    return SearchHistory(
      id: id ?? this.id,
      query: query ?? this.query,
    );
  }
   
}