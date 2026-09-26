import 'dart:async';

import 'package:petcare/features/weight/domain/entities/weight_entry.dart';
import 'package:petcare/features/weight/domain/repositories/weight_repository.dart';

class FakeWeightRepository implements WeightRepository {
  FakeWeightRepository([List<WeightEntry> initial = const []]) {
    for (final e in initial) {
      _items[e.id] = e;
    }
  }

  final _items = <String, WeightEntry>{};
  final _changes = StreamController<void>.broadcast();
  var _next = 1;

  List<WeightEntry> get items => _items.values.toList();

  List<WeightEntry> _forPet(String petId) => items.where((e) => e.petId == petId).toList();

  @override
  Stream<List<WeightEntry>> watchForPet(String ownerId, String petId) async* {
    yield _forPet(petId);
    yield* _changes.stream.map((_) => _forPet(petId));
  }

  @override
  Future<List<WeightEntry>> listForPet(String ownerId, String petId) async => _forPet(petId);

  @override
  String newId(String ownerId) => 'w${_next++}';

  @override
  Future<void> save(WeightEntry entry) async {
    _items[entry.id] = entry;
    _changes.add(null);
  }

  @override
  Future<void> delete(String ownerId, String entryId) async {
    _items.remove(entryId);
    _changes.add(null);
  }

  @override
  Future<void> deleteAllForPet({required String ownerId, required String petId}) async {
    _items.removeWhere((_, e) => e.petId == petId);
    _changes.add(null);
  }
}
