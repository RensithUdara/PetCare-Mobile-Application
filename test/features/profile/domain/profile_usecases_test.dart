import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/domain/entities/photo_change.dart';
import 'package:petcare/features/pets/domain/usecases/delete_pet.dart';
import 'package:petcare/features/profile/domain/entities/user_profile.dart';
import 'package:petcare/features/profile/domain/usecases/change_password.dart';
import 'package:petcare/features/profile/domain/usecases/delete_account.dart';
import 'package:petcare/features/profile/domain/usecases/update_user_profile.dart';

import '../../../helpers/fake_auth_repository.dart';
import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/fake_profile_repository.dart';

void main() {
  const kasun = UserProfile(
    id: 'u1',
    fullName: 'Kasun Silva',
    email: 'k@pets.lk',
    photoUrl: 'https://photos/old.jpg',
  );

  group('UpdateUserProfile', () {
    test('trims fields, stores blanks as null and keeps the photo', () async {
      final repo = FakeProfileRepository(kasun);
      await UpdateUserProfile(repo)(kasun.copyWith(
        fullName: '  Kasun Perera ',
        phone: () => ' 0771234567 ',
        city: () => '   ',
      ));

      expect(repo.profile!.fullName, 'Kasun Perera');
      expect(repo.profile!.phone, '0771234567');
      expect(repo.profile!.city, isNull);
      expect(repo.profile!.photoUrl, 'https://photos/old.jpg');
      expect(repo.calls, ['save:Kasun Perera']);
    });

    test('uploads a new photo, then deletes the old one', () async {
      final repo = FakeProfileRepository(kasun);
      await UpdateUserProfile(repo)(kasun, photo: PhotoReplaced(Uint8List(3)));

      expect(repo.profile!.photoUrl, 'https://photos/new.jpg');
      expect(repo.calls, ['upload:3', 'save:Kasun Silva', 'deletePhoto:https://photos/old.jpg']);
    });

    test('removing the photo clears it and deletes the file', () async {
      final repo = FakeProfileRepository(kasun);
      await UpdateUserProfile(repo)(kasun, photo: const PhotoRemoved());

      expect(repo.profile!.photoUrl, isNull);
      expect(repo.calls.last, 'deletePhoto:https://photos/old.jpg');
    });

    test('rejects an empty name without saving', () async {
      final repo = FakeProfileRepository(kasun);
      await expectLater(
        UpdateUserProfile(repo)(kasun.copyWith(fullName: ' ')),
        throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-name')),
      );
      expect(repo.calls, isEmpty);
    });
  });

  test('ChangePassword rejects reusing the current password', () async {
    final auth = FakeAuthRepository();
    await expectLater(
      ChangePassword(auth)(currentPassword: 'abc12345', newPassword: 'abc12345'),
      throwsA(isA<Failure>()),
    );
    await ChangePassword(auth)(currentPassword: 'abc12345', newPassword: 'new12345');
    expect(auth.calls, ['changePassword:abc12345:new12345']);
  });

  group('DeleteAccount', () {
    late FakeAuthRepository auth;
    late FakePetRepository pets;
    late FakeProfileRepository profiles;
    late DeleteAccount deleteAccount;

    setUp(() {
      auth = FakeAuthRepository();
      pets = FakePetRepository(const [
        Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog),
        Pet(id: 'milo', ownerId: 'u1', name: 'Milo', species: PetSpecies.cat),
      ]);
      profiles = FakeProfileRepository(kasun);
      deleteAccount = DeleteAccount(auth: auth, pets: pets, deletePet: DeletePet(pets), profiles: profiles);
    });

    test('confirms identity, deletes pets and data, then the login', () async {
      await deleteAccount(uid: 'u1', password: 'secret1');

      expect(auth.calls, ['reauth:secret1', 'deleteUser']);
      expect(pets.calls, ['delete:bruno', 'delete:milo']);
      expect(profiles.calls, ['deleteUserData:u1']);
    });

    test('deletes nothing when the password is wrong', () async {
      auth.nextFailure = const Failure('Incorrect email or password.');

      await expectLater(deleteAccount(uid: 'u1', password: 'nope'), throwsA(isA<Failure>()));
      expect(pets.calls, isEmpty);
      expect(profiles.calls, isEmpty);
      expect(auth.calls, ['reauth:nope']);
    });
  });
}
