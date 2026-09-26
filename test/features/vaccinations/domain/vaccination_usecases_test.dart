import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/domain/reminder_offset.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/vaccinations/domain/entities/vaccination.dart';
import 'package:petcare/features/vaccinations/domain/entities/vaccination_overview.dart';
import 'package:petcare/features/vaccinations/domain/usecases/save_vaccination.dart';
import 'package:petcare/features/vaccinations/domain/usecases/watch_pet_vaccination_overview.dart';

import '../../../helpers/fake_vaccination_repository.dart';

void main() {
  DateTime now() => DateTime(2026, 9, 26, 10);

  final draft = Vaccination(
    ownerId: '',
    petId: 'p1',
    vaccineName: '  Rabies ',
    dateAdministered: DateTime(2026, 9, 1),
    nextDueDate: DateTime(2027, 9, 1),
  );

  group('SaveVaccination', () {
    late FakeVaccinationRepository repo;
    late SaveVaccination save;

    setUp(() {
      repo = FakeVaccinationRepository();
      save = SaveVaccination(repo, now);
    });

    test('assigns id and owner and trims the name', () async {
      final id = await save(ownerId: 'u1', vaccination: draft);

      final saved = repo.items.single;
      expect(saved.id, id);
      expect(saved.ownerId, 'u1');
      expect(saved.vaccineName, 'Rabies');
    });

    test('rejects an empty name', () {
      expect(
        save(ownerId: 'u1', vaccination: draft.copyWith(vaccineName: '  ')),
        throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-name')),
      );
    });

    test('rejects a future administration date', () {
      expect(
        save(ownerId: 'u1', vaccination: draft.copyWith(dateAdministered: DateTime(2026, 9, 27))),
        throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-administered-date')),
      );
    });

    test('rejects a due date on or before the administration date', () {
      expect(
        save(ownerId: 'u1', vaccination: draft.copyWith(nextDueDate: DateTime(2026, 9, 1))),
        throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-due-date')),
      );
      expect(repo.items, isEmpty);
    });

    test('drops the reminder when there is no due date', () async {
      await save(
        ownerId: 'u1',
        vaccination: draft.copyWith(nextDueDate: null, reminder: ReminderOffset.oneDay),
      );
      expect(repo.items.single.reminder, isNull);
    });

    test('updates keep the existing id', () async {
      await save(ownerId: 'u1', vaccination: draft.copyWith(id: 'v9'));
      expect(repo.items.single.id, 'v9');
    });
  });

  test('WatchPetVaccinationOverview evaluates only that pet’s records', () async {
    final repo = FakeVaccinationRepository([
      draft.copyWith(id: 'a', ownerId: 'u1', nextDueDate: DateTime(2026, 9, 1)),
      draft.copyWith(id: 'b', ownerId: 'u1', petId: 'p2'),
    ]);

    final overview =
        await WatchPetVaccinationOverview(repo, now)(ownerId: 'u1', petId: 'p1').first;

    expect(overview.totalRecords, 1);
    expect(overview.current.single.status, VaccinationStatus.overdue);
  });
}
