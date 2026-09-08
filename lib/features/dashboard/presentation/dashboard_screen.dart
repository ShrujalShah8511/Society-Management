import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_badge.dart';
import '../../authentication/presentation/auth_notifier.dart';
import '../../role/domain/role.dart';
import '../../society/presentation/society_profile_notifier.dart';
import 'dashboard_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(dashboardNotifierProvider);
    final societyState = ref.watch(societyProfileNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final userRole = authState.role;
    final canManage = RolePermissions.canManageSociety(userRole);

    if (dashState.isLoading && dashState.stats == null) {
      return const LoadingView(message: 'Loading society dashboard...');
    }

    if (dashState.errorMessage != null && dashState.stats == null) {
      return ErrorRetryView(
        message: dashState.errorMessage!,
        onRetry: () => ref.read(dashboardNotifierProvider.notifier).loadStats(),
      );
    }

    final stats = dashState.stats;
    final society = societyState.society;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh metrics',
            onPressed: () {
              ref.read(dashboardNotifierProvider.notifier).loadStats();
              ref.read(societyProfileNotifierProvider.notifier).loadProfile();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Society Summary Banner
            Card(
              color: AppColors.slate900,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.apartment, color: AppColors.white, size: 30),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                society?.name ?? user?.societyName ?? 'Society Administration',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              StatusBadge.forRole(userRole.code),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${society?.city ?? "Mumbai"}, ${society?.state ?? "Maharashtra"} • Reg: ${society?.registrationNumber ?? "Active"}',
                            style: const TextStyle(fontSize: 13, color: AppColors.slate400),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Statistics Metrics Grid
            Text(
              'Phase 1 Inventory Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1100
                    ? 5
                    : (constraints.maxWidth > 700 ? 3 : 2);

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      context,
                      title: 'Total Towers',
                      value: '${stats?.totalTowers ?? 0}',
                      icon: Icons.apartment,
                      color: AppColors.primary,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Total Floors',
                      value: '${stats?.totalFloors ?? 0}',
                      icon: Icons.layers,
                      color: AppColors.secondary,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Total Flats',
                      value: '${stats?.totalFlats ?? 0}',
                      icon: Icons.door_front_door_outlined,
                      color: AppColors.infoDark,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Occupied Flats',
                      value: '${stats?.occupiedFlats ?? 0}',
                      icon: Icons.how_to_reg_outlined,
                      color: AppColors.success,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Vacant Flats',
                      value: '${stats?.vacantFlats ?? 0}',
                      icon: Icons.meeting_room_outlined,
                      color: AppColors.warningDark,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Occupancy Ratio Visual Card
            if (stats != null && stats.totalFlats > 0) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Occupancy Distribution',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${stats.occupancyRate.toStringAsFixed(1)}% Occupancy Rate',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            if (stats.occupiedFlats > 0)
                              Expanded(
                                flex: stats.occupiedFlats,
                                child: Container(
                                  height: 14,
                                  color: AppColors.success,
                                ),
                              ),
                            if (stats.vacantFlats > 0)
                              Expanded(
                                flex: stats.vacantFlats,
                                child: Container(
                                  height: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            if (stats.underMaintenanceFlats > 0)
                              Expanded(
                                flex: stats.underMaintenanceFlats,
                                child: Container(
                                  height: 14,
                                  color: AppColors.warning,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _buildLegendItem('Occupied (${stats.occupiedFlats})', AppColors.success),
                          const SizedBox(width: 20),
                          _buildLegendItem('Vacant (${stats.vacantFlats})', AppColors.primary),
                          const SizedBox(width: 20),
                          _buildLegendItem('Maintenance (${stats.underMaintenanceFlats})', AppColors.warning),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],

            // Quick Actions Section
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildActionCard(
                  context,
                  title: 'Manage Towers',
                  description: 'Add, view, and organize building towers',
                  icon: Icons.apartment,
                  onTap: () => context.go(RouteConstants.towersPath),
                ),
                _buildActionCard(
                  context,
                  title: 'Configure Floors',
                  description: 'Manage floor levels for each tower',
                  icon: Icons.layers,
                  onTap: () => context.go(RouteConstants.floorsPath),
                ),
                _buildActionCard(
                  context,
                  title: 'Flat Inventory',
                  description: 'Filter, search, and update flat occupancy',
                  icon: Icons.meeting_room,
                  onTap: () => context.go(RouteConstants.flatsPath),
                ),
                _buildActionCard(
                  context,
                  title: 'Society Profile',
                  description: 'View and update legal society registration',
                  icon: Icons.info_outline,
                  onTap: () => context.go(RouteConstants.societyProfilePath),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.slate600),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 250,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
