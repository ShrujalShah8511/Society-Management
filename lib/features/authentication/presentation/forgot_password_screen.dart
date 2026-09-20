import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'auth_notifier.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  bool _isSubmitted = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref.read(authNotifierProvider.notifier).sendPasswordReset(
          emailOrMobile: _identifierController.text.trim(),
        );

    setState(() {
      _isLoading = false;
      if (success) {
        _isSubmitted = true;
      } else {
        _errorMessage = ref.read(authNotifierProvider).errorMessage ?? 'Unable to send reset instructions';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.loginPath),
        ),
      ),
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
                child: _isSubmitted ? _buildSuccessView() : _buildFormView(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock_reset, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 20),
          Text(
            'Reset Password',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter your registered email address or mobile number to receive instructions to reset your password.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate500,
                ),
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.errorDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
          AppTextField(
            controller: _identifierController,
            label: 'Email or Mobile Number',
            hint: 'name@society.com or 9876543210',
            prefixIcon: Icons.mark_email_read_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.emailOrMobile,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Send Reset Instructions',
            isLoading: _isLoading,
            onPressed: _handleSubmit,
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Back to Sign In',
            variant: AppButtonVariant.text,
            onPressed: () => context.go(RouteConstants.loginPath),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: AppColors.successDark, size: 32),
        ),
        const SizedBox(height: 20),
        Text(
          'Instructions Sent',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We have dispatched password reset verification instructions to ${_identifierController.text.trim()}.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.slate500,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        AppButton(
          text: 'Return to Login',
          onPressed: () => context.go(RouteConstants.loginPath),
        ),
      ],
    );
  }
}
