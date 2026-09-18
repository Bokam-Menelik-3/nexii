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
            color: customAccent ?? (isDark ? NexiiColors.deepBorder : NexiiColors.lightBorder),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (customAccent ?? NexiiColors.primary).withValues(alpha: isDark ? 0.2 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        );
        break;
      case SurfaceTier.secondary:
        decoration = BoxDecoration(
          color: isDark ? NexiiColors.deepSurfacePrimary : NexiiColors.lightSurfacePrimary,
          borderRadius: BorderRadius.circular(NexiiRadii.xl),
          border: Border.all(
            color: isDark ? NexiiColors.deepBorder : NexiiColors.lightBorder,
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
              color: (customAccent ?? NexiiColors.primary).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
        break;
      case SurfaceTier.glass:
        decoration = BoxDecoration(
          color: (isDark ? NexiiColors.deepElevated : Colors.white).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(NexiiRadii.xl),
          border: Border.all(
            color: (isDark ? NexiiColors.deepBorder : NexiiColors.lightBorder).withValues(alpha: 0.5),
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

/// Breathing visual widget representing Aura score (0–100) dynamically.
class AuraVisualWidget extends StatefulWidget {
  final int score;
  final double size;

  const AuraVisualWidget({
    super.key,
    required this.score,
    this.size = 64.0,
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
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
            gradient: RadialGradient(
              colors: [
                auraColor.withValues(alpha: 0.8),
                auraColor.withValues(alpha: 0.2),
                Colors.transparent,
              ],
              stops: const [0.3, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: auraColor.withValues(alpha: 0.3 * _breathingAnimation.value),
                blurRadius: 16 * _breathingAnimation.value,
                spreadRadius: 4 * _breathingAnimation.value,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${widget.score}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
