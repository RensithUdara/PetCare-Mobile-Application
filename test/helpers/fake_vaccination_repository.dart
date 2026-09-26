import 'dart:async';

import 'package:petcare/features/vaccinations/domain/entities/vaccination.dart';
import 'package:petcare/features/vaccinations/domain/repositories/vaccination_repository.dart';

/// In-memory [VaccinationRepository] for tests.
class FakeVaccinationRepository implements VaccinationRepository {
  FakeVaccinationRepository([List<Vaccination> initial = const []]) {
    for (final v in initial) {
      _items[v.id] = v;
    }
  }

  final _items = <String, Vaccination>{};
  final _changes = StreamController<void>.broadcast();
  var _nextId = 1;
  final calls = <String>[];

  List<Vaccination> get items => _items.values.toList();

  List<Vaccination> _forPet(String petId) =>
      _items.values.where((v) => v.petId == petId).toList();

  @override
  Stream<List<Vaccination>> watchForPet(String ownerId, String petId) async* {
    yield _forPet(petId);
    yield* _changes.stream.map((_) => _forPet(petId));
  }

  @override
  Stream<List<Vaccination>> watchAll(String ownerId) async* {
    yield items;
    yield* _changes.stream.map((_) => items);
  }

  @override
  Stream<Vaccination?> watchOne(String ownerId, String vaccinationId) async* {
    yield _items[vaccinationId];
    yield* _changes.stream.map((_) => _items[vaccinationId]);
  }

  @override
  String newId(String ownerId) => 'vac${_nextId++}';

  @override
  Future<void> save(Vaccination vaccination) async {
    calls.add('save:${vaccination.id}');
    _items[vaccination.id] = vaccination;
    _changes.add(null);
  }

  @override
  Future<void> delete(String ownerId, String vaccinationId) async {
    calls.add('delete:$vaccinationId');
    _items.remove(vaccinationId);
    _changes.add(null);
  }

  @override
  Future<void> deleteAllForPet({required String ownerId, required String petId}) async {
    calls.add('deleteAllForPet:$petId');
    _items.removeWhere((_, v) => v.petId == petId);
    _changes.add(null);
  }
}
