import 'package:flutter/material.dart';
import '../theme/nexii_colors.dart';

enum SurfaceTier { dominant, secondary, action, glass }

/// Reusable Adaptive Living Surface primitive for Nexii Adaptive Living OS.
class AdaptiveSurface extends StatelessWidget {
  final Widget child;
  final SurfaceTier tier;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? customAccent;

  const AdaptiveSurface({
    super.key,
    required this.child,
    this.tier = SurfaceTier.secondary,
    this.padding,
    this.margin,
    this.onTap,
    this.customAccent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    BoxDecoration decoration;

    switch (tier) {
      case SurfaceTier.dominant:
        decoration = BoxDecoration(
          color: isDark ? NexiiColors.deepElevated : NexiiColors.lightElevated,
          borderRadius: BorderRadius.circular(NexiiRadii.xxl),
          border: Border.all(
            color: customAccent?.withValues(alpha: 0.15) ?? (isDark ? NexiiColors.deepBorder.withValues(alpha: 0.5) : NexiiColors.lightBorder),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
            if (customAccent != null)
              BoxShadow(
                color: customAccent!.withValues(alpha: isDark ? 0.06 : 0.03),
                blurRadius: 32,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
          ],
        );
        break;
      case SurfaceTier.secondary:
        decoration = BoxDecoration(
          color: isDark ? NexiiColors.deepSurfacePrimary : NexiiColors.lightSurfacePrimary,
          borderRadius: BorderRadius.circular(NexiiRadii.xl),
          border: Border.all(
            color: isDark ? NexiiColors.deepBorder.withValues(alpha: 0.5) : NexiiColors.lightBorder.withValues(alpha: 0.5),
            width: 1.0,
          ),
        );
        break;
      case SurfaceTier.action:
        decoration = BoxDecoration(
          gradient: LinearGradient(
            colors: [
              customAccent ?? NexiiColors.primary,
              NexiiColors.primaryGradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(NexiiRadii.lg),
          boxShadow: [
            BoxShadow(
              color: (customAccent ?? NexiiColors.primary).withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
        break;
      case SurfaceTier.glass:
        decoration = BoxDecoration(
          color: (isDark ? NexiiColors.deepElevated : Colors.white).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(NexiiRadii.xl),
          border: Border.all(
            color: (isDark ? NexiiColors.deepBorder : NexiiColors.lightBorder).withValues(alpha: 0.3),
            width: 1.0,
          ),
        );
        break;
    }

    final content = AnimatedContainer(
      duration: NexiiMotion.normal,
      padding: padding ?? const EdgeInsets.all(NexiiSpacing.lg),
      margin: margin ?? const EdgeInsets.only(bottom: NexiiSpacing.md),
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

/// Ambient visual widget representing Aura score dynamically without numbers.
class AuraVisualWidget extends StatefulWidget {
  final int score;
  final double size;

  const AuraVisualWidget({
    super.key,
    required this.score,
    this.size = 12.0,
  });

  @override
  State<AuraVisualWidget> createState() => _AuraVisualWidgetState();
}

class _AuraVisualWidgetState extends State<AuraVisualWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: NexiiMotion.auraBreathing,
    );

    _breathingAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      if (_controller.isAnimating) _controller.stop();
    } else {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color auraColor = widget.score >= 80
        ? NexiiColors.success
        : widget.score >= 50
            ? NexiiColors.aiAccent
            : NexiiColors.warning;

    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * _breathingAnimation.value,
          height: widget.size * _breathingAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: auraColor.withValues(alpha: 0.8),
            boxShadow: [
              BoxShadow(
                color: auraColor.withValues(alpha: 0.4 * _breathingAnimation.value),
                blurRadius: 8 * _breathingAnimation.value,
                spreadRadius: 2 * _breathingAnimation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
