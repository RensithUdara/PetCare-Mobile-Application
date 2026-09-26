import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/storage/shared_preferences_provider.dart';
import 'package:petcare/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:petcare/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('pages through onboarding and completes it', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    expect(find.text('Manage Your Pets'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Keep Medical Records Safe'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pump();
    expect(container.read(onboardingCompleteProvider), isTrue);
  });
}
