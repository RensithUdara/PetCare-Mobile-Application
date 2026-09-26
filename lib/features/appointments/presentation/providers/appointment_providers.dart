import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/clock.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/datasources/appointment_remote_data_source.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_overview.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/usecases/delete_appointment.dart';
import '../../domain/usecases/save_appointment.dart';
import '../../domain/usecases/update_appointment_status.dart';
import '../../domain/usecases/watch_appointment.dart';
import '../../domain/usecases/watch_pet_appointment_overview.dart';

// ── Data ────────────────────────────────────────────────────────────────
final appointmentRemoteDataSourceProvider = Provider<AppointmentRemoteDataSource>(
  (ref) => FirestoreAppointmentRemoteDataSource(FirebaseFirestore.instance),
);

final appointmentRepositoryProvider = Provider<AppointmentRepository>(
  (ref) => AppointmentRepositoryImpl(ref.watch(appointmentRemoteDataSourceProvider)),
);

// ── Use cases ───────────────────────────────────────────────────────────
final watchPetAppointmentOverviewProvider = Provider(
  (ref) => WatchPetAppointmentOverview(
    ref.watch(appointmentRepositoryProvider),
    ref.watch(clockProvider),
  ),
);
final watchAppointmentProvider =
    Provider((ref) => WatchAppointment(ref.watch(appointmentRepositoryProvider)));
final saveAppointmentProvider = Provider(
  (ref) => SaveAppointment(ref.watch(appointmentRepositoryProvider), ref.watch(clockProvider)),
);
final updateAppointmentStatusProvider = Provider(
  (ref) => UpdateAppointmentStatus(
    ref.watch(appointmentRepositoryProvider),
    ref.watch(clockProvider),
  ),
);
final deleteAppointmentProvider =
    Provider((ref) => DeleteAppointment(ref.watch(appointmentRepositoryProvider)));

// ── State ───────────────────────────────────────────────────────────────
final petAppointmentOverviewProvider =
    StreamProvider.family<AppointmentOverview, String>((ref, petId) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(AppointmentOverview.empty);
  return ref.watch(watchPetAppointmentOverviewProvider)(ownerId: uid, petId: petId);
});

final appointmentProvider = StreamProvider.family<Appointment?, String>((ref, id) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(watchAppointmentProvider)(ownerId: uid, appointmentId: id);
});
