import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:url_launcher/url_launcher.dart';

import '../widgets/task_card.dart';
import '../utils/colors.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';
import 'auth_service.dart';

class CollectorDashboard extends StatefulWidget {
  const CollectorDashboard({super.key});

  @override
  State<CollectorDashboard> createState() => _CollectorDashboardState();
}

class _CollectorDashboardState extends State<CollectorDashboard> {
  bool showMapView = true;
  late MapController _mapController;
  List<latlong2.LatLng> _binLocations = [];
  final Map<latlong2.LatLng, String> _locationNames = {};
  bool _isLoadingLocations = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadBinLocations();
  }

  Future<void> _loadBinLocations() async {
    setState(() => _isLoadingLocations = true);

    try {
      final generatorLocation = LocationService.getBinLocation();
      final locations = [
        if (generatorLocation != null) generatorLocation,
        const latlong2.LatLng(-1.2865, 36.8175),
        const latlong2.LatLng(-1.2860, 36.8180),
      ];

      setState(() {
        _binLocations = locations;
        _locationNames.clear();
      });

      for (final location in _binLocations) {
        await _getLocationName(location);
      }

      if (_binLocations.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(_binLocations.first, 15);
        });
      }
    } catch (e) {
      print('Error loading bin locations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load locations')),
      );
    } finally {
      setState(() => _isLoadingLocations = false);
    }
  }

  Future<void> _getLocationName(latlong2.LatLng location) async {
    try {
      final name = await GeocodingService.reverseGeocode(location);
      setState(() {
        _locationNames[location] = name;
      });
    } catch (e) {
      print('Geocoding error: $e');
      setState(() {
        _locationNames[location] =
            'Location (${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)})';
      });
    }
  }

  String _getDisplayName(latlong2.LatLng location) {
    return _locationNames[location] ?? 'Loading location...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showProfileDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBinLocations,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(_binLocations.length.toString(), "Pending Pickups"),
                _buildStat('8', 'Completed Today'),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => setState(() => showMapView = true),
                  style: TextButton.styleFrom(
                    backgroundColor: showMapView
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 20),
                      SizedBox(width: 8),
                      Text('Map View'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => setState(() => showMapView = false),
                  style: TextButton.styleFrom(
                    backgroundColor: !showMapView
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list, size: 20),
                      SizedBox(width: 8),
                      Text('List View'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoadingLocations)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: showMapView ? _buildMapView() : _buildListView(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerMapOnBins,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildMapView() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: const latlong2.LatLng(-1.286389, 36.817223),
        zoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.ecotrack',
        ),
        MarkerLayer(
          markers: _binLocations.map((location) {
            return Marker(
              point: location,
              width: 40,
              height: 40,
              child: Icon(
                Icons.delete,
                color: location == LocationService.getBinLocation()
                    ? Colors.red
                    : Colors.blue,
                size: 40,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildListView() {
    if (_binLocations.isEmpty) {
      return const Center(
        child: Text('No collection tasks available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _binLocations.length,
      itemBuilder: (ctx, index) {
        final location = _binLocations[index];
        final displayName = _getDisplayName(location);

        return TaskCard(
          location: displayName,
          wasteType: 'General Waste',
          time: index == 0 ? 'Just added' : '1 hour ago',
          priority: index == 0 ? 'high' : 'medium',
          onStartTask: () => _startCollection(location),
          onNavigate: () => _navigateToBin(location),
        );
      },
    );
  }

  void _centerMapOnBins() {
    if (_binLocations.isNotEmpty) {
      _mapController.move(_binLocations.first, 15);
    }
  }

  void _startCollection(latlong2.LatLng location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Collection'),
        content: Text('Mark bin at ${_getDisplayName(location)} as collected?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _binLocations.remove(location);
                _locationNames.remove(location);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Collection confirmed!')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToBin(latlong2.LatLng location) async {
    final latitude = location.latitude;
    final longitude = location.longitude;

    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch Maps')),
      );
    }
  }

  Widget _buildStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.local_shipping, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Waste Collector',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('collector@example.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AuthService.logout(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
