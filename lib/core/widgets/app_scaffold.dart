import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/auth_notifier.dart';
import '../../features/role/domain/role.dart';
import '../../features/settings/presentation/settings_notifier.dart';
import '../../features/society/presentation/active_society_provider.dart';
import '../animations/app_animations.dart';
import '../constants/app_constants.dart';
import '../constants/route_constants.dart';
import '../theme/app_colors.dart';
import 'confirm_dialog.dart';
import 'responsive_layout.dart';
import 'society_logo_widget.dart';
import 'status_badge.dart';

class NavItem {
  final String title;
  final String? shortTitle;
  final String category;
  final IconData icon;
  final IconData activeIcon;
  final String routePath;
  final Permission? requiredPermission;

  const NavItem({
    required this.title,
    this.shortTitle,
    required this.category,
    required this.icon,
    required this.activeIcon,
    required this.routePath,
    this.requiredPermission,
  });
}

const List<NavItem> appNavItems = [
  NavItem(
    title: 'Dashboard',
    category: 'OVERVIEW',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
    routePath: RouteConstants.dashboardPath,
    requiredPermission: Permission.viewDashboard,
  ),
  NavItem(
    title: 'Towers',
    category: 'INFRASTRUCTURE',
    icon: Icons.domain_outlined,
    activeIcon: Icons.domain_rounded,
    routePath: RouteConstants.towersPath,
    requiredPermission: Permission.viewTowers,
  ),
  NavItem(
    title: 'Floors',
    category: 'INFRASTRUCTURE',
    icon: Icons.layers_outlined,
    activeIcon: Icons.layers_rounded,
    routePath: RouteConstants.floorsPath,
    requiredPermission: Permission.viewFloors,
  ),
  NavItem(
    title: 'Flat Inventory',
    shortTitle: 'Flats',
    category: 'INFRASTRUCTURE',
    icon: Icons.meeting_room_rounded,
    activeIcon: Icons.meeting_room_rounded,
    routePath: RouteConstants.flatsPath,
    requiredPermission: Permission.viewFlats,
  ),
  NavItem(
    title: 'All Societies',
    category: 'ORGANIZATION',
    icon: Icons.domain_add_rounded,
    activeIcon: Icons.domain_add_rounded,
    routePath: RouteConstants.societiesPath,
    requiredPermission: Permission.manageAllSocieties,
  ),
  NavItem(
    title: 'Society Profile',
    category: 'ORGANIZATION',
    icon: Icons.apartment_outlined,
    activeIcon: Icons.apartment_rounded,
    routePath: RouteConstants.societyProfilePath,
    requiredPermission: Permission.viewSociety,
  ),
  NavItem(
    title: 'My Profile',
    category: 'PREFERENCES',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    routePath: RouteConstants.profilePath,
    requiredPermission: Permission.editOwnProfile,
  ),
  NavItem(
    title: 'Settings',
    category: 'PREFERENCES',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
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

  // --- Desktop Shell with Global Top Bar and Categorized Sidebar ---
  Widget _buildDesktopScaffold(
    BuildContext context,
    WidgetRef ref,
    List<NavItem> items,
  ) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final authState = ref.watch(authNotifierProvider);
    final activeSociety = ref.watch(activeSocietyProvider).activeSociety;
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Group items by category
    final categories = <String, List<NavItem>>{};
    for (final item in items) {
      categories.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                right: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Column(
              children: [
                // Branded Header with Society Logo & Dynamic Active Society Name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      SocietyLogoWidget(
                        logoUrl: activeSociety?.logoUrl,
                        societyName: activeSociety?.name ?? AppConstants.appName,
                        size: 42,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeSociety?.name ?? AppConstants.appName,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: -0.3,
                                color: isDark ? AppColors.slate50 : AppColors.slate900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const PulsingStatusDot(color: AppColors.primary, size: 6),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    activeSociety != null ? 'Active Society' : 'Platform Hub',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.slate500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                const SizedBox(height: 10),

                // Grouped Categorized Navigation
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    children: categories.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 12, bottom: 6),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppColors.slate500,
                              ),
                            ),
                          ),
                          ...entry.value.map((item) {
                            final isSelected = currentRoute.startsWith(item.routePath);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: _SidebarNavItem(
                                title: item.title,
                                icon: item.icon,
                                activeIcon: item.activeIcon,
                                isSelected: isSelected,
                                onTap: () {
                                  if (!isSelected) {
                                    context.go(item.routePath);
                                  }
                                },
                              ),
                            );
                          }),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                // User Profile & Role Footer
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                if (user != null)
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDarkCard : AppColors.slate100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
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
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isDark ? AppColors.slate100 : AppColors.slate900,
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
                          icon: Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: isDark ? AppColors.slate400 : AppColors.slate600,
                          ),
                          tooltip: 'Sign Out',
                          onPressed: () => _handleLogout(context, ref),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Right Area: Global Executive Top Bar + Main Content Canvas
          Expanded(
            child: Column(
              children: [
                _buildGlobalTopBar(context, ref, currentRoute, user, isDark),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Global Executive Top Bar ---
  Widget _buildGlobalTopBar(
    BuildContext context,
    WidgetRef ref,
    String currentRoute,
    dynamic user,
    bool isDark,
  ) {
    String pageTitle = 'Dashboard';
    String sectionCategory = 'Overview';

    for (final item in appNavItems) {
      if (currentRoute.startsWith(item.routePath)) {
        pageTitle = item.title;
        sectionCategory = item.category;
        break;
      }
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          // Breadcrumbs
          Text(
            sectionCategory,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.slate500,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.slate400),
          const SizedBox(width: 8),
          Text(
            pageTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.slate100 : AppColors.slate900,
            ),
          ),

          const Spacer(),

          // Active Society Switcher Dropdown
          _buildSocietySwitcher(context, ref, isDark),
          const SizedBox(width: 14),

          // Theme Mode Toggle (Sun / Moon)
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 20,
              color: isDark ? AppColors.gold : AppColors.slate600,
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              ref.read(settingsNotifierProvider.notifier).setThemeMode(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  );
            },
          ),
          const SizedBox(width: 6),

          // Notification Bell
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: isDark ? AppColors.slate300 : AppColors.slate600,
                ),
                tooltip: 'Notifications',
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Reusable Active Society Switcher ---
  Widget _buildSocietySwitcher(
    BuildContext context,
    WidgetRef ref,
    bool isDark, {
    bool isMobile = false,
  }) {
    return Consumer(
      builder: (context, ref, _) {
        final activeSocietyState = ref.watch(activeSocietyProvider);
        final activeSociety = activeSocietyState.activeSociety;
        final allSocieties = activeSocietyState.allSocieties;
        final authState = ref.watch(authNotifierProvider);
        final isSuperAdmin = RolePermissions.hasPermission(
          authState.role,
          Permission.manageAllSocieties,
        );

        return PopupMenuButton<String>(
          tooltip: 'Switch Active Society',
          offset: const Offset(0, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (societyId) {
            if (societyId == '__new__') {
              context.go(RouteConstants.societiesPath);
            } else {
              ref.read(activeSocietyProvider.notifier).selectSociety(societyId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Switched to ${activeSocietyState.allSocieties.firstWhere((s) => s.id == societyId).name}',
                  ),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          itemBuilder: (context) {
            return [
              const PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  'SWITCH ACTIVE SOCIETY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate400,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              ...allSocieties.map((s) {
                final isCurrent = s.id == activeSociety?.id;
                return PopupMenuItem<String>(
                  value: s.id,
                  child: Row(
                    children: [
                      SocietyLogoWidget(
                        logoUrl: s.logoUrl,
                        societyName: s.name,
                        size: 20,
                        borderRadius: 5,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s.name,
                          style: TextStyle(
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                            color: isCurrent ? AppColors.primary : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrent)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                );
              }),
              if (isSuperAdmin) ...[
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: '__new__',
                  child: Row(
                    children: [
                      Icon(Icons.add_business_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text(
                        'Manage / Add Societies...',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ];
          },
          child: Container(
            padding: isMobile
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDarkCard : (isMobile ? AppColors.slate100 : AppColors.primaryLight),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
              border: Border.all(
                color: isDark ? AppColors.borderDark : (isMobile ? AppColors.borderLight : AppColors.primary.withValues(alpha: 0.3)),
              ),
            ),
            child: Row(
              mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
              children: [
                const PulsingStatusDot(color: AppColors.primary, size: 6),
                const SizedBox(width: 8),
                if (isMobile)
                  Expanded(
                    child: Text(
                      activeSociety?.name ?? 'Select Society',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.slate200 : AppColors.primaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  Text(
                    activeSociety?.name ?? 'Select Society',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.slate200 : AppColors.primaryDark,
                    ),
                  ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 18,
                  color: isDark ? AppColors.slate400 : AppColors.primaryDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Mobile Drawer with Full Feature Parity to Desktop Sidebar ---
  Widget _buildMobileDrawer(
    BuildContext context,
    WidgetRef ref,
    List<NavItem> items,
    String currentRoute,
    bool isDark,
  ) {
    final authState = ref.watch(authNotifierProvider);
    final activeSociety = ref.watch(activeSocietyProvider).activeSociety;
    final user = authState.user;

    // Group items by category (Overview, Infrastructure, Organization, Preferences)
    final categories = <String, List<NavItem>>{};
    for (final item in items) {
      categories.putIfAbsent(item.category, () => []).add(item);
    }

    return Drawer(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: SafeArea(
        child: Column(
          children: [
            // Branded Drawer Header with Dynamic Society Logo
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
              child: Row(
                children: [
                  SocietyLogoWidget(
                    logoUrl: activeSociety?.logoUrl,
                    societyName: activeSociety?.name ?? AppConstants.appName,
                    size: 38,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeSociety?.name ?? AppConstants.appName,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: -0.3,
                            color: isDark ? AppColors.slate50 : AppColors.slate900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const PulsingStatusDot(color: AppColors.primary, size: 6),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                activeSociety != null ? 'Active Society' : 'Platform Hub',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.slate500,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Close Menu',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),

            // Active Society Switcher Section in Drawer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      'ACTIVE SOCIETY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.slate500,
                      ),
                    ),
                  ),
                  _buildSocietySwitcher(context, ref, isDark, isMobile: true),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),

            // All Categorized Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                children: categories.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 12, bottom: 6),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.slate500,
                          ),
                        ),
                      ),
                      ...entry.value.map((item) {
                        final isSelected = currentRoute.startsWith(item.routePath);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: _SidebarNavItem(
                            title: item.title,
                            icon: item.icon,
                            activeIcon: item.activeIcon,
                            isSelected: isSelected,
                            onTap: () {
                              Navigator.of(context).pop(); // Close drawer
                              if (!isSelected) {
                                context.go(item.routePath);
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),

            // User Profile Card & Full Sign Out Button
            Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
            if (user != null)
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDarkCard : AppColors.slate100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
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
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isDark ? AppColors.slate100 : AppColors.slate900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              StatusBadge.forRole(user.role.code),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 16),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close drawer
                          _handleLogout(context, ref);
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Mobile Shell with Header & Bottom Navigation ---
  Widget _buildMobileScaffold(
    BuildContext context,
    WidgetRef ref,
    List<NavItem> items,
  ) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final authState = ref.watch(authNotifierProvider);
    final activeSociety = ref.watch(activeSocietyProvider).activeSociety;
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bottomBarItems = items.take(4).toList();
    final activeBottomIndex = bottomBarItems.indexWhere(
      (i) =>
          currentRoute == i.routePath ||
          (i.routePath != RouteConstants.dashboardPath && currentRoute.startsWith(i.routePath)),
    );
    final isBottomActive = activeBottomIndex != -1;
    final currentIndex = isBottomActive ? activeBottomIndex : 0;

    return Scaffold(
      drawer: _buildMobileDrawer(context, ref, items, currentRoute, isDark),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Open Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            SocietyLogoWidget(
              logoUrl: activeSociety?.logoUrl,
              societyName: activeSociety?.name ?? AppConstants.appName,
              size: 28,
              borderRadius: 7,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                activeSociety?.name ?? AppConstants.appName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.slate50 : AppColors.slate900,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Theme Toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 20,
              color: isDark ? AppColors.gold : AppColors.slate600,
            ),
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
            onPressed: () {
              ref.read(settingsNotifierProvider.notifier).setThemeMode(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  );
            },
          ),
          // User Avatar / Quick Profile & Logout
          if (user != null)
            PopupMenuButton<String>(
              tooltip: 'Account Menu',
              offset: const Offset(0, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (value) {
                if (value == 'profile') {
                  context.go(RouteConstants.profilePath);
                } else if (value == 'settings') {
                  context.go(RouteConstants.settingsPath);
                } else if (value == 'logout') {
                  _handleLogout(context, ref);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark ? AppColors.slate100 : AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      StatusBadge.forRole(user.role.code),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person_rounded, size: 18),
                      SizedBox(width: 10),
                      Text('My Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_rounded, size: 18),
                      SizedBox(width: 10),
                      Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                      SizedBox(width: 10),
                      Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: isBottomActive
                  ? AppColors.primary
                  : (isDark ? AppColors.slate400 : AppColors.slate500),
              unselectedItemColor: isDark ? AppColors.slate400 : AppColors.slate500,
              selectedFontSize: 11.5,
              unselectedFontSize: 11.5,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                height: 1.35,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
                height: 1.35,
              ),
              elevation: 0,
              iconSize: 24,
              onTap: (index) {
                if (index < bottomBarItems.length) {
                  context.go(bottomBarItems[index].routePath);
                }
              },
              items: bottomBarItems.map((item) {
                final label = item.shortTitle ?? item.title;
                return BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Icon(item.icon, size: 24),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Icon(item.activeIcon, size: 24),
                  ),
                  label: label,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // --- Shared Logout Handler with Confirmation Dialog ---
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmLabel: 'Sign Out',
      isDestructive: true,
    );
    if (confirm && context.mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) {
        context.go(RouteConstants.loginPath);
      }
    }
  }
}

class _SidebarNavItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    BoxDecoration decoration;
    Color iconColor;
    Color textColor;

    if (widget.isSelected) {
      decoration = BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );
      iconColor = AppColors.white;
      textColor = AppColors.white;
    } else {
      decoration = BoxDecoration(
        color: _isHovered
            ? (isDark ? AppColors.surfaceDarkHigher : AppColors.slate100)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      );
      iconColor = _isHovered
          ? (isDark ? AppColors.slate100 : AppColors.slate900)
          : (isDark ? AppColors.slate400 : AppColors.slate600);
      textColor = _isHovered
          ? (isDark ? AppColors.slate100 : AppColors.slate900)
          : (isDark ? AppColors.slate300 : AppColors.slate700);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: decoration,
          child: Row(
            children: [
              Icon(
                widget.isSelected ? widget.activeIcon : widget.icon,
                color: iconColor,
                size: 19,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                    fontSize: 13,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
