import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/datasources/clinic_remote_data_source.dart';
import '../../data/datasources/overpass_data_source.dart';
import '../../data/repositories/clinic_repositories_impl.dart';
import '../../domain/entities/clinic.dart';
import '../../domain/repositories/clinic_repository.dart';
import '../../domain/repositories/nearby_clinics_repository.dart';
import '../../domain/usecases/clinic_usecases.dart';
import '../../domain/usecases/nearby_usecases.dart';

// ── Data ────────────────────────────────────────────────────────────────
final clinicRepositoryProvider = Provider<ClinicRepository>(
  (ref) => ClinicRepositoryImpl(ClinicRemoteDataSource(FirebaseFirestore.instance)),
);

final nearbyClinicsRepositoryProvider = Provider<NearbyClinicsRepository>(
  (ref) => NearbyClinicsRepositoryImpl(OverpassDataSource(ref.watch(dioProvider))),
);

final locationRepositoryProvider =
    Provider<LocationRepository>((ref) => GeolocatorLocationRepository());

/// OpenStreetMap raster tiles; `null` hides tiles (used by widget tests).
final mapTileUrlProvider =
    Provider<String?>((ref) => 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');

// ── Use cases ───────────────────────────────────────────────────────────
final watchClinicsProvider = Provider((ref) => WatchClinics(ref.watch(clinicRepositoryProvider)));
final watchClinicProvider = Provider((ref) => WatchClinic(ref.watch(clinicRepositoryProvider)));
final saveClinicProvider = Provider((ref) => SaveClinic(ref.watch(clinicRepositoryProvider)));
final toggleFavoriteClinicProvider =
    Provider((ref) => ToggleFavoriteClinic(ref.watch(clinicRepositoryProvider)));
final deleteClinicProvider = Provider((ref) => DeleteClinic(ref.watch(clinicRepositoryProvider)));
final watchVetsProvider = Provider((ref) => WatchVets(ref.watch(clinicRepositoryProvider)));
final saveVetProvider = Provider((ref) => SaveVet(ref.watch(clinicRepositoryProvider)));
final deleteVetProvider = Provider((ref) => DeleteVet(ref.watch(clinicRepositoryProvider)));
final getCurrentLocationProvider =
    Provider((ref) => GetCurrentLocation(ref.watch(locationRepositoryProvider)));
final searchNearbyClinicsProvider =
    Provider((ref) => SearchNearbyClinics(ref.watch(nearbyClinicsRepositoryProvider)));

// ── State ───────────────────────────────────────────────────────────────
final clinicsProvider = StreamProvider<List<Clinic>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(watchClinicsProvider)(uid);
});

final clinicProvider = StreamProvider.family<Clinic?, String>((ref, id) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(watchClinicProvider)(ownerId: uid, clinicId: id);
});

/// Saved clinic names, for autocomplete in record forms.
final clinicNameSuggestionsProvider = Provider<List<String>>(
  (ref) => [for (final c in ref.watch(clinicsProvider).value ?? const <Clinic>[]) c.name],
);

/// Saved veterinarian names, for autocomplete in record forms.
final vetNameSuggestionsProvider = Provider<List<String>>(
  (ref) => [for (final v in ref.watch(vetsProvider).value ?? const <Veterinarian>[]) v.name],
);

final vetsProvider = StreamProvider<List<Veterinarian>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(watchVetsProvider)(uid);
});
