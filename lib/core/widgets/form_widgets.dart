import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'modern_widgets.dart';

/// A titled group of form fields in one soft card.
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final FeatureAccent accent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(title: title, icon: icon, accent: accent),
        SoftCard(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (subtitle != null) ...[
                Text(subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 14),
              ],
              for (final (i, child) in children.indexed) ...[
                if (i > 0) const SizedBox(height: 14),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Small bold label above a group of choices inside a [FormSection].
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
      );
}

/// Selectable tile with an icon (or emoji) on top of a label — for
/// species, gender, appointment types…
class SelectTile extends StatelessWidget {
  const SelectTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.accent,
    this.icon,
    this.emoji,
    this.enabled = true,
  }) : assert(icon != null || emoji != null);

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final FeatureAccent accent;
  final IconData? icon;
  final String? emoji;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = accent.color;
    final idle = isDark ? theme.colorScheme.surfaceContainerHigh : const Color(0xFFF1F5F9);

    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: isDark ? 0.25 : 0.12) : idle,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? color : Colors.transparent, width: 2),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: selected ? accent.gradient : null,
                      color: selected ? null : (isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white),
                    ),
                    child: emoji != null
                        ? Text(emoji!, style: const TextStyle(fontSize: 22))
                        : Icon(icon, size: 22, color: selected ? Colors.white : color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? (isDark ? Colors.white : accent.deep) : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays [children] out in rows of [columns] equal-width cells.
class TileGrid extends StatelessWidget {
  const TileGrid({super.key, required this.children, this.columns = 3, this.spacing = 10});

  final List<Widget> children;
  final int columns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [for (final c in children) SizedBox(width: width, child: c)],
      );
    });
  }
}

/// Sticky bottom bar holding a form's main button.
class FormSaveBar extends StatelessWidget {
  const FormSaveBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.busyLabel,
    this.icon = Icons.check_rounded,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final String? busyLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainer : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.navy).withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: FilledButton(
            onPressed: busy ? null : onPressed,
            child: busy
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      if (busyLabel != null) ...[const SizedBox(width: 12), Text(busyLabel!)],
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(icon), const SizedBox(width: 8), Text(label)],
                  ),
          ),
        ),
      ),
    );
  }
}
