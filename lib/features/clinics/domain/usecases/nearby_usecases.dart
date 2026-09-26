import '../entities/clinic.dart';
import '../logic/geo.dart';
import '../repositories/nearby_clinics_repository.dart';

class GetCurrentLocation {
  const GetCurrentLocation(this._location);

  final LocationRepository _location;

  Future<GeoPoint> call() => _location.currentLocation();
}

/// Veterinary clinics near [center], closest first, with distances.
class SearchNearbyClinics {
  const SearchNearbyClinics(this._nearby);

  final NearbyClinicsRepository _nearby;

  static const defaultRadiusMeters = 5000;
  static const maxResults = 30;

  Future<List<NearbyClinic>> call(GeoPoint center, {int radiusMeters = defaultRadiusMeters}) async {
    final found = await _nearby.search(center, radiusMeters: radiusMeters);
    final withDistance = [
      for (final c in found)
        NearbyClinic(
          externalId: c.externalId,
          name: c.name,
          location: c.location,
          distanceMeters: distanceMeters(center, c.location),
          address: c.address,
          phone: c.phone,
          website: normalizeWebsite(c.website),
          openingHours: c.openingHours,
        ),
    ]..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return withDistance.take(maxResults).toList();
  }
}
