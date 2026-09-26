import 'dart:async';

import 'package:meta/meta.dart';

import '../errors/failure.dart';

/// A write that reached the server with an error after the UI moved on.
@immutable
class FailedWrite {
  const FailedWrite({required this.id, required this.label, required this.message, required this.retry});

  final int id;

  /// What the user was doing, e.g. "Save vaccination".
  final String label;
  final String message;
  final Future<void> Function() retry;
}

@immutable
class SyncState {
  const SyncState({this.pending = 0, this.failed = const []});

  static const idle = SyncState();

  /// Writes saved locally but not yet confirmed by the server.
  final int pending;
  final List<FailedWrite> failed;

  bool get isIdle => pending == 0 && failed.isEmpty;
}

/// Makes Firestore writes offline-friendly.
///
/// Firestore applies a write to its local cache immediately, but the
/// returned future only completes once the *server* confirms — which never
/// happens while offline. [track] therefore waits briefly ([localAckTimeout]):
///
/// * confirmed in time → done (errors are thrown as usual);
/// * not confirmed → treated as **pending** (the UI moves on; the data is
///   already in the local cache and syncs automatically);
/// * fails later → recorded as a [FailedWrite] the user can retry.
class PendingWriteTracker {
  PendingWriteTracker({this.localAckTimeout = const Duration(seconds: 2)});

  /// Shared instance used by the data layer (like `FirebaseFirestore.instance`).
  static final instance = PendingWriteTracker();

  final Duration localAckTimeout;
  final _changes = StreamController<SyncState>.broadcast();
  var _state = SyncState.idle;
  var _nextId = 0;
  var _offline = false;

  /// When the device is known to be offline, writes are treated as pending
  /// immediately instead of waiting for [localAckTimeout].
  void setOffline(bool offline) => _offline = offline;

  SyncState get state => _state;

  /// Emits the current state, then every change.
  Stream<SyncState> watch() async* {
    yield _state;
    yield* _changes.stream;
  }

  void _set(SyncState s) {
    _state = s;
    _changes.add(s);
  }

  Future<void> track(
    Future<void> Function() write, {
    required String label,
    required Failure Function(Object error) toFailure,
  }) async {
    final future = write();
    try {
      await future.timeout(_offline ? Duration.zero : localAckTimeout);
    } on TimeoutException {
      _set(SyncState(pending: _state.pending + 1, failed: _state.failed));
      unawaited(future.then(
        (_) => _set(SyncState(pending: _state.pending - 1, failed: _state.failed)),
        onError: (Object e) => _set(SyncState(
          pending: _state.pending - 1,
          failed: [
            ..._state.failed,
            FailedWrite(
              id: _nextId++,
              label: label,
              message: toFailure(e).message,
              retry: () => track(write, label: label, toFailure: toFailure),
            ),
          ],
        )),
      ));
    } catch (e) {
      throw toFailure(e);
    }
  }

  /// Retries [write]; if it fails again it goes back on the failed list.
  Future<void> retry(FailedWrite write) async {
    dismiss(write);
    try {
      await write.retry();
    } on Failure catch (e) {
      _set(SyncState(
        pending: _state.pending,
        failed: [
          ..._state.failed,
          FailedWrite(id: _nextId++, label: write.label, message: e.message, retry: write.retry),
        ],
      ));
    }
  }

  void dismiss(FailedWrite write) => _set(SyncState(
        pending: _state.pending,
        failed: [for (final f in _state.failed) if (f.id != write.id) f],
      ));
}
