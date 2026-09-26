import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_profile_model.dart';

/// Raw Firebase Auth / Google / Firestore calls. Throws SDK exceptions;
/// the repository translates them into domain failures.
abstract interface class AuthRemoteDataSource {
  Stream<User?> userChanges();

  User? get currentUser;

  Future<UserCredential> signInWithEmail(String email, String password);

  Future<UserCredential> createUser(String email, String password);

  /// Returns `null` if the user dismissed the account picker.
  Future<UserCredential?> signInWithGoogle();

  Future<void> updateDisplayName(User user, String name);

  Future<void> createProfile(String uid, UserProfileModel profile);

  Future<void> mergeProfile(String uid, Map<String, dynamic> fields);

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource(this._auth, this._firestore, this._googleSignIn);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInit;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  Stream<User?> userChanges() => _auth.userChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  @override
  Future<UserCredential> createUser(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  @override
  Future<UserCredential?> signInWithGoogle() async {
    _googleInit ??= _googleSignIn.initialize();
    await _googleInit;

    final GoogleSignInAccount account;
    try {
      account = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }

    return _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: account.authentication.idToken),
    );
  }

  @override
  Future<void> updateDisplayName(User user, String name) => user.updateDisplayName(name);

  @override
  Future<void> createProfile(String uid, UserProfileModel profile) =>
      _userDoc(uid).set(profile.toCreateJson());

  @override
  Future<void> mergeProfile(String uid, Map<String, dynamic> fields) =>
      _userDoc(uid).set(fields, SetOptions(merge: true));

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  @override
  Future<void> signOut() async {
    if (_googleInit != null) await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
