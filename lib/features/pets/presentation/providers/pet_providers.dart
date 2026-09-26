import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../appointments/presentation/providers/appointment_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../vaccinations/presentation/providers/vaccination_providers.dart';
import '../../data/datasources/pet_remote_data_source.dart';
import '../../data/repositories/pet_repository_impl.dart';
import '../../domain/entities/pet.dart';
import '../../domain/repositories/pet_repository.dart';
import '../../domain/usecases/delete_pet.dart';
import '../../domain/usecases/save_pet.dart';
import '../../domain/usecases/watch_pet.dart';
import '../../domain/usecases/watch_pets.dart';

// ── Data ────────────────────────────────────────────────────────────────
final petRemoteDataSourceProvider = Provider<PetRemoteDataSource>(
  (ref) => FirebasePetRemoteDataSource(FirebaseFirestore.instance, FirebaseStorage.instance),
);

final petRepositoryProvider = Provider<PetRepository>(
  (ref) => PetRepositoryImpl(ref.watch(petRemoteDataSourceProvider)),
);

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

// ── Use cases ───────────────────────────────────────────────────────────
final watchPetsProvider = Provider((ref) => WatchPets(ref.watch(petRepositoryProvider)));
final watchPetProvider = Provider((ref) => WatchPet(ref.watch(petRepositoryProvider)));
final savePetProvider = Provider((ref) => SavePet(ref.watch(petRepositoryProvider)));
final deletePetProvider = Provider(
  (ref) => DeletePet(ref.watch(petRepositoryProvider), [
    ref.watch(vaccinationRepositoryProvider),
    ref.watch(appointmentRepositoryProvider),
  ]),
);

// ── State ───────────────────────────────────────────────────────────────
/// All pets of the signed-in user.
final petsProvider = StreamProvider<List<Pet>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(watchPetsProvider)(uid);
});

/// A single pet by id; `null` if it doesn't exist (e.g. just deleted).
final petProvider = StreamProvider.family<Pet?, String>((ref, petId) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(watchPetProvider)(uid, petId);
});
