import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadge.fromStatus(String status) {
    final normalized = status.toUpperCase();
    switch (normalized) {
      case 'OCCUPIED':
      case 'ACTIVE':
        return StatusBadge(
          label: Formatters.formatEnumString(status),
          backgroundColor: AppColors.successLight,
          textColor: AppColors.successDark,
          icon: Icons.check_circle_outline,
        );
      case 'VACANT':
        return StatusBadge(
          label: Formatters.formatEnumString(status),
          backgroundColor: AppColors.infoLight,
          textColor: AppColors.primaryDark,
          icon: Icons.meeting_room_outlined,
        );
      case 'UNDER_MAINTENANCE':
        return StatusBadge(
          label: 'Under Maintenance',
          backgroundColor: AppColors.warningLight,
          textColor: AppColors.warningDark,
          icon: Icons.build_outlined,
        );
      case 'INACTIVE':
        return StatusBadge(
          label: 'Inactive',
          backgroundColor: AppColors.errorLight,
          textColor: AppColors.errorDark,
          icon: Icons.cancel_outlined,
        );
      default:
        return StatusBadge(
          label: Formatters.formatEnumString(status),
          backgroundColor: AppColors.slate100,
          textColor: AppColors.slate700,
        );
    }
  }

  factory StatusBadge.forRole(String role) {
    return StatusBadge(
      label: Formatters.formatEnumString(role),
      backgroundColor: AppColors.primaryLight,
      textColor: AppColors.primaryDark,
      icon: Icons.shield_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
