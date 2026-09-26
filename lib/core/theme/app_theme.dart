import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized Material 3 theme for PetCare: colourful, soft shadows,
/// rounded shapes. Screens get the modern look from here automatically —
/// avoid styling individual widgets unless a screen needs something special.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  /// Soft, slightly tinted drop shadow used for cards and floating surfaces.
  static List<BoxShadow> softShadow(BuildContext context, {Color? tint, double strength = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = tint ?? (isDark ? Colors.black : AppColors.navy);
    return [
      BoxShadow(
        color: base.withValues(alpha: (isDark ? 0.45 : 0.10) * strength),
        blurRadius: 24,
        spreadRadius: -4,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: base.withValues(alpha: (isDark ? 0.25 : 0.05) * strength),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    var scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: brightness,
      secondary: isDark ? null : AppColors.blue,
      error: isDark ? null : AppColors.danger,
    );
    scheme = isDark
        ? scheme.copyWith(
            surface: const Color(0xFF121A21),
            surfaceContainerLowest: const Color(0xFF0D1318),
            surfaceContainerLow: const Color(0xFF17212A),
            surfaceContainer: const Color(0xFF1B2630),
            surfaceContainerHigh: const Color(0xFF212E39),
            surfaceContainerHighest: const Color(0xFF283643),
          )
        : scheme.copyWith(
            surface: Colors.white,
            onSurface: AppColors.navy,
            surfaceContainerLowest: Colors.white,
            surfaceContainerLow: const Color(0xFFF7F9FC),
            surfaceContainer: const Color(0xFFF1F5F9),
            surfaceContainerHigh: const Color(0xFFEAF0F6),
            surfaceContainerHighest: const Color(0xFFE2E9F1),
          );

    final background = isDark ? const Color(0xFF0D1318) : const Color(0xFFF3F6FB);
    final cardColor = isDark ? scheme.surfaceContainer : Colors.white;
    final shadowColor = isDark ? Colors.black : AppColors.navy.withValues(alpha: 0.35);
    final radius = BorderRadius.circular(20);
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final text = base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      extensions: [isDark ? StatusColors.dark : StatusColors.light],
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 2 : 6,
        shadowColor: shadowColor.withValues(alpha: isDark ? 0.6 : 0.18),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: 0.4), space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? scheme.surfaceContainerHigh : const Color(0xFFF1F5F9),
        prefixIconColor: scheme.primary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          elevation: 3,
          shadowColor: scheme.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: text.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.5), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: text.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 6,
        highlightElevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        extendedTextStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
        backgroundColor: isDark ? scheme.surfaceContainerHigh : const Color(0xFFF1F5F9),
        selectedColor: scheme.primaryContainer,
        labelStyle: text.labelLarge?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primary,
          selectedForegroundColor: scheme.onPrimary,
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.primary : null,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        elevation: 12,
        shadowColor: shadowColor,
        surfaceTintColor: Colors.transparent,
        backgroundColor: isDark ? scheme.surfaceContainer : Colors.white,
        indicatorColor: scheme.primary.withValues(alpha: isDark ? 0.3 : 0.14),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => (text.labelMedium ?? const TextStyle()).copyWith(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: scheme.primary, width: 3),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        surfaceTintColor: Colors.transparent,
        backgroundColor: cardColor,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: cardColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: isDark ? scheme.surfaceContainerHighest : AppColors.navy,
        contentTextStyle: text.bodyMedium?.copyWith(color: isDark ? scheme.onSurface : Colors.white),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        surfaceTintColor: Colors.transparent,
        color: cardColor,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withValues(alpha: 0.12),
      ),
    );
  }
}
