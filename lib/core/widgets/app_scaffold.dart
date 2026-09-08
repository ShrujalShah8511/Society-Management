import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/auth_notifier.dart';
import '../../features/role/domain/role.dart';
import '../constants/app_constants.dart';
import '../constants/route_constants.dart';
import '../theme/app_colors.dart';
import 'confirm_dialog.dart';
import 'responsive_layout.dart';
import 'status_badge.dart';

class NavItem {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final String routePath;
  final Permission? requiredPermission;

  const NavItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.routePath,
    this.requiredPermission,
  });
}

const List<NavItem> appNavItems = [
  NavItem(
    title: 'Dashboard',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
    routePath: RouteConstants.dashboardPath,
    requiredPermission: Permission.viewDashboard,
  ),
  NavItem(
    title: 'Society Profile',
    icon: Icons.apartment_outlined,
    activeIcon: Icons.apartment,
    routePath: RouteConstants.societyProfilePath,
    requiredPermission: Permission.viewSociety,
  ),
  NavItem(
    title: 'Towers',
    icon: Icons.domain_outlined,
    activeIcon: Icons.domain,
    routePath: RouteConstants.towersPath,
    requiredPermission: Permission.viewTowers,
  ),
  NavItem(
    title: 'Floors',
    icon: Icons.layers_outlined,
    activeIcon: Icons.layers,
    routePath: RouteConstants.floorsPath,
    requiredPermission: Permission.viewFloors,
  ),
  NavItem(
    title: 'Flats',
    icon: Icons.meeting_room_outlined,
    activeIcon: Icons.meeting_room,
    routePath: RouteConstants.flatsPath,
    requiredPermission: Permission.viewFlats,
  ),
  NavItem(
    title: 'My Profile',
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    routePath: RouteConstants.profilePath,
    requiredPermission: Permission.editOwnProfile,
  ),
  NavItem(
    title: 'Settings',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
    routePath: RouteConstants.settingsPath,
    requiredPermission: Permission.manageSettings,
  ),
];

class AppScaffold extends ConsumerWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userRole = authState.role;

    final visibleNavItems = appNavItems.where((item) {
      if (item.requiredPermission == null) return true;
      return RolePermissions.hasPermission(userRole, item.requiredPermission!);
    }).toList();

    return ResponsiveLayout(
      mobile: (context) => _buildMobileScaffold(context, ref, visibleNavItems),
      desktop: (context) => _buildDesktopScaffold(context, ref, visibleNavItems),
    );
  }

  // --- Desktop Shell with Persistent Sidebar ---
  Widget _buildDesktopScaffold(
    BuildContext context,
    WidgetRef ref,
    List<NavItem> items,
  ) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              border: Border(
                right: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Column(
              children: [
                // Society Brand Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.apartment, color: AppColors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.appName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Phase 1 System',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.slate500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = currentRoute.startsWith(item.routePath);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: isSelected
                              ? AppColors.primaryLight.withOpacity(0.5)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          child: ListTile(
                            dense: true,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            leading: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected ? AppColors.primary : AppColors.slate600,
                              size: 20,
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? AppColors.primaryDark : AppColors.slate800,
                                fontSize: 14,
                              ),
                            ),
                            onTap: () {
                              if (!isSelected) {
                                context.go(item.routePath);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // User Profile & Role Footer
                const Divider(height: 1),
                if (user != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  StatusBadge.forRole(user.role.code),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout, size: 18, color: AppColors.slate400),
                              tooltip: 'Sign Out',
                              onPressed: () async {
                                final confirm = await ConfirmDialog.show(
                                  context: context,
                                  title: 'Sign Out',
                                  message: 'Are you sure you want to sign out?',
                                  confirmLabel: 'Sign Out',
                                  isDestructive: true,
                                );
                                if (confirm && context.mounted) {
                                  await ref.read(authNotifierProvider.notifier).logout();
                                  context.go(RouteConstants.loginPath);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Main Canvas
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  // --- Mobile Shell with Bottom Navigation ---
  Widget _buildMobileScaffold(
    BuildContext context,
    WidgetRef ref,
    List<NavItem> items,
  ) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    int currentIndex = items.indexWhere((i) => currentRoute.startsWith(i.routePath));
    if (currentIndex == -1) currentIndex = 0;

    // Keep primary 4 items for bottom bar
    final bottomBarItems = items.take(4).toList();
    if (currentIndex >= 4) {
      // If navigating to profile or settings, map accordingly
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex < 4 ? currentIndex : 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.slate500,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          if (index < bottomBarItems.length) {
            context.go(bottomBarItems[index].routePath);
          }
        },
        items: bottomBarItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.activeIcon),
            label: item.title,
          );
        }).toList(),
      ),
    );
  }
}
