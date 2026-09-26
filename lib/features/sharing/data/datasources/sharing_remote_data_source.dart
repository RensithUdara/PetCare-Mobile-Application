import 'package:cloud_firestore/cloud_firestore.dart';

/// Raw Firestore access for doctor lookup and shares. Throws SDK exceptions.
class SharingRemoteDataSource {
  SharingRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _shares => _firestore.collection('shares');

  /// Security rules require asking for approved doctors explicitly.
  Future<QuerySnapshot<Map<String, dynamic>>> findDoctorByCode(String code) => _firestore
      .collection('doctors')
      .where('doctorCode', isEqualTo: code)
      .where('status', isEqualTo: 'approved')
      .limit(1)
      .get(const GetOptions(source: Source.server));

  Stream<QuerySnapshot<Map<String, dynamic>>> watchPetShares(String ownerId, String petId) => _shares
      .where('ownerId', isEqualTo: ownerId)
      .where('petId', isEqualTo: petId)
      .snapshots();

  Future<QuerySnapshot<Map<String, dynamic>>> sharesForPet(String ownerId, String petId) =>
      _shares.where('ownerId', isEqualTo: ownerId).where('petId', isEqualTo: petId).get();

  Future<void> setShare(String id, Map<String, dynamic> data) => _shares.doc(id).set(data);

  Future<void> deleteShare(String id) => _shares.doc(id).delete();
}
