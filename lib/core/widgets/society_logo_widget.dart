import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SocietyLogoWidget extends StatelessWidget {
  final String? logoUrl;
  final String? societyName;
  final double size;
  final double? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;
  final IconData fallbackIcon;
  final bool showInitialsWhenNoLogo;
  final VoidCallback? onTap;

  const SocietyLogoWidget({
    super.key,
    this.logoUrl,
    this.societyName,
    this.size = 40,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.backgroundColor,
    this.fallbackIcon = Icons.apartment_rounded,
    this.showInitialsWhenNoLogo = true,
    this.onTap,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) {
      final w = parts[0];
      return w.length >= 2 ? w.substring(0, 2).toUpperCase() : w.toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _buildFallback(BuildContext context, double radius) {
    final name = societyName?.trim() ?? '';
    final hasInitials = showInitialsWhenNoLogo && name.isNotEmpty && name.length >= 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: hasInitials
          ? Text(
              _getInitials(name),
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.4,
                letterSpacing: 0.5,
              ),
            )
          : Icon(
              fallbackIcon,
              color: AppColors.white,
              size: size * 0.55,
            ),
    );
  }

  Widget _buildImageContent(BuildContext context, double radius) {
    final url = logoUrl?.trim();
    if (url == null || url.isEmpty) {
      return _buildFallback(context, radius);
    }

    // 1. Data URL (Base64)
    if (url.startsWith('data:image/')) {
      try {
        final commaIndex = url.indexOf(',');
        final base64String = commaIndex != -1 ? url.substring(commaIndex + 1) : url;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(context, radius),
        );
      } catch (_) {
        return _buildFallback(context, radius);
      }
    }

    // 2. HTTP / HTTPS Network Image
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(context, radius),
      );
    }

    // 3. Local Flutter Asset
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallback(context, radius),
      );
    }

    // 4. Raw base64 string
    if (url.length > 50 && !url.contains(' ') && !url.contains('/')) {
      try {
        final bytes = base64Decode(url);
        return Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(context, radius),
        );
      } catch (_) {
        return _buildFallback(context, radius);
      }
    }

    // Fallback if unsupported format
    return _buildFallback(context, radius);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? (size * 0.28);
    final hasLogo = logoUrl != null && logoUrl!.trim().isNotEmpty;

    Widget container = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? (hasLogo ? AppColors.white : null),
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: border ??
            Border.all(
              color: hasLogo ? AppColors.borderLight : Colors.transparent,
              width: 1,
            ),
        boxShadow: boxShadow ??
            (hasLogo
                ? [
                    BoxShadow(
                      color: AppColors.slate900.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: _buildImageContent(context, effectiveRadius),
      ),
    );

    if (onTap != null) {
      container = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: container,
      );
    }

    return container;
  }
}
