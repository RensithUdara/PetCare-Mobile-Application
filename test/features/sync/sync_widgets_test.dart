import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/sync/pending_write_tracker.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/documents/domain/entities/medical_document.dart';
import 'package:petcare/features/documents/presentation/controllers/document_editor_controller.dart';
import 'package:petcare/features/documents/presentation/providers/document_providers.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/domain/entities/photo_change.dart';
import 'package:petcare/features/pets/presentation/controllers/pet_editor_controller.dart';
import 'package:petcare/features/pets/presentation/providers/pet_providers.dart';
import 'package:petcare/features/sync/presentation/providers/sync_providers.dart';
import 'package:petcare/features/sync/presentation/widgets/sync_widgets.dart';

import '../../helpers/fake_document_repository.dart';
import '../../helpers/fake_pet_repository.dart';

void main() {
  Future<void> pumpBanner(WidgetTester tester, {bool online = true, SyncState sync = SyncState.idle}) =>
      tester.pumpWidget(ProviderScope(
        overrides: [
          isOnlineProvider.overrideWith((ref) => Stream.value(online)),
          syncStateProvider.overrideWith((ref) => Stream.value(sync)),
        ],
        child: const MaterialApp(home: Scaffold(body: SyncStatusBanner())),
      )).then((_) => tester.pumpAndSettle()); // let AnimatedSize finish

  group('SyncStatusBanner', () {
    testWidgets('hidden when online and idle', (tester) async {
      await pumpBanner(tester);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('offline', (tester) async {
      await pumpBanner(tester, online: false);
      expect(find.text('You’re offline · Saved data is still available'), findsOneWidget);
    });

    testWidgets('offline with pending changes', (tester) async {
      await pumpBanner(tester, online: false, sync: const SyncState(pending: 2));
      expect(find.textContaining('2 changes will sync'), findsOneWidget);
    });

    testWidgets('syncing', (tester) async {
      await pumpBanner(tester, sync: const SyncState(pending: 1));
      expect(find.text('Syncing 1 change…'), findsOneWidget);
    });

    testWidgets('failed writes open a sheet with retry and dismiss', (tester) async {
      final tracker = PendingWriteTracker();
      var retried = 0;
      final failed = FailedWrite(
        id: 1,
        label: 'Save vaccination',
        message: 'You don’t have permission to do that.',
        retry: () async => retried++,
      );
      await pumpBanner(tester, sync: SyncState(failed: [failed]));

      expect(find.text('1 change couldn’t be saved · Tap to review'), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.text('Save vaccination'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
      expect(tracker.state.isIdle, isTrue, reason: 'separate tracker untouched');
    });
  });

  testWidgets('PendingSyncBadge shows only for pending records', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [pendingDocumentIdsProvider.overrideWith((ref) => Stream.value({'p1'}))],
      child: const MaterialApp(
        home: Scaffold(body: Column(children: [PendingSyncBadge(id: 'p1'), PendingSyncBadge(id: 'p2')])),
      ),
    ));
    await tester.pump();
    expect(find.text('Pending sync'), findsOneWidget);
  });

  group('offline upload guards', () {
    List<Override> offline() => [
          isOnlineProvider.overrideWith((ref) => Stream.value(false)),
          currentUserIdProvider.overrideWithValue('u1'),
        ];

    test('pet photo upload is refused offline; saving without a photo works', () async {
      final pets = FakePetRepository();
      final c = ProviderContainer(overrides: [...offline(), petRepositoryProvider.overrideWithValue(pets)]);
      addTearDown(c.dispose);
      c.listen(isOnlineProvider, (_, _) {});
      c.listen(petEditorControllerProvider, (_, _) {});
      await pumpEventQueue();

      const pet = Pet(ownerId: '', name: 'Bruno', species: PetSpecies.dog);
      final ctrl = c.read(petEditorControllerProvider.notifier);
      expect(await ctrl.save(pet, photo: PhotoReplaced(Uint8List(4))), isNull);
      expect(c.read(petEditorControllerProvider).error?.code, 'offline');
      expect(pets.pets, isEmpty);

      expect(await ctrl.save(pet), isNotNull, reason: 'Firestore writes work offline');
    });

    test('document upload is refused offline', () async {
      final docs = FakeDocumentRepository();
      final c = ProviderContainer(overrides: [...offline(), documentRepositoryProvider.overrideWithValue(docs)]);
      addTearDown(c.dispose);
      c.listen(isOnlineProvider, (_, _) {});
      c.listen(documentEditorControllerProvider, (_, _) {});
      await pumpEventQueue();

      final id = await c.read(documentEditorControllerProvider.notifier).add(
            petId: 'p1',
            name: 'X-ray',
            type: DocumentType.xRay,
            date: DateTime(2026),
            file: DocumentFile(bytes: Uint8List(4), fileName: 'x.jpg', contentType: 'image/jpeg'),
          );
      expect(id, isNull);
      expect(c.read(documentEditorControllerProvider).error?.code, 'offline');
      expect(docs.calls, isEmpty);
    });
  });
}
