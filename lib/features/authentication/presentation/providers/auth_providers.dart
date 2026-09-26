import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/register_with_email.dart';
import '../../domain/usecases/send_password_reset_email.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/watch_auth_state.dart';

// ── Data ────────────────────────────────────────────────────────────────
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => FirebaseAuthRemoteDataSource(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    GoogleSignIn.instance,
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider)),
);

// ── Use cases ───────────────────────────────────────────────────────────
final watchAuthStateProvider =
    Provider((ref) => WatchAuthState(ref.watch(authRepositoryProvider)));
final signInWithEmailProvider =
    Provider((ref) => SignInWithEmail(ref.watch(authRepositoryProvider)));
final registerWithEmailProvider =
    Provider((ref) => RegisterWithEmail(ref.watch(authRepositoryProvider)));
final signInWithGoogleProvider =
    Provider((ref) => SignInWithGoogle(ref.watch(authRepositoryProvider)));
final sendPasswordResetEmailProvider =
    Provider((ref) => SendPasswordResetEmail(ref.watch(authRepositoryProvider)));
final signOutProvider = Provider((ref) => SignOut(ref.watch(authRepositoryProvider)));

// ── State ───────────────────────────────────────────────────────────────
final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(watchAuthStateProvider)(),
);

/// Id of the signed-in user, or `null` when signed out.
final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).value?.id,
);
