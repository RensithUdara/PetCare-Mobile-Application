import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/utils/clock.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/presentation/providers/pet_providers.dart';
import 'package:petcare/features/weight/domain/entities/weight_entry.dart';
import 'package:petcare/features/weight/domain/logic/weight_trend.dart';
import 'package:petcare/features/weight/presentation/providers/weight_providers.dart';
import 'package:petcare/features/weight/presentation/screens/weight_screen.dart';

import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/fake_weight_repository.dart';
import '../../../helpers/pump_screen.dart';

void main() {
  final now = DateTime(2026, 9, 26, 12);
  late FakePetRepository pets;

  WeightEntry w(String id, DateTime date, double kg) =>
      WeightEntry(id: id, ownerId: 'u1', petId: 'bruno', date: date, weightKg: kg);

  Future<void> pump(WidgetTester tester, FakeWeightRepository repo) {
    pets = FakePetRepository(const [
      Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog, weightKg: 12.1),
    ]);
    return pumpScreen(tester, const WeightScreen(petId: 'bruno'),
        physicalSize: const Size(1080, 3600),
        overrides: [
          currentUserIdProvider.overrideWithValue('u1'),
          clockProvider.overrideWithValue(() => now),
          petRepositoryProvider.overrideWithValue(pets),
          weightRepositoryProvider.overrideWithValue(repo),
        ]);
  }

  testWidgets('empty state', (tester) async {
    await pump(tester, FakeWeightRepository());
    expect(find.text('No weigh-ins yet'), findsOneWidget);
  });

  testWidgets('summary, chart, history and range filter', (tester) async {
    await pump(tester, FakeWeightRepository([
      w('jan', DateTime(2026, 1, 1), 10.2),
      w('jun', DateTime(2026, 6, 1), 11.5),
      w('sep', DateTime(2026, 9, 1), 12.1),
    ]));

    expect(find.text('Bruno’s Weight'), findsOneWidget);
    expect(find.text('12.1 kg'), findsWidgets);
    expect(find.textContaining('+0.6 kg (+5.2%) since Jun 1'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('+1.3 kg'), findsOneWidget, reason: 'Jan → Jun delta in history');

    await tester.tap(find.text(WeightRange.month.label));
    await tester.pumpAndSettle();
    expect(find.byType(LineChart), findsNothing);
    expect(find.text('Log another weigh-in to see a trend'), findsOneWidget);
  });

  testWidgets('log weight from the sheet updates history and pet', (tester) async {
    final repo = FakeWeightRepository([w('sep', DateTime(2026, 9, 1), 12.1)]);
    await pump(tester, repo);

    await tester.tap(find.text('Log Weight'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Weight *'), '12,4');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.items.map((e) => e.weightKg), containsAll([12.1, 12.4]));
    expect(pets.pets.single.weightKg, 12.4);
    expect(find.text('Weight logged'), findsOneWidget);
    expect(find.textContaining('+0.3 kg'), findsWidgets);
  });

  testWidgets('swipe to delete an entry', (tester) async {
    final repo = FakeWeightRepository([
      w('jun', DateTime(2026, 6, 1), 11.5),
      w('sep', DateTime(2026, 9, 1), 12.1),
    ]);
    await pump(tester, repo);

    await tester.drag(find.text('Sep 1, 2026'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(repo.items.map((e) => e.id), ['jun']);
    expect(pets.pets.single.weightKg, 11.5);
  });
}
