import 'package:firebase_core/firebase_core.dart';

import 'failure.dart';

/// Runs [action], converting Firebase errors into [Failure]s.
///
/// Used by repository implementations so that data sources can throw raw
/// SDK exceptions while the domain only ever sees [Failure].
Future<T> guardFirebase<T>(
  Future<T> Function() action, {
  String message = 'Something went wrong. Please try again.',
}) async {
  try {
    return await action();
  } on Failure {
    rethrow;
  } on FirebaseException catch (e) {
    throw Failure(firebaseErrorMessage(e.code, fallback: message), code: e.code, cause: e);
  }
}

/// Wraps a stream so Firebase errors surface as [Failure]s.
Stream<T> guardFirebaseStream<T>(
  Stream<T> stream, {
  String message = 'Could not load data. Please try again.',
}) {
  return stream.handleError(
    (Object e, StackTrace st) => throw e is FirebaseException
        ? Failure(firebaseErrorMessage(e.code, fallback: message), code: e.code, cause: e)
        : e,
  );
}

String firebaseErrorMessage(String code, {required String fallback}) => switch (code) {
      'permission-denied' || 'unauthorized' => 'You don’t have permission to do that.',
      'unavailable' => 'No internet connection. Check your network and try again.',
      _ => fallback,
    };
