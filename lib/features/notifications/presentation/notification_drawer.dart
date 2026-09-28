import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../domain/notification_item.dart';
import 'notification_provider.dart';

class NotificationDrawer extends ConsumerStatefulWidget {
  const NotificationDrawer({super.key});

  @override
  ConsumerState<NotificationDrawer> createState() => _NotificationDrawerState();
}

class _NotificationDrawerState extends ConsumerState<NotificationDrawer> {
  bool _filterOnlyUnread = false;

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredItems = _filterOnlyUnread
        ? notifState.items.where((n) => !n.isRead).toList()
        : notifState.items;

    return Drawer(
      width: (MediaQuery.sizeOf(context).width * 0.85).clamp(320.0, 420.0),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          notifState.unreadCount > 0
                              ? '${notifState.unreadCount} unread update${notifState.unreadCount > 1 ? 's' : ''}'
                              : 'All caught up',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.slate400 : AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Filter Tabs & Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All', style: TextStyle(fontSize: 12)),
                    selected: !_filterOnlyUnread,
                    onSelected: (val) => setState(() => _filterOnlyUnread = false),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Unread', style: TextStyle(fontSize: 12)),
                        if (notifState.unreadCount > 0) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${notifState.unreadCount}',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    selected: _filterOnlyUnread,
                    onSelected: (val) => setState(() => _filterOnlyUnread = true),
                    visualDensity: VisualDensity.compact,
                  ),
                  const Spacer(),
                  if (notifState.unreadCount > 0)
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () => ref.read(notificationNotifierProvider.notifier).markAllAsRead(),
                      child: const Text('Mark all read', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Notification List
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 48,
                              color: isDark ? AppColors.slate600 : AppColors.slate400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _filterOnlyUnread ? 'No unread notifications' : 'No notifications yet',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'System events, inventory and society updates will appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.slate400 : AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _NotificationCard(
                          item: item,
                          onTap: () {
                            if (!item.isRead) {
                              ref.read(notificationNotifierProvider.notifier).markAsRead(item.id);
                            }
                          },
                          onDismiss: () {
                            ref.read(notificationNotifierProvider.notifier).removeNotification(item.id);
                          },
                        );
                      },
                    ),
            ),

            if (notifState.items.isNotEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${notifState.items.length} total updates',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.slate400 : AppColors.slate500,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => ref.read(notificationNotifierProvider.notifier).clearAll(),
                      child: const Text('Clear all', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: !item.isRead
            ? (isDark ? AppColors.primary.withValues(alpha: 0.08) : AppColors.primaryLight.withValues(alpha: 0.5))
            : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 18, color: item.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
                            color: isDark ? AppColors.slate100 : AppColors.slate900,
                          ),
                        ),
                      ),
                      if (!item.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.slate300 : AppColors.slate600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.formatDateTime(item.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.slate500 : AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 14),
              color: isDark ? AppColors.slate500 : AppColors.slate400,
              tooltip: 'Dismiss',
              visualDensity: VisualDensity.compact,
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
