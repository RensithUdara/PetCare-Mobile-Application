import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/theme/app_theme.dart';
import 'package:petcare/core/utils/clock.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/documents/presentation/providers/document_providers.dart';
import 'package:petcare/features/documents/presentation/screens/document_form_screen.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/presentation/providers/pet_providers.dart';
import 'package:petcare/features/vaccinations/presentation/providers/vaccination_providers.dart';
import 'package:petcare/features/vaccinations/presentation/screens/vaccination_form_screen.dart';

import '../helpers/fake_document_repository.dart';
import '../helpers/fake_pet_repository.dart';
import '../helpers/fake_vaccination_repository.dart';

void main() {
  const dir = 'C:/Users/USER/fvm/versions/3.35.1/bin/cache/artifacts/material_fonts';
  setUpAll(() async {
    for (final w in ['Regular', 'Medium', 'Bold']) {
      final l = FontLoader('Roboto')..addFont(Future.value(ByteData.sublistView(File('$dir/Roboto-$w.ttf').readAsBytesSync())));
      await l.load();
    }
    final l = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(File('$dir/MaterialIcons-Regular.otf').readAsBytesSync())));
    await l.load();
  });

  Future<void> shot(WidgetTester tester, Widget screen, String name, double h) async {
    tester.view.physicalSize = Size(1080, h);
    tester.view.devicePixelRatio = 2.75;
    tester.view.padding = const FakeViewPadding(top: 90);
    final t = AppTheme.light;
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        currentUserIdProvider.overrideWithValue('u1'),
        clockProvider.overrideWithValue(() => DateTime(2026, 9, 26, 9)),
        petRepositoryProvider.overrideWithValue(FakePetRepository(const [
          Pet(id: 'p1', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog),
        ])),
        vaccinationRepositoryProvider.overrideWithValue(FakeVaccinationRepository()),
        documentRepositoryProvider.overrideWithValue(FakeDocumentRepository()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: t.copyWith(textTheme: t.textTheme.apply(fontFamily: 'Roboto')),
        home: screen,
      ),
    ));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('$name.png'));
  }

  testWidgets('doc', (t) => shot(t, const DocumentFormScreen(petId: 'p1'), 'doc', 3900));
  testWidgets('vax', (t) async {
    await shot(t, const VaccinationFormScreen(petId: 'p1'), 'vax', 5200);
  });
}
