/// Whether the device has a network connection.
abstract interface class ConnectivityRepository {
  Stream<bool> watchOnline();

  Future<bool> isOnline();
}
