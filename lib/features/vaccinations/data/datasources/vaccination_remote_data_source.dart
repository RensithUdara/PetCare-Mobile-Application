import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/storage/firestore_json.dart';
import '../models/vaccination_model.dart';

/// Raw Firestore access for vaccinations. Throws SDK exceptions.
abstract interface class VaccinationRemoteDataSource {
  Stream<List<VaccinationModel>> watchForPet(String ownerId, String petId);

  Stream<List<VaccinationModel>> watchAll(String ownerId);

  Stream<VaccinationModel?> watchOne(String ownerId, String id);

  String newId(String ownerId);

  Future<void> save(VaccinationModel model);

  Future<void> delete(String ownerId, String id);

  Future<void> deleteAllForPet(String ownerId, String petId);
}

class FirestoreVaccinationRemoteDataSource implements VaccinationRemoteDataSource {
  FirestoreVaccinationRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Firestore allows at most 500 writes per batch.
  static const _batchLimit = 500;

  CollectionReference<Map<String, dynamic>> _collection(String ownerId) =>
      _firestore.collection('users').doc(ownerId).collection('vaccinations');

  static List<VaccinationModel> _toModels(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map((d) => VaccinationModel.fromJson(firestoreDocToJson(d))).toList();

  // Single-field equality filters need no composite index; sorting is done
  // in the domain layer.
  @override
  Stream<List<VaccinationModel>> watchForPet(String ownerId, String petId) =>
      _collection(ownerId).where('petId', isEqualTo: petId).snapshots().map(_toModels);

  @override
  Stream<List<VaccinationModel>> watchAll(String ownerId) =>
      _collection(ownerId).snapshots().map(_toModels);

  @override
  Stream<VaccinationModel?> watchOne(String ownerId, String id) =>
      _collection(ownerId).doc(id).snapshots().map(
            (d) => d.exists ? VaccinationModel.fromJson(firestoreDocToJson(d)) : null,
          );

  @override
  String newId(String ownerId) => _collection(ownerId).doc().id;

  @override
  Future<void> save(VaccinationModel model) => _collection(model.ownerId).doc(model.id).set({
        ...model.toJson(),
        'createdAt': model.createdAt ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> delete(String ownerId, String id) => _collection(ownerId).doc(id).delete();

  @override
  Future<void> deleteAllForPet(String ownerId, String petId) async {
    final snapshot = await _collection(ownerId).where('petId', isEqualTo: petId).get();
    final docs = snapshot.docs;
    for (var i = 0; i < docs.length; i += _batchLimit) {
      final batch = _firestore.batch();
      for (final doc in docs.skip(i).take(_batchLimit)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
