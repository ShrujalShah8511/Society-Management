import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_badge.dart';
import '../../authentication/presentation/auth_notifier.dart';
import '../../role/domain/role.dart';
import '../domain/flat.dart';
import '../domain/floor.dart';
import '../domain/tower.dart';
import 'flat_detail_dialog.dart';
import 'flat_form_dialog.dart';
import 'flat_notifier.dart';

class FlatListScreen extends ConsumerStatefulWidget {
  const FlatListScreen({super.key});

  @override
  ConsumerState<FlatListScreen> createState() => _FlatListScreenState();
}

class _FlatListScreenState extends ConsumerState<FlatListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Tower? _getTower(List<Tower> towers, String towerId) {
    try {
      return towers.firstWhere((t) => t.id == towerId);
    } catch (_) {
      return null;
    }
  }

  Floor? _getFloor(List<Floor> floors, String floorId) {
    try {
      return floors.firstWhere((f) => f.id == floorId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _showCreateDialog(
    BuildContext context,
    List<Tower> towers,
    List<Floor> floors,
  ) async {
    final created = await FlatFormDialog.show(
      context,
      towers: towers,
      floors: floors,
    );
    if (created != null && mounted) {
      final success = await ref
          .read(flatNotifierProvider.notifier)
          .createFlat(created);
      if (success && mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flat unit created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flatNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final canManage = RolePermissions.canManageFlats(authState.role);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate quick counts for the segmented status ribbon
    final totalCount = state.flats.length;
    final occupiedCount = state.flats.where((f) => f.occupancyStatus == OccupancyStatus.occupied).length;
    final vacantCount = state.flats.where((f) => f.occupancyStatus == OccupancyStatus.vacant).length;
    final maintenanceCount = state.flats.where((f) => f.occupancyStatus == OccupancyStatus.underMaintenance).length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Title & Add Flat Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 620;

                    final headerLeft = Row(
                      children: [
                        Container(
                          width: isMobile ? 38 : 42,
                          height: isMobile ? 38 : 42,
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.meeting_room_rounded,
                            color: AppColors.white,
                            size: isMobile ? 20 : 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Flat Inventory',
                                    style: TextStyle(
                                      fontSize: isMobile ? 18 : 20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                      color: isDark ? AppColors.slate50 : AppColors.slate900,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      '$totalCount Units',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Directory of residential units and occupancy',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.slate400 : AppColors.slate600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          headerLeft,
                          if (canManage && state.towers.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: AppButton(
                                key: const Key('add_flat_button'),
                                text: 'Add Flat',
                                icon: Icons.add_rounded,
                                height: 42,
                                onPressed: () => _showCreateDialog(context, state.towers, state.floors),
                              ),
                            ),
                          ],
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: headerLeft),
                        if (canManage && state.towers.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          AppButton(
                            key: const Key('add_flat_button'),
                            text: 'Add Flat',
                            icon: Icons.add_rounded,
                            height: 42,
                            onPressed: () => _showCreateDialog(context, state.towers, state.floors),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Segmented Status Filter Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSegmentTab(
                        label: 'All Units',
                        count: state.filters.selectedOccupancyStatus == null ? totalCount : null,
                        isSelected: state.filters.selectedOccupancyStatus == null,
                        indicatorColor: AppColors.primary,
                        isDark: isDark,
                        onTap: () {
                          ref.read(flatNotifierProvider.notifier).updateFilters(
                                state.filters.copyWith(clearStatus: true),
                              );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildSegmentTab(
                        label: 'Occupied',
                        count: occupiedCount,
                        isSelected: state.filters.selectedOccupancyStatus == OccupancyStatus.occupied,
                        indicatorColor: AppColors.primary,
                        isDark: isDark,
                        onTap: () {
                          ref.read(flatNotifierProvider.notifier).updateFilters(
                                state.filters.copyWith(
                                  selectedOccupancyStatus: OccupancyStatus.occupied,
                                ),
                              );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildSegmentTab(
                        label: 'Vacant',
                        count: vacantCount,
                        isSelected: state.filters.selectedOccupancyStatus == OccupancyStatus.vacant,
                        indicatorColor: AppColors.secondary,
                        isDark: isDark,
                        onTap: () {
                          ref.read(flatNotifierProvider.notifier).updateFilters(
                                state.filters.copyWith(
                                  selectedOccupancyStatus: OccupancyStatus.vacant,
                                ),
                              );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildSegmentTab(
                        label: 'Maintenance',
                        count: maintenanceCount,
                        isSelected: state.filters.selectedOccupancyStatus == OccupancyStatus.underMaintenance,
                        indicatorColor: AppColors.gold,
                        isDark: isDark,
                        onTap: () {
                          ref.read(flatNotifierProvider.notifier).updateFilters(
                                state.filters.copyWith(
                                  selectedOccupancyStatus: OccupancyStatus.underMaintenance,
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Controls Strip: Search + Sort + Dropdown Selectors
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Search Input Box
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280, minWidth: 200),
                      child: TextField(
                        key: const Key('flat_search_field'),
                        controller: _searchController,
                        onChanged: (val) {
                          ref.read(flatNotifierProvider.notifier).updateFilters(
                                state.filters.copyWith(searchQuery: val),
                              );
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by number (e.g. A-101)...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 18),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(flatNotifierProvider.notifier).updateFilters(
                                          state.filters.copyWith(searchQuery: ''),
                                        );
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),

                    // Tower Filter Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight,
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String?>(
                        value: state.filters.selectedTowerId,
                        hint: const Text('All Towers', style: TextStyle(fontSize: 13)),
                        underline: const SizedBox.shrink(),
                        dropdownColor: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Towers', style: TextStyle(fontSize: 13)),
                          ),
                          ...state.towers.map(
                            (t) => DropdownMenuItem<String?>(
                              value: t.id,
                              child: Text(t.name, style: const TextStyle(fontSize: 13)),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          ref.read(flatNotifierProvider.notifier).updateFilters(
                                state.filters.copyWith(
                                  selectedTowerId: val,
                                  clearTower: val == null,
                                ),
                              );
                        },
                      ),
                    ),

                    // Occupancy Filter Dropdown (keeps explicit test match)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight,
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<OccupancyStatus?>(
                        value: state.filters.selectedOccupancyStatus,
                        hint: const Text('All Statuses', style: TextStyle(fontSize: 13)),
                        underline: const SizedBox.shrink(),
                        dropdownColor: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight,
                        items: [
                          const DropdownMenuItem<OccupancyStatus?>(
                            value: null,
                            child: Text('All Statuses', style: TextStyle(fontSize: 13)),
                          ),
                          ...OccupancyStatus.values.map(
                            (s) => DropdownMenuItem<OccupancyStatus?>(
                              value: s,
                              child: Text(s.displayName, style: const TextStyle(fontSize: 13)),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          ref.read(flatNotifierProvider.notifier).updateFilters(
                                state.filters.copyWith(
                                  selectedOccupancyStatus: val,
                                  clearStatus: val == null,
                                ),
                              );
                        },
                      ),
                    ),

                    // Flat Type Filter Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight,
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<FlatType?>(
                        value: state.filters.selectedFlatType,
                        hint: const Text('All Flat Types', style: TextStyle(fontSize: 13)),
                        underline: const SizedBox.shrink(),
                        dropdownColor: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight,
                        items: [
                          const DropdownMenuItem<FlatType?>(
                            value: null,
                            child: Text('All Flat Types', style: TextStyle(fontSize: 13)),
                          ),
                          ...FlatType.values.map(
                            (t) => DropdownMenuItem<FlatType?>(
                              value: t,
                              child: Text(t.displayName, style: const TextStyle(fontSize: 13)),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          ref.read(flatNotifierProvider.notifier).updateFilters(
                                state.filters.copyWith(
                                  selectedFlatType: val,
                                  clearType: val == null,
                                ),
                              );
                        },
                      ),
                    ),

                    // Sort selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight,
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<String>(
                            value: state.filters.sortBy,
                            underline: const SizedBox.shrink(),
                            dropdownColor: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight,
                            items: const [
                              DropdownMenuItem(
                                value: 'number',
                                child: Text('Sort: Flat Number', style: TextStyle(fontSize: 13)),
                              ),
                              DropdownMenuItem(
                                value: 'area',
                                child: Text('Sort: Area (sq.ft.)', style: TextStyle(fontSize: 13)),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(flatNotifierProvider.notifier).updateFilters(
                                      state.filters.copyWith(sortBy: val),
                                    );
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              state.filters.ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                              size: 16,
                            ),
                            tooltip: state.filters.ascending ? 'Ascending' : 'Descending',
                            onPressed: () {
                              ref.read(flatNotifierProvider.notifier).updateFilters(
                                    state.filters.copyWith(ascending: !state.filters.ascending),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Clear Filters button
                    if (state.filters.selectedTowerId != null ||
                        state.filters.selectedOccupancyStatus != null ||
                        state.filters.selectedFlatType != null ||
                        state.filters.searchQuery.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                        label: const Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(flatNotifierProvider.notifier).updateFilters(
                                const FlatFilterState(),
                              );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (state.isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: LoadingView(message: 'Loading inventory...'),
            ),
          )
        else if (state.errorMessage != null && state.flats.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: ErrorRetryView(
                message: state.errorMessage!,
                onRetry: () => ref.read(flatNotifierProvider.notifier).init(),
              ),
            ),
          )
        else if (state.flats.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: EmptyStateView(
                title: 'No Flats Found',
                message: 'No units match the current filters or query.',
                icon: Icons.meeting_room_rounded,
                actionLabel: canManage && state.towers.isNotEmpty ? 'Add Flat' : null,
                onAction: canManage && state.towers.isNotEmpty
                    ? () => _showCreateDialog(context, state.towers, state.floors)
                    : null,
              ),
            ),
          )
          else
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.crossAxisExtent < 650;
                final crossAxisCount = constraints.crossAxisExtent > 1100
                    ? 3
                    : (constraints.crossAxisExtent > 650 ? 2 : 1);

                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, isMobile ? 96 : 24),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: isMobile ? 210 : 195,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final flat = state.flats[index];
                        final tower = _getTower(state.towers, flat.towerId);
                        final floor = _getFloor(state.floors, flat.floorId);
                        return _buildFlatCard(flat, tower, floor, canManage, isDark);
                      },
                      childCount: state.flats.length,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // Segment Tab Pill
  Widget _buildSegmentTab({
    required String label,
    int? count,
    required bool isSelected,
    required Color indicatorColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? indicatorColor.withValues(alpha: 0.18) : indicatorColor.withValues(alpha: 0.12))
              : (isDark ? AppColors.surfaceDarkCard : AppColors.slate100),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? indicatorColor : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: indicatorColor,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: indicatorColor.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.slate100 : AppColors.slate900)
                    : (isDark ? AppColors.slate400 : AppColors.slate600),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? indicatorColor.withValues(alpha: 0.25)
                      : (isDark ? AppColors.surfaceDarkHigher : AppColors.slate200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? indicatorColor
                        : (isDark ? AppColors.slate300 : AppColors.slate700),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFlatCard(
    Flat flat,
    Tower? tower,
    Floor? floor,
    bool canManage,
    bool isDark,
  ) {
    final glowColor = flat.occupancyStatus == OccupancyStatus.occupied
        ? AppColors.primary
        : (flat.occupancyStatus == OccupancyStatus.vacant
            ? AppColors.secondary
            : AppColors.gold);

    return HoverLiftCard(
      glowColor: glowColor,
      onTap: () {
        FlatDetailDialog.show(
          context,
          flat: flat,
          tower: tower,
          floor: floor,
        );
      },
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primary.withValues(alpha: 0.25) : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  flat.flatNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDarkHigher : AppColors.slate100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    flat.flatType.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.slate300 : AppColors.slate700,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: StatusBadge.fromStatus(flat.occupancyStatus.code),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.apartment_rounded, size: 16, color: AppColors.slate400),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  tower?.name ?? 'Tower ${flat.towerId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: isDark ? AppColors.slate300 : AppColors.slate600),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.layers_rounded, size: 16, color: AppColors.slate400),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  floor?.displayName ?? 'Floor ${flat.floorId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: isDark ? AppColors.slate300 : AppColors.slate600),
                ),
              ),
            ],
          ),
          const Spacer(),
          Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.square_foot_rounded, size: 16, color: AppColors.slate400),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.formatArea(flat.areaSqFt),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.slate200 : AppColors.slate800,
                    ),
                  ),
                ],
              ),
              if (canManage)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: const EdgeInsets.all(4),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: 'Edit Flat',
                      onPressed: () async {
                        final state = ref.read(flatNotifierProvider);
                        final updated = await FlatFormDialog.show(
                          context,
                          flat: flat,
                          towers: state.towers,
                          floors: state.floors,
                        );
                        if (updated != null) {
                          await ref.read(flatNotifierProvider.notifier).updateFlat(updated);
                        }
                      },
                    ),
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: const EdgeInsets.all(4),
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      tooltip: 'Delete Flat',
                      onPressed: () async {
                        final confirm = await ConfirmDialog.show(
                          context: context,
                          title: 'Delete Flat',
                          message: 'Are you sure you want to delete flat ${flat.flatNumber}?',
                          confirmLabel: 'Delete',
                          isDestructive: true,
                        );
                        if (confirm) {
                          await ref.read(flatNotifierProvider.notifier).deleteFlat(flat.id);
                        }
                      },
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

