import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/medical_document.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../providers/document_providers.dart';

@immutable
class DocumentEditorState {
  const DocumentEditorState({this.isBusy = false, this.uploadProgress, this.error});

  final bool isBusy;

  /// 0–1 while uploading, otherwise `null`.
  final double? uploadProgress;
  final Failure? error;
}

/// UI state for adding, editing and deleting documents.
class DocumentEditorController extends Notifier<DocumentEditorState> {
  @override
  DocumentEditorState build() => const DocumentEditorState();

  /// Returns the new document id, or `null` on failure.
  Future<String?> add({
    required String petId,
    required String name,
    required DocumentType type,
    required DateTime date,
    required DocumentFile file,
    String? description,
    String? vaccinationId,
  }) =>
      _run(() {
        // Storage uploads need a connection (unlike Firestore writes).
        if (ref.read(isOfflineProvider)) {
          throw const Failure(
            'You’re offline. Uploading photos and documents needs an internet connection — '
            'try again when you’re back online.',
            code: 'offline',
          );
        }
        return ref.read(addDocumentProvider)(
            ownerId: _uid(),
            petId: petId,
            name: name,
            type: type,
            date: date,
            file: file,
            description: description,
            vaccinationId: vaccinationId,
            onProgress: (p) {
              if (ref.mounted) state = DocumentEditorState(isBusy: true, uploadProgress: p);
            },
          );
      });

  Future<bool> update(
    MedicalDocument document, {
    required String name,
    required DocumentType type,
    required DateTime date,
    String? description,
  }) async =>
      await _run(() async {
        await ref.read(updateDocumentDetailsProvider)(
          document,
          name: name,
          type: type,
          date: date,
          description: description,
        );
        return document.id;
      }) !=
      null;

  Future<bool> delete(MedicalDocument document) async =>
      await _run(() async {
        await ref.read(deleteDocumentProvider)(document);
        return document.id;
      }) !=
      null;

  String _uid() {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) throw const Failure('You are signed out. Please sign in again.');
    return uid;
  }

  Future<String?> _run(Future<String> Function() action) async {
    if (state.isBusy) return null;
    state = const DocumentEditorState(isBusy: true);
    try {
      final id = await action();
      if (ref.mounted) state = const DocumentEditorState();
      return id;
    } catch (e) {
      final failure =
          e is Failure ? e : Failure('Something went wrong. Please try again.', cause: e);
      if (ref.mounted) state = DocumentEditorState(error: failure);
      return null;
    }
  }
}

final documentEditorControllerProvider =
    NotifierProvider.autoDispose<DocumentEditorController, DocumentEditorState>(
  DocumentEditorController.new,
);
