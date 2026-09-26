import '../../../../core/errors/firebase_error_handler.dart';
import '../../../../core/sync/pending_write_tracker.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/entities/pet_share.dart';
import '../../domain/repositories/sharing_repository.dart';
import '../datasources/sharing_remote_data_source.dart';
import '../models/sharing_models.dart';

class SharingRepositoryImpl implements SharingRepository {
  SharingRepositoryImpl(this._remote, {PendingWriteTracker? tracker}) : _tracker = tracker;

  final SharingRemoteDataSource _remote;
  final PendingWriteTracker? _tracker;

  @override
  Future<DoctorProfile?> findDoctorByCode(String code) => guardFirebase(() async {
        final result = await _remote.findDoctorByCode(code);
        if (result.docs.isEmpty) return null;
        final d = result.docs.first;
        return DoctorProfileModel.fromDoc(d.id, d.data());
      }, message: 'Could not look up that code. Check your connection and try again.');

  @override
  Stream<List<PetShare>> watchPetShares({required String ownerId, required String petId}) =>
      guardFirebaseStream(
        _remote.watchPetShares(ownerId, petId).map(
              (s) => s.docs.map((d) => PetShareModel.fromDoc(d.data())).toList()
                ..sort((a, b) => a.doctorName.compareTo(b.doctorName)),
            ),
        message: 'Could not load vet access.',
      );

  @override
  Future<void> share(PetShare share) => guardFirebaseWrite(
        () => _remote.setShare(share.id, PetShareModel.toJson(share)),
        label: 'Share with vet',
        message: 'Could not share with this vet. Please try again.',
        tracker: _tracker,
      );

  @override
  Future<void> revoke(PetShare share) => guardFirebaseWrite(
        () => _remote.deleteShare(share.id),
        label: 'Remove vet access',
        message: 'Could not remove access. Please try again.',
        tracker: _tracker,
      );

  /// Deleting a pet revokes every vet's access to it.
  @override
  Future<void> deleteAllForPet({required String ownerId, required String petId}) => guardFirebase(() async {
        final shares = await _remote.sharesForPet(ownerId, petId);
        await Future.wait(shares.docs.map((d) => _remote.deleteShare(d.id)));
      });
}
