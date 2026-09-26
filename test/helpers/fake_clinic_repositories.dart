import 'dart:async';

import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/clinics/domain/entities/clinic.dart';
import 'package:petcare/features/clinics/domain/repositories/clinic_repository.dart';
import 'package:petcare/features/clinics/domain/repositories/nearby_clinics_repository.dart';

class FakeClinicRepository implements ClinicRepository {
  FakeClinicRepository({List<Clinic> clinics = const [], List<Veterinarian> vets = const []}) {
    for (final c in clinics) {
      _clinics[c.id] = c;
    }
    for (final v in vets) {
      _vets[v.id] = v;
    }
  }

  final _clinics = <String, Clinic>{};
  final _vets = <String, Veterinarian>{};
  final _changes = StreamController<void>.broadcast();
  var _next = 1;

  List<Clinic> get clinics => _clinics.values.toList();
  List<Veterinarian> get vets => _vets.values.toList();

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<List<Clinic>> watchClinics(String ownerId) => _watch(() => clinics);

  @override
  Stream<Clinic?> watchClinic(String ownerId, String clinicId) => _watch(() => _clinics[clinicId]);

  @override
  String newClinicId(String ownerId) => 'clinic${_next++}';

  @override
  Future<void> saveClinic(Clinic clinic) async {
    _clinics[clinic.id] = clinic;
    _changes.add(null);
  }

  @override
  Future<void> deleteClinic(String ownerId, String clinicId) async {
    _clinics.remove(clinicId);
    _changes.add(null);
  }

  @override
  Stream<List<Veterinarian>> watchVets(String ownerId) => _watch(() => vets);

  @override
  String newVetId(String ownerId) => 'vet${_next++}';

  @override
  Future<void> saveVet(Veterinarian vet) async {
    _vets[vet.id] = vet;
    _changes.add(null);
  }

  @override
  Future<void> deleteVet(String ownerId, String vetId) async {
    _vets.remove(vetId);
    _changes.add(null);
  }
}

class FakeNearbyClinicsRepository implements NearbyClinicsRepository {
  FakeNearbyClinicsRepository(this.results);

  final List<NearbyClinic> results;
  GeoPoint? lastCenter;

  @override
  Future<List<NearbyClinic>> search(GeoPoint center, {required int radiusMeters}) async {
    lastCenter = center;
    return results;
  }
}

class FakeLocationRepository implements LocationRepository {
  FakeLocationRepository([this.location = const GeoPoint(6.9271, 79.8612), this.failure]);

  final GeoPoint location;
  final Failure? failure;

  @override
  Future<GeoPoint> currentLocation() async {
    if (failure != null) throw failure!;
    return location;
  }
}
