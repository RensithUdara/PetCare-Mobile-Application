import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/theme/app_theme.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/clinics/domain/entities/clinic.dart';
import 'package:petcare/features/clinics/presentation/providers/clinic_providers.dart';
import 'package:petcare/features/clinics/presentation/screens/vet_form_screen.dart';
import '../helpers/fake_clinic_repositories.dart';

void main() {
  testWidgets('vet', (tester) async {
    const dir = 'C:/Users/USER/fvm/versions/3.35.1/bin/cache/artifacts/material_fonts';
    for (final w in ['Regular', 'Medium', 'Bold']) {
      final l = FontLoader('Roboto')..addFont(Future.value(ByteData.sublistView(File('$dir/Roboto-$w.ttf').readAsBytesSync())));
      await l.load();
    }
    final l = FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(File('$dir/MaterialIcons-Regular.otf').readAsBytesSync())));
    await l.load();
    tester.view.physicalSize = const Size(1080, 4300);
    tester.view.devicePixelRatio = 2.75;
    tester.view.padding = const FakeViewPadding(top: 90);
    final t = AppTheme.light;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('u1'),
        clinicRepositoryProvider.overrideWithValue(FakeClinicRepository(clinics: const [
          Clinic(id: 'c1', ownerId: 'u1', name: 'Happy Paws Veterinary'),
          Clinic(id: 'c2', ownerId: 'u1', name: 'City Pet Hospital'),
        ])),
      ],
      child: MaterialApp(debugShowCheckedModeBanner: false,
        theme: t.copyWith(textTheme: t.textTheme.apply(fontFamily: 'Roboto')), home: const VetFormScreen(clinicId: 'c1')),
    ));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextFormField, 'Dr. '), 'Dr. Nimali Perera');
    await tester.tap(find.text('Surgery'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('vet.png'));
  });
}
