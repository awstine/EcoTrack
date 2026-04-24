import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Required for launching the dialer
import '../widgets/waste_card.dart';
import '../utils/colors.dart';
import 'auth_service.dart';
import '../services/waste_item_service.dart';

class ReuserDashboard extends StatefulWidget {
  const ReuserDashboard({super.key});

  @override
  State<ReuserDashboard> createState() => _ReuserDashboardState();
}

class _ReuserDashboardState extends State<ReuserDashboard> {
  String materialFilter = 'all';
  String distanceFilter = '10';
  final TextEditingController _searchController = TextEditingController();
  List<WasteItem> wasteItems = [];

  @override
  void initState() {
    super.initState();
    _loadWasteItems();
  }

  Future<void> _loadWasteItems() async {
    final items = await WasteItemService.getWasteItems();
    setState(() {
      wasteItems = items;
    });
  }

  List<WasteItem> get filteredItems {
    final query = _searchController.text.trim().toLowerCase();

    return wasteItems.where((item) {
      final name = item.name.toLowerCase();
      final type = item.type.toLowerCase();
      final distance = item.distance;

      final matchesSearch = query.isEmpty ||
          name.contains(query) ||
          type.contains(query) ||
          item.location.toLowerCase().contains(query);

      final matchesMaterial = materialFilter == 'all' || type == materialFilter;
      final matchesDistance = distance <= double.parse(distanceFilter);

      return matchesSearch && matchesMaterial && matchesDistance;
    }).toList();
  }

  void _showContactDialog(WasteItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.contact_phone, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Contact Provider'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Location: ${item.location}'),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Phone Number:', style: TextStyle(color: Colors.grey)),
            Text(
              item.phone,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final Uri launchUri = Uri(
                scheme: 'tel',
                path: item.phone,
              );
              if (await canLaunchUrl(launchUri)) {
                await launchUrl(launchUri);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open the dialer app')),
                  );
                }
              }
            },
            icon: const Icon(Icons.call),
            label: const Text('Call Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
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
              child: Icon(Icons.recycling, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Recycling Company',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('reuser@gmail.com'),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showProfileDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search materials...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.filter_list),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    value: materialFilter,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Materials')),
                      DropdownMenuItem(value: 'plastic', child: Text('Plastic')),
                      DropdownMenuItem(value: 'paper', child: Text('Paper')),
                      DropdownMenuItem(value: 'metal', child: Text('Metal')),
                      DropdownMenuItem(value: 'glass', child: Text('Glass')),
                      DropdownMenuItem(value: 'organic', child: Text('Organic')),
                    ],
                    onChanged: (value) {
                      setState(() => materialFilter = value.toString());
                    },
                    decoration: InputDecoration(
                      labelText: 'Material Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    value: distanceFilter,
                    items: const [
                      DropdownMenuItem(value: '5', child: Text('Within 5km')),
                      DropdownMenuItem(value: '10', child: Text('Within 10km')),
                      DropdownMenuItem(value: '25', child: Text('Within 25km')),
                      DropdownMenuItem(value: '50', child: Text('Within 50km')),
                    ],
                    onChanged: (value) {
                      setState(() => distanceFilter = value.toString());
                    },
                    decoration: InputDecoration(
                      labelText: 'Distance',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredItems.length,
              itemBuilder: (ctx, index) {
                final item = filteredItems[index];
                return WasteCard(
                  name: item.name,
                  type: item.type,
                  location: item.location,
                  distance: item.distance,
                  quantity: item.quantity,
                  onViewDetails: () {},
                  onContact: () => _showContactDialog(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
