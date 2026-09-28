import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/notification_item.dart';

class NotificationState {
  final List<NotificationItem> items;
  final bool isLoading;

  const NotificationState({
    this.items = const [],
    this.isLoading = false,
  });

  int get unreadCount => items.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<NotificationItem>? items,
    bool? isLoading,
  }) {
    return NotificationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState()) {
    _seedInitialNotifications();
  }

  void _seedInitialNotifications() {
    final now = DateTime.now();
    state = NotificationState(
      items: [
        NotificationItem(
          id: 'notif-1',
          title: 'Society Maintenance Scheduled',
          message: 'Elevator regular safety audit will occur this Wednesday between 10 AM to 2 PM.',
          timestamp: now.subtract(const Duration(minutes: 25)),
          type: NotificationType.announcement,
          isRead: false,
        ),
        NotificationItem(
          id: 'notif-2',
          title: 'Tower Provisioning Completed',
          message: 'Tower B inventory generated and initialized with standard units.',
          timestamp: now.subtract(const Duration(hours: 2)),
          type: NotificationType.inventory,
          isRead: false,
        ),
        NotificationItem(
          id: 'notif-3',
          title: 'Security Gate System Synchronized',
          message: 'Gate pass logs verified and automated backup completed successfully.',
          timestamp: now.subtract(const Duration(hours: 5)),
          type: NotificationType.security,
          isRead: true,
        ),
        NotificationItem(
          id: 'notif-4',
          title: 'Welcome to Society Management',
          message: 'All system modules, analytics and cloud services are operational.',
          timestamp: now.subtract(const Duration(days: 1)),
          type: NotificationType.system,
          isRead: true,
        ),
      ],
    );
  }

  void addNotification(NotificationItem item) {
    state = state.copyWith(items: [item, ...state.items]);
  }

  void markAsRead(String id) {
    state = state.copyWith(
      items: state.items.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );
  }

  void markAllAsRead() {
    state = state.copyWith(
      items: state.items.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }

  void removeNotification(String id) {
    state = state.copyWith(
      items: state.items.where((n) => n.id != id).toList(),
    );
  }

  void clearAll() {
    state = state.copyWith(items: []);
  }
}

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
