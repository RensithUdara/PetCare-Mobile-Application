import 'dart:math' as math;

import '../entities/clinic.dart';

const _earthRadiusMeters = 6371000.0;

/// Great-circle distance in meters (haversine formula).
double distanceMeters(GeoPoint a, GeoPoint b) {
  double rad(double deg) => deg * math.pi / 180;
  final dLat = rad(b.latitude - a.latitude);
  final dLon = rad(b.longitude - a.longitude);
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.latitude)) * math.cos(rad(b.latitude)) * math.pow(math.sin(dLon / 2), 2);
  return 2 * _earthRadiusMeters * math.asin(math.sqrt(h));
}

/// "850 m", "2.4 km", "12 km".
String formatDistance(double meters) {
  if (meters < 1000) return '${(meters / 10).round() * 10} m';
  final km = meters / 1000;
  return km < 10 ? '${km.toStringAsFixed(1)} km' : '${km.round()} km';
}

/// Adds `https://` when the user typed a bare domain; `null` for blanks.
String? normalizeWebsite(String? input) {
  final t = input?.trim();
  if (t == null || t.isEmpty) return null;
  return RegExp(r'^https?://', caseSensitive: false).hasMatch(t) ? t : 'https://$t';
}
