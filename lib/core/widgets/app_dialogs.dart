import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shows [child] as a popup that scales and fades in.
Future<T?> _showPopup<T>(BuildContext context, Widget child, {bool dismissible = true}) =>
    showGeneralDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, _, _) => child,
      transitionBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(scale: Tween(begin: 0.85, end: 1.0).animate(curved), child: child),
        );
      },
    );

/// Rounded card used by the app's popups.
class _PopupCard extends StatelessWidget {
  const _PopupCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Material(
            color: isDark ? theme.colorScheme.surfaceContainer : Colors.white,
            borderRadius: BorderRadius.circular(28),
            elevation: 16,
            shadowColor: Colors.black.withValues(alpha: 0.3),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradient circle with a soft halo, used as the popup's hero icon.
class _HaloIcon extends StatelessWidget {
  const _HaloIcon({required this.gradient, required this.color, required this.child});

  final Gradient gradient;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12)),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: child,
        ),
      ),
    );
  }
}

List<Widget> _texts(BuildContext context, String title, String? message) {
  final theme = Theme.of(context);
  return [
    const SizedBox(height: 18),
    Text(title,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
    if (message != null) ...[
      const SizedBox(height: 8),
      Text(message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.4)),
    ],
    const SizedBox(height: 24),
  ];
}

/// Asks the user to confirm an action. Resolves to `true` only when they
/// tap [confirmLabel]; dismissing or cancelling gives `false`.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  IconData icon = Icons.help_outline_rounded,
  FeatureAccent accent = FeatureAccent.pets,
  bool destructive = false,
}) async {
  final result = await _showPopup<bool>(
    context,
    Builder(builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      final a = destructive ? FeatureAccent.emergency : accent;
      return _PopupCard(children: [
        _HaloIcon(
          gradient: a.gradient,
          color: a.color,
          child: Icon(icon, color: Colors.white, size: 36),
        ),
        ..._texts(context, title, message),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: destructive ? scheme.error : null,
                  foregroundColor: destructive ? scheme.onError : null,
                  shadowColor: destructive ? scheme.error.withValues(alpha: 0.5) : null,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmLabel),
              ),
            ),
          ],
        ),
      ]);
    }),
  );
  return result ?? false;
}

/// Celebrates a completed action with an animated check. Closes itself
/// after a short countdown, or when the user taps [buttonLabel].
Future<void> showSuccessDialog(
  BuildContext context, {
  required String title,
  String? message,
  String buttonLabel = 'Done',
  Duration autoClose = const Duration(milliseconds: 2200),
}) =>
    _showPopup<void>(
      context,
      _SuccessPopup(title: title, message: message, buttonLabel: buttonLabel, autoClose: autoClose),
    );

class _SuccessPopup extends StatefulWidget {
  const _SuccessPopup({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.autoClose,
  });

  final String title;
  final String? message;
  final String buttonLabel;
  final Duration autoClose;

  @override
  State<_SuccessPopup> createState() => _SuccessPopupState();
}

class _SuccessPopupState extends State<_SuccessPopup> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: widget.autoClose)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) _close();
    })
    ..forward();
  bool _closed = false;

  void _close() {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = FeatureAccent.vaccinations;
    // The check draws during the first 40% of the countdown.
    final draw = CurvedAnimation(parent: _controller, curve: const Interval(0.05, 0.4, curve: Curves.easeOutCubic));

    return _PopupCard(children: [
      _HaloIcon(
        gradient: accent.gradient,
        color: accent.color,
        child: AnimatedBuilder(
          animation: draw,
          builder: (_, _) => CustomPaint(size: const Size.square(38), painter: _CheckPainter(draw.value)),
        ),
      ),
      ..._texts(context, widget.title, widget.message),
      FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: accent.color,
          shadowColor: accent.color.withValues(alpha: 0.5),
        ),
        onPressed: _close,
        child: Text(widget.buttonLabel),
      ),
      const SizedBox(height: 14),
      // Countdown until the popup closes itself.
      AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: 1 - _controller.value,
            minHeight: 3,
            color: accent.color,
            backgroundColor: accent.color.withValues(alpha: 0.12),
          ),
        ),
      ),
    ]);
  }
}

/// A white tick drawn progressively as [progress] goes from 0 to 1.
class _CheckPainter extends CustomPainter {
  _CheckPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.53)
      ..lineTo(size.width * 0.42, size.height * 0.76)
      ..lineTo(size.width * 0.84, size.height * 0.28);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.13
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * math.min(1, progress)), paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}
