import 'dart:async';
import 'dart:typed_data';

import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/domain/repositories/pet_repository.dart';

/// In-memory [PetRepository] for tests.
class FakePetRepository implements PetRepository {
  FakePetRepository([List<Pet> initial = const []]) {
    for (final pet in initial) {
      _pets[pet.id] = pet;
    }
  }

  final _pets = <String, Pet>{};
  final _changes = StreamController<void>.broadcast();
  var _nextId = 1;

  final calls = <String>[];
  final deletedPhotos = <String>[];
  Failure? saveFailure;

  List<Pet> get pets => _pets.values.toList();

  List<Pet> _sorted(String ownerId) => _pets.values
      .where((p) => p.ownerId == ownerId)
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  @override
  Stream<List<Pet>> watchPets(String ownerId) async* {
    yield _sorted(ownerId);
    yield* _changes.stream.map((_) => _sorted(ownerId));
  }

  @override
  Stream<Pet?> watchPet(String ownerId, String petId) async* {
    yield _pets[petId];
    yield* _changes.stream.map((_) => _pets[petId]);
  }

  @override
  String newPetId(String ownerId) => 'pet${_nextId++}';

  @override
  Future<void> savePet(Pet pet) async {
    calls.add('save:${pet.id}');
    if (saveFailure != null) throw saveFailure!;
    _pets[pet.id] = pet;
    _changes.add(null);
  }

  @override
  Future<void> deletePet(String ownerId, String petId) async {
    calls.add('delete:$petId');
    _pets.remove(petId);
    _changes.add(null);
  }

  @override
  Future<String> uploadPhoto({
    required String ownerId,
    required String petId,
    required Uint8List bytes,
    void Function(double progress)? onProgress,
  }) async {
    calls.add('upload:$petId:${bytes.length}');
    onProgress?.call(0.5);
    onProgress?.call(1);
    return 'https://photos/$petId/${calls.length}.jpg';
  }

  @override
  Future<void> deletePhoto(String photoUrl) async {
    deletedPhotos.add(photoUrl);
  }
}
