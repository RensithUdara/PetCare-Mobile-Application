import 'dart:typed_data';

import '../../../../core/errors/firebase_error_handler.dart';
import '../../domain/entities/pet.dart';
import '../../domain/repositories/pet_repository.dart';
import '../datasources/pet_remote_data_source.dart';
import '../models/pet_model.dart';

class PetRepositoryImpl implements PetRepository {
  PetRepositoryImpl(this._remote);

  final PetRemoteDataSource _remote;

  @override
  Stream<List<Pet>> watchPets(String ownerId) => guardFirebaseStream(
        _remote.watchPets(ownerId).map((models) {
          final pets = models.map((m) => m.toEntity()).toList()
            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          return pets;
        }),
        message: 'Could not load your pets.',
      );

  @override
  Stream<Pet?> watchPet(String ownerId, String petId) => guardFirebaseStream(
        _remote.watchPet(ownerId, petId).map((m) => m?.toEntity()),
        message: 'Could not load this pet.',
      );

  @override
  String newPetId(String ownerId) => _remote.newPetId(ownerId);

  @override
  Future<void> savePet(Pet pet) {
    assert(!pet.isNew, 'Pet id must be set before saving');
    return guardFirebaseWrite(
      () => _remote.savePet(PetModel.fromEntity(pet)),
      label: 'Save pet',
      message: 'Could not save pet. Please try again.',
    );
  }

  @override
  Future<void> deletePet(String ownerId, String petId) {
    return guardFirebaseWrite(() async {
      await _remote.deletePet(ownerId, petId);
      // Best effort: leftover photos must not make the delete fail.
      try {
        await _remote.deleteAllPhotos(ownerId, petId);
      } catch (_) {}
    }, label: 'Delete pet', message: 'Could not delete pet. Please try again.');
  }

  @override
  Future<String> uploadPhoto({
    required String ownerId,
    required String petId,
    required Uint8List bytes,
    void Function(double progress)? onProgress,
  }) =>
      guardFirebase(
        () => _remote.uploadPhoto(
          ownerId: ownerId,
          petId: petId,
          bytes: bytes,
          onProgress: onProgress,
        ),
        message: 'Could not upload photo. Please try again.',
      );

  @override
  Future<void> deletePhoto(String photoUrl) => guardFirebase(() => _remote.deletePhoto(photoUrl));
}
