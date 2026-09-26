import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/clock.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/datasources/medication_remote_data_source.dart';
import '../../data/repositories/medication_repository_impl.dart';
import '../../domain/entities/medication.dart';
import '../../domain/entities/medication_overview.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../domain/usecases/delete_medication.dart';
import '../../domain/usecases/save_medication.dart';
import '../../domain/usecases/stop_medication.dart';
import '../../domain/usecases/watch_medication.dart';
import '../../domain/usecases/watch_pet_medication_overview.dart';

// ── Data ────────────────────────────────────────────────────────────────
final medicationRemoteDataSourceProvider = Provider<MedicationRemoteDataSource>(
  (ref) => FirestoreMedicationRemoteDataSource(FirebaseFirestore.instance),
);

final medicationRepositoryProvider = Provider<MedicationRepository>(
  (ref) => MedicationRepositoryImpl(ref.watch(medicationRemoteDataSourceProvider)),
);

// ── Use cases ───────────────────────────────────────────────────────────
final watchPetMedicationOverviewProvider = Provider(
  (ref) => WatchPetMedicationOverview(
    ref.watch(medicationRepositoryProvider),
    ref.watch(clockProvider),
  ),
);
final watchMedicationProvider =
    Provider((ref) => WatchMedication(ref.watch(medicationRepositoryProvider)));
final saveMedicationProvider =
    Provider((ref) => SaveMedication(ref.watch(medicationRepositoryProvider)));
final stopMedicationProvider = Provider(
  (ref) => StopMedication(ref.watch(medicationRepositoryProvider), ref.watch(clockProvider)),
);
final deleteMedicationProvider =
    Provider((ref) => DeleteMedication(ref.watch(medicationRepositoryProvider)));

// ── State ───────────────────────────────────────────────────────────────
final petMedicationOverviewProvider =
    StreamProvider.family<MedicationOverview, String>((ref, petId) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(MedicationOverview.empty);
  return ref.watch(watchPetMedicationOverviewProvider)(ownerId: uid, petId: petId);
});

final medicationProvider = StreamProvider.family<Medication?, String>((ref, id) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(watchMedicationProvider)(ownerId: uid, medicationId: id);
});
