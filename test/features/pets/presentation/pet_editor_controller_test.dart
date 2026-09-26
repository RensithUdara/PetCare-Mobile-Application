import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/appointments/presentation/providers/appointment_providers.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/documents/presentation/providers/document_providers.dart';
import 'package:petcare/features/medications/presentation/providers/medication_providers.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/domain/entities/photo_change.dart';
import 'package:petcare/features/pets/presentation/controllers/pet_editor_controller.dart';
import 'package:petcare/features/pets/presentation/providers/pet_providers.dart';
import 'package:petcare/features/vaccinations/presentation/providers/vaccination_providers.dart';

import '../../../helpers/fake_appointment_repository.dart';
import '../../../helpers/fake_document_repository.dart';
import '../../../helpers/fake_medication_repository.dart';
import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/fake_vaccination_repository.dart';

/// Business rules are covered by the use case tests; this checks the
/// controller's UI state (busy / progress / error).
void main() {
  late FakePetRepository repo;
  late ProviderContainer container;
  final states = <PetEditorState>[];

  const existing = Pet(id: 'p1', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog);

  ProviderContainer build({String? uid = 'u1'}) {
    final c = ProviderContainer(overrides: [
      petRepositoryProvider.overrideWithValue(repo),
      vaccinationRepositoryProvider.overrideWithValue(FakeVaccinationRepository()),
      appointmentRepositoryProvider.overrideWithValue(FakeAppointmentRepository()),
      medicationRepositoryProvider.overrideWithValue(FakeMedicationRepository()),
      documentRepositoryProvider.overrideWithValue(FakeDocumentRepository()),
      currentUserIdProvider.overrideWithValue(uid),
    ]);
    c.listen(petEditorControllerProvider, (_, next) => states.add(next));
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    repo = FakePetRepository([existing]);
    states.clear();
    container = build();
  });

  PetEditorController controller() => container.read(petEditorControllerProvider.notifier);

  test('save reports upload progress, then returns to idle', () async {
    final id = await controller().save(existing, photo: PhotoReplaced(Uint8List(2)));

    expect(id, 'p1');
    expect(states.map((s) => s.uploadProgress), containsAllInOrder([0.5, 1.0]));
    expect(states.last.isBusy, isFalse);
    expect(states.last.error, isNull);
  });

  test('save failure is exposed as error state', () async {
    repo.saveFailure = const Failure('Could not save pet.');

    expect(await controller().save(existing), isNull);
    expect(container.read(petEditorControllerProvider).error?.message, 'Could not save pet.');
  });

  test('signed-out user gets a friendly error', () async {
    container = build(uid: null);

    expect(await controller().save(existing), isNull);
    expect(container.read(petEditorControllerProvider).error?.message, contains('signed out'));
  });

  test('delete goes through the DeletePet use case', () async {
    expect(await controller().delete('p1'), isTrue);
    expect(repo.pets, isEmpty);
  });
}
