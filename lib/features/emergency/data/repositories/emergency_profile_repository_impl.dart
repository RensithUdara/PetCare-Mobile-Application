import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/firebase_error_handler.dart';
import '../../../../core/storage/firestore_json.dart';
import '../../domain/entities/emergency_profile.dart';
import '../../domain/repositories/emergency_profile_repository.dart';
import '../models/emergency_models.dart';

class EmergencyProfileRepositoryImpl implements EmergencyProfileRepository {
  EmergencyProfileRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _settings(String ownerId, String petId) =>
      _firestore.collection('users').doc(ownerId).collection('emergencyProfiles').doc(petId);

  DocumentReference<Map<String, dynamic>> _public(String publicId) =>
      _firestore.collection('publicProfiles').doc(publicId);

  static EmergencyProfile? _settingsFrom(DocumentSnapshot<Map<String, dynamic>> d) =>
      d.exists ? EmergencyProfileModel.fromJson(firestoreDocToJson(d)).toEntity() : null;

  @override
  Stream<EmergencyProfile?> watchSettings(String ownerId, String petId) => guardFirebaseStream(
        _settings(ownerId, petId).snapshots().map(_settingsFrom),
        message: 'Could not load the emergency profile.',
      );

  @override
  Future<EmergencyProfile?> getSettings(String ownerId, String petId) =>
      guardFirebase(() async => _settingsFrom(await _settings(ownerId, petId).get()));

  @override
  Future<void> saveSettings(EmergencyProfile settings) => guardFirebaseWrite(
        () => _settings(settings.ownerId, settings.petId).set({
          ...EmergencyProfileModel.fromEntity(settings).toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        }),
        label: 'Save emergency profile',
        message: 'Could not save the emergency profile.',
      );

  @override
  Future<bool> publicIdExists(String publicId) =>
      guardFirebase(() async => (await _public(publicId).get()).exists);

  @override
  Future<void> publish(PublicPetProfile profile) => guardFirebaseWrite(
        () => _public(profile.publicId).set({
          ...PublicPetProfileModel.fromEntity(profile).toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        }),
        label: 'Publish emergency profile',
        message: 'Could not publish the emergency profile.',
      );

  @override
  Future<void> unpublish(String publicId) => guardFirebaseWrite(
        () => _public(publicId).delete(),
        label: 'Turn off public profile',
        message: 'Could not turn off the public profile.',
      );

  @override
  Stream<PublicPetProfile?> watchPublic(String publicId) => guardFirebaseStream(
        _public(publicId).snapshots().map(
              (d) => d.exists ? PublicPetProfileModel.fromJson(firestoreDocToJson(d)).toEntity() : null,
            ),
        message: 'Could not load this profile.',
      );

  @override
  Future<void> deleteAllForPet({required String ownerId, required String petId}) =>
      guardFirebaseWrite(() async {
        final settings = await getSettings(ownerId, petId);
        if (settings != null) await _public(settings.publicId).delete();
        await _settings(ownerId, petId).delete();
      }, label: 'Delete emergency profile', message: 'Could not delete the emergency profile.');
}
