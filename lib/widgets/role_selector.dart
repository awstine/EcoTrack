import 'package:flutter/material.dart';
import '../utils/colors.dart';

class RoleSelector extends StatefulWidget {
  final Function(String) onRoleSelected;
  final String initialRole;

  const RoleSelector({
    super.key,
    required this.onRoleSelected,
    required this.initialRole,
  });

  @override
  State<RoleSelector> createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<RoleSelector> {
  late String selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.initialRole;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Role',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRoleOption(
              icon: Icons.delete_outline,
              label: 'Generator',
              value: 'generator',
            ),
            const SizedBox(width: 8),
            _buildRoleOption(
              icon: Icons.local_shipping,
              label: 'Collector',
              value: 'collector',
            ),
            const SizedBox(width: 8),
            _buildRoleOption(
              icon: Icons.recycling,
              label: 'Reuser',
              value: 'reuser',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleOption({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRole = value;
          });
          widget.onRoleSelected(value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selectedRole == value
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            border: Border.all(
              color: selectedRole == value
                  ? AppColors.primary
                  : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selectedRole == value
                    ? AppColors.primary
                    : AppColors.textMedium,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selectedRole == value
                      ? AppColors.primary
                      : AppColors.textMedium,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
