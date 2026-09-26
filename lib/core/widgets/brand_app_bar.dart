import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Colourful branded app bar for the main tabs: brand gradient reaching
/// under the status bar, soft decorative circles, the logo tile with a bold
/// title in the centre, and glass-style [BrandActionButton]s on the right.
class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandAppBar({
    super.key,
    this.title = AppConstants.appName,
    this.actions = const [],
    this.bottom,
  });

  final String title;

  /// Usually [BrandActionButton]s.
  final List<Widget> actions;

  /// Optional content under the title row (search field, tabs…), laid out
  /// on the gradient.
  final PreferredSizeWidget? bottom;

  static const _toolbarHeight = 72.0;

  @override
  Size get preferredSize => Size.fromHeight(_toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppColors.brandGradientDark : AppColors.brandGradient;

    return AppBar(
      toolbarHeight: _toolbarHeight,
      centerTitle: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      // Keeps the title centred when there are actions on the right only.
      leadingWidth: actions.isEmpty ? 0 : 16.0 + 44 * actions.length + 8 * (actions.length - 1),
      leading: const SizedBox.shrink(),
      titleSpacing: 0,
      title: _BrandTitle(title: title),
      actions: [
        for (final (i, action) in actions.indexed) ...[
          if (i > 0) const SizedBox(width: 8),
          action,
        ],
        const SizedBox(width: 16),
      ],
      bottom: bottom,
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const ClipRect(
          child: Stack(
            children: [
              Positioned(left: -60, top: -30, child: _Circle(size: 190, opacity: 0.10)),
              Positioned(right: -34, top: -48, child: _Circle(size: 150, opacity: 0.14)),
              Positioned(right: 70, bottom: -70, child: _Circle(size: 120, opacity: 0.07)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/app_icon.png',
            semanticLabel: AppConstants.appName,
            errorBuilder: (_, _, _) => Image.asset('assets/images/app_logo_splash.png'),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
          ),
        ),
      ],
    );
  }
}

/// Translucent rounded-square icon button for [BrandAppBar], with an
/// optional count badge (e.g. unread alerts).
class BrandActionButton extends StatelessWidget {
  const BrandActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(14);
    return Tooltip(
      message: tooltip,
      child: Badge(
        isLabelVisible: badgeCount > 0,
        label: Text(badgeCount > 9 ? '9+' : '$badgeCount'),
        backgroundColor: AppColors.danger,
        offset: const Offset(-2, 2),
        child: Material(
          color: Colors.white.withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(
            borderRadius: shape,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: InkWell(
            borderRadius: shape,
            onTap: onPressed,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, color: Colors.white, size: 24, semanticLabel: tooltip),
            ),
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.opacity});

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
