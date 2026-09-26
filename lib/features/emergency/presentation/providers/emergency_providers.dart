import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/repositories/emergency_profile_repository_impl.dart';
import '../../domain/entities/emergency_profile.dart';
import '../../domain/repositories/emergency_profile_repository.dart';
import '../../domain/usecases/emergency_usecases.dart';

// ── Data ────────────────────────────────────────────────────────────────
final emergencyProfileRepositoryProvider = Provider<EmergencyProfileRepository>(
  (ref) => EmergencyProfileRepositoryImpl(FirebaseFirestore.instance),
);

/// Public page base URL on Firebase Hosting (`https://<project>.web.app/p/`).
final publicProfileBaseUrlProvider = Provider<String>((ref) {
  try {
    return 'https://${Firebase.app().options.projectId}.web.app/p/';
  } catch (_) {
    return 'https://petcare.web.app/p/';
  }
});

// ── Use cases ───────────────────────────────────────────────────────────
final watchEmergencyProfileProvider =
    Provider((ref) => WatchEmergencyProfile(ref.watch(emergencyProfileRepositoryProvider)));
final watchPublicProfileProvider =
    Provider((ref) => WatchPublicProfile(ref.watch(emergencyProfileRepositoryProvider)));
final saveEmergencyProfileProvider =
    Provider((ref) => SaveEmergencyProfile(ref.watch(emergencyProfileRepositoryProvider)));
final createEmergencyProfileProvider = Provider(
  (ref) => CreateEmergencyProfile(
    ref.watch(emergencyProfileRepositoryProvider),
    ref.watch(saveEmergencyProfileProvider),
  ),
);
final refreshPublicProfileProvider =
    Provider((ref) => RefreshPublicProfile(ref.watch(emergencyProfileRepositoryProvider)));

// ── State ───────────────────────────────────────────────────────────────
/// The owner's emergency settings for a pet (`null` = not set up yet).
final emergencyProfileProvider = StreamProvider.family<EmergencyProfile?, String>((ref, petId) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(watchEmergencyProfileProvider)(ownerId: uid, petId: petId);
});

/// A public profile by its QR id — works when signed out.
final publicProfileProvider = StreamProvider.family<PublicPetProfile?, String>(
  (ref, publicId) => ref.watch(watchPublicProfileProvider)(publicId),
);
