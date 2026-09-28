import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/status_badge.dart';
import '../../authentication/domain/user.dart';
import '../../authentication/presentation/auth_notifier.dart';
import '../../role/domain/role.dart';
import '../../society/presentation/active_society_provider.dart';
import 'user_form_dialog.dart';
import 'user_provider.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddUserDialog() async {
    final authState = ref.read(authNotifierProvider);
    final isSuperAdmin = authState.role == Role.superAdmin;
    final activeSocietyState = ref.read(activeSocietyProvider);
    final activeSociety = activeSocietyState.activeSociety;
    final allSocieties = activeSocietyState.allSocieties;
    final allFlats = await ref.read(flatRepositoryProvider).getFlats(
          societyId: activeSociety?.id ?? '',
        );
    final existingUsers = ref.read(userManagementProvider).users;

    if (!mounted) return;

    final result = await UserFormDialog.show(
      context,
      isSuperAdmin: isSuperAdmin,
      societies: allSocieties,
      currentSociety: activeSociety,
      availableFlats: allFlats,
      existingUsers: existingUsers,
      generateUserId: (city) => ref.read(userManagementProvider.notifier).generateUserId(city),
    );

    if (result != null && mounted) {
      try {
        final created = await ref.read(userManagementProvider.notifier).createUser(
              user: result.user,
              temporaryPassword: result.temporaryPassword,
            );

        if (created != null && mounted) {
          await UserCreatedSuccessDialog.show(
            context,
            user: created,
            temporaryPassword: result.temporaryPassword,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create user: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  Future<void> _handleDeleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete user "${user.name}" (${user.id})?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(userManagementProvider.notifier).deleteUser(user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User "${user.name}" removed')),
        );
      }
    }
  }

  /// Super Admin: impersonate the selected user's session.
  void _handleImpersonate(User targetUser) {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    authNotifier.impersonateUser(targetUser);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.switch_account_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Logged in as ${targetUser.name} (${targetUser.role.displayName}). '
                  'Tap "Exit" to return to Super Admin.',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Exit',
            textColor: Colors.white,
            onPressed: () => authNotifier.exitImpersonation(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userManagementProvider);
    final authState = ref.watch(authNotifierProvider);
    final isSuperAdmin = authState.role == Role.superAdmin;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allUsers = state.users;
    final filteredUsers = state.filteredUsers;

    final adminCount = allUsers.where((u) => u.role == Role.societyAdmin || u.role == Role.superAdmin).length;
    final residentCount = allUsers.where((u) => u.role == Role.resident).length;
    final staffCount = allUsers.where((u) => u.role == Role.staff || u.role == Role.security).length;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(userManagementProvider.notifier).loadUsers(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header & Action Bar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSuperAdmin ? 'Platform User & Admin Provisioning' : 'Society Member Management',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isSuperAdmin
                              ? 'Manage platform administrators, society admins, and configure role assignments across all societies.'
                              : 'Manage residents, committee members, and security personnel. Allocate dedicated flats to verified residents.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.slate400 : AppColors.slate600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  AppButton(
                    key: const Key('add_user_button'),
                    text: isSuperAdmin ? 'Provision User / Admin' : 'Add Member',
                    icon: Icons.person_add_rounded,
                    onPressed: _openAddUserDialog,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Metric Overview Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 640;
                  return GridView.count(
                    crossAxisCount: isCompact ? 2 : 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isCompact ? 1.8 : 2.2,
                    children: [
                      _buildMetricCard('Total Users', allUsers.length.toString(), Icons.people_outline_rounded, AppColors.primary, isDark),
                      _buildMetricCard('Administrators', adminCount.toString(), Icons.admin_panel_settings_outlined, AppColors.gold, isDark),
                      _buildMetricCard('Residents', residentCount.toString(), Icons.home_outlined, AppColors.success, isDark),
                      _buildMetricCard('Staff & Security', staffCount.toString(), Icons.shield_outlined, AppColors.secondary, isDark),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Search & Role Filter Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: _searchController,
                      label: 'Search Users',
                      hint: 'Search by name, mobile number, email, user ID or flat...',
                      prefixIcon: Icons.search_rounded,
                      onChanged: (val) => ref.read(userManagementProvider.notifier).setSearchQuery(val),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All Roles', null, state.roleFilter == null),
                          const SizedBox(width: 8),
                          if (isSuperAdmin) ...[
                            _buildFilterChip('Super Admins', Role.superAdmin, state.roleFilter == Role.superAdmin),
                            const SizedBox(width: 8),
                          ],
                          _buildFilterChip('Society Admins', Role.societyAdmin, state.roleFilter == Role.societyAdmin),
                          const SizedBox(width: 8),
                          _buildFilterChip('Residents', Role.resident, state.roleFilter == Role.resident),
                          const SizedBox(width: 8),
                          _buildFilterChip('Committee', Role.committeeMember, state.roleFilter == Role.committeeMember),
                          const SizedBox(width: 8),
                          _buildFilterChip('Security', Role.security, state.roleFilter == Role.security),
                          const SizedBox(width: 8),
                          _buildFilterChip('Staff', Role.staff, state.roleFilter == Role.staff),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Users Table / Cards
              if (state.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else if (filteredUsers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.person_search_rounded, size: 48, color: isDark ? AppColors.slate600 : AppColors.slate400),
                      const SizedBox(height: 12),
                      const Text('No users match your query', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Try adjusting your search criteria or role filters.', style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredUsers.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    itemBuilder: (context, index) {
                      final u = filteredUsers[index];
                      final isCurrentUser = u.id == authState.user?.id;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            const SizedBox(width: 8),
                            StatusBadge.forRole(u.role.code),
                            if (u.mustChangePassword) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                                ),
                                child: const Text(
                                  'Temp Pass',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.goldDark),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Text('ID: ${u.id}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 12),
                              Icon(Icons.phone_android_rounded, size: 12, color: isDark ? AppColors.slate400 : AppColors.slate500),
                              const SizedBox(width: 3),
                              Text(u.mobile, style: const TextStyle(fontSize: 11)),
                              const SizedBox(width: 12),
                              Icon(Icons.apartment_rounded, size: 12, color: isDark ? AppColors.slate400 : AppColors.slate500),
                              const SizedBox(width: 3),
                              Text(u.societyName, style: const TextStyle(fontSize: 11)),
                              if (u.flatNumber != null) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('Flat ${u.flatNumber}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ),
                              ],
                            ],
                          ),
                        ),
                        trailing: isCurrentUser
                            ? const Chip(label: Text('You', style: TextStyle(fontSize: 11)), visualDensity: VisualDensity.compact)
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Super Admin: Login As (impersonate) button — shown for non-super-admin users
                                  if (isSuperAdmin && u.role != Role.superAdmin)
                                    Tooltip(
                                      message: 'Login As this user (Impersonate)',
                                      child: IconButton(
                                        icon: const Icon(Icons.switch_account_rounded, size: 20, color: AppColors.primary),
                                        onPressed: () => _handleImpersonate(u),
                                      ),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                    tooltip: 'Delete user',
                                    onPressed: () => _handleDeleteUser(u),
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, Role? role, bool isSelected) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (_) => ref.read(userManagementProvider.notifier).setRoleFilter(role),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildMetricCard(String title, String count, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text(title, style: TextStyle(fontSize: 11, color: isDark ? AppColors.slate400 : AppColors.slate500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
