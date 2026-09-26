// Pure-Dart stream helpers (no Flutter / Riverpod) usable from the domain layer.
import 'dart:async';

/// Emits [combiner] of the latest values once every source has emitted,
/// then again whenever any source emits. Errors are forwarded.
Stream<R> combineLatest<R>(List<Stream<Object?>> sources, R Function(List<Object?> values) combiner) {
  late StreamController<R> controller;
  final subs = <StreamSubscription<Object?>>[];

  controller = StreamController<R>(
    onListen: () {
      final values = List<Object?>.filled(sources.length, null);
      final ready = List<bool>.filled(sources.length, false);
      var done = 0;
      for (var i = 0; i < sources.length; i++) {
        subs.add(sources[i].listen(
          (value) {
            values[i] = value;
            ready[i] = true;
            if (ready.every((r) => r)) controller.add(combiner(List.unmodifiable(values)));
          },
          onError: controller.addError,
          onDone: () {
            if (++done == sources.length) controller.close();
          },
        ));
      }
    },
    onPause: () {
      for (final s in subs) {
        s.pause();
      }
    },
    onResume: () {
      for (final s in subs) {
        s.resume();
      }
    },
    onCancel: () => Future.wait(subs.map((s) => s.cancel())),
  );
  return controller.stream;
}
