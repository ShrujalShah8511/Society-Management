import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Staggered entrance animation (Fade + Slide Up) for page elements and list items.
class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  const AnimatedEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 250),
    this.offset = const Offset(0, 0.04),
  });

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Luxury Interactive card with mouse hover lift, scale, tactile press, and neon glow.
class HoverLiftCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final Border? border;
  final Color? hoverBorderColor;
  final Color? glowColor;
  final double hoverElevation;
  final double scaleFactor;

  const HoverLiftCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.borderRadius,
    this.border,
    this.hoverBorderColor,
    this.glowColor,
    this.hoverElevation = 8,
    this.scaleFactor = 1.018,
  });

  @override
  State<HoverLiftCard> createState() => _HoverLiftCardState();
}

class _HoverLiftCardState extends State<HoverLiftCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(18);
    final defaultBg = widget.color ?? (isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight);
    final defaultBorderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final effectiveGlowColor = widget.glowColor ?? AppColors.primary;
    final activeBorderColor = widget.hoverBorderColor ??
        (isDark ? effectiveGlowColor.withValues(alpha: 0.7) : effectiveGlowColor.withValues(alpha: 0.5));

    final currentScale = _isPressed ? 0.985 : (_isHovered ? widget.scaleFactor : 1.0);

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: currentScale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            margin: widget.margin,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.gradient == null ? defaultBg : null,
              gradient: widget.gradient,
              borderRadius: borderRadius,
              border: widget.border ??
                  Border.all(
                    color: _isHovered ? activeBorderColor : defaultBorderColor,
                    width: _isHovered ? 1.4 : 1.0,
                  ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: effectiveGlowColor.withValues(alpha: isDark ? 0.22 : 0.10),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.5) : AppColors.slate300.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.slate200.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Smooth easing numeric counter animation for KPI stats.
class AnimatedCountNumber extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final String prefix;
  final String suffix;

  const AnimatedCountNumber({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 750),
    this.prefix = '',
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Text(
          '$prefix${val.round()}$suffix',
          style: style,
        );
      },
    );
  }
}

/// Animated segmented horizontal progress bar with ease-out reveal.
class AnimatedSegmentedBar extends StatelessWidget {
  final List<BarSegment> segments;
  final double height;
  final double borderRadius;
  final Duration duration;

  const AnimatedSegmentedBar({
    super.key,
    required this.segments,
    this.height = 12,
    this.borderRadius = 8,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<int>(0, (sum, s) => sum + s.value);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        if (total == 0) {
          return Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.slate200,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            height: height,
            child: Row(
              children: segments.where((s) => s.value > 0).map((segment) {
                final ratio = segment.value / total;
                return Expanded(
                  flex: (ratio * 1000 * progress).clamp(1, 1000).toInt(),
                  child: Container(
                    color: segment.color,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class BarSegment {
  final int value;
  final Color color;
  final String label;

  const BarSegment({
    required this.value,
    required this.color,
    required this.label,
  });
}

/// Subtle glowing status dot with ambient halo indicator.
class PulsingStatusDot extends StatelessWidget {
  final Color color;
  final double size;

  const PulsingStatusDot({
    super.key,
    required this.color,
    this.size = 7,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size + 6,
          height: size + 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.25),
          ),
        ),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.65),
                blurRadius: 6,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
