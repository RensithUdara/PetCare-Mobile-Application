import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/storage/shared_preferences_provider.dart';
import 'package:petcare/core/theme/theme_mode_controller.dart';
import 'package:petcare/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<(ProviderContainer, SharedPreferences)> _container(
  Map<String, Object> initial,
) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return (container, prefs);
}

void main() {
  group('ThemeModeController', () {
    test('defaults to system', () async {
      final (container, _) = await _container({});
      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('restores and persists the chosen mode', () async {
      final (container, prefs) =
          await _container({PrefKeys.themeMode: 'dark'});
      expect(container.read(themeModeProvider), ThemeMode.dark);

      await container.read(themeModeProvider.notifier).setMode(ThemeMode.light);
      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(prefs.getString(PrefKeys.themeMode), 'light');
    });
  });

  group('OnboardingController', () {
    test('is incomplete by default and persists completion', () async {
      final (container, prefs) = await _container({});
      expect(container.read(onboardingCompleteProvider), isFalse);

      await container.read(onboardingCompleteProvider.notifier).complete();
      expect(container.read(onboardingCompleteProvider), isTrue);
      expect(prefs.getBool(PrefKeys.onboardingComplete), isTrue);
    });
  });
}
