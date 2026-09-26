import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/theme/app_theme.dart';
import 'package:petcare/features/splash/presentation/screens/splash_screen.dart';

Future<void> _font(String family, String path) async {
  final l = FontLoader(family)..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await l.load();
}

void main() {
  testWidgets('splash', (tester) async {
    const dir = 'C:/Users/USER/fvm/versions/3.35.1/bin/cache/artifacts/material_fonts';
    await _font('Roboto', '$dir/Roboto-Medium.ttf');
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(theme: AppTheme.light.copyWith(textTheme: AppTheme.light.textTheme.apply(fontFamily: 'Roboto')), home: const SplashScreen()));
      final ctx = tester.element(find.byType(Image));
      await precacheImage(const AssetImage('assets/images/app_logo.png'), ctx);
    });
    await tester.pump(const Duration(milliseconds: 1500));
    await expectLater(find.byType(SplashScreen), matchesGoldenFile('splash.png'));
    await tester.pumpWidget(const SizedBox());
  });
}
