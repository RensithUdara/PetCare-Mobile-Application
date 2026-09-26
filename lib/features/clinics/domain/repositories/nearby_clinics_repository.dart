import '../entities/clinic.dart';

/// Searches public map data for veterinary clinics.
abstract interface class NearbyClinicsRepository {
  /// Clinics within [radiusMeters] of [center] (distance not yet computed).
  Future<List<NearbyClinic>> search(GeoPoint center, {required int radiusMeters});
}

/// The device's location.
abstract interface class LocationRepository {
  /// Throws `Failure` if location is off or permission is denied.
  Future<GeoPoint> currentLocation();
}
