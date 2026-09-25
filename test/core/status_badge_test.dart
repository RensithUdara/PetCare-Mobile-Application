import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/theme/app_colors.dart';
import 'package:petcare/core/theme/app_theme.dart';
import 'package:petcare/core/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge renders label in the tone color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: StatusBadge(label: 'Overdue', tone: StatusTone.danger),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Overdue'));
    expect(text.style?.color, StatusColors.light.danger);
  });
}
