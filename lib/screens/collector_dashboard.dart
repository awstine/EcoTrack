import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:url_launcher/url_launcher.dart';

import '../widgets/task_card.dart';
import '../utils/colors.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';
import '../services/waste_item_service.dart';
import 'auth_service.dart';
import 'package:flutter/services.dart';
import 'dart:math';

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

  void _showAddWasteItemDialog() {
    final _nameController = TextEditingController();
    final _locationController = TextEditingController();
    final _distanceController = TextEditingController();
    final _quantityController = TextEditingController();
    final _phoneController = TextEditingController();
    String _selectedType = 'plastic';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_circle, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Add Waste Material'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Material Name',
                  hintText: 'e.g., Clean PET Plastic',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'plastic', child: Text('Plastic')),
                  DropdownMenuItem(value: 'paper', child: Text('Paper')),
                  DropdownMenuItem(value: 'metal', child: Text('Metal')),
                  DropdownMenuItem(value: 'glass', child: Text('Glass')),
                  DropdownMenuItem(value: 'organic', child: Text('Organic')),
                ],
                onChanged: (value) {
                  _selectedType = value!;
                },
                decoration: const InputDecoration(
                  labelText: 'Material Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Central Collection Facility',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _distanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Distance (km)',
                  hintText: 'e.g., 3.2',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity (kg)',
                  hintText: 'e.g., 420',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g., +254712345678',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isEmpty ||
                  _locationController.text.isEmpty ||
                  _distanceController.text.isEmpty ||
                  _quantityController.text.isEmpty ||
                  _phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final distance = double.tryParse(_distanceController.text);
              final quantity = int.tryParse(_quantityController.text);

              if (distance == null || quantity == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid numbers for distance and quantity')),
                );
                return;
              }

              final wasteItem = WasteItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text.trim(),
                type: _selectedType,
                location: _locationController.text.trim(),
                distance: distance,
                quantity: quantity,
                phone: _phoneController.text.trim(),
              );

              await WasteItemService.addWasteItem(wasteItem);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Waste material added successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Material'),
          ),
        ],
      ),
    );
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
        onPressed: _showAddWasteItemDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
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
          //urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
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

    print('Attempting navigation to: $latitude, $longitude');

    // List of URLs to try in order of preference
    final urlsToTry = [
      // Google Maps app (most common on Android)
      Uri.parse('google.navigation:q=$latitude,$longitude&mode=d'),

      // Google Maps web version
      Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving'),

      // Apple Maps (for iOS or some Android devices)
      Uri.parse('https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d'),

      // Generic geo URI (works with many map apps)
      Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude(Waste+Collection+Point)'),

      // Waze (if installed)
      Uri.parse('waze://?ll=$latitude,$longitude&navigate=yes'),

      // Here WeGo maps
      Uri.parse('here-route://$latitude,$longitude'),
    ];

    bool launched = false;

    for (final url in urlsToTry) {
      try {
        print('Trying URL: ${url.toString()}');
        if (await canLaunchUrl(url)) {
          print('Success - can launch this URL');
          await launchUrl(url, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        } else {
          print('Cannot launch this URL');
        }
      } catch (e) {
        print('Error launching URL: $e');
      }
    }

    if (!launched) {
      _showNavigationFallbackDialog(latitude, longitude);
    }
  }

  void _showNavigationFallbackDialog(double latitude, double longitude) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navigation Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('No navigation app found. Choose an option:'),
            const SizedBox(height: 16),
            Text(
              'Coordinates:\nLatitude: ${latitude.toStringAsFixed(6)}\nLongitude: ${longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          // Copy coordinates option
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _copyCoordinatesToClipboard(latitude, longitude);
            },
            child: const Text('Copy Coordinates'),
          ),
          // Open in browser option
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openInWebBrowser(latitude, longitude);
            },
            child: const Text('Open in Browser'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyCoordinatesToClipboard(double lat, double lng) async {
    final coordinates = '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
    await Clipboard.setData(ClipboardData(text: coordinates));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Coordinates copied: $coordinates')),
    );
  }

  Future<void> _openInWebBrowser(double lat, double lng) async {
    final url = Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=16/$lat/$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open browser')),
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
