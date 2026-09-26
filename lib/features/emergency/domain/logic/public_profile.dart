import 'dart:math';

import '../../../pets/domain/entities/pet.dart';
import '../entities/emergency_profile.dart';

/// Letters and digits without look-alikes (no 0/O, 1/I/L) so IDs read
/// clearly off a printed tag.
const _alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
const publicIdLength = 7;

/// A new random public ID such as `PC-8A72F9K`.
String generatePublicId([Random? random]) {
  final r = random ?? Random.secure();
  final code = List.generate(publicIdLength, (_) => _alphabet[r.nextInt(_alphabet.length)]).join();
  return 'PC-$code';
}

final _publicIdPattern = RegExp('^PC-[$_alphabet]{$publicIdLength}\$');

bool isValidPublicId(String id) => _publicIdPattern.hasMatch(id);

String? _clean(String? s) {
  final t = s?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

/// The privacy gate: copies only what [settings] allow from [pet].
PublicPetProfile buildPublicProfile(Pet pet, EmergencyProfile settings) => PublicPetProfile(
      publicId: settings.publicId,
      ownerId: settings.ownerId,
      petName: pet.name,
      species: pet.species.name,
      breed: settings.showBreed ? _clean(pet.breed) : null,
      photoUrl: settings.showPhoto ? pet.photoUrl : null,
      microchipId: settings.showMicrochip ? _clean(pet.microchipId) : null,
      contactName: _clean(settings.contactName),
      contactPhone: _clean(settings.contactPhone),
      medicalWarnings: _clean(settings.medicalWarnings),
      message: _clean(settings.message),
    );
