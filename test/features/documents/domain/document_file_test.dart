import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file/local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/documents/data/repositories/cached_document_file_repository.dart';
import 'package:petcare/features/documents/domain/entities/medical_document.dart';
import 'package:petcare/features/documents/domain/usecases/document_queries.dart';
import 'package:petcare/features/documents/domain/usecases/load_document_file.dart';

import '../../../helpers/fake_document_file_repository.dart';
import '../../../helpers/fake_document_repository.dart';

class _MockCache extends Mock implements BaseCacheManager {}

void main() {
  MedicalDocument doc({String contentType = 'application/pdf'}) => MedicalDocument(
        id: 'd1',
        ownerId: 'u1',
        petId: 'p1',
        name: 'Blood test',
        date: DateTime(2026, 8, 12),
        fileUrl: 'https://firebasestorage.googleapis.com/v0/b/x/o/d1.pdf?alt=media&token=abc',
        storagePath: 'users/u1/pets/p1/documents/d1/blood.pdf',
        fileName: 'blood.pdf',
        contentType: contentType,
        sizeBytes: 100,
      );

  group('LoadDocumentFile', () {
    test('returns valid PDF bytes', () async {
      final files = FakeDocumentFileRepository();
      final bytes = await LoadDocumentFile(files)(doc());
      expect(utf8.decode(bytes.sublist(0, 4)), '%PDF');
    });

    test('rejects a file that is not really a PDF', () {
      final files = FakeDocumentFileRepository(bytes: Uint8List.fromList(utf8.encode('<html>')));
      expect(LoadDocumentFile(files)(doc()),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-pdf')));
    });

    test('rejects empty files; images skip the PDF check', () async {
      expect(LoadDocumentFile(FakeDocumentFileRepository(bytes: Uint8List(0)))(doc()),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'empty-file')));

      final jpeg = FakeDocumentFileRepository(bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF]));
      expect(await LoadDocumentFile(jpeg)(doc(contentType: 'image/jpeg')), hasLength(3));
    });
  });

  test('DeleteDocument drops the cached copy', () async {
    final d = doc();
    final files = FakeDocumentFileRepository();
    await DeleteDocument(FakeDocumentRepository([d]), files)(d);
    expect(files.evicted, ['d1']);
  });

  group('CachedDocumentFileRepository', () {
    late _MockCache cache;
    late CachedDocumentFileRepository repo;
    late Directory tmp;

    setUp(() async {
      cache = _MockCache();
      repo = CachedDocumentFileRepository(cache);
      tmp = await Directory.systemTemp.createTemp('petcare_pdf');
    });

    tearDown(() => tmp.delete(recursive: true));

    test('keys the cache by storage path (stable across token changes)', () async {
      final file = const LocalFileSystem().file('${tmp.path}/blood.pdf')
        ..writeAsBytesSync(utf8.encode('%PDF-1.7'));
      when(() => cache.getSingleFile(any(), key: any(named: 'key'))).thenAnswer((_) async => file);

      final bytes = await repo.load(doc());

      expect(utf8.decode(bytes), '%PDF-1.7');
      verify(() => cache.getSingleFile(doc().fileUrl, key: doc().storagePath)).called(1);
    });

    test('offline without a cached copy gives a clear message', () {
      when(() => cache.getSingleFile(any(), key: any(named: 'key')))
          .thenThrow(const SocketException('Failed host lookup'));
      expect(repo.load(doc()),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'offline-not-cached')));
    });

    test('missing file on the server', () {
      when(() => cache.getSingleFile(any(), key: any(named: 'key')))
          .thenThrow(HttpExceptionWithStatus(404, 'Not found'));
      expect(repo.load(doc()),
          throwsA(isA<Failure>().having((f) => f.message, 'message', contains('no longer available'))));
    });

    test('evict removes the cached file', () async {
      when(() => cache.removeFile(any())).thenAnswer((_) async {});
      await repo.evict(doc());
      verify(() => cache.removeFile(doc().storagePath)).called(1);
    });
  });
}
