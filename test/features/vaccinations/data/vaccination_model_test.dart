import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/domain/reminder_offset.dart';
import 'package:petcare/features/vaccinations/data/models/vaccination_model.dart';
import 'package:petcare/features/vaccinations/domain/entities/vaccination.dart';

void main() {
  final rabies = Vaccination(
    id: 'v1',
    ownerId: 'u1',
    petId: 'p1',
    vaccineName: 'Rabies',
    category: VaccineCategory.core,
    dateAdministered: DateTime(2025, 10, 20),
    nextDueDate: DateTime(2026, 10, 20),
    veterinarian: 'Dr. Silva',
    clinic: 'Happy Paws Veterinary Clinic',
    reminder: ReminderOffset.sevenDays,
  );

  test('round-trips through JSON', () {
    final json = VaccinationModel.fromEntity(rabies).toJson();

    expect(json.containsKey('id'), isFalse);
    expect(json['category'], 'core');
    expect(json['reminderDaysBefore'], 7);
    expect(VaccinationModel.fromJson({...json, 'id': 'v1'}).toEntity(), rabies);
  });

  test('stores a denormalized reminderAt for server-side scheduling', () {
    final json = VaccinationModel.fromEntity(rabies).toJson();
    expect(json['reminderAt'], DateTime(2026, 10, 13, 9));

    final noReminder = VaccinationModel.fromEntity(rabies.copyWith(reminder: null)).toJson();
    expect(noReminder['reminderAt'], isNull);
    expect(noReminder['reminderDaysBefore'], isNull);
  });

  test('tolerates unknown category and missing reminder', () {
    final v = VaccinationModel.fromJson({
      'id': 'v2',
      'ownerId': 'u1',
      'petId': 'p1',
      'vaccineName': 'Mystery',
      'category': 'experimental',
      'dateAdministered': DateTime(2025),
    }).toEntity();

    expect(v.category, VaccineCategory.other);
    expect(v.reminder, isNull);
  });
}
