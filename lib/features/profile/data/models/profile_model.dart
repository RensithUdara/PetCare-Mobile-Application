import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';

/// Maps the `users/{uid}` document. Shares its shape with the document the
/// authentication feature creates at sign-up (`fullName`, `email`, `phone`,
/// `photoUrl`, `createdAt`) and adds `city`.
abstract final class ProfileModel {
  static UserProfile fromDoc(String uid, Map<String, dynamic> data, {String fallbackEmail = ''}) =>
      UserProfile(
        id: uid,
        fullName: (data['fullName'] as String?) ?? '',
        email: (data['email'] as String?) ?? fallbackEmail,
        phone: data['phone'] as String?,
        city: data['city'] as String?,
        photoUrl: data['photoUrl'] as String?,
        memberSince: (data['createdAt'] as Timestamp?)?.toDate(),
      );

  /// Editable fields only; `email` and `createdAt` are left untouched.
  static Map<String, dynamic> toUpdateJson(UserProfile p) => {
        'fullName': p.fullName,
        'phone': p.phone,
        'city': p.city,
        'photoUrl': p.photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
