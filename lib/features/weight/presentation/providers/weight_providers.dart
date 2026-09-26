import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/clock.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../data/repositories/weight_repository_impl.dart';
import '../../domain/entities/weight_entry.dart';
import '../../domain/repositories/weight_repository.dart';
import '../../domain/usecases/weight_usecases.dart';

// ── Data ────────────────────────────────────────────────────────────────
final weightRepositoryProvider = Provider<WeightRepository>(
  (ref) => WeightRepositoryImpl(WeightRemoteDataSource(FirebaseFirestore.instance)),
);

// ── Use cases ───────────────────────────────────────────────────────────
final watchPetWeightsProvider =
    Provider((ref) => WatchPetWeights(ref.watch(weightRepositoryProvider)));
final syncPetCurrentWeightProvider = Provider(
  (ref) => SyncPetCurrentWeight(ref.watch(weightRepositoryProvider), ref.watch(petRepositoryProvider)),
);
final logWeightProvider = Provider(
  (ref) => LogWeight(
    ref.watch(weightRepositoryProvider),
    ref.watch(syncPetCurrentWeightProvider),
    ref.watch(clockProvider),
  ),
);
final deleteWeightEntryProvider = Provider(
  (ref) => DeleteWeightEntry(ref.watch(weightRepositoryProvider), ref.watch(syncPetCurrentWeightProvider)),
);

// ── State ───────────────────────────────────────────────────────────────
/// A pet's weigh-ins, oldest first.
final petWeightsProvider = StreamProvider.family<List<WeightEntry>, String>((ref, petId) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(watchPetWeightsProvider)(ownerId: uid, petId: petId);
});
