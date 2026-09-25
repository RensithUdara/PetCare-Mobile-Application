import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/errors/failure.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';
import 'auth_error_mapper.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore, this._googleSignIn);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInit;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  Stream<AppUser?> authStateChanges() => _auth.userChanges().map(_toAppUser);

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Future<void> signInWithEmail({required String email, required String password}) {
    return _guard(() => _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        ));
  }

  @override
  Future<void> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) {
    return _guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(fullName.trim());
      await _userDoc(user.uid).set({
        'fullName': fullName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<bool> signInWithGoogle() {
    return _guard(() async {
      _googleInit ??= _googleSignIn.initialize();
      await _googleInit;

      final GoogleSignInAccount account;
      try {
        account = await _googleSignIn.authenticate();
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) return false;
        throw Failure(
          'Google sign-in failed. Please try again.',
          code: e.code.name,
          cause: e,
        );
      }

      final idToken = account.authentication.idToken;
      final result = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );

      final user = result.user!;
      await _userDoc(user.uid).set({
        'fullName': user.displayName ?? account.displayName ?? '',
        'email': user.email ?? account.email,
        'photoUrl': user.photoURL,
        if (result.additionalUserInfo?.isNewUser ?? false) ...{
          'phone': null,
          'createdAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
      return true;
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));
  }

  @override
  Future<void> signOut() {
    return _guard(() async {
      if (_googleInit != null) await _googleSignIn.signOut();
      await _auth.signOut();
    });
  }

  /// Runs [action], converting Firebase errors into [Failure]s.
  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on Failure {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw Failure(authErrorMessage(e.code), code: e.code, cause: e);
    } on FirebaseException catch (e) {
      throw Failure('Something went wrong. Please try again.', code: e.code, cause: e);
    }
  }

  static AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
