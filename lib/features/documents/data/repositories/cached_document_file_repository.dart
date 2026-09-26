import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/medical_document.dart';
import '../../domain/repositories/document_file_repository.dart';

/// [DocumentFileRepository] backed by `flutter_cache_manager`. Files are
/// keyed by their Storage path, which is stable even if the download URL's
/// token changes.
class CachedDocumentFileRepository implements DocumentFileRepository {
  CachedDocumentFileRepository(this._cache);

  final BaseCacheManager _cache;

  @override
  Future<Uint8List> load(MedicalDocument document) async {
    try {
      final file = await _cache.getSingleFile(document.fileUrl, key: document.storagePath);
      return await file.readAsBytes();
    } on SocketException catch (e) {
      throw Failure(
        'This document hasn’t been downloaded to this device yet. '
        'Connect to the internet to open it.',
        code: 'offline-not-cached',
        cause: e,
      );
    } on HttpExceptionWithStatus catch (e) {
      throw Failure(
        e.statusCode == 403 || e.statusCode == 404
            ? 'This file is no longer available.'
            : 'Could not download the document. Please try again.',
        code: 'http-${e.statusCode}',
        cause: e,
      );
    } on FileSystemException catch (e) {
      throw Failure('Could not read the downloaded file.', code: 'file-read', cause: e);
    }
  }

  @override
  Future<void> evict(MedicalDocument document) => _cache.removeFile(document.storagePath);
}
