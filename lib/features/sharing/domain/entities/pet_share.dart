import 'package:meta/meta.dart';

/// Access to one pet's records granted by its owner to one doctor.
@immutable
class PetShare {
  const PetShare({
    required this.ownerId,
    required this.petId,
    required this.doctorId,
    required this.petName,
    required this.doctorName,
    this.petSpecies,
    this.petPhotoUrl,
    this.ownerName,
    this.ownerEmail,
    this.ownerPhone,
    this.clinicName,
    this.doctorCode,
    this.createdAt,
  });

  final String ownerId;
  final String petId;
  final String doctorId;
  final String petName;
  final String doctorName;
  final String? petSpecies;
  final String? petPhotoUrl;
  final String? ownerName;
  final String? ownerEmail;
  final String? ownerPhone;
  final String? clinicName;
  final String? doctorCode;
  final DateTime? createdAt;

  /// Deterministic id, so security rules can check a share exists.
  String get id => idFor(ownerId: ownerId, petId: petId, doctorId: doctorId);

  static String idFor({required String ownerId, required String petId, required String doctorId}) =>
      '${ownerId}_${petId}_$doctorId';

  @override
  bool operator ==(Object other) => other is PetShare && other.id == id && other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, createdAt);
}
