import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/stream_utils.dart';
import '../../domain/repositories/pending_documents_repository.dart';

/// Uses Firestore's `hasPendingWrites` metadata. The listeners share the
/// local cache with the app's other queries, so they add no network cost.
class FirestorePendingDocumentsRepository implements PendingDocumentsRepository {
  FirestorePendingDocumentsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Per-user collections whose records show a "pending" badge.
  static const collections = [
    'pets',
    'vaccinations',
    'appointments',
    'medications',
    'documents',
    'weights',
    'clinics',
    'veterinarians',
  ];

  @override
  Stream<Set<String>> watchPendingIds(String ownerId) => combineLatest(
        [
          for (final c in collections)
            _firestore
                .collection('users')
                .doc(ownerId)
                .collection(c)
                .snapshots(includeMetadataChanges: true)
                .map((s) => {
                      for (final d in s.docs)
                        if (d.metadata.hasPendingWrites) d.id,
                    }),
        ],
        (sets) => {for (final s in sets) ...s! as Set<String>},
      );
}
