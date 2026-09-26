import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Rounded square with a gradient and a white icon — the app's colourful
/// "feature icon" (use a [FeatureAccent] for consistency).
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.accent, this.size = 44});

  final IconData icon;
  final FeatureAccent accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: accent.gradient,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: accent.color.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.5),
    );
  }
}

/// A container with the app's soft shadow, optionally filled with a
/// gradient. Use for custom boxes that aren't `Card`s.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
    this.color,
    this.radius = 20,
    this.onTap,
    this.shadowTint,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? color;
  final double radius;
  final VoidCallback? onTap;
  final Color? shadowTint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        gradient: gradient,
        color: gradient == null ? (color ?? (isDark ? scheme.surfaceContainer : Colors.white)) : null,
        boxShadow: AppTheme.softShadow(context, tint: shadowTint),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: shape,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Gradient hero banner with rounded bottom corners, used at the top of
/// the dashboard, profiles and auth screens. Content is laid out in white.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.child,
    this.gradient,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 28),
    this.bottomRadius = 32,
  });

  final Widget child;
  final Gradient? gradient;
  final EdgeInsetsGeometry padding;
  final double bottomRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final g = gradient ?? (isDark ? AppColors.brandGradientDark : AppColors.brandGradient);
    final firstColor = g is LinearGradient ? g.colors.first : AppColors.teal;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: g,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(bottomRadius)),
        boxShadow: [
          BoxShadow(
            color: firstColor.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative bubbles for depth.
          Positioned(right: -40, top: -30, child: _Bubble(size: 150, opacity: 0.12)),
          Positioned(right: 60, bottom: -50, child: _Bubble(size: 110, opacity: 0.08)),
          Padding(
            padding: padding,
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.white),
              child: IconTheme.merge(data: const IconThemeData(color: Colors.white), child: child),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );
}

/// Section title with a small coloured icon and optional action.
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.icon,
    this.accent = FeatureAccent.pets,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final IconData? icon;
  final FeatureAccent accent;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            IconBadge(icon: icon!, accent: accent, size: 30),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
          if (actionLabel != null) TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// White translucent pill used on gradient headers (quick stats).
class HeaderStat extends StatelessWidget {
  const HeaderStat({super.key, required this.value, required this.label, this.icon});

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            if (icon != null) Icon(icon, color: Colors.white, size: 20),
            Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
