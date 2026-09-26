import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/firebase_error_handler.dart';
import '../../../../core/storage/firestore_json.dart';
import '../../domain/entities/weight_entry.dart';
import '../../domain/repositories/weight_repository.dart';
import '../models/weight_entry_model.dart';

/// Raw Firestore access for weigh-ins (`users/{uid}/weights`).
class WeightRemoteDataSource {
  WeightRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  static const _batchLimit = 500;

  CollectionReference<Map<String, dynamic>> _collection(String ownerId) =>
      _firestore.collection('users').doc(ownerId).collection('weights');

  Query<Map<String, dynamic>> _forPet(String ownerId, String petId) =>
      _collection(ownerId).where('petId', isEqualTo: petId);

  static WeightEntryModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) =>
      WeightEntryModel.fromJson(firestoreDocToJson(d));

  Stream<List<WeightEntryModel>> watchForPet(String ownerId, String petId) =>
      _forPet(ownerId, petId).snapshots().map((s) => s.docs.map(_fromDoc).toList());

  Future<List<WeightEntryModel>> listForPet(String ownerId, String petId) async =>
      (await _forPet(ownerId, petId).get()).docs.map(_fromDoc).toList();

  String newId(String ownerId) => _collection(ownerId).doc().id;

  Future<void> save(WeightEntryModel m) => _collection(m.ownerId).doc(m.id).set({
        ...m.toJson(),
        'createdAt': m.createdAt ?? FieldValue.serverTimestamp(),
      });

  Future<void> delete(String ownerId, String id) => _collection(ownerId).doc(id).delete();

  Future<void> deleteAllForPet(String ownerId, String petId) async {
    final docs = (await _forPet(ownerId, petId).get()).docs;
    for (var i = 0; i < docs.length; i += _batchLimit) {
      final batch = _firestore.batch();
      for (final doc in docs.skip(i).take(_batchLimit)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}

class WeightRepositoryImpl implements WeightRepository {
  WeightRepositoryImpl(this._remote);

  final WeightRemoteDataSource _remote;

  @override
  Stream<List<WeightEntry>> watchForPet(String ownerId, String petId) => guardFirebaseStream(
        _remote.watchForPet(ownerId, petId).map((ms) => ms.map((m) => m.toEntity()).toList()),
        message: 'Could not load weight history.',
      );

  @override
  Future<List<WeightEntry>> listForPet(String ownerId, String petId) => guardFirebase(
        () async => (await _remote.listForPet(ownerId, petId)).map((m) => m.toEntity()).toList(),
        message: 'Could not load weight history.',
      );

  @override
  String newId(String ownerId) => _remote.newId(ownerId);

  @override
  Future<void> save(WeightEntry entry) => guardFirebaseWrite(
        () => _remote.save(WeightEntryModel.fromEntity(entry)),
        label: 'Log weight',
        message: 'Could not save weight. Please try again.',
      );

  @override
  Future<void> delete(String ownerId, String entryId) => guardFirebaseWrite(
        () => _remote.delete(ownerId, entryId),
        label: 'Delete weigh-in',
        message: 'Could not delete entry. Please try again.',
      );

  @override
  Future<void> deleteAllForPet({required String ownerId, required String petId}) => guardFirebaseWrite(
        () => _remote.deleteAllForPet(ownerId, petId),
        label: 'Delete weight history',
        message: 'Could not delete this pet’s weight history.',
      );
}
