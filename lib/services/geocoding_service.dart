import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart' as latlong2;

class GeocodingService {
  static Future<String> reverseGeocode(latlong2.LatLng location) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&addressdetails=1';

    final response = await http.get(Uri.parse(url), headers: {
      'User-Agent': 'ecotrack-app' // Required by Nominatim
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final address = data['address'];

      // You can adjust these fields as needed
      final road = address['road'] ?? '';
      final suburb = address['suburb'] ?? '';
      final town = address['town'] ?? address['city'] ?? '';
      final placeName = [road, suburb, town]
          .where((part) => part.isNotEmpty)
          .join(', ')
          .trim();

      return placeName.isNotEmpty ? placeName : 'Unnamed Location';
    } else {
      throw Exception('Failed to reverse geocode location');
    }
  }
}
