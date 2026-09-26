import 'dart:async';

import 'package:petcare/features/appointments/domain/entities/appointment.dart';
import 'package:petcare/features/appointments/domain/repositories/appointment_repository.dart';

/// In-memory [AppointmentRepository] for tests.
class FakeAppointmentRepository implements AppointmentRepository {
  FakeAppointmentRepository([List<Appointment> initial = const []]) {
    for (final a in initial) {
      _items[a.id] = a;
    }
  }

  final _items = <String, Appointment>{};
  final _changes = StreamController<void>.broadcast();
  var _nextId = 1;
  final calls = <String>[];

  List<Appointment> get items => _items.values.toList();

  List<Appointment> _forPet(String petId) =>
      _items.values.where((a) => a.petId == petId).toList();

  @override
  Stream<List<Appointment>> watchForPet(String ownerId, String petId) async* {
    yield _forPet(petId);
    yield* _changes.stream.map((_) => _forPet(petId));
  }

  @override
  Stream<List<Appointment>> watchAll(String ownerId) async* {
    yield items;
    yield* _changes.stream.map((_) => items);
  }

  @override
  Stream<Appointment?> watchOne(String ownerId, String appointmentId) async* {
    yield _items[appointmentId];
    yield* _changes.stream.map((_) => _items[appointmentId]);
  }

  @override
  String newId(String ownerId) => 'apt${_nextId++}';

  @override
  Future<void> save(Appointment appointment) async {
    calls.add('save:${appointment.id}');
    _items[appointment.id] = appointment;
    _changes.add(null);
  }

  @override
  Future<void> delete(String ownerId, String appointmentId) async {
    calls.add('delete:$appointmentId');
    _items.remove(appointmentId);
    _changes.add(null);
  }

  @override
  Future<void> deleteAllForPet({required String ownerId, required String petId}) async {
    calls.add('deleteAllForPet:$petId');
    _items.removeWhere((_, a) => a.petId == petId);
    _changes.add(null);
  }
}
