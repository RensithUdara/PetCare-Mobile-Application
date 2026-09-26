import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/failure.dart';

/// Identifies the app to public APIs (required by OpenStreetMap services).
const appUserAgent = 'PetCare/1.0 (com.petcare.petcare)';

Dio buildDio() => Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 25),
      headers: {'User-Agent': appUserAgent},
    ));

/// Shared HTTP client for REST APIs.
final dioProvider = Provider<Dio>((ref) {
  final dio = buildDio();
  ref.onDispose(dio.close);
  return dio;
});

/// Converts Dio errors into user-presentable [Failure]s.
Failure failureFromDio(DioException e, {String fallback = 'Something went wrong. Please try again.'}) {
  final message = switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      'The server took too long to respond. Please try again.',
    DioExceptionType.connectionError => 'No internet connection. Check your network and try again.',
    DioExceptionType.badResponse when (e.response?.statusCode ?? 0) == 429 =>
      'Too many requests. Please wait a minute and try again.',
    _ => fallback,
  };
  return Failure(message, code: 'http-${e.response?.statusCode ?? e.type.name}', cause: e);
}
