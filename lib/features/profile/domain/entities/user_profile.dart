import 'package:meta/meta.dart';

/// The owner's personal details (`users/{uid}` document).
@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.city,
    this.photoUrl,
    this.memberSince,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? city;
  final String? photoUrl;
  final DateTime? memberSince;

  /// Up to two initials for avatar placeholders.
  String get initials => fullName
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p[0].toUpperCase())
      .join();

  UserProfile copyWith({
    String? fullName,
    String? Function()? phone,
    String? Function()? city,
    String? Function()? photoUrl,
  }) =>
      UserProfile(
        id: id,
        fullName: fullName ?? this.fullName,
        email: email,
        phone: phone == null ? this.phone : phone(),
        city: city == null ? this.city : city(),
        photoUrl: photoUrl == null ? this.photoUrl : photoUrl(),
        memberSince: memberSince,
      );

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.id == id &&
      other.fullName == fullName &&
      other.email == email &&
      other.phone == phone &&
      other.city == city &&
      other.photoUrl == photoUrl &&
      other.memberSince == memberSince;

  @override
  int get hashCode => Object.hash(id, fullName, email, phone, city, photoUrl, memberSince);
}
