import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/documents/domain/entities/medical_document.dart';
import 'package:petcare/features/documents/domain/usecases/add_document.dart';
import 'package:petcare/features/documents/domain/usecases/document_queries.dart';
import 'package:petcare/features/documents/domain/usecases/update_document_details.dart';

import '../../../helpers/fake_document_repository.dart';

void main() {
  DocumentFile file({String name = 'rabies.pdf', String type = 'application/pdf', int size = 1000}) =>
      DocumentFile(bytes: Uint8List(size), fileName: name, contentType: type);

  MedicalDocument doc(String id, DateTime date, {String name = 'Doc', String? vaccinationId}) =>
      MedicalDocument(
        id: id,
        ownerId: 'u1',
        petId: 'p1',
        name: name,
        date: date,
        fileUrl: 'https://files/$id',
        storagePath: 'path/$id',
        fileName: '$id.pdf',
        contentType: 'application/pdf',
        sizeBytes: 10,
        vaccinationId: vaccinationId,
      );

  group('AddDocument', () {
    late FakeDocumentRepository repo;
    late AddDocument add;

    setUp(() {
      repo = FakeDocumentRepository();
      add = AddDocument(repo);
    });

    Future<String> addWith({String name = ' Rabies certificate ', DocumentFile? f}) => add(
          ownerId: 'u1',
          petId: 'p1',
          name: name,
          type: DocumentType.vaccinationCertificate,
          date: DateTime(2025, 10, 20, 15),
          file: f ?? file(),
          description: '  ',
          vaccinationId: 'v1',
        );

    test('uploads then saves the record with file metadata', () async {
      final id = await addWith();

      expect(repo.calls, ['upload:users/u1/pets/p1/documents/$id/rabies.pdf', 'save:$id']);
      final saved = repo.items.single;
      expect(saved.name, 'Rabies certificate');
      expect(saved.date, DateTime(2025, 10, 20));
      expect(saved.isPdf, isTrue);
      expect(saved.sizeBytes, 1000);
      expect(saved.vaccinationId, 'v1');
      expect(saved.description, isNull);
    });

    test('validates name, type and size before uploading', () async {
      await expectLater(addWith(name: ' '),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-name')));
      await expectLater(addWith(f: file(name: 'a.docx', type: 'application/msword')),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-type')));
      await expectLater(addWith(f: file(size: AddDocument.maxSizeBytes + 1)),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'too-large')));
      expect(repo.calls, isEmpty);
    });

    test('removes the uploaded file if the record cannot be saved', () async {
      repo.saveFailure = const Failure('Could not save document.');

      await expectLater(addWith(), throwsA(isA<Failure>()));
      expect(repo.files, isEmpty);
      expect(repo.calls.last, startsWith('deleteFile:'));
    });
  });

  test('UpdateDocumentDetails edits metadata only', () async {
    final original = doc('d1', DateTime(2025));
    final repo = FakeDocumentRepository([original]);

    await UpdateDocumentDetails(repo)(
      original,
      name: ' Blood panel ',
      type: DocumentType.bloodTest,
      date: DateTime(2026, 8, 12, 10),
      description: 'Normal',
    );

    final saved = repo.items.single;
    expect(saved.name, 'Blood panel');
    expect(saved.type, DocumentType.bloodTest);
    expect(saved.date, DateTime(2026, 8, 12));
    expect(saved.fileUrl, original.fileUrl);
  });

  test('queries sort newest first and filter by vaccination', () async {
    final repo = FakeDocumentRepository([
      doc('old', DateTime(2024)),
      doc('new', DateTime(2026)),
      doc('cert', DateTime(2025), vaccinationId: 'v1'),
    ]);

    final all = await WatchPetDocuments(repo)(ownerId: 'u1', petId: 'p1').first;
    expect(all.map((d) => d.id), ['new', 'cert', 'old']);

    final certs = await WatchVaccinationDocuments(repo)(ownerId: 'u1', vaccinationId: 'v1').first;
    expect(certs.map((d) => d.id), ['cert']);
  });

  test('DeleteDocument removes record and file', () async {
    final d = doc('d1', DateTime(2025));
    final repo = FakeDocumentRepository([d]);

    await DeleteDocument(repo)(d);

    expect(repo.items, isEmpty);
    expect(repo.files, isEmpty);
  });
}
