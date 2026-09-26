import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Pumps [screen] at `/screen` on top of a `/` page ("previous page") so
/// `context.pop()` can be asserted. Any other location pushed by the screen
/// renders as `Text('route: <location>')`.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: '/screen',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('previous page')),
        routes: [GoRoute(path: 'screen', builder: (_, _) => screen)],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(body: Text('route: ${state.uri}')),
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  ));
  await tester.pump();
  await tester.pump();
}
