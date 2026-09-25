import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/shared_preferences_provider.dart';

/// Whether the user has finished the first-run onboarding.
class OnboardingController extends Notifier<bool> {
  @override
  bool build() =>
      ref.read(sharedPreferencesProvider).getBool(PrefKeys.onboardingComplete) ??
      false;

  Future<void> complete() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(PrefKeys.onboardingComplete, true);
  }
}

final onboardingCompleteProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);
