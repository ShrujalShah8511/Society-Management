import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Floor Management'),
        actions: [
          if (canManage && selectedTower != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: AppButton(
                key: const Key('add_floor_button'),
                text: 'Add Floor',
                icon: Icons.add,
                height: 38,
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
      ),
      body: Column(
        children: [
          // Tower Selector Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.apartment, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                const Text(
                  'Select Tower:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(width: 16),
                if (state.towers.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: DropdownButtonFormField<String>(
                      value: state.selectedTowerId,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      items: state.towers.map((tower) {
                        return DropdownMenuItem(
                          value: tower.id,
                          child: Text(tower.name),
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
                  const Text('No towers available'),
              ],
            ),
          ),

          // Floors List Content
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return const LoadingView(message: 'Loading floors...');
                }

                if (state.errorMessage != null && state.floors.isEmpty) {
                  return ErrorRetryView(
                    message: state.errorMessage!,
                    onRetry: () => ref.read(floorNotifierProvider.notifier).init(),
                  );
                }

                if (state.towers.isEmpty) {
                  return const EmptyStateView(
                    title: 'No Towers Created',
                    message: 'Please create at least one tower before configuring floors.',
                    icon: Icons.domain_disabled,
                  );
                }

                if (state.floors.isEmpty) {
                  return EmptyStateView(
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
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.floors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final floor = state.floors[index];
                    return _buildFloorCard(context, ref, floor, selectedTower?.name ?? '', canManage);
                  },
                );
              },
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
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            '${floor.floorNumber}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        title: Text(
          floor.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          'Tower: $towerName • Floor Level: ${floor.floorNumber}',
          style: const TextStyle(fontSize: 13, color: AppColors.slate500),
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
