import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/status_badge.dart';
import 'auth_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _openEditProfile(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final mobileController = TextEditingController(text: user.mobile);

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: nameController,
                  label: 'Full Name',
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: mobileController,
                  label: 'Mobile Number',
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
              ],
            ),
          ),
        ),
        actions: [
          AppButton(
            text: 'Cancel',
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton(
            text: 'Save',
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
      ),
    );

    if (updated == true) {
      final success = await ref.read(authNotifierProvider.notifier).updateProfile(
            name: nameController.text.trim(),
            mobile: mobileController.text.trim(),
          );
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _openChangePassword(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: currentPassController,
                  label: 'Current Password',
                  isPassword: true,
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: newPassController,
                  label: 'New Password',
                  isPassword: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: confirmPassController,
                  label: 'Confirm New Password',
                  isPassword: true,
                  validator: (val) {
                    if (val != newPassController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          AppButton(
            text: 'Cancel',
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton(
            text: 'Update Password',
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(authNotifierProvider.notifier).changePassword(
            currentPassword: currentPassController.text,
            newPassword: newPassController.text,
          );
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (context.mounted) {
        final err = ref.read(authNotifierProvider).errorMessage ?? 'Failed to change password';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No active session')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(width: 10),
                                StatusBadge.forRole(user.role.code),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.email,
                              style: const TextStyle(color: AppColors.slate500, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Member of: ${user.societyName}',
                              style: const TextStyle(color: AppColors.slate500, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Contact & Account Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Account Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          AppButton(
                            text: 'Edit Profile',
                            icon: Icons.edit_outlined,
                            variant: AppButtonVariant.outlined,
                            height: 36,
                            onPressed: () => _openEditProfile(context, ref),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow('User ID', user.id),
                      const Divider(height: 24),
                      _buildDetailRow('Email Address', user.email),
                      const Divider(height: 24),
                      _buildDetailRow('Mobile Number', user.mobile),
                      const Divider(height: 24),
                      _buildDetailRow('Assigned Role', user.role.displayName),
                      const Divider(height: 24),
                      _buildDetailRow('Account Created', Formatters.formatDate(user.createdAt)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Security & Actions Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security & Session',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.password, color: AppColors.primary),
                        title: const Text('Change Password'),
                        subtitle: const Text('Update your password regularly for better security'),
                        trailing: OutlinedButton(
                          onPressed: () => _openChangePassword(context, ref),
                          child: const Text('Change'),
                        ),
                      ),
                      const Divider(height: 24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.logout, color: AppColors.error),
                        title: const Text(
                          'Sign Out',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text('Terminate your current session securely'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorLight,
                            foregroundColor: AppColors.errorDark,
                            elevation: 0,
                          ),
                          onPressed: () async {
                            final confirm = await ConfirmDialog.show(
                              context: context,
                              title: 'Sign Out',
                              message: 'Are you sure you want to sign out?',
                              confirmLabel: 'Sign Out',
                              isDestructive: true,
                            );
                            if (confirm && context.mounted) {
                              await ref.read(authNotifierProvider.notifier).logout();
                              context.go(RouteConstants.loginPath);
                            }
                          },
                          child: const Text('Sign Out'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.slate500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
