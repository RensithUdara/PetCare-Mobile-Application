import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/widgets/app_dialogs.dart';

void main() {
  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        context = c;
        return const Scaffold();
      }),
    ));
    return context;
  }

  group('showConfirmDialog', () {
    testWidgets('resolves true on confirm', (tester) async {
      final context = await pumpHost(tester);
      final result = showConfirmDialog(context, title: 'Delete Bruno?', confirmLabel: 'Delete', destructive: true);
      await tester.pumpAndSettle();

      expect(find.text('Delete Bruno?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(await result, isTrue);
      expect(find.text('Delete Bruno?'), findsNothing);
    });

    testWidgets('resolves false on cancel or tapping outside', (tester) async {
      final context = await pumpHost(tester);
      var result = showConfirmDialog(context, title: 'Log out?');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await result, isFalse);

      result = showConfirmDialog(context, title: 'Log out?');
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(await result, isFalse);
    });
  });

  group('showSuccessDialog', () {
    testWidgets('closes itself after the countdown', (tester) async {
      final context = await pumpHost(tester);
      var closed = false;
      showSuccessDialog(context, title: 'Bruno added!', message: 'Welcome').then((_) => closed = true);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Bruno added!'), findsOneWidget);
      expect(find.text('Welcome'), findsOneWidget);
      expect(closed, isFalse);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Bruno added!'), findsNothing);
      expect(closed, isTrue);
    });

    testWidgets('Done closes it early', (tester) async {
      final context = await pumpHost(tester);
      showSuccessDialog(context, title: 'Saved');
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Done'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Saved'), findsNothing);
    });
  });
}
