import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/core/errors/firebase_error_handler.dart';
import 'package:petcare/core/sync/pending_write_tracker.dart';

void main() {
  late PendingWriteTracker tracker;
  final states = <SyncState>[];

  Failure toFailure(Object e) => e is Failure ? e : Failure('mapped: $e');

  setUp(() {
    tracker = PendingWriteTracker(localAckTimeout: const Duration(milliseconds: 30));
    states.clear();
    tracker.watch().listen(states.add);
  });

  test('a write confirmed quickly completes normally and is never pending', () async {
    await tracker.track(() async {}, label: 'Save pet', toFailure: toFailure);
    await pumpEventQueue();
    expect(tracker.state.isIdle, isTrue);
    expect(states.every((s) => s.pending == 0), isTrue);
  });

  test('a quick error is thrown to the caller as a Failure', () async {
    await expectLater(
      tracker.track(() async => throw StateError('boom'), label: 'Save pet', toFailure: toFailure),
      throwsA(isA<Failure>().having((f) => f.message, 'message', contains('boom'))),
    );
    expect(tracker.state.isIdle, isTrue);
  });

  test('an unconfirmed write returns early as pending, then clears when confirmed', () async {
    final server = Completer<void>();
    await tracker.track(() => server.future, label: 'Save vaccination', toFailure: toFailure);

    expect(tracker.state.pending, 1, reason: 'UI moved on while the write is pending');

    server.complete();
    await pumpEventQueue();
    expect(tracker.state.isIdle, isTrue);
  });

  test('a late failure becomes a retryable FailedWrite', () async {
    final first = Completer<void>();
    var attempts = 0;
    Future<void> write() {
      attempts++;
      return attempts == 1 ? first.future : Future.value();
    }

    await tracker.track(write, label: 'Save vaccination', toFailure: toFailure);
    first.completeError(const Failure('You don’t have permission to do that.'));
    await pumpEventQueue();

    final failed = tracker.state.failed.single;
    expect(failed.label, 'Save vaccination');
    expect(failed.message, 'You don’t have permission to do that.');
    expect(tracker.state.pending, 0);

    await tracker.retry(failed);
    await pumpEventQueue();
    expect(attempts, 2);
    expect(tracker.state.isIdle, isTrue);
  });

  test('a retry that fails again goes back on the list; dismiss removes it', () async {
    final first = Completer<void>();
    var attempts = 0;
    Future<void> write() {
      attempts++;
      return attempts == 1 ? first.future : Future.error(const Failure('still failing'));
    }

    await tracker.track(write, label: 'Delete clinic', toFailure: toFailure);
    first.completeError(const Failure('nope'));
    await pumpEventQueue();

    await tracker.retry(tracker.state.failed.single);
    expect(tracker.state.failed.single.message, 'still failing');

    tracker.dismiss(tracker.state.failed.single);
    expect(tracker.state.isIdle, isTrue);
  });

  test('known offline: writes return immediately as pending', () async {
    tracker = PendingWriteTracker(localAckTimeout: const Duration(seconds: 30))..setOffline(true);
    final sw = Stopwatch()..start();
    await tracker.track(() => Completer<void>().future, label: 'Save pet', toFailure: toFailure);
    expect(sw.elapsed, lessThan(const Duration(seconds: 1)));
    expect(tracker.state.pending, 1);
  });

  test('guardFirebaseWrite maps Firebase errors to friendly Failures', () async {
    await expectLater(
      guardFirebaseWrite(
        () async => throw FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
        label: 'Save pet',
        tracker: tracker,
      ),
      throwsA(isA<Failure>()
          .having((f) => f.code, 'code', 'permission-denied')
          .having((f) => f.message, 'message', contains('permission'))),
    );
  });
}
