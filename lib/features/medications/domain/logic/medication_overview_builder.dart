import '../entities/medication.dart';
import '../entities/medication_overview.dart';
import 'medication_schedule.dart';

MedicationOverview buildMedicationOverview(List<Medication> all, DateTime now) {
  if (all.isEmpty) return MedicationOverview.empty;

  final active = <MedicationEntry>[];
  final upcoming = <MedicationEntry>[];
  final completed = <MedicationEntry>[];
  for (final m in all) {
    final status = medicationStatus(m, now);
    final entry = MedicationEntry(m, status, nextDose(m, now));
    switch (status) {
      case MedicationStatus.active:
        active.add(entry);
      case MedicationStatus.upcoming:
        upcoming.add(entry);
      case MedicationStatus.completed:
        completed.add(entry);
    }
  }

  final far = DateTime(9999);
  active.sort((a, b) {
    final byDose = (a.nextDose ?? far).compareTo(b.nextDose ?? far);
    return byDose != 0 ? byDose : a.medication.name.compareTo(b.medication.name);
  });
  upcoming.sort((a, b) => a.medication.startDate.compareTo(b.medication.startDate));
  completed.sort((a, b) => b.medication.endDate!.compareTo(a.medication.endDate!));

  return MedicationOverview(active: active, upcoming: upcoming, completed: completed);
}
