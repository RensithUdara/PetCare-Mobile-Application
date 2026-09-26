import 'dart:async';

import 'package:petcare/features/sharing/domain/entities/doctor_profile.dart';
import 'package:petcare/features/sharing/domain/entities/pet_share.dart';
import 'package:petcare/features/sharing/domain/repositories/sharing_repository.dart';

/// In-memory [SharingRepository] for tests.
class FakeSharingRepository implements SharingRepository {
  FakeSharingRepository({List<DoctorProfile> doctors = const [], List<PetShare> shares = const []})
      : _doctors = doctors,
        _shares = [...shares];

  final List<DoctorProfile> _doctors;
  final List<PetShare> _shares;
  final _changes = StreamController<void>.broadcast();
  final calls = <String>[];

  List<PetShare> get shares => List.unmodifiable(_shares);

  @override
  Future<DoctorProfile?> findDoctorByCode(String code) async {
    calls.add('find:$code');
    return _doctors.where((d) => d.doctorCode == code).firstOrNull;
  }

  List<PetShare> _for(String ownerId, String petId) =>
      _shares.where((s) => s.ownerId == ownerId && s.petId == petId).toList();

  @override
  Stream<List<PetShare>> watchPetShares({required String ownerId, required String petId}) async* {
    yield _for(ownerId, petId);
    yield* _changes.stream.map((_) => _for(ownerId, petId));
  }

  @override
  Future<void> share(PetShare share) async {
    calls.add('share:${share.id}');
    _shares.add(share);
    _changes.add(null);
  }

  @override
  Future<void> revoke(PetShare share) async {
    calls.add('revoke:${share.id}');
    _shares.removeWhere((s) => s.id == share.id);
    _changes.add(null);
  }

  @override
  Future<void> deleteAllForPet({required String ownerId, required String petId}) async {
    calls.add('deleteAllForPet:$petId');
    _shares.removeWhere((s) => s.ownerId == ownerId && s.petId == petId);
    _changes.add(null);
  }
}
