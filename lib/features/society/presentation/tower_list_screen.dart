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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredList = state.filteredTowers;

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
                              Icons.apartment_rounded,
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
                                      'Tower Management',
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
                                        color: AppColors.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        '${state.towers.length} Towers',
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
                                  'Architectural towers, building configurations, and structure',
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
                            if (canManage) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: AppButton(
                                  key: const Key('add_tower_button'),
                                  text: 'Add Tower',
                                  icon: Icons.add_rounded,
                                  height: 42,
                                  onPressed: _openAddDialog,
                                ),
                              ),
                            ],
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: headerLeft),
                          if (canManage) ...[
                            const SizedBox(width: 14),
                            AppButton(
                              key: const Key('add_tower_button'),
                              text: 'Add Tower',
                              icon: Icons.add_rounded,
                              height: 42,
                              onPressed: _openAddDialog,
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: TextField(
                      key: const Key('tower_search_field'),
                      controller: _searchController,
                      onChanged: (val) {
                        ref.read(towerNotifierProvider.notifier).setSearchQuery(val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search towers by name or description...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(towerNotifierProvider.notifier).setSearchQuery('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (state.isLoading)
            const SliverFillRemaining(
              child: LoadingView(message: 'Loading towers...'),
            )
          else if (state.errorMessage != null && state.towers.isEmpty)
            SliverFillRemaining(
              child: ErrorRetryView(
                message: state.errorMessage!,
                onRetry: () => ref.read(towerNotifierProvider.notifier).loadTowers(),
              ),
            )
          else if (filteredList.isEmpty)
            SliverFillRemaining(
              child: EmptyStateView(
                title: 'No Towers Found',
                message: state.searchQuery.isNotEmpty
                    ? 'No towers matched "${state.searchQuery}".'
                    : 'No towers have been added to this society yet.',
                icon: Icons.domain_disabled_outlined,
                actionLabel: canManage ? 'Add Tower' : null,
                onAction: canManage ? _openAddDialog : null,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.crossAxisExtent > 1100
                      ? 3
                      : (constraints.crossAxisExtent > 700 ? 2 : 1);

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      mainAxisExtent: 195,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tower = filteredList[index];
                        return _buildTowerCard(tower, canManage);
                      },
                      childCount: filteredList.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTowerCard(Tower tower, bool canManage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HoverLiftCard(
      glowColor: AppColors.primary,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
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
                child: const Icon(Icons.apartment_rounded, color: AppColors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tower.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.2,
                        color: isDark ? AppColors.slate100 : AppColors.slate900,
                      ),
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
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.slate400 : AppColors.slate500,
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tower.floorCount} Total Floors',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.slate300 : AppColors.slate700,
                ),
              ),
              const Icon(Icons.layers_rounded, size: 16, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}
