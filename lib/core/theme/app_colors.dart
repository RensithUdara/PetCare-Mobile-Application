import 'package:flutter/material.dart';

/// Raw brand palette. Screens should not use these directly — read colors
/// from `Theme.of(context).colorScheme` or the [StatusColors] extension.
abstract final class AppColors {
  static const teal = Color(0xFF14A38B);
  static const blue = Color(0xFF3B82F6);
  static const navy = Color(0xFF0F2742);
  static const background = Color(0xFFF6F8FA);

  // Brand gradient (teal → blue) used for hero headers and primary accents.
  static const tealDeep = Color(0xFF0E8A76);
  static const sky = Color(0xFF4F8DF7);
  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF12B39A), Color(0xFF3B82F6)],
  );
  static const brandGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B6E60), Color(0xFF1E4FA8)],
  );

  static const success = Color(0xFF22A06B);
  static const warning = Color(0xFFE2A400);
  static const danger = Color(0xFFD64545);
  static const info = Color(0xFF3B82F6);
}

/// Semantic status colors (up to date / upcoming / overdue / info),
/// exposed as a [ThemeExtension] so they adapt to light and dark mode.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  static const light = StatusColors(
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    info: AppColors.info,
  );

  static const dark = StatusColors(
    success: Color(0xFF4CC38A),
    warning: Color(0xFFF5C542),
    danger: Color(0xFFF07171),
    info: Color(0xFF6EA8FE),
  );

  static StatusColors of(BuildContext context) =>
      Theme.of(context).extension<StatusColors>() ?? light;

  @override
  StatusColors copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
  }) {
    return StatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

/// One colour per feature so every screen shares the same visual language
/// (vaccinations are always teal, appointments always blue, …).
enum FeatureAccent {
  pets(Color(0xFF12B39A), Color(0xFF0E8A76)),
  vaccinations(Color(0xFF10B981), Color(0xFF059669)),
  appointments(Color(0xFF3B82F6), Color(0xFF2563EB)),
  medications(Color(0xFF8B5CF6), Color(0xFF7C3AED)),
  documents(Color(0xFFF59E0B), Color(0xFFEA580C)),
  weight(Color(0xFFEC4899), Color(0xFFDB2777)),
  emergency(Color(0xFFEF4444), Color(0xFFDC2626)),
  clinics(Color(0xFF06B6D4), Color(0xFF0891B2)),
  calendar(Color(0xFF6366F1), Color(0xFF4F46E5)),
  settings(Color(0xFF64748B), Color(0xFF475569));

  const FeatureAccent(this.color, this.deep);

  final Color color;
  final Color deep;

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, deep],
      );
}
