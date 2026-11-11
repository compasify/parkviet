import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_api/pos_api.dart';

part 'errors.freezed.dart';

/// Every way a call to the server can fail, in terms a screen can explain.
@freezed
sealed class AppFailure with _$AppFailure implements Exception {
  const factory AppFailure.timeout() = TimeoutFailure;

  /// The certificate was refused: self-signed, expired or for another name.
  const factory AppFailure.tls() = TlsFailure;

  /// The platform refused plain HTTP to this address.
  const factory AppFailure.cleartext() = CleartextFailure;

  /// No answer at that address: wrong address, server off, other network.
  const factory AppFailure.unreachable() = UnreachableFailure;

  const factory AppFailure.unauthorized(String code) = UnauthorizedFailure;
  const factory AppFailure.forbidden(String code) = ForbiddenFailure;
  const factory AppFailure.notFound(String code) = NotFoundFailure;
  const factory AppFailure.rateLimited(String code) = RateLimitedFailure;

  /// A refused command, as `render_pos_conflict` and the device API send it.
  const factory AppFailure.conflict({
    required String reason,
    int? currentRevision,
    String? message,
  }) = ConflictFailure;

  const factory AppFailure.server({
    required int status,
    String? code,
    String? message,
  }) = ServerFailure;

  const factory AppFailure.unexpected(String detail) = UnexpectedFailure;
}

/// Whether the failure means the network or server is not there right now,
/// so the same request may succeed later.
bool isTransient(AppFailure failure) => switch (failure) {
      TimeoutFailure() || UnreachableFailure() => true,
      ServerFailure(:final status) => status >= 500,
      _ => false,
    };

AppFailure failureFrom(Object error) {
  if (error is AppFailure) return error;
  if (error is DioException) return _fromDio(error);
  if (error is HandshakeException || error is TlsException) {
    return const AppFailure.tls();
  }
  if (error is SocketException) return _fromSocket(error);
  return AppFailure.unexpected(error.toString());
}

AppFailure _fromDio(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const AppFailure.timeout();
    case DioExceptionType.badCertificate:
      return const AppFailure.tls();
    case DioExceptionType.badResponse:
      return _fromResponse(error.response!);
    case DioExceptionType.connectionError:
    case DioExceptionType.unknown:
    case DioExceptionType.cancel:
      final inner = error.error;
      if (inner is HandshakeException || inner is TlsException) {
        return const AppFailure.tls();
      }
      if (_mentionsCleartext('${error.message} $inner')) {
        return const AppFailure.cleartext();
      }
      if (inner is SocketException) return _fromSocket(inner);
      if (error.type == DioExceptionType.connectionError) {
        return const AppFailure.unreachable();
      }
      return AppFailure.unexpected('${error.message ?? inner}');
  }
}

AppFailure _fromSocket(SocketException error) {
  if (_mentionsCleartext(error.message)) return const AppFailure.cleartext();
  return const AppFailure.unreachable();
}

bool _mentionsCleartext(String text) {
  final lower = text.toLowerCase();
  return lower.contains('cleartext') || lower.contains('insecure http');
}

AppFailure _fromResponse(Response<dynamic> response) {
  final status = response.statusCode ?? 0;
  final error = _errorBody(response.data);
  final code = error?.code ?? 'http_$status';
  final reason = error?.details?.reason;
  return switch (status) {
    401 => AppFailure.unauthorized(code),
    403 => AppFailure.forbidden(reason ?? code),
    404 => AppFailure.notFound(code),
    409 => AppFailure.conflict(
        reason: reason ?? code,
        currentRevision: error?.details?.currentRevision,
        message: error?.message,
      ),
    429 => AppFailure.rateLimited(code),
    _ => AppFailure.server(status: status, code: error?.code, message: error?.message),
  };
}

/// The error envelope through the generated contract model, or null when
/// the body is not one (a proxy page, an empty body).
ErrorResponseError? _errorBody(Object? data) {
  if (data is! Map) return null;
  try {
    final body = standardSerializers.deserializeWith(ErrorResponse.serializer, data);
    return body?.error;
  } on Object {
    return null;
  }
}
