import 'dart:typed_data';

import '../entities/medical_document.dart';

/// Downloads document files for in-app viewing, caching them on the device
/// so documents opened once stay viewable offline.
/// Implementations throw `Failure` with a user-presentable message.
abstract interface class DocumentFileRepository {
  Future<Uint8List> load(MedicalDocument document);

  /// Removes a cached copy (e.g. after the document is deleted).
  Future<void> evict(MedicalDocument document);
}
