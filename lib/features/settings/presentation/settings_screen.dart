import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../authentication/presentation/auth_notifier.dart';
import 'settings_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showPlaceholderDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              Text(
                'Appearance & Theme',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Customize how the Society Management application looks on this device.',
                style: TextStyle(fontSize: 13, color: AppColors.slate500),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.system,
                      groupValue: settings.themeMode,
                      title: const Text('System Default'),
                      subtitle: const Text('Match system brightness automatically'),
                      secondary: const Icon(Icons.brightness_auto_outlined),
                      onChanged: (val) {
                        if (val != null) settingsNotifier.setThemeMode(val);
                      },
                    ),
                    const Divider(),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.light,
                      groupValue: settings.themeMode,
                      title: const Text('Light Mode'),
                      subtitle: const Text('Clean slate with high-contrast surfaces'),
                      secondary: const Icon(Icons.light_mode_outlined),
                      onChanged: (val) {
                        if (val != null) settingsNotifier.setThemeMode(val);
                      },
                    ),
                    const Divider(),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.dark,
                      groupValue: settings.themeMode,
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Eye-friendly dark palette for low light'),
                      secondary: const Icon(Icons.dark_mode_outlined),
                      onChanged: (val) {
                        if (val != null) settingsNotifier.setThemeMode(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Account Section
              Text(
                'Account Shortcuts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('View Profile'),
                      subtitle: const Text('Manage your name, mobile, and view roles'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go(RouteConstants.profilePath),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.error),
                      title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                      subtitle: const Text('Sign out from this session'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Application Section
              Text(
                'About & Policies',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('About Application'),
                      subtitle: const Text('Phase 1 Society Management Application'),
                      trailing: Text(
                        'v${AppConstants.appVersion}',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.slate500),
                      ),
                      onTap: () {
                        _showPlaceholderDialog(
                          context,
                          'About ${AppConstants.appName}',
                          '${AppConstants.appName} is a scalable single-codebase Flutter application engineered for multi-platform management across Android, iOS, and Web.\n\nPhase 1 Scope covers:\n• Authentication & Session\n• Role & Permissions Architecture\n• Society Profile Management\n• Tower Management\n• Floor Management\n• Flat Management\n• Role-Aware Dashboard & Settings.',
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy Policy'),
                      subtitle: const Text('Data protection and privacy guidelines'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showPlaceholderDialog(
                          context,
                          'Privacy Policy',
                          'This application values your privacy. Phase 1 manages resident account data, society identifiers, and flat inventory securely in accordance with local regulations.\n\nAll credentials and session tokens are stored using secure encryption mechanisms.',
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Terms & Conditions'),
                      subtitle: const Text('Standard society management terms of service'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showPlaceholderDialog(
                          context,
                          'Terms & Conditions',
                          'By accessing this application, society members and administrators agree to maintain the confidentiality of their credentials and adhere to society governance bylaws.',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
