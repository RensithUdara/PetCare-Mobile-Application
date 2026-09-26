import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/domain/reminder_offset.dart';
import 'package:petcare/features/appointments/data/models/appointment_model.dart';
import 'package:petcare/features/appointments/domain/entities/appointment.dart';

void main() {
  final checkup = Appointment(
    id: 'a1',
    ownerId: 'u1',
    petId: 'p2',
    dateTime: DateTime(2026, 10, 25, 10, 30),
    type: AppointmentType.routineCheckup,
    clinic: 'Happy Paws Veterinary Clinic',
    veterinarian: 'Dr. Silva',
    reminder: ReminderOffset.oneDay,
  );

  test('round-trips through JSON', () {
    final json = AppointmentModel.fromEntity(checkup).toJson();

    expect(json.containsKey('id'), isFalse);
    expect(json['type'], 'routineCheckup');
    expect(json['status'], 'scheduled');
    expect(json['reminderAt'], DateTime(2026, 10, 24, 10, 30));
    expect(AppointmentModel.fromJson({...json, 'id': 'a1'}).toEntity(), checkup);
  });

  test('cancelled appointments store no reminderAt', () {
    final json = AppointmentModel.fromEntity(
      checkup.copyWith(status: AppointmentStatus.cancelled),
    ).toJson();
    expect(json['reminderAt'], isNull);
  });

  test('unknown enums fall back safely', () {
    final a = AppointmentModel.fromJson({
      'id': 'a2',
      'ownerId': 'u1',
      'petId': 'p1',
      'dateTime': DateTime(2026),
      'type': 'acupuncture',
      'status': 'rescheduled',
    }).toEntity();

    expect(a.type, AppointmentType.other);
    expect(a.status, AppointmentStatus.scheduled);
  });
}
