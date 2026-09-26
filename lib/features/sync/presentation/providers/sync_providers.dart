import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_repository_impl.dart';
import '../../../../core/sync/pending_write_tracker.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/repositories/firestore_pending_documents_repository.dart';
import '../../domain/repositories/pending_documents_repository.dart';

export '../../../../core/network/connectivity_repository_impl.dart' show isOnlineProvider;

final pendingWriteTrackerProvider = Provider<PendingWriteTracker>((ref) => PendingWriteTracker.instance);

/// Pending / failed writes (see [PendingWriteTracker]).
final syncStateProvider = StreamProvider<SyncState>(
  (ref) => ref.watch(pendingWriteTrackerProvider).watch(),
);

final pendingDocumentsRepositoryProvider = Provider<PendingDocumentsRepository>(
  (ref) => FirestorePendingDocumentsRepository(FirebaseFirestore.instance),
);

/// Ids of records with local changes not yet on the server.
final pendingDocumentIdsProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const {});
  return ref.watch(pendingDocumentsRepositoryProvider).watchPendingIds(uid);
});

/// Whether record [id] has unsynced local changes.
final isPendingSyncProvider = Provider.family<bool, String>(
  (ref, id) => ref.watch(pendingDocumentIdsProvider).value?.contains(id) ?? false,
);

/// Whether the sync banner is showing (offline, syncing, or failures).
final syncBannerVisibleProvider = Provider<bool>((ref) {
  final sync = ref.watch(syncStateProvider).value;
  return ref.watch(isOfflineProvider) || (sync != null && !sync.isIdle);
});

/// `true` only when we know the device is offline.
final isOfflineProvider = Provider<bool>((ref) => ref.watch(isOnlineProvider).value == false);
