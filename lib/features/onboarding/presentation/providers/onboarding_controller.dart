import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/shared_preferences_provider.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/usecases/complete_onboarding.dart';
import '../../domain/usecases/get_onboarding_status.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepositoryImpl(ref.watch(sharedPreferencesProvider)),
);

final getOnboardingStatusProvider =
    Provider((ref) => GetOnboardingStatus(ref.watch(onboardingRepositoryProvider)));
final completeOnboardingProvider =
    Provider((ref) => CompleteOnboarding(ref.watch(onboardingRepositoryProvider)));

/// Whether the user has finished the first-run onboarding.
class OnboardingController extends Notifier<bool> {
  @override
  bool build() => ref.read(getOnboardingStatusProvider)();

  Future<void> complete() async {
    state = true;
    await ref.read(completeOnboardingProvider)();
  }
}

final onboardingCompleteProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);
