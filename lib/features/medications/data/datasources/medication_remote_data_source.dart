import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/storage/firestore_json.dart';
import '../models/medication_model.dart';

/// Raw Firestore access for medications. Throws SDK exceptions.
abstract interface class MedicationRemoteDataSource {
  Stream<List<MedicationModel>> watchForPet(String ownerId, String petId);

  Stream<List<MedicationModel>> watchAll(String ownerId);

  Stream<MedicationModel?> watchOne(String ownerId, String id);

  String newId(String ownerId);

  Future<void> save(MedicationModel model);

  Future<void> delete(String ownerId, String id);

  Future<void> deleteAllForPet(String ownerId, String petId);
}

class FirestoreMedicationRemoteDataSource implements MedicationRemoteDataSource {
  FirestoreMedicationRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  static const _batchLimit = 500;

  CollectionReference<Map<String, dynamic>> _collection(String ownerId) =>
      _firestore.collection('users').doc(ownerId).collection('medications');

  static List<MedicationModel> _toModels(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map((d) => MedicationModel.fromJson(firestoreDocToJson(d))).toList();

  @override
  Stream<List<MedicationModel>> watchForPet(String ownerId, String petId) =>
      _collection(ownerId).where('petId', isEqualTo: petId).snapshots().map(_toModels);

  @override
  Stream<List<MedicationModel>> watchAll(String ownerId) =>
      _collection(ownerId).snapshots().map(_toModels);

  @override
  Stream<MedicationModel?> watchOne(String ownerId, String id) =>
      _collection(ownerId).doc(id).snapshots().map(
            (d) => d.exists ? MedicationModel.fromJson(firestoreDocToJson(d)) : null,
          );

  @override
  String newId(String ownerId) => _collection(ownerId).doc().id;

  @override
  Future<void> save(MedicationModel model) => _collection(model.ownerId).doc(model.id).set({
        ...model.toJson(),
        'createdAt': model.createdAt ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> delete(String ownerId, String id) => _collection(ownerId).doc(id).delete();

  @override
  Future<void> deleteAllForPet(String ownerId, String petId) async {
    final docs = (await _collection(ownerId).where('petId', isEqualTo: petId).get()).docs;
    for (var i = 0; i < docs.length; i += _batchLimit) {
      final batch = _firestore.batch();
      for (final doc in docs.skip(i).take(_batchLimit)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
