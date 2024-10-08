import 'package:flutter/material.dart';
import 'package:nature_connect/model/search_history.dart';
import 'package:nature_connect/providers/search_history_provider.dart';

class SearchHistoryWidget extends StatefulWidget {
  const SearchHistoryWidget({super.key});

  @override

   createState() => _SearchHistoryWidgetState();
}

class _SearchHistoryWidgetState extends State<SearchHistoryWidget> {
  late Future<List<SearchHistory>> _searchHistory;

  @override
  void initState() {
    super.initState();
    // Load search history when the widget is initialized
    _loadSearchHistory();
  }

  // Method to load search history
  void _loadSearchHistory() {
    setState(() {
      _searchHistory = SearchHistoryProvider().getSearchHistory();
    });
  }

  // Method to delete a history entry and reload the list
  Future<void> _deleteHistoryEntry(int id) async {
    await SearchHistoryProvider().deleteSearchHistory(id);
    _loadSearchHistory(); // Reload the list after deletion
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SearchHistory>>(
      future: _searchHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No search history found.'));
        }

        final searchHistory = snapshot.data!;

        return ListView.builder(
          itemCount: searchHistory.length,
          itemBuilder: (context, index) {
            final history = searchHistory[index];
            return ListTile(
              title: Text(history.query),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteHistoryEntry(history.id!), // Delete entry
              ),
              onTap: () {
                // Optionally, you can trigger a search or something else on tap
                print('Tapped on: ${history.query}');
              },
            );
          },
        );
      },
    );
  }
}
