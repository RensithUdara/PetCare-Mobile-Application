import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/weight/data/models/weight_entry_model.dart';
import 'package:petcare/features/weight/domain/entities/weight_entry.dart';
import 'package:petcare/features/weight/domain/logic/weight_trend.dart';
import 'package:petcare/features/weight/domain/usecases/weight_usecases.dart';

import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/fake_weight_repository.dart';

void main() {
  final now = DateTime(2026, 9, 26, 12);
  WeightEntry w(String id, DateTime date, double kg, {DateTime? created}) =>
      WeightEntry(id: id, ownerId: 'u1', petId: 'bruno', date: date, weightKg: kg, createdAt: created);

  final history = [
    w('sep', DateTime(2026, 9, 1), 12.1),
    w('jan', DateTime(2026, 1, 1), 10.2),
    w('jun', DateTime(2026, 6, 1), 11.5),
    w('mar', DateTime(2026, 3, 1), 10.8),
  ];

  group('trend logic', () {
    test('sortByDate orders oldest first, same-day by creation', () {
      final sorted = sortByDate([
        ...history,
        w('sep-late', DateTime(2026, 9, 1), 12.3, created: DateTime(2026, 9, 1, 20)),
      ]);
      expect(sorted.map((e) => e.id), ['jan', 'mar', 'jun', 'sep', 'sep-late']);
    });

    test('entriesInRange', () {
      final sorted = sortByDate(history);
      expect(entriesInRange(sorted, WeightRange.month, now).map((e) => e.id), ['sep']);
      expect(entriesInRange(sorted, WeightRange.halfYear, now).map((e) => e.id), ['jun', 'sep']);
      expect(entriesInRange(sorted, WeightRange.all, now), hasLength(4));
    });

    test('summarize', () {
      final s = summarize(sortByDate(history))!;
      expect(s.latest.id, 'sep');
      expect(s.previous?.id, 'jun');
      expect(s.changeKg, 0.6);
      expect(s.changePercent, 5.2);
      expect(s.minKg, 10.2);
      expect(s.maxKg, 12.1);
      expect(s.count, 4);

      final single = summarize([history.first])!;
      expect(single.changeKg, isNull);
      expect(summarize([]), isNull);
    });
  });

  group('LogWeight', () {
    late FakeWeightRepository weights;
    late FakePetRepository pets;
    late LogWeight log;

    setUp(() {
      weights = FakeWeightRepository(history);
      pets = FakePetRepository(const [
        Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog, weightKg: 12.1),
      ]);
      log = LogWeight(weights, SyncPetCurrentWeight(weights, pets), () => now);
    });

    test('records a rounded, date-only entry and syncs the pet', () async {
      final id = await log(
        ownerId: 'u1',
        entry: WeightEntry(
          ownerId: '',
          petId: 'bruno',
          date: DateTime(2026, 9, 26, 18),
          weightKg: 12.456,
          note: '  ',
        ),
      );

      final saved = weights.items.firstWhere((e) => e.id == id);
      expect(saved.weightKg, 12.46);
      expect(saved.date, DateTime(2026, 9, 26));
      expect(saved.note, isNull);
      expect(pets.pets.single.weightKg, 12.46);
    });

    test('back-dated entry does not change the current weight', () async {
      await log(
        ownerId: 'u1',
        entry: WeightEntry(ownerId: '', petId: 'bruno', date: DateTime(2025, 1, 1), weightKg: 8),
      );
      expect(pets.pets.single.weightKg, 12.1);
    });

    test('validates weight and date', () {
      expect(
        log(ownerId: 'u1', entry: WeightEntry(ownerId: '', petId: 'bruno', date: now, weightKg: 0)),
        throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-weight')),
      );
      expect(
        log(
          ownerId: 'u1',
          entry: WeightEntry(ownerId: '', petId: 'bruno', date: DateTime(2026, 9, 27), weightKg: 5),
        ),
        throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-date')),
      );
    });
  });

  test('DeleteWeightEntry re-syncs the pet to the new latest entry', () async {
    final weights = FakeWeightRepository(history);
    final pets = FakePetRepository(const [
      Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog, weightKg: 12.1),
    ]);

    await DeleteWeightEntry(weights, SyncPetCurrentWeight(weights, pets))(history.first); // 'sep'

    expect(pets.pets.single.weightKg, 11.5);
  });

  test('WeightEntryModel round-trips', () {
    final e = w('w1', DateTime(2026, 9, 1), 12.1);
    final json = WeightEntryModel.fromEntity(e).toJson();
    expect(json.containsKey('id'), isFalse);
    expect(WeightEntryModel.fromJson({...json, 'id': 'w1', 'weightKg': 12.1}).toEntity(), e);
    expect(WeightEntryModel.fromJson({...json, 'id': 'w1', 'weightKg': 12}).toEntity().weightKg, 12.0);
  });
}
