import 'dart:async';

import 'package:petcare/features/emergency/domain/entities/emergency_profile.dart';
import 'package:petcare/features/emergency/domain/repositories/emergency_profile_repository.dart';

class FakeEmergencyRepository implements EmergencyProfileRepository {
  FakeEmergencyRepository({List<EmergencyProfile> settings = const [], Set<String> takenIds = const {}}) {
    for (final s in settings) {
      _settings[s.petId] = s;
    }
    _takenIds.addAll(takenIds);
  }

  final _settings = <String, EmergencyProfile>{};

  /// Published pages by public id.
  final public = <String, PublicPetProfile>{};
  final _takenIds = <String>{};
  final _changes = StreamController<void>.broadcast();
  final calls = <String>[];

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  EmergencyProfile? settingsFor(String petId) => _settings[petId];

  @override
  Stream<EmergencyProfile?> watchSettings(String ownerId, String petId) => _watch(() => _settings[petId]);

  @override
  Future<EmergencyProfile?> getSettings(String ownerId, String petId) async => _settings[petId];

  @override
  Future<void> saveSettings(EmergencyProfile settings) async {
    _settings[settings.petId] = settings;
    _changes.add(null);
  }

  @override
  Future<bool> publicIdExists(String publicId) async =>
      _takenIds.contains(publicId) || public.containsKey(publicId);

  @override
  Future<void> publish(PublicPetProfile profile) async {
    calls.add('publish:${profile.publicId}');
    public[profile.publicId] = profile;
    _changes.add(null);
  }

  @override
  Future<void> unpublish(String publicId) async {
    calls.add('unpublish:$publicId');
    public.remove(publicId);
    _changes.add(null);
  }

  @override
  Stream<PublicPetProfile?> watchPublic(String publicId) => _watch(() => public[publicId]);

  @override
  Future<void> deleteAllForPet({required String ownerId, required String petId}) async {
    final s = _settings.remove(petId);
    if (s != null) public.remove(s.publicId);
    _changes.add(null);
  }
}
