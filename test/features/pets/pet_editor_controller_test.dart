import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/authentication/presentation/auth_providers.dart';
import 'package:petcare/features/pets/domain/pet.dart';
import 'package:petcare/features/pets/presentation/pet_editor_controller.dart';
import 'package:petcare/features/pets/presentation/pet_providers.dart';

import '../../helpers/fake_pet_repository.dart';

void main() {
  late FakePetRepository repo;
  late ProviderContainer container;
  final progress = <double?>[];

  const draft = Pet(ownerId: '', name: 'Bruno', species: PetSpecies.dog);
  const existing = Pet(
    id: 'p1',
    ownerId: 'u1',
    name: 'Bruno',
    species: PetSpecies.dog,
    photoUrl: 'https://photos/old.jpg',
  );

  setUp(() {
    repo = FakePetRepository([existing]);
    progress.clear();
    container = ProviderContainer(overrides: [
      petRepositoryProvider.overrideWithValue(repo),
      currentUserIdProvider.overrideWithValue('u1'),
    ]);
    container.listen(
      petEditorControllerProvider,
      (_, next) => progress.add(next.uploadProgress),
    );
  });

  tearDown(() => container.dispose());

  PetEditorController controller() => container.read(petEditorControllerProvider.notifier);

  test('new pet gets an id and the signed-in owner', () async {
    final id = await controller().save(draft);

    expect(id, 'pet1');
    final saved = repo.pets.firstWhere((p) => p.id == 'pet1');
    expect(saved.ownerId, 'u1');
    expect(saved.photoUrl, isNull);
  });

  test('new photo is uploaded before saving, with progress', () async {
    final id = await controller().save(
      draft,
      photo: PhotoReplaced(Uint8List.fromList([1, 2, 3])),
    );

    expect(repo.calls, ['upload:$id:3', 'save:$id']);
    expect(repo.pets.firstWhere((p) => p.id == id).photoUrl, startsWith('https://photos/$id/'));
    expect(progress, containsAllInOrder([0.5, 1.0]));
  });

  test('replacing a photo deletes the old file after saving', () async {
    await controller().save(existing, photo: PhotoReplaced(Uint8List(4)));

    final saved = repo.pets.firstWhere((p) => p.id == 'p1');
    expect(saved.photoUrl, isNot(existing.photoUrl));
    expect(repo.deletedPhotos, [existing.photoUrl]);
  });

  test('removing a photo clears the url and deletes the file', () async {
    await controller().save(existing, photo: const PhotoRemoved());

    expect(repo.pets.firstWhere((p) => p.id == 'p1').photoUrl, isNull);
    expect(repo.deletedPhotos, [existing.photoUrl]);
  });

  test('unchanged photo is kept and nothing is deleted', () async {
    await controller().save(existing.copyWith(name: 'Bruno II'));

    expect(repo.pets.single.name, 'Bruno II');
    expect(repo.pets.single.photoUrl, existing.photoUrl);
    expect(repo.deletedPhotos, isEmpty);
  });

  test('a failed save exposes the error and keeps the old photo', () async {
    repo.saveFailure = const Failure('Could not save pet.');

    final id = await controller().save(existing, photo: PhotoReplaced(Uint8List(1)));

    expect(id, isNull);
    expect(container.read(petEditorControllerProvider).error?.message, 'Could not save pet.');
    expect(repo.deletedPhotos, isEmpty);
  });

  test('delete removes the pet', () async {
    expect(await controller().delete('p1'), isTrue);
    expect(repo.pets, isEmpty);
  });
}
