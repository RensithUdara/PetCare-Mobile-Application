import 'package:freezed_annotation/freezed_annotation.dart';

part 'emergency_profile.freezed.dart';

/// The owner's private emergency settings for one pet: what to share and
/// how to reach them. Never readable by others — see [PublicPetProfile].
@freezed
abstract class EmergencyProfile with _$EmergencyProfile {
  const factory EmergencyProfile({
    required String petId,
    required String ownerId,

    /// Stable public identifier printed in the QR code, e.g. `PC-8A72F9K`.
    required String publicId,

    /// Whether the public page is currently available.
    @Default(true) bool enabled,
    @Default(true) bool showPhoto,
    @Default(true) bool showBreed,
    @Default(false) bool showMicrochip,
    String? contactName,
    String? contactPhone,

    /// Allergies, conditions, medication a finder or vet must know about.
    String? medicalWarnings,

    /// e.g. "Friendly but nervous around bikes. Please call me!"
    String? message,
    DateTime? updatedAt,
  }) = _EmergencyProfile;
}

/// What anyone scanning the pet's QR code can see. Contains only the
/// fields the owner chose to share (built by `buildPublicProfile`).
@freezed
abstract class PublicPetProfile with _$PublicPetProfile {
  const factory PublicPetProfile({
    required String publicId,

    /// Needed so security rules can restrict writes to the owner.
    required String ownerId,
    required String petName,

    /// `PetSpecies` name, e.g. "dog".
    required String species,
    String? breed,
    String? photoUrl,
    String? microchipId,
    String? contactName,
    String? contactPhone,
    String? medicalWarnings,
    String? message,
    DateTime? updatedAt,
  }) = _PublicPetProfile;
}
