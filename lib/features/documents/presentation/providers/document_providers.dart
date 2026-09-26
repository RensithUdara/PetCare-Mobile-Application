import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../data/datasources/document_remote_data_source.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/entities/medical_document.dart';
import '../../domain/repositories/document_repository.dart';
import '../../domain/usecases/add_document.dart';
import '../../domain/usecases/document_queries.dart';
import '../../domain/usecases/update_document_details.dart';
import '../services/document_picker.dart';

// ── Data ────────────────────────────────────────────────────────────────
final documentRemoteDataSourceProvider = Provider<DocumentRemoteDataSource>(
  (ref) => FirebaseDocumentRemoteDataSource(FirebaseFirestore.instance, FirebaseStorage.instance),
);

final documentRepositoryProvider = Provider<DocumentRepository>(
  (ref) => DocumentRepositoryImpl(ref.watch(documentRemoteDataSourceProvider)),
);

final documentPickerProvider = Provider<DocumentPicker>(
  (ref) => DeviceDocumentPicker(ref.watch(imagePickerProvider)),
);

// ── Use cases ───────────────────────────────────────────────────────────
final watchPetDocumentsProvider =
    Provider((ref) => WatchPetDocuments(ref.watch(documentRepositoryProvider)));
final watchVaccinationDocumentsProvider =
    Provider((ref) => WatchVaccinationDocuments(ref.watch(documentRepositoryProvider)));
final watchDocumentProvider =
    Provider((ref) => WatchDocument(ref.watch(documentRepositoryProvider)));
final addDocumentProvider = Provider((ref) => AddDocument(ref.watch(documentRepositoryProvider)));
final updateDocumentDetailsProvider =
    Provider((ref) => UpdateDocumentDetails(ref.watch(documentRepositoryProvider)));
final deleteDocumentProvider =
    Provider((ref) => DeleteDocument(ref.watch(documentRepositoryProvider)));

// ── State ───────────────────────────────────────────────────────────────
final petDocumentsProvider = StreamProvider.family<List<MedicalDocument>, String>((ref, petId) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(watchPetDocumentsProvider)(ownerId: uid, petId: petId);
});

final vaccinationDocumentsProvider =
    StreamProvider.family<List<MedicalDocument>, String>((ref, vaccinationId) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(watchVaccinationDocumentsProvider)(ownerId: uid, vaccinationId: vaccinationId);
});

final documentProvider = StreamProvider.family<MedicalDocument?, String>((ref, id) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(watchDocumentProvider)(ownerId: uid, documentId: id);
});
