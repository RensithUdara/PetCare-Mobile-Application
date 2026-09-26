import '../../../pets/domain/repositories/pet_records_cleaner.dart';
import '../entities/weight_entry.dart';

/// Persistence for weigh-ins. Also a [PetRecordsCleaner].
/// Implementations throw `Failure` with a user-presentable message.
abstract interface class WeightRepository implements PetRecordsCleaner {
  Stream<List<WeightEntry>> watchForPet(String ownerId, String petId);

  Future<List<WeightEntry>> listForPet(String ownerId, String petId);

  String newId(String ownerId);

  Future<void> save(WeightEntry entry);

  Future<void> delete(String ownerId, String entryId);
}
