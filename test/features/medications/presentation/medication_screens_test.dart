import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/utils/clock.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/medications/domain/entities/dose_time.dart';
import 'package:petcare/features/medications/domain/entities/medication.dart';
import 'package:petcare/features/medications/presentation/providers/medication_providers.dart';
import 'package:petcare/features/medications/presentation/screens/medication_details_screen.dart';
import 'package:petcare/features/medications/presentation/screens/medication_form_screen.dart';
import 'package:petcare/features/medications/presentation/screens/medications_screen.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/presentation/providers/pet_providers.dart';

import '../../../helpers/fake_medication_repository.dart';
import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/pump_screen.dart';

void main() {
  final now = DateTime(2026, 9, 26, 12);
  const bruno = Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog);

  Future<void> pump(WidgetTester tester, FakeMedicationRepository repo, Widget screen) =>
      pumpScreen(tester, screen, physicalSize: const Size(1080, 6000), overrides: [
        currentUserIdProvider.overrideWithValue('u1'),
        clockProvider.overrideWithValue(() => now),
        petRepositoryProvider.overrideWithValue(FakePetRepository([bruno])),
        medicationRepositoryProvider.overrideWithValue(repo),
      ]);

  Medication med(String id, {DateTime? start, DateTime? end}) => Medication(
        id: id,
        ownerId: 'u1',
        petId: 'bruno',
        name: 'Med $id',
        dosage: '1 tablet',
        frequency: MedicationFrequency.twiceDaily,
        startDate: start ?? DateTime(2026, 9, 20),
        endDate: end,
        doseTimes: const [DoseTime(8, 0), DoseTime(20, 0)],
      );

  testWidgets('list groups by status with next dose and progress', (tester) async {
    final repo = FakeMedicationRepository([
      med('a', end: DateTime(2026, 10, 19)),
      med('b', start: DateTime(2026, 10, 1)),
      med('c', start: DateTime(2026, 8, 1), end: DateTime(2026, 9, 1)),
    ]);
    await pump(tester, repo, const MedicationsScreen(petId: 'bruno'));

    expect(find.text('Active (1)'), findsOneWidget);
    expect(find.text('Starting soon (1)'), findsOneWidget);
    expect(find.text('Completed (1)'), findsOneWidget);
    expect(find.textContaining('Next: Today at 8:00'), findsOneWidget);
    expect(find.text('Day 7 of 30'), findsOneWidget);
  });

  group('MedicationFormScreen', () {
    Finder field(String label) => find.widgetWithText(TextFormField, label);

    Future<void> tapSave(WidgetTester tester) =>
        tester.tap(find.widgetWithText(FilledButton, 'Add Medication'));

    testWidgets('requires name, dosage and an end date unless ongoing', (tester) async {
      final repo = FakeMedicationRepository();
      await pump(tester, repo, const MedicationFormScreen(petId: 'bruno'));

      await tapSave(tester);
      await tester.pump();

      expect(find.text('Medicine name is required'), findsOneWidget);
      expect(find.text('Dosage is required'), findsOneWidget);
      expect(find.text('Choose an end date or mark as ongoing'), findsOneWidget);
      expect(repo.items, isEmpty);
    });

    testWidgets('twice daily with a 30-day course gets default times', (tester) async {
      final repo = FakeMedicationRepository();
      await pump(tester, repo, const MedicationFormScreen(petId: 'bruno'));

      await tester.enterText(field('Medicine name *'), 'Vitamin Supplement');
      await tester.tap(find.widgetWithText(ActionChip, '1 tablet'));
      await tester.tap(find.byType(DropdownButtonFormField<MedicationFrequency>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Twice daily').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ActionChip, '30 days'));
      await tester.pump();

      await tapSave(tester);
      await tester.pumpAndSettle();

      final saved = repo.items.single;
      expect(saved.name, 'Vitamin Supplement');
      expect(saved.dosage, '1 tablet');
      expect(saved.frequency, MedicationFrequency.twiceDaily);
      expect(saved.startDate, DateTime(2026, 9, 26));
      expect(saved.endDate, DateTime(2026, 10, 25));
      expect(saved.doseTimes, const [DoseTime(8, 0), DoseTime(20, 0)]);
      expect(find.text('previous page'), findsOneWidget);
    });
  });

  testWidgets('details can stop an active medication', (tester) async {
    final repo = FakeMedicationRepository([med('a')]);
    await pump(tester, repo, const MedicationDetailsScreen(medicationId: 'a'));

    expect(find.text('Active'), findsOneWidget);
    expect(find.textContaining('Next dose: Today at 8:00'), findsOneWidget);

    await tester.tap(find.text('Stop Medication'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Stop'));
    await tester.pumpAndSettle();

    expect(repo.items.single.endDate, DateTime(2026, 9, 26));
  });
}
