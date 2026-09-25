import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../authentication/presentation/auth_providers.dart';
import '../data/firebase_pet_repository.dart';
import '../domain/pet.dart';
import '../domain/pet_repository.dart';

final petRepositoryProvider = Provider<PetRepository>(
  (ref) => FirebasePetRepository(FirebaseFirestore.instance, FirebaseStorage.instance),
);

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

/// All pets of the signed-in user.
final petsProvider = StreamProvider<List<Pet>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(petRepositoryProvider).watchPets(uid);
});

/// A single pet by id; `null` if it doesn't exist (e.g. just deleted).
final petProvider = StreamProvider.family<Pet?, String>((ref, petId) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(petRepositoryProvider).watchPet(uid, petId);
});
