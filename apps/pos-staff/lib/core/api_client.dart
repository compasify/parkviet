import 'package:dio/dio.dart';
import 'package:pos_api/pos_api.dart';
import 'package:uuid/uuid.dart';

import 'config.dart';
import 'errors.dart';

/// The secrets a request carries. Held in memory; the device token is also
/// in secure storage, the staff session token never is.
class DeviceCredentials {
  String? deviceToken;
  String? staffSessionToken;

  void clear() {
    deviceToken = null;
    staffSessionToken = null;
  }
}

const staffSessionHeader = 'X-Pos-Staff-Session';
const idempotencyHeader = 'Idempotency-Key';

/// Adds `Authorization: Device`, the staff session and, on writes, an
/// idempotency key. A header the caller set already is left alone, so a
/// command retried with its own key keeps it.
class PosHeadersInterceptor extends Interceptor {
  PosHeadersInterceptor(this.credentials, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  final DeviceCredentials credentials;
  final Uuid _uuid;

  static const _writes = {'POST', 'PUT', 'PATCH', 'DELETE'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final headers = options.headers;
    final device = credentials.deviceToken;
    if (device != null && !headers.containsKey('Authorization')) {
      headers['Authorization'] = 'Device $device';
    }
    final staff = credentials.staffSessionToken;
    if (staff != null && !headers.containsKey(staffSessionHeader)) {
      headers[staffSessionHeader] = staff;
    }
    if (_writes.contains(options.method.toUpperCase()) && !headers.containsKey(idempotencyHeader)) {
      headers[idempotencyHeader] = _uuid.v4();
    }
    handler.next(options);
  }
}

/// The generated client bound to one server, with failures turned into
/// [AppFailure].
class PosApiClient {
  PosApiClient({
    required String baseUrl,
    required this.credentials,
    HttpClientAdapter? adapter,
  }) : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
        )) {
    if (adapter != null) dio.httpClientAdapter = adapter;
    _api = PosApi(dio: dio, interceptors: [PosHeadersInterceptor(credentials)]).getDefaultApi();
  }

  final Dio dio;
  final DeviceCredentials credentials;
  late final DefaultApi _api;

  String get baseUrl => dio.options.baseUrl;

  /// Runs one generated call and returns its body.
  Future<T> call<T>(Future<Response<T>> Function(DefaultApi api) request) async {
    try {
      final response = await request(_api);
      return response.data as T;
    } on Object catch (error) {
      throw failureFrom(error);
    }
  }

  /// Rails' health check. It is not part of the POS contract, so it is the
  /// one request made without the generated client.
  Future<void> checkUp() async {
    try {
      await dio.get<void>('/up');
    } on Object catch (error) {
      throw failureFrom(error);
    }
  }
}
