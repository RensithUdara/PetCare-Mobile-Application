import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/domain/reminder_offset.dart';
import 'package:petcare/features/vaccinations/domain/entities/vaccination.dart';
import 'package:petcare/features/vaccinations/domain/entities/vaccination_overview.dart';
import 'package:petcare/features/vaccinations/domain/logic/common_vaccines.dart';
import 'package:petcare/features/vaccinations/domain/logic/vaccination_status.dart';

Vaccination vac(
  String id,
  String name,
  DateTime given, {
  DateTime? due,
  ReminderOffset? reminder = ReminderOffset.sevenDays,
}) =>
    Vaccination(
      id: id,
      ownerId: 'u1',
      petId: 'p1',
      vaccineName: name,
      dateAdministered: given,
      nextDueDate: due,
      reminder: reminder,
    );

void main() {
  final now = DateTime(2026, 9, 26, 15, 30);

  group('vaccinationStatus', () {
    VaccinationStatus status(DateTime? due) =>
        vaccinationStatus(vac('v', 'Rabies', DateTime(2025), due: due), now: now);

    test('no due date is up to date', () => expect(status(null), VaccinationStatus.upToDate));

    test('past due date is overdue', () {
      expect(status(DateTime(2026, 9, 25)), VaccinationStatus.overdue);
    });

    test('due today and within 30 days is upcoming', () {
      expect(status(DateTime(2026, 9, 26)), VaccinationStatus.upcoming);
      expect(status(DateTime(2026, 10, 26)), VaccinationStatus.upcoming); // day 30
    });

    test('more than 30 days away is up to date', () {
      expect(status(DateTime(2026, 10, 27)), VaccinationStatus.upToDate); // day 31
    });

    test('superseded dose is completed even if its due date passed', () {
      expect(
        vaccinationStatus(vac('v', 'Rabies', DateTime(2024), due: DateTime(2025)),
            now: now, superseded: true),
        VaccinationStatus.completed,
      );
    });
  });

  group('buildVaccinationOverview', () {
    final history = [
      vac('r24', 'Rabies', DateTime(2024, 10, 20), due: DateTime(2025, 10, 20)),
      vac('r25', 'rabies ', DateTime(2025, 10, 20), due: DateTime(2026, 10, 20)),
      vac('d24', 'DHPP', DateTime(2024, 5, 1), due: DateTime(2025, 5, 1)),
      vac('b25', 'Bordetella', DateTime(2025, 2, 1), due: DateTime(2027, 2, 1)),
      vac('l26', 'Leptospirosis', DateTime(2026, 1, 1)),
    ];
    final overview = buildVaccinationOverview(history, now);

    test('keeps only the latest dose per vaccine (name match is fuzzy)', () {
      expect(overview.current.map((e) => e.vaccination.id), containsAll(['r25', 'd24', 'b25', 'l26']));
      expect(overview.current, hasLength(4));
    });

    test('orders current doses by urgency then due date', () {
      expect(overview.current.map((e) => (e.vaccination.id, e.status)), [
        ('d24', VaccinationStatus.overdue),
        ('r25', VaccinationStatus.upcoming),
        ('b25', VaccinationStatus.upToDate),
        ('l26', VaccinationStatus.upToDate), // no due date sorts last
      ]);
    });

    test('groups history by year, newest first, superseded as completed', () {
      expect(overview.historyByYear.map((y) => y.$1), [2026, 2025, 2024]);
      final y2024 = overview.historyByYear.last.$2;
      expect(y2024.map((e) => e.vaccination.id), ['r24', 'd24']);
      expect(y2024.first.status, VaccinationStatus.completed);
    });

    test('counts and next due', () {
      expect(overview.totalRecords, 5);
      expect(overview.count(VaccinationStatus.overdue), 1);
      expect(overview.count(VaccinationStatus.upcoming), 1);
      expect(overview.count(VaccinationStatus.upToDate), 2);
      expect(overview.count(VaccinationStatus.completed), 1);
      expect(overview.hasOverdue, isTrue);
      expect(overview.nextDue?.vaccination.id, 'r25');
    });

    test('empty input gives the empty overview', () {
      expect(buildVaccinationOverview([], now), same(VaccinationOverview.empty));
    });
  });

  group('reminders', () {
    test('reminder date is N days before due, at 9:00', () {
      final v = vac('v', 'Rabies', DateTime(2025, 10, 20), due: DateTime(2026, 10, 20));
      expect(v.reminderDate, DateTime(2026, 10, 13, 9));
      expect(v.copyWith(reminder: ReminderOffset.onTheDay).reminderDate, DateTime(2026, 10, 20, 9));
    });

    test('no reminder without due date or when disabled', () {
      expect(vac('v', 'Rabies', DateTime(2025)).reminderDate, isNull);
      expect(
        vac('v', 'Rabies', DateTime(2025), due: DateTime(2026), reminder: null).reminderDate,
        isNull,
      );
    });

    test('fromDays maps stored values back', () {
      expect(ReminderOffset.fromDays(7), ReminderOffset.sevenDays);
      expect(ReminderOffset.fromDays(null), isNull);
      expect(ReminderOffset.fromDays(5), isNull);
    });
  });

  test('addMonths clamps to the end of shorter months', () {
    expect(addMonths(DateTime(2025, 10, 20), 12), DateTime(2026, 10, 20));
    expect(addMonths(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
    expect(addMonths(DateTime(2024, 1, 31), 1), DateTime(2024, 2, 29));
    expect(addMonths(DateTime(2025, 11, 15), 3), DateTime(2026, 2, 15));
  });
}
