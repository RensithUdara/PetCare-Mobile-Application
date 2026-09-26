import 'dart:async';

import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/documents/domain/entities/medical_document.dart';
import 'package:petcare/features/documents/domain/repositories/document_repository.dart';

/// In-memory [DocumentRepository] with a fake file store.
class FakeDocumentRepository implements DocumentRepository {
  FakeDocumentRepository([List<MedicalDocument> initial = const []]) {
    for (final d in initial) {
      _items[d.id] = d;
      files.add(d.storagePath);
    }
  }

  final _items = <String, MedicalDocument>{};
  final _changes = StreamController<void>.broadcast();
  var _nextId = 1;

  /// Storage paths currently "uploaded".
  final files = <String>{};
  final calls = <String>[];
  Failure? saveFailure;

  List<MedicalDocument> get items => _items.values.toList();

  Stream<List<MedicalDocument>> _watch(bool Function(MedicalDocument) test) async* {
    yield items.where(test).toList();
    yield* _changes.stream.map((_) => items.where(test).toList());
  }

  @override
  Stream<List<MedicalDocument>> watchForPet(String ownerId, String petId) =>
      _watch((d) => d.petId == petId);

  @override
  Stream<List<MedicalDocument>> watchForVaccination(String ownerId, String vaccinationId) =>
      _watch((d) => d.vaccinationId == vaccinationId);

  @override
  Stream<MedicalDocument?> watchOne(String ownerId, String documentId) async* {
    yield _items[documentId];
    yield* _changes.stream.map((_) => _items[documentId]);
  }

  @override
  String newId(String ownerId) => 'doc${_nextId++}';

  @override
  Future<UploadedFile> uploadFile({
    required String ownerId,
    required String petId,
    required String documentId,
    required DocumentFile file,
    void Function(double progress)? onProgress,
  }) async {
    final path = 'users/$ownerId/pets/$petId/documents/$documentId/${file.fileName}';
    calls.add('upload:$path');
    onProgress?.call(1);
    files.add(path);
    return UploadedFile(url: 'https://files/$path', storagePath: path);
  }

  @override
  Future<void> deleteFile(String storagePath) async {
    calls.add('deleteFile:$storagePath');
    files.remove(storagePath);
  }

  @override
  Future<void> save(MedicalDocument document) async {
    calls.add('save:${document.id}');
    if (saveFailure != null) throw saveFailure!;
    _items[document.id] = document;
    _changes.add(null);
  }

  @override
  Future<void> delete(MedicalDocument document) async {
    calls.add('delete:${document.id}');
    _items.remove(document.id);
    files.remove(document.storagePath);
    _changes.add(null);
  }

  @override
  Future<void> deleteAllForPet({required String ownerId, required String petId}) async {
    for (final d in items.where((d) => d.petId == petId)) {
      _items.remove(d.id);
      files.remove(d.storagePath);
    }
    _changes.add(null);
  }
}
