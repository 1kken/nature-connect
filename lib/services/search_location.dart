import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchLocation {
  final String apiKey = '672e07ea23e47657998620siu5f26db';
  final String apiUrl = 'https://geocode.maps.co/search';

  Future<Map<String, dynamic>?> searchLocation(String address) async {
    try {
      // Replace spaces with '+' for URL encoding
      String formattedAddress = address.replaceAll(' ', '+');
      String url = '$apiUrl?q=$formattedAddress&api_key=$apiKey';

      // Call the API
      final response = await http.get(Uri.parse(url));

      // Check if response is successful
      if (response.statusCode == 200) {
        // Decode the response
        List<dynamic> result = jsonDecode(response.body);

        // Return the first result if available
        return result.isNotEmpty ? result[0] : null;
      } else {
        print('Failed to load location data');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
