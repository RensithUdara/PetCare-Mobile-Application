import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Colourful branded app bar: brand gradient reaching under the status
/// bar, soft decorative circles and a bold white title.
///
/// * [BrandAppBar.new] — main tabs: logo tile + title in the centre.
/// * [BrandAppBar.page] — every other screen: glass back button, title.
///
/// Icons, text buttons and tabs placed in it are styled white.
class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandAppBar({
    super.key,
    this.title = AppConstants.appName,
    this.actions = const [],
    this.bottom,
  }) : _page = false;

  const BrandAppBar.page({
    super.key,
    required this.title,
    this.actions = const [],
    this.bottom,
  }) : _page = true;

  final String title;
  final bool _page;

  /// Usually [BrandActionButton]s.
  final List<Widget> actions;

  /// Optional content under the title row (search field, tabs…), laid out
  /// on the gradient.
  final PreferredSizeWidget? bottom;

  double get _toolbarHeight => _page ? 66 : 72;

  @override
  Size get preferredSize => Size.fromHeight(_toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradient = isDark ? AppColors.brandGradientDark : AppColors.brandGradient;
    final route = ModalRoute.of(context);
    final canPop = route?.canPop ?? false;
    final isDialog = route is PageRoute && route.fullscreenDialog;
    const white70 = Color(0xD9FFFFFF);

    final Widget? leading;
    final double leadingWidth;
    if (_page) {
      leading = canPop
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: BrandActionButton(
                  icon: isDialog ? Icons.close_rounded : Icons.arrow_back_rounded,
                  tooltip: isDialog ? 'Close' : 'Back',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            )
          : null;
      leadingWidth = canPop ? 68 : 16;
    } else {
      leading = const SizedBox.shrink();
      // Keeps the title centred when there are actions on the right only.
      leadingWidth = actions.isEmpty ? 0 : 16.0 + 44 * actions.length + 8 * (actions.length - 1);
    }

    final bar = AppBar(
      toolbarHeight: _toolbarHeight,
      centerTitle: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leadingWidth: leadingWidth,
      leading: leading,
      titleSpacing: _page ? 12 : 0,
      title: _page
          ? Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            )
          : _BrandTitle(title: title),
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

    // White text buttons and tabs on the gradient.
    return Theme(
      data: theme.copyWith(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white54,
            textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        tabBarTheme: theme.tabBarTheme.copyWith(
          labelColor: Colors.white,
          unselectedLabelColor: white70,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.white, width: 3),
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
        ),
      ),
      child: bar,
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
