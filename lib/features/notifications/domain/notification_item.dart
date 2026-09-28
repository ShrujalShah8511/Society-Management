import 'package:flutter/material.dart';

enum NotificationType {
  announcement,
  inventory,
  security,
  user,
  system,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? actionRoute;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.type = NotificationType.system,
    this.isRead = false,
    this.actionRoute,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? actionRoute,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.announcement:
        return Icons.campaign_rounded;
      case NotificationType.inventory:
        return Icons.apartment_rounded;
      case NotificationType.security:
        return Icons.shield_rounded;
      case NotificationType.user:
        return Icons.person_add_rounded;
      case NotificationType.system:
        return Icons.info_outline_rounded;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.announcement:
        return const Color(0xFFF59E0B);
      case NotificationType.inventory:
        return const Color(0xFF2563EB);
      case NotificationType.security:
        return const Color(0xFFDC2626);
      case NotificationType.user:
        return const Color(0xFF10B981);
      case NotificationType.system:
        return const Color(0xFF6B7280);
    }
  }
}
