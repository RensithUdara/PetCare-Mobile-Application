import '../../../../core/errors/firebase_error_handler.dart';
import '../../domain/entities/vaccination.dart';
import '../../domain/repositories/vaccination_repository.dart';
import '../datasources/vaccination_remote_data_source.dart';
import '../models/vaccination_model.dart';

class VaccinationRepositoryImpl implements VaccinationRepository {
  VaccinationRepositoryImpl(this._remote);

  final VaccinationRemoteDataSource _remote;

  static List<Vaccination> _toEntities(List<VaccinationModel> models) =>
      models.map((m) => m.toEntity()).toList();

  @override
  Stream<List<Vaccination>> watchForPet(String ownerId, String petId) => guardFirebaseStream(
        _remote.watchForPet(ownerId, petId).map(_toEntities),
        message: 'Could not load vaccinations.',
      );

  @override
  Stream<List<Vaccination>> watchAll(String ownerId) => guardFirebaseStream(
        _remote.watchAll(ownerId).map(_toEntities),
        message: 'Could not load vaccinations.',
      );

  @override
  Stream<Vaccination?> watchOne(String ownerId, String vaccinationId) => guardFirebaseStream(
        _remote.watchOne(ownerId, vaccinationId).map((m) => m?.toEntity()),
        message: 'Could not load this vaccination.',
      );

  @override
  String newId(String ownerId) => _remote.newId(ownerId);

  @override
  Future<void> save(Vaccination vaccination) {
    assert(!vaccination.isNew, 'Vaccination id must be set before saving');
    return guardFirebase(
      () => _remote.save(VaccinationModel.fromEntity(vaccination)),
      message: 'Could not save vaccination. Please try again.',
    );
  }

  @override
  Future<void> delete(String ownerId, String vaccinationId) => guardFirebase(
        () => _remote.delete(ownerId, vaccinationId),
        message: 'Could not delete vaccination. Please try again.',
      );

  @override
  Future<void> deleteAllForPet({required String ownerId, required String petId}) =>
      guardFirebase(
        () => _remote.deleteAllForPet(ownerId, petId),
        message: 'Could not delete this pet’s vaccinations. Please try again.',
      );
}
