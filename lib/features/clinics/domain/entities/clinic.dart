import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart' as meta;

part 'clinic.freezed.dart';

/// A geographic coordinate (framework-free).
@meta.immutable
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is GeoPoint && other.latitude == latitude && other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => '($latitude, $longitude)';
}

/// A veterinary clinic saved by the user.
@freezed
abstract class Clinic with _$Clinic {
  const Clinic._();

  const factory Clinic({
    @Default('') String id,
    required String ownerId,
    required String name,
    String? address,
    String? phone,
    String? email,

    /// Always stored with a scheme, e.g. `https://happypaws.lk`.
    String? website,

    /// Free text, e.g. "Mon–Fri 8:00–18:00, Sat 9:00–13:00".
    String? openingHours,
    GeoPoint? location,
    String? notes,
    @Default(false) bool isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Clinic;

  bool get isNew => id.isEmpty;
}

/// A veterinarian, optionally working at one of the user's clinics.
@freezed
abstract class Veterinarian with _$Veterinarian {
  const Veterinarian._();

  const factory Veterinarian({
    @Default('') String id,
    required String ownerId,
    required String name,
    String? clinicId,
    String? specialization,
    String? phone,
    String? email,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Veterinarian;

  bool get isNew => id.isEmpty;
}

/// A clinic found near the user (from OpenStreetMap), not yet saved.
@meta.immutable
class NearbyClinic {
  const NearbyClinic({
    required this.externalId,
    required this.name,
    required this.location,
    required this.distanceMeters,
    this.address,
    this.phone,
    this.website,
    this.openingHours,
  });

  /// e.g. `osm:node/123`.
  final String externalId;
  final String name;
  final GeoPoint location;
  final double distanceMeters;
  final String? address;
  final String? phone;
  final String? website;
  final String? openingHours;

  Clinic toClinic(String ownerId) => Clinic(
        ownerId: ownerId,
        name: name,
        address: address,
        phone: phone,
        website: website,
        openingHours: openingHours,
        location: location,
      );
}
