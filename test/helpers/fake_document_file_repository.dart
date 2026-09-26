import 'dart:convert';
import 'dart:typed_data';

import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/documents/domain/entities/medical_document.dart';
import 'package:petcare/features/documents/domain/repositories/document_file_repository.dart';

/// Serves a minimal PDF (or a configured failure) without any network.
class FakeDocumentFileRepository implements DocumentFileRepository {
  FakeDocumentFileRepository({Uint8List? bytes, this.failure})
      : bytes = bytes ?? Uint8List.fromList(utf8.encode('%PDF-1.4\n%fake\n'));

  Uint8List bytes;
  Failure? failure;
  final loads = <String>[];
  final evicted = <String>[];

  @override
  Future<Uint8List> load(MedicalDocument document) async {
    loads.add(document.id);
    if (failure != null) throw failure!;
    return bytes;
  }

  @override
  Future<void> evict(MedicalDocument document) async => evicted.add(document.id);
}
