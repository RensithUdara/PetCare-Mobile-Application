import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/medical_document.dart';

enum DocumentSource { camera, gallery, pdf }

/// Lets the user choose a file to attach. Abstracted so widget tests can
/// supply files without platform channels.
abstract interface class DocumentPicker {
  /// Returns `null` if the user cancelled.
  Future<DocumentFile?> pick(DocumentSource source);
}

class DeviceDocumentPicker implements DocumentPicker {
  DeviceDocumentPicker(this._images);

  final ImagePicker _images;

  static String contentTypeFor(String fileName) =>
      switch (fileName.split('.').last.toLowerCase()) {
        'pdf' => 'application/pdf',
        'png' => 'image/png',
        'heic' || 'heif' => 'image/heic',
        _ => 'image/jpeg',
      };

  @override
  Future<DocumentFile?> pick(DocumentSource source) async {
    switch (source) {
      case DocumentSource.camera:
      case DocumentSource.gallery:
        // Documents need legible text: larger than pet photos, still compressed.
        final image = await _images.pickImage(
          source: source == DocumentSource.camera ? ImageSource.camera : ImageSource.gallery,
          maxWidth: 2400,
          maxHeight: 2400,
          imageQuality: 85,
        );
        if (image == null) return null;
        return DocumentFile(
          bytes: await image.readAsBytes(),
          fileName: image.name,
          contentType: contentTypeFor(image.name),
        );
      case DocumentSource.pdf:
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: const ['pdf'],
          withData: true,
        );
        final file = result?.files.singleOrNull;
        if (file == null || file.bytes == null) return null;
        return DocumentFile(
          bytes: file.bytes!,
          fileName: file.name,
          contentType: 'application/pdf',
        );
    }
  }
}
