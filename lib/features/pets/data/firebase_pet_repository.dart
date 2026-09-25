import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/storage/firestore_json.dart';
import '../domain/pet.dart';
import '../domain/pet_repository.dart';

/// Pets live at `users/{uid}/pets/{petId}`; photos at
/// `users/{uid}/pets/{petId}/photo_<millis>.jpg` in Storage.
class FirebasePetRepository implements PetRepository {
  FirebasePetRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _pets(String ownerId) =>
      _firestore.collection('users').doc(ownerId).collection('pets');

  Reference _photoFolder(String ownerId, String petId) =>
      _storage.ref('users/$ownerId/pets/$petId');

  @override
  Stream<List<Pet>> watchPets(String ownerId) {
    return _pets(ownerId).snapshots().map((snapshot) {
      final pets = snapshot.docs.map((d) => Pet.fromJson(firestoreDocToJson(d))).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return pets;
    });
  }

  @override
  Stream<Pet?> watchPet(String ownerId, String petId) {
    return _pets(ownerId).doc(petId).snapshots().map(
          (doc) => doc.exists ? Pet.fromJson(firestoreDocToJson(doc)) : null,
        );
  }

  @override
  String newPetId(String ownerId) => _pets(ownerId).doc().id;

  @override
  Future<void> savePet(Pet pet) {
    assert(pet.id.isNotEmpty, 'Pet id must be set before saving');
    return guardFirebase(
      () => _pets(pet.ownerId).doc(pet.id).set({
        ...pet.toJson(),
        'createdAt': pet.createdAt ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }),
      message: 'Could not save pet. Please try again.',
    );
  }

  @override
  Future<void> deletePet(String ownerId, String petId) {
    return guardFirebase(() async {
      await _pets(ownerId).doc(petId).delete();
      // Best effort: a leftover photo must not make the delete fail.
      try {
        final files = await _photoFolder(ownerId, petId).listAll();
        await Future.wait(files.items.map((f) => f.delete()));
      } on FirebaseException {
        // Ignored.
      }
    }, message: 'Could not delete pet. Please try again.');
  }

  @override
  Future<String> uploadPhoto({
    required String ownerId,
    required String petId,
    required Uint8List bytes,
    void Function(double progress)? onProgress,
  }) {
    return guardFirebase(() async {
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
    }, message: 'Could not upload photo. Please try again.');
  }

  @override
  Future<void> deletePhoto(String photoUrl) async {
    try {
      await _storage.refFromURL(photoUrl).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }
}
