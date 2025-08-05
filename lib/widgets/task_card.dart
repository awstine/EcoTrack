import 'package:flutter/material.dart';
import '../utils/colors.dart';

class TaskCard extends StatelessWidget {
  final String location;
  final String wasteType;
  final String time;
  final String priority;
  final VoidCallback onStartTask;
  final VoidCallback onNavigate;

  const TaskCard({
    super.key,
    required this.location,
    required this.wasteType,
    required this.time,
    required this.priority,
    required this.onStartTask,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    switch (priority) {
      case 'high':
        priorityColor = AppColors.danger;
        break;
      case 'medium':
        priorityColor = AppColors.accent;
        break;
      case 'low':
        priorityColor = AppColors.info;
        break;
      default:
        priorityColor = AppColors.textMedium;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: priorityColor, width: 4)),
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
            Text(
              location,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.delete_outline,
                    size: 16, color: AppColors.textMedium),
                const SizedBox(width: 4),
                Text(wasteType),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.textMedium),
                const SizedBox(width: 4),
                Text(time),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onStartTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Start Task',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onNavigate,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Navigate'),
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
