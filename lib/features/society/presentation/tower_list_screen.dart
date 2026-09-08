import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_badge.dart';
import '../../authentication/presentation/auth_notifier.dart';
import '../../role/domain/role.dart';
import '../domain/tower.dart';
import 'tower_form_dialog.dart';
import 'tower_notifier.dart';

class TowerListScreen extends ConsumerStatefulWidget {
  const TowerListScreen({super.key});

  @override
  ConsumerState<TowerListScreen> createState() => _TowerListScreenState();
}

class _TowerListScreenState extends ConsumerState<TowerListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddDialog() async {
    final result = await TowerFormDialog.show(context);
    if (result != null && mounted) {
      final success = await ref.read(towerNotifierProvider.notifier).createTower(
            name: result.name,
            description: result.description,
            floorCount: result.floorCount,
            status: result.status,
          );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tower created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _openEditDialog(Tower tower) async {
    final result = await TowerFormDialog.show(context, tower: tower);
    if (result != null && mounted) {
      final success =
          await ref.read(towerNotifierProvider.notifier).updateTower(result);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tower updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(Tower tower) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Tower',
      message: 'Are you sure you want to delete ${tower.name}? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      final success =
          await ref.read(towerNotifierProvider.notifier).deleteTower(tower.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tower deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        final err = ref.read(towerNotifierProvider).errorMessage ?? 'Failed to delete tower';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(towerNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final canManage = RolePermissions.canManageTowers(authState.role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tower Management'),
        actions: [
          if (canManage)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: AppButton(
                key: const Key('add_tower_button'),
                text: 'Add Tower',
                icon: Icons.add,
                height: 38,
                onPressed: _openAddDialog,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: TextField(
                      key: const Key('tower_search_field'),
                      controller: _searchController,
                      onChanged: (val) {
                        ref.read(towerNotifierProvider.notifier).setSearchQuery(val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search towers by name or description...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(towerNotifierProvider.notifier).setSearchQuery('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return const LoadingView(message: 'Loading towers...');
                }

                if (state.errorMessage != null && state.towers.isEmpty) {
                  return ErrorRetryView(
                    message: state.errorMessage!,
                    onRetry: () => ref.read(towerNotifierProvider.notifier).loadTowers(),
                  );
                }

                final filteredList = state.filteredTowers;

                if (filteredList.isEmpty) {
                  return EmptyStateView(
                    title: 'No Towers Found',
                    message: state.searchQuery.isNotEmpty
                        ? 'No towers matched "${state.searchQuery}".'
                        : 'No towers have been added to this society yet.',
                    icon: Icons.domain_disabled_outlined,
                    actionLabel: canManage ? 'Add Tower' : null,
                    onAction: canManage ? _openAddDialog : null,
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 900
                        ? 3
                        : (constraints.maxWidth > 600 ? 2 : 1);

                    return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 180,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final tower = filteredList[index];
                        return _buildTowerCard(tower, canManage);
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

  Widget _buildTowerCard(Tower tower, bool canManage) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.apartment, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tower.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      StatusBadge.fromStatus(tower.status.code),
                    ],
                  ),
                ),
                if (canManage) ...[
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'edit') _openEditDialog(tower);
                      if (val == 'delete') _handleDelete(tower);
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
            const SizedBox(height: 12),
            Text(
              tower.description.isNotEmpty ? tower.description : 'No description provided',
              style: const TextStyle(fontSize: 13, color: AppColors.slate500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            const Divider(),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${tower.floorCount} Total Floors',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate700),
                ),
                const Icon(Icons.layers_outlined, size: 16, color: AppColors.slate400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
