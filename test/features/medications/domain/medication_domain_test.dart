import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/medications/domain/entities/dose_time.dart';
import 'package:petcare/features/medications/domain/entities/medication.dart';
import 'package:petcare/features/medications/domain/logic/medication_overview_builder.dart';
import 'package:petcare/features/medications/domain/logic/medication_schedule.dart';
import 'package:petcare/features/medications/domain/usecases/save_medication.dart';
import 'package:petcare/features/medications/domain/usecases/stop_medication.dart';

import '../../../helpers/fake_medication_repository.dart';

void main() {
  final now = DateTime(2026, 9, 26, 12);

  Medication med({
    String id = 'm',
    MedicationFrequency frequency = MedicationFrequency.onceDaily,
    DateTime? start,
    DateTime? end,
    List<DoseTime> times = const [DoseTime(8, 0)],
  }) =>
      Medication(
        id: id,
        ownerId: 'u1',
        petId: 'p1',
        name: 'Vitamin Supplement',
        dosage: '1 tablet',
        frequency: frequency,
        startDate: start ?? DateTime(2026, 9, 20),
        endDate: end,
        doseTimes: times,
      );

  group('DoseTime', () {
    test('parses and formats HH:mm', () {
      expect(DoseTime.tryParse('08:30'), const DoseTime(8, 30));
      expect(DoseTime.tryParse('8:05')?.hhmm, '08:05');
      expect(DoseTime.tryParse('24:00'), isNull);
      expect(DoseTime.tryParse('abc'), isNull);
    });

    test('sorts by time of day', () {
      expect(([const DoseTime(20, 0), const DoseTime(8, 0)]..sort()).first, const DoseTime(8, 0));
    });
  });

  group('medicationStatus', () {
    test('upcoming / active / completed', () {
      expect(medicationStatus(med(start: DateTime(2026, 9, 27)), now), MedicationStatus.upcoming);
      expect(medicationStatus(med(end: DateTime(2026, 9, 26)), now), MedicationStatus.active,
          reason: 'end date is inclusive');
      expect(medicationStatus(med(), now), MedicationStatus.active, reason: 'ongoing');
      expect(medicationStatus(med(end: DateTime(2026, 9, 25)), now), MedicationStatus.completed);
    });
  });

  group('schedule', () {
    test('daily doses on every day of the course, sorted', () {
      final m = med(
        frequency: MedicationFrequency.twiceDaily,
        end: DateTime(2026, 9, 30),
        times: const [DoseTime(20, 0), DoseTime(8, 0)],
      );
      expect(dosesOn(m, DateTime(2026, 9, 20)), [DateTime(2026, 9, 20, 8), DateTime(2026, 9, 20, 20)]);
      expect(dosesOn(m, DateTime(2026, 9, 30)), hasLength(2));
      expect(dosesOn(m, DateTime(2026, 10, 1)), isEmpty);
      expect(dosesOn(m, DateTime(2026, 9, 19)), isEmpty);
    });

    test('every other day and weekly count from the start date', () {
      final alt = med(frequency: MedicationFrequency.everyOtherDay);
      expect(isDosingDay(alt, DateTime(2026, 9, 20)), isTrue);
      expect(isDosingDay(alt, DateTime(2026, 9, 21)), isFalse);
      expect(isDosingDay(alt, DateTime(2026, 9, 22)), isTrue);

      final weekly = med(frequency: MedicationFrequency.weekly);
      expect(isDosingDay(weekly, DateTime(2026, 9, 27)), isTrue);
      expect(isDosingDay(weekly, DateTime(2026, 9, 26)), isFalse);
    });

    test('as-needed has no schedule', () {
      final m = med(frequency: MedicationFrequency.asNeeded);
      expect(dosesOn(m, now), isEmpty);
      expect(nextDose(m, now), isNull);
    });

    test('nextDose finds the next moment after now', () {
      final twice = med(
        frequency: MedicationFrequency.twiceDaily,
        times: const [DoseTime(8, 0), DoseTime(20, 0)],
      );
      expect(nextDose(twice, now), DateTime(2026, 9, 26, 20));
      expect(nextDose(twice, DateTime(2026, 9, 26, 21)), DateTime(2026, 9, 27, 8));

      // Every other day: 26th is offset 6 (dosing), 27th is not.
      final alt = med(frequency: MedicationFrequency.everyOtherDay);
      expect(nextDose(alt, now), DateTime(2026, 9, 28, 8));

      expect(nextDose(med(start: DateTime(2026, 10, 1)), now), DateTime(2026, 10, 1, 8));
      expect(nextDose(med(end: DateTime(2026, 9, 26)), now), isNull, reason: 'last dose passed');
    });

    test('courseProgress', () {
      final p = courseProgress(med(start: DateTime(2026, 9, 20), end: DateTime(2026, 10, 19)), now)!;
      expect(p.totalDays, 30);
      expect(p.day, 7);
      expect(p.daysLeft, 23);
      expect(courseProgress(med(), now), isNull, reason: 'ongoing');
    });
  });

  test('buildMedicationOverview groups and sorts', () {
    final overview = buildMedicationOverview([
      med(id: 'done', end: DateTime(2026, 9, 1)),
      med(id: 'soon', start: DateTime(2026, 10, 1)),
      med(id: 'evening', times: const [DoseTime(20, 0)]),
      med(id: 'afternoon', times: const [DoseTime(14, 0)]),
    ], now);

    expect(overview.active.map((e) => e.medication.id), ['afternoon', 'evening']);
    expect(overview.upcoming.single.medication.id, 'soon');
    expect(overview.completed.single.medication.id, 'done');
    expect(overview.nextDose?.nextDose, DateTime(2026, 9, 26, 14));
  });

  group('SaveMedication', () {
    late FakeMedicationRepository repo;
    late SaveMedication save;

    setUp(() {
      repo = FakeMedicationRepository();
      save = SaveMedication(repo);
    });

    Medication draft() => med(id: '').copyWith(
          name: '  Vitamin ',
          dosage: ' 1 tablet ',
          startDate: DateTime(2026, 9, 20, 15),
          doseTimes: const [DoseTime(20, 0), DoseTime(8, 0), DoseTime(8, 0)],
          instructions: '  ',
        );

    test('normalises fields before saving', () async {
      final id = await save(ownerId: 'u1', medication: draft());

      final saved = repo.items.single;
      expect(saved.id, id);
      expect(saved.name, 'Vitamin');
      expect(saved.dosage, '1 tablet');
      expect(saved.startDate, DateTime(2026, 9, 20));
      expect(saved.doseTimes, const [DoseTime(8, 0), DoseTime(20, 0)]);
      expect(saved.instructions, isNull);
    });

    test('validates required fields and dates', () {
      expect(save(ownerId: 'u1', medication: draft().copyWith(name: ' ')),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-name')));
      expect(save(ownerId: 'u1', medication: draft().copyWith(dosage: '')),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-dosage')));
      expect(save(ownerId: 'u1', medication: draft().copyWith(endDate: DateTime(2026, 9, 19))),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-end-date')));
      expect(save(ownerId: 'u1', medication: draft().copyWith(doseTimes: const [])),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'missing-times')));
    });

    test('as-needed drops times and reminders', () async {
      await save(
        ownerId: 'u1',
        medication: draft().copyWith(frequency: MedicationFrequency.asNeeded),
      );
      expect(repo.items.single.doseTimes, isEmpty);
      expect(repo.items.single.remindersEnabled, isFalse);
    });

    test('reminders off allows no times', () async {
      await save(
        ownerId: 'u1',
        medication: draft().copyWith(doseTimes: const [], remindersEnabled: false),
      );
      expect(repo.items.single.remindersEnabled, isFalse);
    });
  });

  group('StopMedication', () {
    test('ends an active course today', () async {
      final repo = FakeMedicationRepository();
      await StopMedication(repo, () => now)(med());
      expect(repo.items.single.endDate, DateTime(2026, 9, 26));
    });

    test('rejects medication that is not active', () {
      final stop = StopMedication(FakeMedicationRepository(), () => now);
      expect(stop(med(start: DateTime(2026, 10, 1))),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'not-active')));
    });
  });
}
