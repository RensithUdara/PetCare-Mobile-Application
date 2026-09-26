import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/doctor_profile.dart';
import '../../domain/entities/pet_share.dart';

/// Maps `doctors/{uid}` (written by the web doctor portal).
abstract final class DoctorProfileModel {
  static DoctorProfile fromDoc(String id, Map<String, dynamic> d) => DoctorProfile(
        id: id,
        fullName: (d['fullName'] as String?) ?? 'Veterinarian',
        doctorCode: (d['doctorCode'] as String?) ?? '',
        clinicName: d['clinicName'] as String?,
        specialization: d['specialization'] as String?,
        city: d['city'] as String?,
        phone: d['phone'] as String?,
        photoUrl: d['photoUrl'] as String?,
      );
}

/// Maps `shares/{ownerId_petId_doctorId}`.
abstract final class PetShareModel {
  static PetShare fromDoc(Map<String, dynamic> d) => PetShare(
        ownerId: d['ownerId'] as String,
        petId: d['petId'] as String,
        doctorId: d['doctorId'] as String,
        petName: (d['petName'] as String?) ?? '',
        doctorName: (d['doctorName'] as String?) ?? 'Veterinarian',
        petSpecies: d['petSpecies'] as String?,
        petPhotoUrl: d['petPhotoUrl'] as String?,
        ownerName: d['ownerName'] as String?,
        ownerEmail: d['ownerEmail'] as String?,
        ownerPhone: d['ownerPhone'] as String?,
        clinicName: d['clinicName'] as String?,
        doctorCode: d['doctorCode'] as String?,
        createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      );

  static Map<String, dynamic> toJson(PetShare s) => {
        'ownerId': s.ownerId,
        'petId': s.petId,
        'doctorId': s.doctorId,
        'petName': s.petName,
        'petSpecies': s.petSpecies,
        'petPhotoUrl': s.petPhotoUrl,
        'ownerName': s.ownerName,
        'ownerEmail': s.ownerEmail,
        'ownerPhone': s.ownerPhone,
        'doctorName': s.doctorName,
        'clinicName': s.clinicName,
        'doctorCode': s.doctorCode,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
