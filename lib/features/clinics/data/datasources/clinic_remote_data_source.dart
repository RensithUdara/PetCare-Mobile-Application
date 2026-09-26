import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/storage/firestore_json.dart';
import '../models/clinic_models.dart';

/// Raw Firestore access for clinics and veterinarians. Throws SDK exceptions.
class ClinicRemoteDataSource {
  ClinicRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _clinics(String ownerId) =>
      _firestore.collection('users').doc(ownerId).collection('clinics');

  CollectionReference<Map<String, dynamic>> _vets(String ownerId) =>
      _firestore.collection('users').doc(ownerId).collection('veterinarians');

  Map<String, dynamic> _withTimestamps(Map<String, dynamic> json, DateTime? createdAt) => {
        ...json,
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Stream<List<ClinicModel>> watchClinics(String ownerId) => _clinics(ownerId)
      .snapshots()
      .map((s) => s.docs.map((d) => ClinicModel.fromJson(firestoreDocToJson(d))).toList());

  Stream<ClinicModel?> watchClinic(String ownerId, String id) => _clinics(ownerId)
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? ClinicModel.fromJson(firestoreDocToJson(d)) : null);

  String newClinicId(String ownerId) => _clinics(ownerId).doc().id;

  Future<void> saveClinic(ClinicModel m) =>
      _clinics(m.ownerId).doc(m.id).set(_withTimestamps(m.toJson(), m.createdAt));

  Future<void> deleteClinic(String ownerId, String id) => _clinics(ownerId).doc(id).delete();

  Stream<List<VeterinarianModel>> watchVets(String ownerId) => _vets(ownerId)
      .snapshots()
      .map((s) => s.docs.map((d) => VeterinarianModel.fromJson(firestoreDocToJson(d))).toList());

  String newVetId(String ownerId) => _vets(ownerId).doc().id;

  Future<void> saveVet(VeterinarianModel m) =>
      _vets(m.ownerId).doc(m.id).set(_withTimestamps(m.toJson(), m.createdAt));

  Future<void> deleteVet(String ownerId, String id) => _vets(ownerId).doc(id).delete();
}
