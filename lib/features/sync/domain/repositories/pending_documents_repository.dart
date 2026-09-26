/// Which of the user's records have local changes not yet on the server.
abstract interface class PendingDocumentsRepository {
  Stream<Set<String>> watchPendingIds(String ownerId);
}
