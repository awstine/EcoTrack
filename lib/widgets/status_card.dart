import 'package:flutter/material.dart';
import '../utils/colors.dart';

class StatusCard extends StatelessWidget {
  final String status;
  final VoidCallback onMarkFull;
  final VoidCallback? onRequestPickup; // Make this optional

  const StatusCard({
    super.key,
    required this.status,
    required this.onMarkFull,
    this.onRequestPickup,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    String? secondaryText;
    String buttonText;
    VoidCallback? buttonAction;

    switch (status) {
      case 'empty':
        statusColor = AppColors.textMedium;
        statusText = 'Empty';
        buttonText = 'Mark as Full';
        buttonAction = onMarkFull;
        break;
      case 'full':
        statusColor = AppColors.danger;
        statusText = 'Full - Needs Collection';
        buttonText = 'Request Pickup';
        buttonAction = onRequestPickup;
        break;
      case 'pending':
        statusColor = AppColors.accent;
        statusText = 'Pickup Scheduled';
        secondaryText = 'Collector ETA: 15 min';
        buttonText = '';
        break;
      default:
        statusColor = AppColors.textMedium;
        statusText = 'Empty';
        buttonText = 'Mark as Full';
        buttonAction = onMarkFull;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bin Status: $statusText',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (secondaryText != null)
                  Text(
                    secondaryText!,
                    style: TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          if (buttonText.isNotEmpty && buttonAction != null)
            ElevatedButton(
              onPressed: buttonAction,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    status == 'full' ? AppColors.accent : AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
