import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/features/authentication/presentation/auth_providers.dart';
import 'package:petcare/features/pets/domain/pet.dart';
import 'package:petcare/features/pets/presentation/pet_form_screen.dart';
import 'package:petcare/features/pets/presentation/pet_providers.dart';
import 'package:petcare/features/pets/presentation/pets_screen.dart';

import '../../helpers/fake_pet_repository.dart';

void main() {
  /// Hosts [screen] at `/screen` above a `/` page, with pet details
  /// stubbed so post-save navigation can be asserted.
  Future<void> pump(WidgetTester tester, FakePetRepository repo, Widget screen) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/screen',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Text('root page'),
          routes: [GoRoute(path: 'screen', builder: (_, _) => screen)],
        ),
        GoRoute(
          path: '/pets/:petId',
          builder: (_, state) => Text('details ${state.pathParameters['petId']}'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          petRepositoryProvider.overrideWithValue(repo),
          currentUserIdProvider.overrideWithValue('u1'),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
  }

  group('PetsScreen', () {
    testWidgets('shows empty state when there are no pets', (tester) async {
      await pump(tester, FakePetRepository(), const PetsScreen());

      expect(find.text('No pets yet'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('lists pets sorted by name with breed and weight', (tester) async {
      final repo = FakePetRepository(const [
        Pet(id: '2', ownerId: 'u1', name: 'Milo', species: PetSpecies.cat),
        Pet(
          id: '1',
          ownerId: 'u1',
          name: 'Bruno',
          species: PetSpecies.dog,
          breed: 'Golden Retriever',
          weightKg: 12.5,
        ),
      ]);
      await pump(tester, repo, const PetsScreen());

      expect(find.text('Bruno'), findsOneWidget);
      expect(find.text('Golden Retriever'), findsOneWidget);
      expect(find.text('12.5 kg'), findsOneWidget);
      expect(find.text('Cat'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Bruno')).dy,
        lessThan(tester.getTopLeft(find.text('Milo')).dy),
      );
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('PetFormScreen', () {
    Finder field(String label) => find.widgetWithText(TextFormField, label);

    testWidgets('requires name and species', (tester) async {
      final repo = FakePetRepository();
      await pump(tester, repo, const PetFormScreen());

      await tester.tap(find.widgetWithText(FilledButton, 'Add Pet'));
      await tester.pump();

      expect(find.text('Pet name is required'), findsOneWidget);
      expect(find.text('Choose a species'), findsOneWidget);
      expect(repo.calls, isEmpty);
    });

    testWidgets('rejects an invalid weight', (tester) async {
      final repo = FakePetRepository();
      await pump(tester, repo, const PetFormScreen());

      await tester.enterText(field('Weight'), '-3');
      await tester.tap(find.widgetWithText(FilledButton, 'Add Pet'));
      await tester.pump();

      expect(find.text('Enter a weight between 0 and 200 kg'), findsOneWidget);
    });

    testWidgets('saves a new pet', (tester) async {
      final repo = FakePetRepository();
      await pump(tester, repo, const PetFormScreen());

      await tester.enterText(field('Pet name *'), 'Bruno');
      await tester.tap(find.textContaining('Dog'));
      await tester.enterText(field('Breed'), 'Golden Retriever');
      await tester.enterText(field('Weight'), '12,5');
      await tester.tap(find.text('Male'));
      await tester.tap(find.widgetWithText(FilledButton, 'Add Pet'));
      await tester.pump();

      final pet = repo.pets.single;
      expect(pet.name, 'Bruno');
      expect(pet.species, PetSpecies.dog);
      expect(pet.breed, 'Golden Retriever');
      expect(pet.weightKg, 12.5);
      expect(pet.gender, PetGender.male);
      expect(pet.ownerId, 'u1');
      expect(pet.color, isNull, reason: 'empty optional fields are stored as null');

      await tester.pumpAndSettle();
      expect(find.text('details ${pet.id}'), findsOneWidget);
    });

    testWidgets('edit pre-fills the form and saves changes', (tester) async {
      final repo = FakePetRepository(const [
        Pet(id: 'p1', ownerId: 'u1', name: 'Milo', species: PetSpecies.cat, weightKg: 4),
      ]);
      await pump(tester, repo, const PetFormScreen(petId: 'p1'));
      await tester.pump();

      expect(find.text('Edit Milo'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '4'), findsOneWidget);

      await tester.enterText(field('Color'), 'Orange');
      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      expect(repo.pets.single.color, 'Orange');
      expect(repo.pets.single.id, 'p1');

      await tester.pumpAndSettle();
      expect(find.text('root page'), findsOneWidget, reason: 'edit pops back');
    });
  });
}
