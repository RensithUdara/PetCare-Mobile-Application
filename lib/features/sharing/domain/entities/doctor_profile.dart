import 'package:meta/meta.dart';

/// An approved veterinarian's public profile (from the web doctor portal).
@immutable
class DoctorProfile {
  const DoctorProfile({
    required this.id,
    required this.fullName,
    required this.doctorCode,
    this.clinicName,
    this.specialization,
    this.city,
    this.phone,
    this.photoUrl,
  });

  final String id;
  final String fullName;
  final String doctorCode;
  final String? clinicName;
  final String? specialization;
  final String? city;
  final String? phone;
  final String? photoUrl;

  @override
  bool operator ==(Object other) => other is DoctorProfile && other.id == id && other.doctorCode == doctorCode;

  @override
  int get hashCode => Object.hash(id, doctorCode);
}
