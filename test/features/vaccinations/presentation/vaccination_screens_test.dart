import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/core/utils/clock.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/presentation/providers/pet_providers.dart';
import 'package:petcare/features/vaccinations/domain/entities/vaccination.dart';
import 'package:petcare/features/vaccinations/presentation/screens/vaccination_form_screen.dart';
import 'package:petcare/features/vaccinations/presentation/screens/vaccinations_screen.dart';
import 'package:petcare/features/vaccinations/presentation/providers/vaccination_providers.dart';
import 'package:petcare/features/vaccinations/presentation/widgets/vaccination_formatters.dart';

import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/fake_vaccination_repository.dart';

void main() {
  final now = DateTime(2026, 9, 26, 10);
  const bruno = Pet(id: 'p1', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog);

  Vaccination vac(String id, String name, DateTime given, [DateTime? due]) => Vaccination(
        id: id,
        ownerId: 'u1',
        petId: 'p1',
        vaccineName: name,
        dateAdministered: given,
        nextDueDate: due,
      );

  Future<void> pump(WidgetTester tester, FakeVaccinationRepository repo, Widget screen) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/screen',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Text('previous page'),
          routes: [GoRoute(path: 'screen', builder: (_, _) => screen)],
        ),
        GoRoute(path: '/pets/:petId/vaccinations/:id', builder: (_, s) => Text('details ${s.pathParameters['id']}')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('u1'),
        clockProvider.overrideWithValue(() => now),
        petRepositoryProvider.overrideWithValue(FakePetRepository([bruno])),
        vaccinationRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump();
    await tester.pump();
  }

  test('dueLabel', () {
    expect(dueLabel(DateTime(2026, 9, 26), now), 'Due today');
    expect(dueLabel(DateTime(2026, 9, 27), now), 'Due tomorrow');
    expect(dueLabel(DateTime(2026, 10, 6), now), 'Due in 10 days');
    expect(dueLabel(DateTime(2026, 9, 25), now), 'Overdue by 1 day');
    expect(dueLabel(DateTime(2026, 9, 20), now), 'Overdue by 6 days');
  });

  group('VaccinationsScreen', () {
    testWidgets('empty state', (tester) async {
      await pump(tester, FakeVaccinationRepository(), const VaccinationsScreen(petId: 'p1'));

      expect(find.text('Bruno’s Vaccinations'), findsOneWidget);
      expect(find.text('No vaccinations yet'), findsOneWidget);
    });

    testWidgets('current tab shows statuses most urgent first', (tester) async {
      final repo = FakeVaccinationRepository([
        vac('r', 'Rabies', DateTime(2025, 10, 20), DateTime(2026, 10, 20)),
        vac('d', 'DHPP', DateTime(2024, 5, 1), DateTime(2025, 5, 1)),
      ]);
      await pump(tester, repo, const VaccinationsScreen(petId: 'p1'));

      expect(find.text('Overdue'), findsWidgets);
      expect(find.text('Upcoming'), findsWidgets);
      expect(find.textContaining('Due in 24 days'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('DHPP')).dy,
        lessThan(tester.getTopLeft(find.text('Rabies')).dy),
      );
    });

    testWidgets('history tab groups by year', (tester) async {
      final repo = FakeVaccinationRepository([
        vac('r24', 'Rabies', DateTime(2024, 10, 20), DateTime(2025, 10, 20)),
        vac('r25', 'Rabies', DateTime(2025, 10, 20), DateTime(2026, 10, 20)),
      ]);
      await pump(tester, repo, const VaccinationsScreen(petId: 'p1'));

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.text('2025'), findsOneWidget);
      expect(find.text('2024'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget, reason: '2024 dose superseded');
    });
  });

  group('VaccinationFormScreen', () {
    Finder field(String label) => find.widgetWithText(TextFormField, label);

    testWidgets('requires a vaccine name', (tester) async {
      final repo = FakeVaccinationRepository();
      await pump(tester, repo, const VaccinationFormScreen(petId: 'p1'));

      await tester.tap(find.widgetWithText(FilledButton, 'Add Vaccination'));
      await tester.pump();

      expect(find.text('Vaccine name is required'), findsOneWidget);
      expect(repo.items, isEmpty);
    });

    testWidgets('suggestion fills name and a 1-year due date, then saves', (tester) async {
      final repo = FakeVaccinationRepository();
      await pump(tester, repo, const VaccinationFormScreen(petId: 'p1'));

      // Dog suggestions are offered for Bruno.
      await tester.tap(find.widgetWithText(ActionChip, 'Rabies'));
      await tester.pump();
      await tester.enterText(field('Veterinarian'), 'Dr. Silva');
      await tester.tap(find.widgetWithText(FilledButton, 'Add Vaccination'));
      await tester.pumpAndSettle();

      final saved = repo.items.single;
      expect(saved.vaccineName, 'Rabies');
      expect(saved.petId, 'p1');
      expect(saved.dateAdministered, DateTime(2026, 9, 26));
      expect(saved.nextDueDate, DateTime(2027, 9, 26));
      expect(saved.veterinarian, 'Dr. Silva');
      expect(find.text('previous page'), findsOneWidget, reason: 'form pops after save');
    });
  });
}
