import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/medications/data/models/medication_model.dart';
import 'package:petcare/features/medications/domain/entities/dose_time.dart';
import 'package:petcare/features/medications/domain/entities/medication.dart';

void main() {
  final vitamin = Medication(
    id: 'm1',
    ownerId: 'u1',
    petId: 'p1',
    name: 'Vitamin Supplement',
    dosage: '1 tablet',
    frequency: MedicationFrequency.twiceDaily,
    startDate: DateTime(2026, 9, 1),
    endDate: DateTime(2026, 9, 30),
    doseTimes: const [DoseTime(8, 0), DoseTime(20, 0)],
    instructions: 'Give with food',
  );

  test('round-trips, storing dose times as HH:mm', () {
    final json = MedicationModel.fromEntity(vitamin).toJson();

    expect(json.containsKey('id'), isFalse);
    expect(json['frequency'], 'twiceDaily');
    expect(json['doseTimes'], ['08:00', '20:00']);
    expect(MedicationModel.fromJson({...json, 'id': 'm1'}).toEntity(), vitamin);
  });

  test('ignores malformed times and unknown frequency', () {
    final m = MedicationModel.fromJson({
      'id': 'm2',
      'ownerId': 'u1',
      'petId': 'p1',
      'name': 'Drops',
      'dosage': '1 drop',
      'frequency': 'hourly',
      'startDate': DateTime(2026),
      'doseTimes': ['20:00', 'noon', '07:30'],
    }).toEntity();

    expect(m.frequency, MedicationFrequency.onceDaily);
    expect(m.doseTimes, const [DoseTime(7, 30), DoseTime(20, 0)]);
    expect(m.isOngoing, isTrue);
  });
}
