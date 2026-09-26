import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum StatusTone { success, warning, danger, info, neutral }

extension StatusToneColor on StatusTone {
  Color colorOf(BuildContext context) {
    final colors = StatusColors.of(context);
    return switch (this) {
      StatusTone.success => colors.success,
      StatusTone.warning => colors.warning,
      StatusTone.danger => colors.danger,
      StatusTone.info => colors.info,
      StatusTone.neutral => Theme.of(context).colorScheme.onSurfaceVariant,
    };
  }
}

/// Small pill used for statuses like "Up to date", "Upcoming", "Overdue".
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final color = tone.colorOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
