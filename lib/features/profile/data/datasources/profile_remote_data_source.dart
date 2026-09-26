import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Raw Firestore / Storage / Auth access for the owner profile. Throws SDK
/// exceptions.
abstract interface class ProfileRemoteDataSource {
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProfile(String uid);

  Future<void> mergeProfile(String uid, Map<String, dynamic> fields);

  /// Mirrors name / photo onto the Firebase Auth user.
  Future<void> updateAuthUser({required String displayName, required String? photoUrl});

  Future<String> uploadPhoto(String uid, Uint8List bytes);

  Future<void> deletePhoto(String photoUrl);

  Future<void> deleteUserData(String uid);
}

class FirebaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  FirebaseProfileRemoteDataSource(this._firestore, this._storage, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  /// Per-user collections that don't belong to a pet (pet records are
  /// removed by `DeletePet`).
  static const _userCollections = ['clinics', 'veterinarians', 'devices'];

  DocumentReference<Map<String, dynamic>> _doc(String uid) => _firestore.collection('users').doc(uid);

  Reference _photoFolder(String uid) => _storage.ref('users/$uid/profile');

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProfile(String uid) => _doc(uid).snapshots();

  @override
  Future<void> mergeProfile(String uid, Map<String, dynamic> fields) =>
      _doc(uid).set(fields, SetOptions(merge: true));

  @override
  Future<void> updateAuthUser({required String displayName, required String? photoUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (user.displayName != displayName) await user.updateDisplayName(displayName);
    if (user.photoURL != photoUrl) await user.updatePhotoURL(photoUrl);
  }

  @override
  Future<String> uploadPhoto(String uid, Uint8List bytes) async {
    final ref = _photoFolder(uid).child('avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
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
  Future<void> deleteUserData(String uid) async {
    for (final name in _userCollections) {
      final docs = await _doc(uid).collection(name).get();
      // Batches are limited to 500 operations.
      for (var i = 0; i < docs.docs.length; i += 450) {
        final batch = _firestore.batch();
        for (final d in docs.docs.skip(i).take(450)) {
          batch.delete(d.reference);
        }
        await batch.commit();
      }
    }
    try {
      final photos = await _photoFolder(uid).listAll();
      await Future.wait(photos.items.map((f) => f.delete()));
    } on FirebaseException catch (_) {
      // Leftover avatar files must not block account deletion.
    }
    await _doc(uid).delete();
  }
}
