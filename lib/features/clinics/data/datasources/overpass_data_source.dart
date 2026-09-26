import 'package:dio/dio.dart';

import '../../domain/entities/clinic.dart';

/// Finds `amenity=veterinary` places via the public OpenStreetMap Overpass
/// API (no key required). Throws [DioException] on network errors.
class OverpassDataSource {
  OverpassDataSource(this._dio);

  final Dio _dio;

  static const endpoint = 'https://overpass-api.de/api/interpreter';

  Future<List<NearbyClinic>> searchVeterinary(GeoPoint center, int radiusMeters) async {
    final around = '(around:$radiusMeters,${center.latitude},${center.longitude})';
    final query = '[out:json][timeout:20];'
        '(node["amenity"="veterinary"]$around;way["amenity"="veterinary"]$around;);'
        'out center 60;';
    final response = await _dio.post<Map<String, dynamic>>(
      endpoint,
      data: {'data': query},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.json,
      ),
    );
    return parseOverpassResponse(response.data ?? const {});
  }
}

/// Parses an Overpass JSON response. Unnamed places are skipped; distances
/// are left at 0 (computed by the domain).
List<NearbyClinic> parseOverpassResponse(Map<String, dynamic> json) {
  final elements = json['elements'];
  if (elements is! List) return const [];

  String? tag(Map tags, List<String> keys) {
    for (final k in keys) {
      final v = tags[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  final results = <NearbyClinic>[];
  for (final e in elements.whereType<Map>()) {
    final tags = e['tags'];
    if (tags is! Map) continue;
    final name = tag(tags, ['name', 'name:en', 'brand']);
    if (name == null) continue;

    // Nodes carry lat/lon; ways carry a computed "center".
    final center = e['center'] is Map ? e['center'] as Map : e;
    final lat = (center['lat'] as num?)?.toDouble();
    final lon = (center['lon'] as num?)?.toDouble();
    if (lat == null || lon == null) continue;

    final street = [tag(tags, ['addr:housenumber']), tag(tags, ['addr:street'])]
        .whereType<String>()
        .join(' ');
    final address = [if (street.isNotEmpty) street, tag(tags, ['addr:city'])]
        .whereType<String>()
        .join(', ');

    results.add(NearbyClinic(
      externalId: 'osm:${e['type']}/${e['id']}',
      name: name,
      location: GeoPoint(lat, lon),
      distanceMeters: 0,
      address: address.isEmpty ? null : address,
      phone: tag(tags, ['phone', 'contact:phone']),
      website: tag(tags, ['website', 'contact:website']),
      openingHours: tag(tags, ['opening_hours']),
    ));
  }
  return results;
}
