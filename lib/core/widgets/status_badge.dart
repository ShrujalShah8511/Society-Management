import 'package:flutter/material.dart';
import '../animations/app_animations.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final IconData? icon;
  final bool showPulse;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.icon,
    this.showPulse = false,
  });

  factory StatusBadge.fromStatus(String status) {
    final normalized = status.toUpperCase();
    switch (normalized) {
      case 'OCCUPIED':
      case 'ACTIVE':
        return StatusBadge(
          label: Formatters.formatEnumString(status),
          backgroundColor: AppColors.success.withValues(alpha: 0.14),
          textColor: AppColors.success,
          borderColor: AppColors.success.withValues(alpha: 0.35),
          showPulse: true,
        );
      case 'VACANT':
        return StatusBadge(
          label: Formatters.formatEnumString(status),
          backgroundColor: AppColors.secondary.withValues(alpha: 0.14),
          textColor: AppColors.secondary,
          borderColor: AppColors.secondary.withValues(alpha: 0.35),
          icon: Icons.meeting_room_rounded,
          showPulse: true,
        );
      case 'UNDER_MAINTENANCE':
        return StatusBadge(
          label: 'Under Maintenance',
          backgroundColor: AppColors.warning.withValues(alpha: 0.14),
          textColor: AppColors.warningDark,
          borderColor: AppColors.warning.withValues(alpha: 0.35),
          icon: Icons.build_outlined,
          showPulse: true,
        );
      case 'INACTIVE':
        return StatusBadge(
          label: 'Inactive',
          backgroundColor: AppColors.error.withValues(alpha: 0.14),
          textColor: AppColors.error,
          borderColor: AppColors.error.withValues(alpha: 0.35),
          icon: Icons.cancel_outlined,
        );
      default:
        return StatusBadge(
          label: Formatters.formatEnumString(status),
          backgroundColor: AppColors.slate100,
          textColor: AppColors.slate700,
          borderColor: AppColors.slate300,
        );
    }
  }

  factory StatusBadge.forRole(String role) {
    final normalized = role.toUpperCase();
    Color bg = AppColors.primary.withValues(alpha: 0.14);
    Color text = AppColors.primary;
    Color border = AppColors.primary.withValues(alpha: 0.35);
    IconData icon = Icons.shield_outlined;

    if (normalized.contains('SUPER')) {
      bg = AppColors.gold.withValues(alpha: 0.14);
      text = AppColors.goldDark;
      border = AppColors.gold.withValues(alpha: 0.35);
      icon = Icons.verified_user_outlined;
    } else if (normalized.contains('ADMIN')) {
      bg = AppColors.primary.withValues(alpha: 0.14);
      text = AppColors.primary;
      border = AppColors.primary.withValues(alpha: 0.35);
      icon = Icons.admin_panel_settings_outlined;
    } else if (normalized.contains('SECURITY')) {
      bg = AppColors.secondary.withValues(alpha: 0.14);
      text = AppColors.secondary;
      border = AppColors.secondary.withValues(alpha: 0.35);
      icon = Icons.local_police_outlined;
    } else if (normalized.contains('RESIDENT')) {
      bg = AppColors.secondary.withValues(alpha: 0.14);
      text = AppColors.secondary;
      border = AppColors.secondary.withValues(alpha: 0.35);
      icon = Icons.home_outlined;
    }

    return StatusBadge(
      label: Formatters.formatEnumString(role),
      backgroundColor: bg,
      textColor: text,
      borderColor: border,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? textColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPulse) ...[
            PulsingStatusDot(color: textColor, size: 7),
            const SizedBox(width: 6),
          ] else if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
