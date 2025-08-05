import 'package:flutter/material.dart';
import '../widgets/waste_card.dart';
import '../utils/colors.dart';
import 'auth_screen.dart';
import 'package:smart_waste_management/screens/auth_service.dart';
import 'package:smart_waste_management/screens/auth_screen.dart';

class ReuserDashboard extends StatefulWidget {
  const ReuserDashboard({super.key});

  @override
  State<ReuserDashboard> createState() => _ReuserDashboardState();
}

class _ReuserDashboardState extends State<ReuserDashboard> {
  String materialFilter = 'all';
  String distanceFilter = '10';

  final List<Map<String, dynamic>> wasteItems = [
    {
      'id': '1',
      'name': 'Clean PET Plastic',
      'type': 'plastic',
      'location': 'Central Collection Facility',
      'distance': 3.2,
      'quantity': 420,
    },
    {
      'id': '2',
      'name': 'Office Paper Waste',
      'type': 'paper',
      'location': 'Downtown Business District',
      'distance': 5.7,
      'quantity': 180,
    },
    {
      'id': '3',
      'name': 'Aluminum Cans',
      'type': 'metal',
      'location': 'Westside Recycling',
      'distance': 8.1,
      'quantity': 320,
    },
  ];

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
                  onPressed: () {},
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
                      DropdownMenuItem(
                          value: 'all', child: Text('All Materials')),
                      DropdownMenuItem(
                          value: 'plastic', child: Text('Plastic')),
                      DropdownMenuItem(value: 'paper', child: Text('Paper')),
                      DropdownMenuItem(value: 'metal', child: Text('Metal')),
                      DropdownMenuItem(value: 'glass', child: Text('Glass')),
                      DropdownMenuItem(
                          value: 'organic', child: Text('Organic')),
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
              itemCount: wasteItems.length,
              itemBuilder: (ctx, index) {
                final item = wasteItems[index];
                return WasteCard(
                  name: item['name'],
                  type: item['type'],
                  location: item['location'],
                  distance: item['distance'],
                  quantity: item['quantity'],
                  onViewDetails: () {},
                  onContact: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
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
          const Text('reuser@example.com'),
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
