import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flatNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final canManage = RolePermissions.canManageFlats(authState.role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flat Inventory'),
        actions: [
          if (canManage && state.towers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: AppButton(
                key: const Key('add_flat_button'),
                text: 'Add Flat',
                icon: Icons.add,
                height: 38,
                onPressed: () async {
                  final created = await FlatFormDialog.show(
                    context,
                    towers: state.towers,
                    floors: state.floors,
                  );
                  if (created != null) {
                    final success = await ref
                        .read(flatNotifierProvider.notifier)
                        .createFlat(created);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Flat created successfully'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Controls Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Search input & Sorting options
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        key: const Key('flat_search_field'),
                        controller: _searchController,
                        onChanged: (val) {
                          ref.read(flatNotifierProvider.notifier).updateFilters(
                                state.filters.copyWith(searchQuery: val),
                              );
                        },
                        decoration: InputDecoration(
                          hintText: 'Search flats by number (e.g. A-101)...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(flatNotifierProvider.notifier).updateFilters(
                                          state.filters.copyWith(searchQuery: ''),
                                        );
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sort By Dropdown
                    DropdownButton<String>(
                      value: state.filters.sortBy,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 'number', child: Text('Sort: Flat Number')),
                        DropdownMenuItem(value: 'area', child: Text('Sort: Area (sq.ft.)')),
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
                        state.filters.ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 20,
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
                const SizedBox(height: 12),

                // Filter chips & selectors
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Tower Filter Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.slate300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String?>(
                          value: state.filters.selectedTowerId,
                          hint: const Text('All Towers', style: TextStyle(fontSize: 13)),
                          underline: const SizedBox.shrink(),
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
                      const SizedBox(width: 10),

                      // Occupancy Filter Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.slate300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<OccupancyStatus?>(
                          value: state.filters.selectedOccupancyStatus,
                          hint: const Text('All Statuses', style: TextStyle(fontSize: 13)),
                          underline: const SizedBox.shrink(),
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
                      const SizedBox(width: 10),

                      // Flat Type Filter Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.slate300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<FlatType?>(
                          value: state.filters.selectedFlatType,
                          hint: const Text('All Flat Types', style: TextStyle(fontSize: 13)),
                          underline: const SizedBox.shrink(),
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
                      const SizedBox(width: 12),

                      // Clear Filters button
                      if (state.filters.selectedTowerId != null ||
                          state.filters.selectedOccupancyStatus != null ||
                          state.filters.selectedFlatType != null ||
                          state.filters.searchQuery.isNotEmpty)
                        TextButton.icon(
                          icon: const Icon(Icons.filter_alt_off, size: 16),
                          label: const Text('Reset Filters', style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(flatNotifierProvider.notifier).updateFilters(
                                  const FlatFilterState(),
                                );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Flat Inventory Content
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return const LoadingView(message: 'Loading flats...');
                }

                if (state.errorMessage != null && state.flats.isEmpty) {
                  return ErrorRetryView(
                    message: state.errorMessage!,
                    onRetry: () => ref.read(flatNotifierProvider.notifier).init(),
                  );
                }

                if (state.flats.isEmpty) {
                  return EmptyStateView(
                    title: 'No Flats Found',
                    message: 'No flats match the current filters or query.',
                    icon: Icons.meeting_room_outlined,
                    actionLabel: canManage && state.towers.isNotEmpty ? 'Add Flat' : null,
                    onAction: canManage && state.towers.isNotEmpty
                        ? () async {
                            final created = await FlatFormDialog.show(
                              context,
                              towers: state.towers,
                              floors: state.floors,
                            );
                            if (created != null) {
                              await ref.read(flatNotifierProvider.notifier).createFlat(created);
                            }
                          }
                        : null,
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 1000
                        ? 3
                        : (constraints.maxWidth > 650 ? 2 : 1);

                    return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 190,
                      ),
                      itemCount: state.flats.length,
                      itemBuilder: (context, index) {
                        final flat = state.flats[index];
                        final tower = _getTower(state.towers, flat.towerId);
                        final floor = _getFloor(state.floors, flat.floorId);
                        return _buildFlatCard(flat, tower, floor, canManage);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlatCard(Flat flat, Tower? tower, Floor? floor, bool canManage) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          FlatDetailDialog.show(
            context,
            flat: flat,
            tower: tower,
            floor: floor,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      flat.flatNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      flat.flatType.displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  StatusBadge.fromStatus(flat.occupancyStatus.code),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.apartment, size: 16, color: AppColors.slate400),
                  const SizedBox(width: 6),
                  Text(
                    tower?.name ?? 'Tower ${flat.towerId}',
                    style: const TextStyle(fontSize: 13, color: AppColors.slate600),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.layers, size: 16, color: AppColors.slate400),
                  const SizedBox(width: 6),
                  Text(
                    floor?.displayName ?? 'Floor ${flat.floorId}',
                    style: const TextStyle(fontSize: 13, color: AppColors.slate600),
                  ),
                ],
              ),
              const Spacer(),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.square_foot, size: 16, color: AppColors.slate500),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.formatArea(flat.areaSqFt),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate800,
                        ),
                      ),
                    ],
                  ),
                  if (canManage)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
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
        ),
      ),
    );
  }
}
