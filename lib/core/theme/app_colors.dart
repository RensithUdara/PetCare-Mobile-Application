import 'package:flutter/material.dart';

/// Raw brand palette. Screens should not use these directly — read colors
/// from `Theme.of(context).colorScheme` or the [StatusColors] extension.
abstract final class AppColors {
  static const teal = Color(0xFF14A38B);
  static const blue = Color(0xFF3B82F6);
  static const navy = Color(0xFF0F2742);
  static const background = Color(0xFFF6F8FA);

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
