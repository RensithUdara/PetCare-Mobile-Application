import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../data/datasources/document_remote_data_source.dart';
import '../../data/repositories/cached_document_file_repository.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/entities/medical_document.dart';
import '../../domain/repositories/document_file_repository.dart';
import '../../domain/repositories/document_repository.dart';
import '../../domain/usecases/add_document.dart';
import '../../domain/usecases/document_queries.dart';
import '../../domain/usecases/load_document_file.dart';
import '../../domain/usecases/update_document_details.dart';
import '../services/document_picker.dart';
import '../widgets/pdf_document_view.dart';

// ── Data ────────────────────────────────────────────────────────────────
final documentRemoteDataSourceProvider = Provider<DocumentRemoteDataSource>(
  (ref) => FirebaseDocumentRemoteDataSource(FirebaseFirestore.instance, FirebaseStorage.instance),
);

final documentRepositoryProvider = Provider<DocumentRepository>(
  (ref) => DocumentRepositoryImpl(ref.watch(documentRemoteDataSourceProvider)),
);

final documentFileRepositoryProvider = Provider<DocumentFileRepository>(
  (ref) => CachedDocumentFileRepository(DefaultCacheManager()),
);

/// Builds the PDF renderer. Overridden in widget tests (pdfx needs native code).
final pdfViewBuilderProvider = Provider<Widget Function(Uint8List bytes)>(
  (ref) => (bytes) => PdfDocumentView(bytes: bytes),
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
final deleteDocumentProvider = Provider(
  (ref) => DeleteDocument(ref.watch(documentRepositoryProvider), ref.watch(documentFileRepositoryProvider)),
);
final loadDocumentFileProvider =
    Provider((ref) => LoadDocumentFile(ref.watch(documentFileRepositoryProvider)));

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

/// A document's file contents for in-app viewing (cached on the device).
final documentBytesProvider = FutureProvider.autoDispose.family<Uint8List, MedicalDocument>(
  (ref, document) => ref.watch(loadDocumentFileProvider)(document),
);
