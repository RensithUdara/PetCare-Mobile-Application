import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/watch_user_profile.dart';

// ── Data ────────────────────────────────────────────────────────────────
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>(
  (ref) => FirebaseProfileRemoteDataSource(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
    FirebaseAuth.instance,
  ),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(
    ref.watch(profileRemoteDataSourceProvider),
    tracker: ref.watch(pendingWriteTrackerProvider),
  ),
);

// ── Use cases ───────────────────────────────────────────────────────────
final watchUserProfileProvider = Provider((ref) => WatchUserProfile(ref.watch(profileRepositoryProvider)));
final updateUserProfileProvider = Provider((ref) => UpdateUserProfile(ref.watch(profileRepositoryProvider)));
final changePasswordProvider = Provider((ref) => ChangePassword(ref.watch(authRepositoryProvider)));
final deleteAccountProvider = Provider(
  (ref) => DeleteAccount(
    auth: ref.watch(authRepositoryProvider),
    pets: ref.watch(petRepositoryProvider),
    deletePet: ref.watch(deletePetProvider),
    profiles: ref.watch(profileRepositoryProvider),
  ),
);

// ── State ───────────────────────────────────────────────────────────────
/// The signed-in owner's profile. Falls back to the login account's
/// details when there's no profile document yet (older accounts).
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(watchUserProfileProvider)(user.id).map(
        (p) =>
            p ??
            UserProfile(
              id: user.id,
              fullName: user.displayName ?? '',
              email: user.email,
              photoUrl: user.photoUrl,
            ),
      );
});

/// Whether the account can change its password in the app.
final usesPasswordProvider = Provider<bool>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(authRepositoryProvider).usesPassword;
});
