import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/storage/firestore_json.dart';
import '../models/appointment_model.dart';

/// Raw Firestore access for appointments. Throws SDK exceptions.
abstract interface class AppointmentRemoteDataSource {
  Stream<List<AppointmentModel>> watchForPet(String ownerId, String petId);

  Stream<List<AppointmentModel>> watchAll(String ownerId);

  Stream<AppointmentModel?> watchOne(String ownerId, String id);

  String newId(String ownerId);

  Future<void> save(AppointmentModel model);

  Future<void> delete(String ownerId, String id);

  Future<void> deleteAllForPet(String ownerId, String petId);
}

class FirestoreAppointmentRemoteDataSource implements AppointmentRemoteDataSource {
  FirestoreAppointmentRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  static const _batchLimit = 500;

  CollectionReference<Map<String, dynamic>> _collection(String ownerId) =>
      _firestore.collection('users').doc(ownerId).collection('appointments');

  static List<AppointmentModel> _toModels(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map((d) => AppointmentModel.fromJson(firestoreDocToJson(d))).toList();

  @override
  Stream<List<AppointmentModel>> watchForPet(String ownerId, String petId) =>
      _collection(ownerId).where('petId', isEqualTo: petId).snapshots().map(_toModels);

  @override
  Stream<List<AppointmentModel>> watchAll(String ownerId) =>
      _collection(ownerId).snapshots().map(_toModels);

  @override
  Stream<AppointmentModel?> watchOne(String ownerId, String id) =>
      _collection(ownerId).doc(id).snapshots().map(
            (d) => d.exists ? AppointmentModel.fromJson(firestoreDocToJson(d)) : null,
          );

  @override
  String newId(String ownerId) => _collection(ownerId).doc().id;

  @override
  Future<void> save(AppointmentModel model) => _collection(model.ownerId).doc(model.id).set({
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
