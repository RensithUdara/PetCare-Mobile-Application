import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/connectivity.dart';

/// Network presence via `connectivity_plus`. "Online" means a network
/// interface is up; it doesn't guarantee the internet is reachable, which
/// is why writes are also tracked by `PendingWriteTracker`.
class ConnectivityRepositoryImpl implements ConnectivityRepository {
  ConnectivityRepositoryImpl(this._connectivity);

  final Connectivity _connectivity;

  static bool _online(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  Future<bool> isOnline() async => _online(await _connectivity.checkConnectivity());

  @override
  Stream<bool> watchOnline() async* {
    yield await isOnline();
    yield* _connectivity.onConnectivityChanged.map(_online).distinct();
  }
}

final connectivityRepositoryProvider =
    Provider<ConnectivityRepository>((ref) => ConnectivityRepositoryImpl(Connectivity()));

/// `true` while the device has a network connection (optimistic default).
final isOnlineProvider = StreamProvider<bool>(
  (ref) => ref.watch(connectivityRepositoryProvider).watchOnline(),
);
