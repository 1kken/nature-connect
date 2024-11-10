import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RatePage extends StatefulWidget {
  final int landMarkId;
  const RatePage({required this.landMarkId, super.key});

  @override
  State<RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  final _supabase = Supabase.instance.client;
  double _rating = 3.0; // Default slider value
  bool _hasRated = false; // Track if user has already rated
  double _averageRating = 0.0; // Average rating to display
  String? _landmarkName; // Name of the landmark

  @override
  void initState() {
    super.initState();
    _checkUserRating();
    _fetchAverageRating();
    _getLandmark(); // Fetch landmark data on initialization
  }

  Future<void> _checkUserRating() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return; // Handle unauthenticated state if needed
    }

    final response = await _supabase
        .from('landmark_ratings')
        .select()
        .eq('user_id', userId)
        .eq('landmark_id', widget.landMarkId)
        .limit(1);

    setState(() {
      _hasRated = response.isNotEmpty; // True if a rating exists
    });
  }

  Future<void> _fetchAverageRating() async {
    final response = await _supabase
        .from('landmark_ratings')
        .select('rating')
        .eq('landmark_id', widget.landMarkId);

    if (response.isNotEmpty) {
      final ratings = response.map((e) {
        // Safely convert the rating to double, if it's a number type
        final rating = e['rating'];
        if (rating is num) {
          return rating.toDouble(); // Convert num to double
        } else {
          // Handle invalid rating types if necessary, e.g. return 0 or throw an error
          return 0.0; // Or handle appropriately
        }
      }).toList();
      setState(() {
        _averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      });
    }
  }

  Future<void> _submitRating() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return; // Handle unauthenticated state if needed
    }

    await _supabase.from('landmark_ratings').insert({
      'user_id': userId,
      'landmark_id': widget.landMarkId,
      'rating': _rating,
    });

    setState(() {
      _hasRated = true; // Disable further rating once submitted
    });

    _fetchAverageRating(); // Refresh the average rating after submission
  }

  Future<void> _getLandmark() async {
    final response = await _supabase
        .from('nature_landmarks')
        .select('name')
        .eq('id', widget.landMarkId)
        .single();

    if (response.isNotEmpty) {
      setState(() {
        _landmarkName = response['name']; // Store the landmark's name
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_landmarkName ??
            'Loading...'), // Display landmark name or a loading placeholder
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Rate this Landmark', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Slider(
              value: _rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: _rating.toString(),
              onChanged: _hasRated
                  ? null
                  : (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _hasRated ? null : _submitRating,
              child: const Text('Submit Rating'),
            ),
            const SizedBox(height: 16),
            Text(
              'Average Rating: ${_averageRating.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
