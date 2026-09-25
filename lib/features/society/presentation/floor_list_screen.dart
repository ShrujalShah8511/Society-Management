import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_badge.dart';
import '../../authentication/presentation/auth_notifier.dart';
import '../../role/domain/role.dart';
import '../domain/floor.dart';
import 'floor_form_dialog.dart';
import 'floor_notifier.dart';

class FloorListScreen extends ConsumerWidget {
  const FloorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(floorNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final canManage = RolePermissions.canManageFloors(authState.role);

    final selectedTower = state.towers.isNotEmpty && state.selectedTowerId != null
        ? state.towers.firstWhere(
            (t) => t.id == state.selectedTowerId,
            orElse: () => state.towers.first,
          )
        : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Executive Header Ribbon
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width < 600 ? 16 : 24,
                16,
                MediaQuery.of(context).size.width < 600 ? 16 : 24,
                14,
              ),
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 620;

                      final headerLeft = Row(
                        children: [
                          Container(
                            width: isMobile ? 38 : 44,
                            height: isMobile ? 38 : 44,
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
                              Icons.layers_rounded,
                              color: AppColors.white,
                              size: isMobile ? 20 : 24,
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
                                      'Floor Management',
                                      style: TextStyle(
                                        fontSize: isMobile ? 18 : 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                        color: isDark ? AppColors.slate50 : AppColors.slate900,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.secondary.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        '${state.floors.length} Floors',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Multi-level vertical configuration, floor designations, and status control',
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
                            if (canManage && selectedTower != null) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: AppButton(
                                  key: const Key('add_floor_button'),
                                  text: 'Add Floor',
                                  icon: Icons.add_rounded,
                                  height: 42,
                                  onPressed: () async {
                                    final result = await FloorFormDialog.show(
                                      context,
                                      towerName: selectedTower.name,
                                    );
                                    if (result != null) {
                                      final success = await ref
                                          .read(floorNotifierProvider.notifier)
                                          .createFloor(
                                            floorNumber: result.floorNumber,
                                            displayName: result.displayName,
                                            status: result.status,
                                          );
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Floor added successfully'),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: headerLeft),
                          if (canManage && selectedTower != null) ...[
                            const SizedBox(width: 14),
                            AppButton(
                              key: const Key('add_floor_button'),
                              text: 'Add Floor',
                              icon: Icons.add_rounded,
                              height: 42,
                              onPressed: () async {
                                final result = await FloorFormDialog.show(
                                  context,
                                  towerName: selectedTower.name,
                                );
                                if (result != null) {
                                  final success = await ref
                                      .read(floorNotifierProvider.notifier)
                                      .createFloor(
                                        floorNumber: result.floorNumber,
                                        displayName: result.displayName,
                                        status: result.status,
                                      );
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Floor added successfully'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tower Selector Bar
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.apartment_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Active Tower:',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isDark ? AppColors.slate300 : AppColors.slate700,
                            ),
                          ),
                        ],
                      ),
                      if (state.towers.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight,
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButton<String>(
                            value: state.selectedTowerId,
                            underline: const SizedBox.shrink(),
                            dropdownColor: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight,
                            items: state.towers.map((tower) {
                              return DropdownMenuItem(
                                value: tower.id,
                                child: Text(tower.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              );
                            }).toList(),
                            onChanged: (towerId) {
                              if (towerId != null) {
                                ref.read(floorNotifierProvider.notifier).selectTower(towerId);
                              }
                            },
                          ),
                        )
                      else
                        const Text('No towers available', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floors List Content
          if (state.isLoading)
            const SliverFillRemaining(
              child: LoadingView(message: 'Loading floors...'),
            )
          else if (state.errorMessage != null && state.floors.isEmpty)
            SliverFillRemaining(
              child: ErrorRetryView(
                message: state.errorMessage!,
                onRetry: () => ref.read(floorNotifierProvider.notifier).init(),
              ),
            )
          else if (state.towers.isEmpty)
            const SliverFillRemaining(
              child: EmptyStateView(
                title: 'No Towers Created',
                message: 'Please create at least one tower before configuring floors.',
                icon: Icons.domain_disabled,
              ),
            )
          else if (state.floors.isEmpty)
            SliverFillRemaining(
              child: EmptyStateView(
                title: 'No Floors Configured',
                message: 'No floors have been added to ${selectedTower?.name ?? "this tower"} yet.',
                icon: Icons.layers_clear_outlined,
                actionLabel: canManage ? 'Add Floor' : null,
                onAction: canManage && selectedTower != null
                    ? () async {
                        final result = await FloorFormDialog.show(
                          context,
                          towerName: selectedTower.name,
                        );
                        if (result != null) {
                          await ref.read(floorNotifierProvider.notifier).createFloor(
                                floorNumber: result.floorNumber,
                                displayName: result.displayName,
                                status: result.status,
                              );
                        }
                      }
                    : null,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final floor = state.floors[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildFloorCard(
                        context,
                        ref,
                        floor,
                        selectedTower?.name ?? '',
                        canManage,
                      ),
                    );
                  },
                  childCount: state.floors.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloorCard(
    BuildContext context,
    WidgetRef ref,
    Floor floor,
    String towerName,
    bool canManage,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HoverLiftCard(
      glowColor: AppColors.secondary,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '${floor.floorNumber}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.white,
            ),
          ),
        ),
        title: Text(
          floor.displayName,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: -0.2,
            color: isDark ? AppColors.slate100 : AppColors.slate900,
          ),
        ),
        subtitle: Text(
          'Tower: $towerName • Floor Level: ${floor.floorNumber}',
          style: TextStyle(fontSize: 13, color: isDark ? AppColors.slate400 : AppColors.slate500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusBadge.fromStatus(floor.status.code),
            if (canManage) ...[
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (val) async {
                  if (val == 'edit') {
                    final updated = await FloorFormDialog.show(
                      context,
                      floor: floor,
                      towerName: towerName,
                    );
                    if (updated != null) {
                      await ref.read(floorNotifierProvider.notifier).updateFloor(updated);
                    }
                  } else if (val == 'delete') {
                    final confirm = await ConfirmDialog.show(
                      context: context,
                      title: 'Delete Floor',
                      message: 'Are you sure you want to delete "${floor.displayName}"?',
                      confirmLabel: 'Delete',
                      isDestructive: true,
                    );
                    if (confirm) {
                      final success = await ref
                          .read(floorNotifierProvider.notifier)
                          .deleteFloor(floor.id);
                      if (!success && context.mounted) {
                        final err = ref.read(floorNotifierProvider).errorMessage ?? 'Cannot delete floor';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(err), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
