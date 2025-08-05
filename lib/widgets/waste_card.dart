import 'package:flutter/material.dart';
import '../utils/colors.dart';

class WasteCard extends StatelessWidget {
  final String name;
  final String type;
  final String location;
  final double distance;
  final int quantity;
  final VoidCallback onViewDetails;
  final VoidCallback onContact;

  const WasteCard({
    super.key,
    required this.name,
    required this.type,
    required this.location,
    required this.distance,
    required this.quantity,
    required this.onViewDetails,
    required this.onContact,
  });

  Color getTypeColor() {
    switch (type) {
      case 'plastic':
        return Colors.blue;
      case 'paper':
        return Colors.green;
      case 'metal':
        return Colors.orange;
      case 'glass':
        return Colors.teal;
      case 'organic':
        return Colors.brown;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text('$type Image')),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                type.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              backgroundColor: getTypeColor(),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.textMedium),
                const SizedBox(width: 4),
                Text('$location (${distance.toStringAsFixed(1)}km)'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.scale, size: 16, color: AppColors.textMedium),
                const SizedBox(width: 4),
                Text('$quantity kg available'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onContact,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Contact'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
