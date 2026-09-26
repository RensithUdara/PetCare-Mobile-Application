import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/firebase_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/clinic.dart';
import '../../domain/repositories/clinic_repository.dart';
import '../../domain/repositories/nearby_clinics_repository.dart';
import '../datasources/clinic_remote_data_source.dart';
import '../datasources/overpass_data_source.dart';
import '../models/clinic_models.dart';

class ClinicRepositoryImpl implements ClinicRepository {
  ClinicRepositoryImpl(this._remote);

  final ClinicRemoteDataSource _remote;

  @override
  Stream<List<Clinic>> watchClinics(String ownerId) => guardFirebaseStream(
        _remote.watchClinics(ownerId).map((ms) => ms.map((m) => m.toEntity()).toList()),
        message: 'Could not load clinics.',
      );

  @override
  Stream<Clinic?> watchClinic(String ownerId, String clinicId) => guardFirebaseStream(
        _remote.watchClinic(ownerId, clinicId).map((m) => m?.toEntity()),
        message: 'Could not load this clinic.',
      );

  @override
  String newClinicId(String ownerId) => _remote.newClinicId(ownerId);

  @override
  Future<void> saveClinic(Clinic clinic) => guardFirebaseWrite(
        () => _remote.saveClinic(ClinicModel.fromEntity(clinic)),
        label: 'Save clinic',
        message: 'Could not save clinic. Please try again.',
      );

  @override
  Future<void> deleteClinic(String ownerId, String clinicId) => guardFirebaseWrite(
        () => _remote.deleteClinic(ownerId, clinicId),
        label: 'Delete clinic',
        message: 'Could not delete clinic. Please try again.',
      );

  @override
  Stream<List<Veterinarian>> watchVets(String ownerId) => guardFirebaseStream(
        _remote.watchVets(ownerId).map((ms) => ms.map((m) => m.toEntity()).toList()),
        message: 'Could not load veterinarians.',
      );

  @override
  String newVetId(String ownerId) => _remote.newVetId(ownerId);

  @override
  Future<void> saveVet(Veterinarian vet) => guardFirebaseWrite(
        () => _remote.saveVet(VeterinarianModel.fromEntity(vet)),
        label: 'Save veterinarian',
        message: 'Could not save veterinarian. Please try again.',
      );

  @override
  Future<void> deleteVet(String ownerId, String vetId) => guardFirebaseWrite(
        () => _remote.deleteVet(ownerId, vetId),
        label: 'Delete veterinarian',
        message: 'Could not delete veterinarian. Please try again.',
      );
}

class NearbyClinicsRepositoryImpl implements NearbyClinicsRepository {
  NearbyClinicsRepositoryImpl(this._overpass);

  final OverpassDataSource _overpass;

  @override
  Future<List<NearbyClinic>> search(GeoPoint center, {required int radiusMeters}) async {
    try {
      return await _overpass.searchVeterinary(center, radiusMeters);
    } on DioException catch (e) {
      throw failureFromDio(e, fallback: 'Could not search for nearby clinics. Please try again.');
    }
  }
}

class GeolocatorLocationRepository implements LocationRepository {
  @override
  Future<GeoPoint> currentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const Failure('Turn on location services to find clinics near you.',
          code: 'location-disabled');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const Failure('Location permission is needed to find clinics near you.',
          code: 'location-denied');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const Failure('Location access is blocked. Enable it for PetCare in Settings.',
          code: 'location-denied-forever');
    }
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return GeoPoint(p.latitude, p.longitude);
  }
}
