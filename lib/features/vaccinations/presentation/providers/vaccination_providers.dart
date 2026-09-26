import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/clock.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/datasources/vaccination_remote_data_source.dart';
import '../../data/repositories/vaccination_repository_impl.dart';
import '../../domain/entities/vaccination.dart';
import '../../domain/entities/vaccination_overview.dart';
import '../../domain/repositories/vaccination_repository.dart';
import '../../domain/usecases/delete_vaccination.dart';
import '../../domain/usecases/save_vaccination.dart';
import '../../domain/usecases/watch_pet_vaccination_overview.dart';
import '../../domain/usecases/watch_vaccination.dart';

// ── Data ────────────────────────────────────────────────────────────────
final vaccinationRemoteDataSourceProvider = Provider<VaccinationRemoteDataSource>(
  (ref) => FirestoreVaccinationRemoteDataSource(FirebaseFirestore.instance),
);

final vaccinationRepositoryProvider = Provider<VaccinationRepository>(
  (ref) => VaccinationRepositoryImpl(ref.watch(vaccinationRemoteDataSourceProvider)),
);

// ── Use cases ───────────────────────────────────────────────────────────
final watchPetVaccinationOverviewProvider = Provider(
  (ref) => WatchPetVaccinationOverview(
    ref.watch(vaccinationRepositoryProvider),
    ref.watch(clockProvider),
  ),
);
final watchVaccinationProvider =
    Provider((ref) => WatchVaccination(ref.watch(vaccinationRepositoryProvider)));
final saveVaccinationProvider = Provider(
  (ref) => SaveVaccination(ref.watch(vaccinationRepositoryProvider), ref.watch(clockProvider)),
);
final deleteVaccinationProvider =
    Provider((ref) => DeleteVaccination(ref.watch(vaccinationRepositoryProvider)));

// ── State ───────────────────────────────────────────────────────────────
/// Statuses + history of one pet's vaccinations.
final petVaccinationOverviewProvider =
    StreamProvider.family<VaccinationOverview, String>((ref, petId) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(VaccinationOverview.empty);
  return ref.watch(watchPetVaccinationOverviewProvider)(ownerId: uid, petId: petId);
});

final vaccinationProvider = StreamProvider.family<Vaccination?, String>((ref, id) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(watchVaccinationProvider)(ownerId: uid, vaccinationId: id);
});
