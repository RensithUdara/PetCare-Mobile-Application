import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/clock.dart';
import '../../../appointments/presentation/providers/appointment_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../medications/presentation/providers/medication_providers.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../../vaccinations/presentation/providers/vaccination_providers.dart';
import '../../domain/entities/calendar_snapshot.dart';
import '../../domain/usecases/watch_calendar.dart';

final watchCalendarProvider = Provider(
  (ref) => WatchCalendar(
    ref.watch(petRepositoryProvider),
    ref.watch(appointmentRepositoryProvider),
    ref.watch(vaccinationRepositoryProvider),
    ref.watch(medicationRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

/// The calendar across all pets.
final calendarProvider = StreamProvider<CalendarSnapshot>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(CalendarSnapshot.empty);
  return ref.watch(watchCalendarProvider)(uid);
});

/// Pet filter on the calendar; `null` shows all pets.
class CalendarPetFilter extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? petId) => state = petId;
}

final calendarPetFilterProvider =
    NotifierProvider<CalendarPetFilter, String?>(CalendarPetFilter.new);

/// The calendar after applying the pet filter.
final filteredCalendarProvider = Provider<AsyncValue<CalendarSnapshot>>((ref) {
  final petId = ref.watch(calendarPetFilterProvider);
  return ref
      .watch(calendarProvider)
      .whenData((snapshot) => petId == null ? snapshot : snapshot.forPet(petId));
});
