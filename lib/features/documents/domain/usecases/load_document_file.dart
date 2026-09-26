import 'dart:typed_data';

import '../../../../core/errors/failure.dart';
import '../entities/medical_document.dart';
import '../repositories/document_file_repository.dart';

/// Loads a document's bytes for in-app viewing, checking PDFs really are
/// PDFs so a damaged file shows a clear message instead of a blank view.
class LoadDocumentFile {
  const LoadDocumentFile(this._files);

  final DocumentFileRepository _files;

  static const _pdfMagic = [0x25, 0x50, 0x44, 0x46]; // "%PDF"

  Future<Uint8List> call(MedicalDocument document) async {
    final bytes = await _files.load(document);
    if (bytes.isEmpty) {
      throw const Failure('This file is empty.', code: 'empty-file');
    }
    if (document.isPdf && !_startsWith(bytes, _pdfMagic)) {
      throw const Failure('This file doesn’t look like a valid PDF.', code: 'invalid-pdf');
    }
    return bytes;
  }

  static bool _startsWith(Uint8List bytes, List<int> prefix) {
    if (bytes.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (bytes[i] != prefix[i]) return false;
    }
    return true;
  }
}
