import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/storage/firestore_json.dart';
import '../models/document_model.dart';

/// Raw Firestore / Storage access for documents. Throws SDK exceptions.
abstract interface class DocumentRemoteDataSource {
  Stream<List<DocumentModel>> watchWhere(String ownerId, String field, String value);

  Stream<DocumentModel?> watchOne(String ownerId, String id);

  String newId(String ownerId);

  /// Returns `(downloadUrl, storagePath)`.
  Future<(String, String)> upload({
    required String path,
    required Uint8List bytes,
    required String contentType,
    void Function(double progress)? onProgress,
  });

  Future<void> deleteFile(String storagePath);

  Future<void> save(DocumentModel model);

  Future<void> deleteRecord(String ownerId, String id);

  Future<List<DocumentModel>> listForPet(String ownerId, String petId);
}

/// Records at `users/{uid}/documents/{id}`; files at
/// `users/{uid}/pets/{petId}/documents/{id}/{fileName}`.
class FirebaseDocumentRemoteDataSource implements DocumentRemoteDataSource {
  FirebaseDocumentRemoteDataSource(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _collection(String ownerId) =>
      _firestore.collection('users').doc(ownerId).collection('documents');

  static DocumentModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) =>
      DocumentModel.fromJson(firestoreDocToJson(d));

  @override
  Stream<List<DocumentModel>> watchWhere(String ownerId, String field, String value) =>
      _collection(ownerId)
          .where(field, isEqualTo: value)
          .snapshots()
          .map((s) => s.docs.map(_fromDoc).toList());

  @override
  Stream<DocumentModel?> watchOne(String ownerId, String id) => _collection(ownerId)
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? _fromDoc(d) : null);

  @override
  String newId(String ownerId) => _collection(ownerId).doc().id;

  @override
  Future<(String, String)> upload({
    required String path,
    required Uint8List bytes,
    required String contentType,
    void Function(double progress)? onProgress,
  }) async {
    final ref = _storage.ref(path);
    final task = ref.putData(bytes, SettableMetadata(contentType: contentType));
    final sub = task.snapshotEvents.listen((s) {
      if (s.totalBytes > 0) onProgress?.call(s.bytesTransferred / s.totalBytes);
    });
    try {
      await task;
    } finally {
      await sub.cancel();
    }
    return (await ref.getDownloadURL(), path);
  }

  @override
  Future<void> deleteFile(String storagePath) async {
    try {
      await _storage.ref(storagePath).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }

  @override
  Future<void> save(DocumentModel model) => _collection(model.ownerId).doc(model.id).set({
        ...model.toJson(),
        'createdAt': model.createdAt ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> deleteRecord(String ownerId, String id) => _collection(ownerId).doc(id).delete();

  @override
  Future<List<DocumentModel>> listForPet(String ownerId, String petId) async =>
      (await _collection(ownerId).where('petId', isEqualTo: petId).get()).docs.map(_fromDoc).toList();
}
