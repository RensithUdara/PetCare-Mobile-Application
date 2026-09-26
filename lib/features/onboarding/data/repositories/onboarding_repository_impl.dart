import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/shared_preferences_provider.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  bool isComplete() => _prefs.getBool(PrefKeys.onboardingComplete) ?? false;

  @override
  Future<void> markComplete() => _prefs.setBool(PrefKeys.onboardingComplete, true);
}
