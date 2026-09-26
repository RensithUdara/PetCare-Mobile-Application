import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('goes full screen while shown and restores system bars after', (tester) async {
    final modes = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemChrome.setEnabledSystemUIMode') modes.add(call.arguments as String);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.text('Healthy pets, happy homes'), findsOneWidget);
    expect(find.bySemanticsLabel('PetCare'), findsOneWidget);
    expect(modes.last, 'SystemUiMode.immersiveSticky');

    await tester.pumpWidget(const SizedBox());
    expect(modes.last, 'SystemUiMode.edgeToEdge');
  });
}
