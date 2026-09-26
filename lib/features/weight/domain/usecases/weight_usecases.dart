import '../../../../core/errors/failure.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../pets/domain/repositories/pet_repository.dart';
import '../entities/weight_entry.dart';
import '../logic/weight_trend.dart';
import '../repositories/weight_repository.dart';

/// A pet's weigh-ins, oldest first.
class WatchPetWeights {
  const WatchPetWeights(this._repository);

  final WeightRepository _repository;

  Stream<List<WeightEntry>> call({required String ownerId, required String petId}) =>
      _repository.watchForPet(ownerId, petId).map(sortByDate);
}

/// Keeps `Pet.weightKg` equal to the latest weigh-in (the history is the
/// source of truth; the pet field is a denormalised "current weight").
class SyncPetCurrentWeight {
  const SyncPetCurrentWeight(this._weights, this._pets);

  final WeightRepository _weights;
  final PetRepository _pets;

  Future<void> call({required String ownerId, required String petId}) async {
    final latest = summarize(sortByDate(await _weights.listForPet(ownerId, petId)))?.latest;
    if (latest == null) return; // keep whatever the pet had
    final pet = await _pets.watchPet(ownerId, petId).first;
    if (pet == null || pet.weightKg == latest.weightKg) return;
    await _pets.savePet(pet.copyWith(weightKg: latest.weightKg));
  }
}

/// Validates and records a weigh-in, then syncs the pet's current weight.
class LogWeight {
  const LogWeight(this._repository, this._sync, this._now);

  final WeightRepository _repository;
  final SyncPetCurrentWeight _sync;
  final DateTime Function() _now;

  static const maxKg = 200.0;

  Future<String> call({required String ownerId, required WeightEntry entry}) async {
    if (entry.weightKg <= 0 || entry.weightKg > maxKg) {
      throw const Failure('Enter a weight between 0 and 200 kg', code: 'invalid-weight');
    }
    if (dateOnly(entry.date).isAfter(dateOnly(_now()))) {
      throw const Failure('Date cannot be in the future', code: 'invalid-date');
    }
    final note = entry.note?.trim();
    final id = entry.isNew ? _repository.newId(ownerId) : entry.id;
    await _repository.save(entry.copyWith(
      id: id,
      ownerId: ownerId,
      date: dateOnly(entry.date),
      weightKg: (entry.weightKg * 100).round() / 100,
      note: (note == null || note.isEmpty) ? null : note,
    ));
    await _sync(ownerId: ownerId, petId: entry.petId);
    return id;
  }
}

class DeleteWeightEntry {
  const DeleteWeightEntry(this._repository, this._sync);

  final WeightRepository _repository;
  final SyncPetCurrentWeight _sync;

  Future<void> call(WeightEntry entry) async {
    await _repository.delete(entry.ownerId, entry.id);
    await _sync(ownerId: entry.ownerId, petId: entry.petId);
  }
}
