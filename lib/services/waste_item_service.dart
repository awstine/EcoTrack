import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WasteItem {
  final String id;
  final String name;
  final String type;
  final String location;
  final double distance;
  final int quantity;
  final String phone;

  WasteItem({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.distance,
    required this.quantity,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'location': location,
      'distance': distance,
      'quantity': quantity,
      'phone': phone,
    };
  }

  factory WasteItem.fromJson(Map<String, dynamic> json) {
    return WasteItem(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      location: json['location'],
      distance: json['distance'],
      quantity: json['quantity'],
      phone: json['phone'],
    );
  }
}

class WasteItemService {
  static const String _wasteItemsKey = 'waste_items';

  static Future<List<WasteItem>> getWasteItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getStringList(_wasteItemsKey) ?? [];

    if (itemsJson.isEmpty) {
      // Add some initial sample data
      final sampleItems = [
        WasteItem(
          id: '1',
          name: 'Clean PET Plastic',
          type: 'plastic',
          location: 'Central Collection Facility',
          distance: 3.2,
          quantity: 420,
          phone: '+254712345678',
        ),
        WasteItem(
          id: '2',
          name: 'Office Paper Waste',
          type: 'paper',
          location: 'Downtown Business District',
          distance: 5.7,
          quantity: 180,
          phone: '+254722000111',
        ),
        WasteItem(
          id: '3',
          name: 'Aluminum Cans',
          type: 'metal',
          location: 'Westside Recycling',
          distance: 8.1,
          quantity: 320,
          phone: '+254733444555',
        ),
      ];

      final itemsJson = sampleItems.map((item) => json.encode(item.toJson())).toList();
      await prefs.setStringList(_wasteItemsKey, itemsJson);
      return sampleItems;
    }

    return itemsJson.map((item) => WasteItem.fromJson(json.decode(item))).toList();
  }

  static Future<void> addWasteItem(WasteItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getWasteItems();
    items.add(item);
    final itemsJson = items.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList(_wasteItemsKey, itemsJson);
  }

  static Future<void> removeWasteItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getWasteItems();
    items.removeWhere((item) => item.id == id);
    final itemsJson = items.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList(_wasteItemsKey, itemsJson);
  }

  static Future<void> updateWasteItem(WasteItem updatedItem) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getWasteItems();
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      items[index] = updatedItem;
      final itemsJson = items.map((item) => json.encode(item.toJson())).toList();
      await prefs.setStringList(_wasteItemsKey, itemsJson);
    }
  }
}