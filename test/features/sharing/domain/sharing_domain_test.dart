import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/sharing/domain/entities/doctor_profile.dart';
import 'package:petcare/features/sharing/domain/entities/pet_share.dart';
import 'package:petcare/features/sharing/domain/logic/doctor_code.dart';
import 'package:petcare/features/sharing/domain/usecases/find_doctor_by_code.dart';
import 'package:petcare/features/sharing/domain/usecases/share_pet_with_doctor.dart';

import '../../../helpers/fake_sharing_repository.dart';

void main() {
  const nimali = DoctorProfile(id: 'doc1', fullName: 'Dr. Nimali Perera', doctorCode: 'DR-7K3M9Q');

  test('normalizeDoctorCode accepts sloppy input and rejects nonsense', () {
    expect(normalizeDoctorCode('DR-7K3M9Q'), 'DR-7K3M9Q');
    expect(normalizeDoctorCode(' dr-7k3m9q '), 'DR-7K3M9Q');
    expect(normalizeDoctorCode('7k3m9q'), 'DR-7K3M9Q');
    expect(normalizeDoctorCode('DR 7K3 M9Q'), 'DR-7K3M9Q');
    expect(normalizeDoctorCode('dr7k3m9q'), 'DR-7K3M9Q');
    expect(normalizeDoctorCode('DR-7K3M9'), isNull); // too short
    expect(normalizeDoctorCode('DR-7K3M0Q'), isNull); // 0 is never used
    expect(normalizeDoctorCode(''), isNull);
  });

  group('FindDoctorByCode', () {
    test('finds an approved doctor from a normalised code', () async {
      final repo = FakeSharingRepository(doctors: const [nimali]);
      expect(await FindDoctorByCode(repo)('7k3m9q'), nimali);
      expect(repo.calls, ['find:DR-7K3M9Q']);
    });

    test('explains invalid and unknown codes', () async {
      final repo = FakeSharingRepository();
      await expectLater(FindDoctorByCode(repo)('hello'),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-code')));
      await expectLater(FindDoctorByCode(repo)('DR-AAAAAA'),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'not-found')));
    });
  });

  test('SharePetWithDoctor refuses to share twice', () async {
    const share = PetShare(ownerId: 'u1', petId: 'bruno', doctorId: 'doc1', petName: 'Bruno', doctorName: 'Dr. Nimali');
    final repo = FakeSharingRepository();
    await SharePetWithDoctor(repo)(share);
    expect(share.id, 'u1_bruno_doc1');
    await expectLater(SharePetWithDoctor(repo)(share),
        throwsA(isA<Failure>().having((f) => f.code, 'code', 'already-shared')));
    expect(repo.shares, hasLength(1));
  });
}
