import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/storage/firestore_json.dart';
import '../models/pet_model.dart';

/// Raw Firestore / Storage access for pets. Throws SDK exceptions.
abstract interface class PetRemoteDataSource {
  Stream<List<PetModel>> watchPets(String ownerId);

  Stream<PetModel?> watchPet(String ownerId, String petId);

  String newPetId(String ownerId);

  Future<void> savePet(PetModel pet);

  Future<void> deletePet(String ownerId, String petId);

  Future<String> uploadPhoto({
    required String ownerId,
    required String petId,
    required Uint8List bytes,
    void Function(double progress)? onProgress,
  });

  Future<void> deletePhoto(String photoUrl);

  Future<void> deleteAllPhotos(String ownerId, String petId);
}

/// Pets live at `users/{uid}/pets/{petId}`; photos at
/// `users/{uid}/pets/{petId}/photo_<millis>.jpg` in Storage.
class FirebasePetRemoteDataSource implements PetRemoteDataSource {
  FirebasePetRemoteDataSource(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _pets(String ownerId) =>
      _firestore.collection('users').doc(ownerId).collection('pets');

  Reference _photoFolder(String ownerId, String petId) =>
      _storage.ref('users/$ownerId/pets/$petId');

  @override
  Stream<List<PetModel>> watchPets(String ownerId) => _pets(ownerId).snapshots().map(
        (s) => s.docs.map((d) => PetModel.fromJson(firestoreDocToJson(d))).toList(),
      );

  @override
  Stream<PetModel?> watchPet(String ownerId, String petId) =>
      _pets(ownerId).doc(petId).snapshots().map(
            (d) => d.exists ? PetModel.fromJson(firestoreDocToJson(d)) : null,
          );

  @override
  String newPetId(String ownerId) => _pets(ownerId).doc().id;

  @override
  Future<void> savePet(PetModel pet) => _pets(pet.ownerId).doc(pet.id).set({
        ...pet.toJson(),
        'createdAt': pet.createdAt ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> deletePet(String ownerId, String petId) =>
      _pets(ownerId).doc(petId).delete();

  @override
  Future<String> uploadPhoto({
    required String ownerId,
    required String petId,
    required Uint8List bytes,
    void Function(double progress)? onProgress,
  }) async {
    final ref = _photoFolder(ownerId, petId)
        .child('photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));

    final sub = task.snapshotEvents.listen((s) {
      if (s.totalBytes > 0) onProgress?.call(s.bytesTransferred / s.totalBytes);
    });
    try {
      await task;
    } finally {
      await sub.cancel();
    }
    return ref.getDownloadURL();
  }

  @override
  Future<void> deletePhoto(String photoUrl) async {
    try {
      await _storage.refFromURL(photoUrl).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }

  @override
  Future<void> deleteAllPhotos(String ownerId, String petId) async {
    final files = await _photoFolder(ownerId, petId).listAll();
    await Future.wait(files.items.map((f) => f.delete()));
  }
}
