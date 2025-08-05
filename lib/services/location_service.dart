// lib/services/location_service.dart
import 'package:latlong2/latlong.dart' as latlong2;

class LocationService {
  static latlong2.LatLng? _currentBinLocation;

  static void setBinLocation(latlong2.LatLng location) {
    _currentBinLocation = location;
  }

  static latlong2.LatLng? getBinLocation() {
    return _currentBinLocation;
  }
}
