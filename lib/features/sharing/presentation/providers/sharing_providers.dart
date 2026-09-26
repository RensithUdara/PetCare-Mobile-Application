import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../../data/datasources/sharing_remote_data_source.dart';
import '../../data/repositories/sharing_repository_impl.dart';
import '../../domain/entities/pet_share.dart';
import '../../domain/repositories/sharing_repository.dart';
import '../../domain/usecases/find_doctor_by_code.dart';
import '../../domain/usecases/revoke_share.dart';
import '../../domain/usecases/share_pet_with_doctor.dart';
import '../../domain/usecases/watch_pet_shares.dart';

// ── Data ────────────────────────────────────────────────────────────────
final sharingRepositoryProvider = Provider<SharingRepository>(
  (ref) => SharingRepositoryImpl(
    SharingRemoteDataSource(FirebaseFirestore.instance),
    tracker: ref.watch(pendingWriteTrackerProvider),
  ),
);

// ── Use cases ───────────────────────────────────────────────────────────
final findDoctorByCodeProvider = Provider((ref) => FindDoctorByCode(ref.watch(sharingRepositoryProvider)));
final sharePetWithDoctorProvider = Provider((ref) => SharePetWithDoctor(ref.watch(sharingRepositoryProvider)));
final watchPetSharesProvider = Provider((ref) => WatchPetShares(ref.watch(sharingRepositoryProvider)));
final revokeShareProvider = Provider((ref) => RevokeShare(ref.watch(sharingRepositoryProvider)));

// ── State ───────────────────────────────────────────────────────────────
/// Vets that can see a pet's records.
final petSharesProvider = StreamProvider.autoDispose.family<List<PetShare>, String>((ref, petId) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(watchPetSharesProvider)(ownerId: uid, petId: petId);
});
