import 'dart:async';

import 'package:petcare/features/medications/domain/entities/medication.dart';
import 'package:petcare/features/medications/domain/repositories/medication_repository.dart';

/// In-memory [MedicationRepository] for tests.
class FakeMedicationRepository implements MedicationRepository {
  FakeMedicationRepository([List<Medication> initial = const []]) {
    for (final m in initial) {
      _items[m.id] = m;
    }
  }

  final _items = <String, Medication>{};
  final _changes = StreamController<void>.broadcast();
  var _nextId = 1;
  final calls = <String>[];

  List<Medication> get items => _items.values.toList();

  List<Medication> _forPet(String petId) =>
      _items.values.where((m) => m.petId == petId).toList();

  @override
  Stream<List<Medication>> watchForPet(String ownerId, String petId) async* {
    yield _forPet(petId);
    yield* _changes.stream.map((_) => _forPet(petId));
  }

  @override
  Stream<List<Medication>> watchAll(String ownerId) async* {
    yield items;
    yield* _changes.stream.map((_) => items);
  }

  @override
  Stream<Medication?> watchOne(String ownerId, String medicationId) async* {
    yield _items[medicationId];
    yield* _changes.stream.map((_) => _items[medicationId]);
  }

  @override
  String newId(String ownerId) => 'med${_nextId++}';

  @override
  Future<void> save(Medication medication) async {
    calls.add('save:${medication.id}');
    _items[medication.id] = medication;
    _changes.add(null);
  }

  @override
  Future<void> delete(String ownerId, String medicationId) async {
    calls.add('delete:$medicationId');
    _items.remove(medicationId);
    _changes.add(null);
  }

  @override
  Future<void> deleteAllForPet({required String ownerId, required String petId}) async {
    calls.add('deleteAllForPet:$petId');
    _items.removeWhere((_, m) => m.petId == petId);
    _changes.add(null);
  }
}
