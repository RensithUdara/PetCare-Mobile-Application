import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/documents/data/models/document_model.dart';
import 'package:petcare/features/documents/data/repositories/document_repository_impl.dart';
import 'package:petcare/features/documents/domain/entities/medical_document.dart';
import 'package:petcare/features/documents/presentation/services/document_picker.dart';

void main() {
  final xray = MedicalDocument(
    id: 'd1',
    ownerId: 'u1',
    petId: 'p1',
    name: 'Chest X-ray',
    type: DocumentType.xRay,
    date: DateTime(2026, 9, 5),
    fileUrl: 'https://files/x.jpg',
    storagePath: 'users/u1/pets/p1/documents/d1/x.jpg',
    fileName: 'x.jpg',
    contentType: 'image/jpeg',
    sizeBytes: 845000,
    description: 'Front view',
  );

  test('DocumentModel round-trips', () {
    final json = DocumentModel.fromEntity(xray).toJson();
    expect(json.containsKey('id'), isFalse);
    expect(json['type'], 'xRay');
    expect(DocumentModel.fromJson({...json, 'id': 'd1'}).toEntity(), xray);
  });

  test('unknown type falls back to other', () {
    final json = {...DocumentModel.fromEntity(xray).toJson(), 'id': 'd1', 'type': 'ultrasound'};
    expect(DocumentModel.fromJson(json).toEntity().type, DocumentType.other);
  });

  test('safeFileName strips path and unsafe characters', () {
    expect(DocumentRepositoryImpl.safeFileName('blood test (Aug).pdf'), 'blood_test_Aug_.pdf');
    expect(DocumentRepositoryImpl.safeFileName('../../evil.pdf'), '.._.._evil.pdf');
    expect(DocumentRepositoryImpl.safeFileName('???'), '_');
  });

  test('picker infers content types from extensions', () {
    expect(DeviceDocumentPicker.contentTypeFor('scan.PDF'), 'application/pdf');
    expect(DeviceDocumentPicker.contentTypeFor('a.png'), 'image/png');
    expect(DeviceDocumentPicker.contentTypeFor('IMG_1.HEIC'), 'image/heic');
    expect(DeviceDocumentPicker.contentTypeFor('photo.jpg'), 'image/jpeg');
  });
}
