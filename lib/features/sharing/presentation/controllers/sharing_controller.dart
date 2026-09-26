import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/entities/pet_share.dart';
import '../providers/sharing_providers.dart';

@immutable
class SharingState {
  const SharingState({this.isBusy = false, this.doctor, this.error});

  final bool isBusy;

  /// The vet found by the last code lookup, awaiting confirmation.
  final DoctorProfile? doctor;
  final Failure? error;
}

/// UI state for looking up a vet by code and granting / revoking access.
class SharingController extends Notifier<SharingState> {
  static const _offline = Failure('You’re offline. Connect to the internet to change vet access.', code: 'offline');

  @override
  SharingState build() => const SharingState();

  Future<T?> _run<T>(Future<T> Function() action, {DoctorProfile? keepDoctor}) async {
    if (state.isBusy) return null;
    if (ref.read(isOfflineProvider)) {
      state = SharingState(doctor: keepDoctor, error: _offline);
      return null;
    }
    state = SharingState(isBusy: true, doctor: keepDoctor);
    try {
      return await action();
    } catch (e) {
      final failure = e is Failure ? e : Failure('Something went wrong. Please try again.', cause: e);
      if (ref.mounted) state = SharingState(doctor: keepDoctor, error: failure);
      return null;
    }
  }

  Future<void> lookUp(String code) async {
    final doctor = await _run(() => ref.read(findDoctorByCodeProvider)(code));
    if (doctor != null && ref.mounted) state = SharingState(doctor: doctor);
  }

  void clear() => state = const SharingState();

  /// Grants [doctor] access to [pet]. Returns `true` on success.
  Future<bool> share(Pet pet, DoctorProfile doctor) async {
    final ok = await _run(() async {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) throw const Failure('You are signed out. Please sign in again.');
      // Shown to the vet; wait briefly in case the profile hasn't loaded yet.
      final owner = await ref
          .read(userProfileProvider.future)
          .timeout(const Duration(seconds: 3), onTimeout: () => null)
          .catchError((_) => null);
      await ref.read(sharePetWithDoctorProvider)(PetShare(
        ownerId: uid,
        petId: pet.id,
        doctorId: doctor.id,
        petName: pet.name,
        petSpecies: pet.species.name,
        petPhotoUrl: pet.photoUrl,
        ownerName: owner?.fullName,
        ownerEmail: owner?.email,
        ownerPhone: owner?.phone,
        doctorName: doctor.fullName,
        clinicName: doctor.clinicName,
        doctorCode: doctor.doctorCode,
      ));
      return true;
    }, keepDoctor: doctor);
    if (ok == true && ref.mounted) state = const SharingState();
    return ok == true;
  }

  Future<bool> revoke(PetShare share) async {
    final ok = await _run(() async {
      await ref.read(revokeShareProvider)(share);
      return true;
    });
    if (ok == true && ref.mounted) state = const SharingState();
    return ok == true;
  }
}

final sharingControllerProvider =
    NotifierProvider.autoDispose<SharingController, SharingState>(SharingController.new);
