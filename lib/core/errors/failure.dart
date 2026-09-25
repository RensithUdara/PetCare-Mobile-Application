/// A user-presentable error raised by the data layer.
///
/// Repositories translate SDK exceptions (Firebase, Dio, etc.) into a
/// [Failure] so presentation code never depends on backend error types.
class Failure implements Exception {
  const Failure(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => 'Failure($code): $message';
}
