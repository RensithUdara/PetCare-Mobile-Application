import '../../../../core/errors/firebase_error_handler.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_remote_data_source.dart';
import '../models/medication_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  MedicationRepositoryImpl(this._remote);

  final MedicationRemoteDataSource _remote;

  static List<Medication> _toEntities(List<MedicationModel> models) =>
      models.map((m) => m.toEntity()).toList();

  @override
  Stream<List<Medication>> watchForPet(String ownerId, String petId) => guardFirebaseStream(
        _remote.watchForPet(ownerId, petId).map(_toEntities),
        message: 'Could not load medications.',
      );

  @override
  Stream<List<Medication>> watchAll(String ownerId) => guardFirebaseStream(
        _remote.watchAll(ownerId).map(_toEntities),
        message: 'Could not load medications.',
      );

  @override
  Stream<Medication?> watchOne(String ownerId, String medicationId) => guardFirebaseStream(
        _remote.watchOne(ownerId, medicationId).map((m) => m?.toEntity()),
        message: 'Could not load this medication.',
      );

  @override
  String newId(String ownerId) => _remote.newId(ownerId);

  @override
  Future<void> save(Medication medication) {
    assert(!medication.isNew, 'Medication id must be set before saving');
    return guardFirebaseWrite(
      () => _remote.save(MedicationModel.fromEntity(medication)),
      label: 'Save medication',
      message: 'Could not save medication. Please try again.',
    );
  }

  @override
  Future<void> delete(String ownerId, String medicationId) => guardFirebaseWrite(
        () => _remote.delete(ownerId, medicationId),
        label: 'Delete medication',
        message: 'Could not delete medication. Please try again.',
      );

  @override
  Future<void> deleteAllForPet({required String ownerId, required String petId}) =>
      guardFirebaseWrite(
        () => _remote.deleteAllForPet(ownerId, petId),
        label: 'Delete medications',
        message: 'Could not delete this pet’s medications. Please try again.',
      );
}
