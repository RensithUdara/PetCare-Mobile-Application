import 'package:cloud_firestore/cloud_firestore.dart';

import '../errors/failure.dart';

/// Converts a Firestore document into plain JSON for `Model.fromJson`,
/// replacing [Timestamp]s (including nested ones) with [DateTime]s and
/// injecting the document id as `id`.
Map<String, dynamic> firestoreDocToJson(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data(serverTimestampBehavior: ServerTimestampBehavior.estimate) ?? {};
  return {..._convert(data) as Map<String, dynamic>, 'id': doc.id};
}

Object? _convert(Object? value) => switch (value) {
      Timestamp t => t.toDate(),
      Map<String, dynamic> m => {for (final e in m.entries) e.key: _convert(e.value)},
      List l => l.map(_convert).toList(),
      _ => value,
    };

/// Runs [action], converting Firebase errors into [Failure]s.
Future<T> guardFirebase<T>(
  Future<T> Function() action, {
  String message = 'Something went wrong. Please try again.',
}) async {
  try {
    return await action();
  } on Failure {
    rethrow;
  } on FirebaseException catch (e) {
    final friendly = switch (e.code) {
      'permission-denied' || 'unauthorized' => 'You don’t have permission to do that.',
      'unavailable' => 'No internet connection. Check your network and try again.',
      _ => message,
    };
    throw Failure(friendly, code: e.code, cause: e);
  }
}
