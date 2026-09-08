import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outlined, text, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.outlined || variant == AppButtonVariant.text
                    ? AppColors.primary
                    : AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );

    Widget buttonWidget;
    switch (variant) {
      case AppButtonVariant.primary:
        buttonWidget = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
          child: buttonChild,
        );
        break;
      case AppButtonVariant.secondary:
        buttonWidget = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.slate700,
            foregroundColor: AppColors.white,
          ),
          child: buttonChild,
        );
        break;
      case AppButtonVariant.outlined:
        buttonWidget = OutlinedButton(
          onPressed: effectiveOnPressed,
          child: buttonChild,
        );
        break;
      case AppButtonVariant.text:
        buttonWidget = TextButton(
          onPressed: effectiveOnPressed,
          child: buttonChild,
        );
        break;
      case AppButtonVariant.danger:
        buttonWidget = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
          ),
          child: buttonChild,
        );
        break;
    }

    if (width != null) {
      return SizedBox(
        width: width,
        height: height,
        child: buttonWidget,
      );
    }

    return SizedBox(
      height: height,
      child: buttonWidget,
    );
  }
}
