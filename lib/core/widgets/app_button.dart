import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outlined, text, danger, gradient }

class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = widget.isLoading ? null : widget.onPressed;

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.variant == AppButtonVariant.outlined || widget.variant == AppButtonVariant.text
                    ? AppColors.primary
                    : AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.1,
            height: 1.15,
          ),
        ),
      ],
    );

    Widget buttonWidget;

    if (widget.variant == AppButtonVariant.gradient || widget.variant == AppButtonVariant.primary) {
      // Modern Indigo-Violet Gradient Button with ambient glow
      final bool isEnabled = effectiveOnPressed != null;
      buttonWidget = Container(
        decoration: BoxDecoration(
          gradient: isEnabled ? AppGradients.primary : null,
          color: isEnabled ? null : AppColors.slate300,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled && _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : (isEnabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null),
        ),
        child: ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: Size(0, widget.height),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            alignment: Alignment.center,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: buttonChild,
        ),
      );
    } else {
      switch (widget.variant) {
        case AppButtonVariant.secondary:
          buttonWidget = ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.slate700,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: Size(0, widget.height),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: buttonChild,
          );
          break;
        case AppButtonVariant.outlined:
          buttonWidget = OutlinedButton(
            onPressed: effectiveOnPressed,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: Size(0, widget.height),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: buttonChild,
          );
          break;
        case AppButtonVariant.text:
          buttonWidget = TextButton(
            onPressed: effectiveOnPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size(0, widget.height),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.center,
            ),
            child: buttonChild,
          );
          break;
        case AppButtonVariant.danger:
          buttonWidget = ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: Size(0, widget.height),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: buttonChild,
          );
          break;
        default:
          buttonWidget = ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: Size(0, widget.height),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: buttonChild,
          );
      }
    }

    final scale = _isPressed ? 0.97 : (_isHovered ? 1.015 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: widget.onPressed != null ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: widget.onPressed != null ? () => setState(() => _isPressed = false) : null,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: buttonWidget,
          ),
        ),
      ),
    );
  }
}
