import 'dart:math';

import '../../../../core/errors/failure.dart';
import '../../../pets/domain/entities/pet.dart';
import '../entities/emergency_profile.dart';
import '../logic/public_profile.dart';
import '../repositories/emergency_profile_repository.dart';

final _phone = RegExp(r'^\+?[0-9]{7,15}$');

class WatchEmergencyProfile {
  const WatchEmergencyProfile(this._repository);

  final EmergencyProfileRepository _repository;

  Stream<EmergencyProfile?> call({required String ownerId, required String petId}) =>
      _repository.watchSettings(ownerId, petId);
}

class WatchPublicProfile {
  const WatchPublicProfile(this._repository);

  final EmergencyProfileRepository _repository;

  Stream<PublicPetProfile?> call(String publicId) => isValidPublicId(publicId)
      ? _repository.watchPublic(publicId)
      : Stream.value(null);
}

/// Validates [settings], stores them and publishes (or withdraws) the
/// public page accordingly.
class SaveEmergencyProfile {
  const SaveEmergencyProfile(this._repository);

  final EmergencyProfileRepository _repository;

  Future<void> call({required Pet pet, required EmergencyProfile settings}) async {
    final phone = settings.contactPhone?.replaceAll(RegExp(r'[\s\-()]'), '');
    if (settings.enabled && (phone == null || phone.isEmpty)) {
      throw const Failure('Add a phone number so finders can reach you', code: 'missing-phone');
    }
    if (phone != null && phone.isNotEmpty && !_phone.hasMatch(phone)) {
      throw const Failure('Enter a valid phone number', code: 'invalid-phone');
    }
    await _repository.saveSettings(settings);
    if (settings.enabled) {
      await _repository.publish(buildPublicProfile(pet, settings));
    } else {
      await _repository.unpublish(settings.publicId);
    }
  }
}

/// Creates a pet's emergency profile with a fresh, unique public ID. The ID
/// then stays the same forever, so printed QR tags keep working.
class CreateEmergencyProfile {
  const CreateEmergencyProfile(this._repository, this._save, [this._random]);

  final EmergencyProfileRepository _repository;
  final SaveEmergencyProfile _save;
  final Random? _random;

  static const _maxAttempts = 5;

  Future<EmergencyProfile> call({
    required String ownerId,
    required Pet pet,
    required String contactPhone,
    String? contactName,
  }) async {
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final id = generatePublicId(_random);
      if (await _repository.publicIdExists(id)) continue;
      final settings = EmergencyProfile(
        petId: pet.id,
        ownerId: ownerId,
        publicId: id,
        contactName: contactName,
        contactPhone: contactPhone,
        // Share the microchip by default only if the pet has one.
        showMicrochip: pet.microchipId != null,
      );
      await _save(pet: pet, settings: settings);
      return settings;
    }
    throw const Failure('Could not create an ID. Please try again.', code: 'id-collision');
  }
}

/// Re-publishes the public page after the pet's own details changed
/// (name, photo, breed…). No-op when there's no enabled profile.
class RefreshPublicProfile {
  const RefreshPublicProfile(this._repository);

  final EmergencyProfileRepository _repository;

  Future<void> call({required String ownerId, required Pet pet}) async {
    final settings = await _repository.getSettings(ownerId, pet.id);
    if (settings == null || !settings.enabled) return;
    await _repository.publish(buildPublicProfile(pet, settings));
  }
}
