import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How long the splash stays up at least, so its intro animation can play
/// even when auth resolves instantly. Override with [Duration.zero] in tests.
final splashMinDurationProvider = Provider<Duration>((_) => const Duration(milliseconds: 2600));

/// Completes once [splashMinDurationProvider] has elapsed since launch.
final splashTimerProvider = FutureProvider<void>(
  (ref) => Future<void>.delayed(ref.watch(splashMinDurationProvider)),
);
