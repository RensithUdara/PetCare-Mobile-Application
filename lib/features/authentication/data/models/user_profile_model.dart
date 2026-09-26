import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';

/// Shape of the `users/{uid}` profile document.
class UserProfileModel {
  const UserProfileModel({
    required this.fullName,
    required this.email,
    this.phone,
    this.photoUrl,
  });

  final String fullName;
  final String email;
  final String? phone;
  final String? photoUrl;

  /// Fields written when the profile is first created.
  Map<String, dynamic> toCreateJson() => {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

  /// Fields refreshed on every social sign-in (never overwrites phone).
  Map<String, dynamic> toSignInJson() => {
        'fullName': fullName,
        'email': email,
        'photoUrl': photoUrl,
      };
}

extension FirebaseUserMapper on User {
  AppUser toEntity() => AppUser(
        id: uid,
        email: email ?? '',
        displayName: displayName,
        photoUrl: photoURL,
      );
}
