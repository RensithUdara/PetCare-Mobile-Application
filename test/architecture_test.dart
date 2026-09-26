import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the Clean Architecture dependency rule:
///
///   presentation ──▶ domain ◀── data
///
/// * domain: pure Dart — no Flutter, Firebase, other SDKs, or outer layers
/// * data: may not depend on presentation
void main() {
  final featureFiles = Directory('lib/features')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart') && !f.path.endsWith('.freezed.dart'))
      .toList();

  String norm(String path) => path.replaceAll(r'\', '/');
  final importPattern = RegExp(r'''^import\s+['"]([^'"]+)['"]''', multiLine: true);
  List<String> importsOf(File f) =>
      importPattern.allMatches(f.readAsStringSync()).map((m) => m.group(1)!).toList();

  List<String> violations(String layer, bool Function(String import) forbidden) => [
        for (final file in featureFiles.where((f) => norm(f.path).contains('/$layer/')))
          for (final import in importsOf(file))
            if (forbidden(import)) '${norm(file.path)} → $import',
      ];

  test('domain layer is pure Dart', () {
    const allowedPackages = {'freezed_annotation', 'meta', 'collection'};
    // The only parts of core that are framework-free.
    const allowedCore = [
      'core/domain/',
      'core/errors/failure.dart',
      'core/utils/date_utils.dart',
      'core/utils/stream_utils.dart',
    ];
    final bad = violations('domain', (import) {
      if (import.startsWith('dart:')) return false;
      if (import.startsWith('package:') && !import.startsWith('package:petcare/')) {
        final pkg = import.substring('package:'.length).split('/').first;
        return !allowedPackages.contains(pkg);
      }
      if (import.contains('core/')) return !allowedCore.any(import.contains);
      return import.contains('/data/') || import.contains('/presentation/');
    });
    expect(bad, isEmpty, reason: 'Domain must not depend on frameworks or outer layers');
  });

  test('data layer does not depend on presentation', () {
    final bad = violations('data', (import) => import.contains('/presentation/'));
    expect(bad, isEmpty);
  });

  test('features never import another feature’s data layer', () {
    final bad = <String>[];
    for (final file in featureFiles) {
      final path = norm(file.path);
      final feature = path.split('lib/features/')[1].split('/').first;
      for (final import in importsOf(file)) {
        final match = RegExp(r'features/(\w+)/data/').firstMatch(import) ??
            RegExp(r'^(?:\.\./)+(\w+)/data/').firstMatch(import);
        if (match != null && match.group(1) != feature) bad.add('$path → $import');
      }
    }
    expect(bad, isEmpty, reason: 'Depend on other features through their domain layer');
  });
}
