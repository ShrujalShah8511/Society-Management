import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_badge.dart';
import '../../authentication/presentation/auth_notifier.dart';
import '../../society/presentation/society_profile_notifier.dart';
import 'dashboard_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final society = ref.watch(societyProfileNotifierProvider).society;
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final userRole = authState.role;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (dashboardState.isLoading) {
      return const Scaffold(
        body: LoadingView(message: 'Loading executive cockpit...'),
      );
    }

    if (dashboardState.errorMessage != null && dashboardState.stats == null) {
      return Scaffold(
        body: ErrorRetryView(
          message: dashboardState.errorMessage!,
          onRetry: () => ref.read(dashboardNotifierProvider.notifier).loadStats(),
        ),
      );
    }

    final stats = dashboardState.stats;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(dashboardNotifierProvider.notifier).loadStats();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Executive Cockpit Header
              _buildExecutiveHeader(context, user, society, isDark),
              const SizedBox(height: 24),

              // Top Key Metrics Ribbon (5 Stat Cards)
              LayoutBuilder(
                builder: (context, constraints) {
                  final double cardWidth = constraints.maxWidth > 1100
                      ? (constraints.maxWidth - (16 * 4)) / 5
                      : (constraints.maxWidth > 750 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth);

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _buildStatCard(
                          context,
                          title: 'Total Towers',
                          value: stats?.totalTowers ?? 0,
                          icon: Icons.apartment_rounded,
                          color: AppColors.primary,
                          gradient: AppGradients.primary,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildStatCard(
                          context,
                          title: 'Total Floors',
                          value: stats?.totalFloors ?? 0,
                          icon: Icons.layers_rounded,
                          color: AppColors.secondary,
                          gradient: AppGradients.accentCyan,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildStatCard(
                          context,
                          title: 'Total Flats',
                          value: stats?.totalFlats ?? 0,
                          icon: Icons.door_front_door_outlined,
                          color: AppColors.gold,
                          gradient: AppGradients.accentAmber,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildStatCard(
                          context,
                          title: 'Occupied Flats',
                          value: stats?.occupiedFlats ?? 0,
                          icon: Icons.how_to_reg_rounded,
                          color: AppColors.primary,
                          gradient: AppGradients.primary,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildStatCard(
                          context,
                          title: 'Vacant Flats',
                          value: stats?.vacantFlats ?? 0,
                          icon: Icons.meeting_room_outlined,
                          color: AppColors.secondary,
                          gradient: AppGradients.accentCyan,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Two-Column Cockpit Workspace
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 960;

                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column (63% width)
                        Expanded(
                          flex: 63,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOccupancyCard(stats, isDark),
                              const SizedBox(height: 24),
                              _buildQuickActionsSection(context, isDark),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Column (37% width)
                        Expanded(
                          flex: 37,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSocietyInfoCard(society, isDark),
                              const SizedBox(height: 24),
                              _buildSystemStatusCard(userRole, isDark),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Single-Column Mobile/Tablet Stack
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOccupancyCard(stats, isDark),
                      const SizedBox(height: 24),
                      _buildQuickActionsSection(context, isDark),
                      const SizedBox(height: 24),
                      _buildSocietyInfoCard(society, isDark),
                      const SizedBox(height: 24),
                      _buildSystemStatusCard(userRole, isDark),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. Executive Header ---
  Widget _buildExecutiveHeader(
    BuildContext context,
    dynamic user,
    dynamic society,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: society?.logoUrl != null
                  ? Image.asset(
                      society!.logoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: const BoxDecoration(gradient: AppGradients.primary),
                        child: const Icon(Icons.shield_rounded, color: AppColors.white, size: 28),
                      ),
                    )
                  : Image.asset(
                      'assets/images/shyam_heights_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: const BoxDecoration(gradient: AppGradients.primary),
                        child: const Icon(Icons.shield_rounded, color: AppColors.white, size: 28),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Welcome back, ${user?.name ?? "Administrator"}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.mintNeon.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.mintNeon.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        'ONLINE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mintNeon,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${society?.name ?? "Shyam Heights"} • ${society?.city ?? "Gandhinagar"}, ${society?.state ?? "Gujarat"}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.slate300,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          AppButton(
            text: 'View Flats',
            icon: Icons.meeting_room_rounded,
            height: 40,
            onPressed: () => context.go(RouteConstants.flatsPath),
          ),
        ],
      ),
    );
  }

  // --- 2. Metric Stat Card ---
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required LinearGradient gradient,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HoverLiftCard(
      glowColor: color,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 3.5,
              child: Container(
                decoration: BoxDecoration(gradient: gradient),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 18, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.slate400 : AppColors.slate600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedCountNumber(
                    value: value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: color,
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

  // --- 3. Occupancy Telemetry Card ---
  Widget _buildOccupancyCard(dynamic stats, bool isDark) {
    if (stats == null || stats.totalFlats == 0) return const SizedBox.shrink();

    return HoverLiftCard(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.pie_chart_outline_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Occupancy Telemetry',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    '${stats.occupancyRate.toStringAsFixed(1)}% Capacity',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedSegmentedBar(
              height: 14,
              borderRadius: 8,
              segments: [
                BarSegment(
                  value: stats.occupiedFlats,
                  color: AppColors.primary,
                  label: 'Occupied',
                ),
                BarSegment(
                  value: stats.vacantFlats,
                  color: AppColors.secondary,
                  label: 'Vacant',
                ),
                BarSegment(
                  value: stats.underMaintenanceFlats,
                  color: AppColors.gold,
                  label: 'Maintenance',
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 24,
              runSpacing: 10,
              children: [
                _buildLegendItem('Occupied (${stats.occupiedFlats})', AppColors.primary),
                _buildLegendItem('Vacant (${stats.vacantFlats})', AppColors.secondary),
                _buildLegendItem('Maintenance (${stats.underMaintenanceFlats})', AppColors.gold),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. Quick Actions Section ---
  Widget _buildQuickActionsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildActionCard(
              context,
              title: 'Manage Towers',
              description: 'Organize residential high-rise towers',
              icon: Icons.apartment_rounded,
              gradient: AppGradients.primary,
              onTap: () => context.go(RouteConstants.towersPath),
            ),
            _buildActionCard(
              context,
              title: 'Configure Floors',
              description: 'Manage floor levels for each tower',
              icon: Icons.layers_rounded,
              gradient: AppGradients.accentCyan,
              onTap: () => context.go(RouteConstants.floorsPath),
            ),
            _buildActionCard(
              context,
              title: 'Flat Inventory',
              description: 'Search, filter, and assign flats',
              icon: Icons.meeting_room_rounded,
              gradient: AppGradients.accentAmber,
              onTap: () => context.go(RouteConstants.flatsPath),
            ),
            _buildActionCard(
              context,
              title: 'All Societies',
              description: 'Manage & switch multiple societies',
              icon: Icons.domain_add_rounded,
              gradient: AppGradients.accentPurple,
              onTap: () => context.go(RouteConstants.societiesPath),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 220,
      child: HoverLiftCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.white),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: AppColors.slate500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- 5. Society Information Card (Right Column) ---
  Widget _buildSocietyInfoCard(dynamic society, bool isDark) {
    return HoverLiftCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.secondary),
              ),
              const SizedBox(width: 10),
              const Text(
                'Society Overview',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Name', society?.name ?? 'Shyam Heights', isDark),
          const SizedBox(height: 10),
          _buildInfoRow('RERA Number', society?.registrationNumber ?? 'PR/GJ/GANDHINAGAR/GANDHINAGAR/OTHERS/MAA10020/130422', isDark),
          const SizedBox(height: 10),
          _buildInfoRow('Location', '${society?.city ?? "Gandhinagar"}, ${society?.state ?? "Gujarat"}', isDark),
          const SizedBox(height: 10),
          _buildInfoRow('Pincode', society?.pinCode ?? '382421', isDark),
        ],
      ),
    );
  }

  // --- 6. Operational Status Card (Right Column) ---
  Widget _buildSystemStatusCard(dynamic userRole, bool isDark) {
    return HoverLiftCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              PulsingStatusDot(color: AppColors.primary, size: 7),
              SizedBox(width: 10),
              Text(
                'System Status',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDarkHigher : AppColors.slate100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current Role', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                StatusBadge.forRole(userRole.code),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Phase 1 Operational • Cloud Sync Active',
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.slate500)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.slate200 : AppColors.slate800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate500),
        ),
      ],
    );
  }
}
