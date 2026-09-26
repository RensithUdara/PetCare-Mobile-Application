import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/clock.dart';
import '../../../appointments/presentation/providers/appointment_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../../vaccinations/presentation/providers/vaccination_providers.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/usecases/watch_calendar_events.dart';

final watchCalendarEventsProvider = Provider(
  (ref) => WatchCalendarEvents(
    ref.watch(petRepositoryProvider),
    ref.watch(appointmentRepositoryProvider),
    ref.watch(vaccinationRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

/// Every calendar event across all pets.
final calendarEventsProvider = StreamProvider<List<CalendarEvent>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(watchCalendarEventsProvider)(uid);
});

/// Pet filter on the calendar; `null` shows all pets.
class CalendarPetFilter extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? petId) => state = petId;
}

final calendarPetFilterProvider =
    NotifierProvider<CalendarPetFilter, String?>(CalendarPetFilter.new);

/// Calendar events after applying the pet filter.
final filteredCalendarEventsProvider = Provider<AsyncValue<List<CalendarEvent>>>((ref) {
  final petId = ref.watch(calendarPetFilterProvider);
  return ref
      .watch(calendarEventsProvider)
      .whenData((events) => petId == null ? events : events.where((e) => e.petId == petId).toList());
});
