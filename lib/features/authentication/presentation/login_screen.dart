import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(text: 'admin@society.com');
  final _passwordController = TextEditingController(text: 'admin123');

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).login(
          emailOrMobile: _identifierController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go(RouteConstants.dashboardPath);
    }
  }

  void _quickFill(String email, String password) {
    setState(() {
      _identifierController.text = email;
      _passwordController.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Logo & Branding
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.apartment_rounded,
                              color: AppColors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppConstants.appName,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                Text(
                                  'Phase 1 Administration',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.slate500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in with your email or registered mobile number.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.slate500,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Error message if any
                      if (authState.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  authState.errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.errorDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Email / Mobile Field
                      AppTextField(
                        key: const Key('login_identifier_field'),
                        controller: _identifierController,
                        label: 'Email or Mobile Number',
                        hint: 'name@society.com or 9876543210',
                        prefixIcon: Icons.person_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.emailOrMobile,
                      ),
                      const SizedBox(height: 18),

                      // Password Field
                      AppTextField(
                        key: const Key('login_password_field'),
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: Validators.password,
                        onSubmitted: (_) => _handleLogin(),
                      ),
                      const SizedBox(height: 10),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.push(RouteConstants.forgotPasswordPath);
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Submit Button
                      AppButton(
                        key: const Key('login_submit_button'),
                        text: 'Sign In',
                        isLoading: authState.status == AuthStatus.loading,
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 24),

                      // Quick Fill Roles for Fast Evaluation
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Demo Credentials (Switch Roles):',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.slate500,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildRoleChip('Society Admin', 'admin@society.com', 'admin123'),
                          _buildRoleChip('Resident', 'resident@society.com', 'resident123'),
                          _buildRoleChip('Super Admin', 'superadmin@society.com', 'super123'),
                          _buildRoleChip('Security', 'security@society.com', 'security123'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String label, String email, String password) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () => _quickFill(email, password),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}
