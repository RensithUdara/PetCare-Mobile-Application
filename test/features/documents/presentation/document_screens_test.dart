import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/utils/clock.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/documents/domain/entities/medical_document.dart';
import 'package:petcare/features/documents/presentation/providers/document_providers.dart';
import 'package:petcare/features/documents/presentation/screens/document_form_screen.dart';
import 'package:petcare/features/documents/presentation/screens/document_viewer_screen.dart';
import 'package:petcare/features/documents/presentation/screens/documents_screen.dart';
import 'package:petcare/features/documents/presentation/services/document_picker.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/presentation/providers/pet_providers.dart';

import '../../../helpers/fake_document_repository.dart';
import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/pump_screen.dart';

class _FakePicker implements DocumentPicker {
  DocumentSource? lastSource;

  @override
  Future<DocumentFile?> pick(DocumentSource source) async {
    lastSource = source;
    return DocumentFile(
      bytes: Uint8List(2048),
      fileName: 'blood_test-aug.pdf',
      contentType: 'application/pdf',
    );
  }
}

void main() {
  final now = DateTime(2026, 9, 26, 12);
  late _FakePicker picker;

  MedicalDocument doc(String id, String name, DocumentType type, {String ct = 'application/pdf'}) =>
      MedicalDocument(
        id: id,
        ownerId: 'u1',
        petId: 'bruno',
        name: name,
        type: type,
        date: DateTime(2026, 8, 12),
        fileUrl: 'https://files/$id',
        storagePath: 'p/$id',
        fileName: '$id.pdf',
        contentType: ct,
        sizeBytes: 2 * 1024 * 1024,
      );

  Future<void> pump(WidgetTester tester, FakeDocumentRepository repo, Widget screen) {
    picker = _FakePicker();
    return pumpScreen(tester, screen, physicalSize: const Size(1080, 4000), overrides: [
      currentUserIdProvider.overrideWithValue('u1'),
      clockProvider.overrideWithValue(() => now),
      petRepositoryProvider.overrideWithValue(FakePetRepository(const [
        Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog),
      ])),
      documentRepositoryProvider.overrideWithValue(repo),
      documentPickerProvider.overrideWithValue(picker),
    ]);
  }

  testWidgets('list filters by document type', (tester) async {
    final repo = FakeDocumentRepository([
      doc('a', 'Rabies certificate', DocumentType.vaccinationCertificate),
      doc('b', 'Blood test', DocumentType.bloodTest),
    ]);
    await pump(tester, repo, const DocumentsScreen(petId: 'bruno'));

    expect(find.text('Bruno’s Documents'), findsOneWidget);
    expect(find.text('All (2)'), findsOneWidget);
    expect(find.textContaining('PDF · 2.0 MB'), findsNWidgets(2));

    // The filter row scrolls horizontally; bring the chip on-screen first.
    final chip = find.widgetWithText(ChoiceChip, 'Blood test');
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pump();

    expect(find.text('Rabies certificate'), findsNothing);
    expect(find.widgetWithText(Card, 'Blood test'), findsOneWidget);
  });

  group('DocumentFormScreen', () {
    testWidgets('requires a file', (tester) async {
      final repo = FakeDocumentRepository();
      await pump(tester, repo, const DocumentFormScreen(petId: 'bruno'));

      await tester.enterText(find.widgetWithText(TextFormField, 'Document name *'), 'Report');
      await tester.tap(find.text('Upload Document'));
      await tester.pump();

      expect(find.text('Choose a file to upload'), findsOneWidget);
      expect(repo.items, isEmpty);
    });

    testWidgets('picks a PDF, suggests a name and uploads it', (tester) async {
      final repo = FakeDocumentRepository();
      await pump(
        tester,
        repo,
        const DocumentFormScreen(petId: 'bruno', vaccinationId: 'v1'),
      );

      await tester.tap(find.text('PDF'));
      await tester.pump();
      expect(picker.lastSource, DocumentSource.pdf);
      expect(find.widgetWithText(TextFormField, 'blood test aug'), findsOneWidget);

      await tester.tap(find.text('Blood test'));
      await tester.tap(find.text('Upload Document'));
      await tester.pumpAndSettle();

      final saved = repo.items.single;
      expect(saved.name, 'blood test aug');
      expect(saved.type, DocumentType.bloodTest);
      expect(saved.vaccinationId, 'v1');
      expect(saved.date, DateTime(2026, 9, 26));
      expect(find.text('previous page'), findsOneWidget);
    });

    testWidgets('edit mode changes details without a new file', (tester) async {
      final repo = FakeDocumentRepository([doc('a', 'Old name', DocumentType.other)]);
      await pump(tester, repo, const DocumentFormScreen(documentId: 'a'));

      expect(find.text('a.pdf'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextFormField, 'Old name'), 'Invoice Aug');
      await tester.tap(find.text('Invoice'));
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(repo.items.single.name, 'Invoice Aug');
      expect(repo.items.single.type, DocumentType.invoice);
      expect(repo.calls.where((c) => c.startsWith('upload')), isEmpty);
    });
  });

  testWidgets('viewer offers to open PDFs externally and can delete', (tester) async {
    final repo = FakeDocumentRepository([doc('a', 'Blood test', DocumentType.bloodTest)]);
    await pump(tester, repo, const DocumentViewerScreen(documentId: 'a'));

    expect(find.text('Open PDF'), findsOneWidget);
    expect(find.textContaining('Blood test · Bruno'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(repo.items, isEmpty);
    expect(repo.files, isEmpty);
  });
}
