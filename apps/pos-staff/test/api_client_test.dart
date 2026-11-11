import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/api_client.dart';
import 'package:parkviet_staff/core/errors.dart';
import 'package:pos_api/pos_api.dart';

/// Answers every request with one canned response and keeps the requests.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.status, this.body);

  final int status;
  final Object? body;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const meBody = {
  'data': {
    'device': {'id': 'posdev_1', 'name': 'Bếp', 'mode': 'print_station', 'status': 'active', 'branch_id': 'posbr_1'},
    'branch': {'id': 'posbr_1', 'name': 'CN1', 'timezone': 'Asia/Ho_Chi_Minh'},
    'register_id': null,
    'kitchen_station_id': null,
    'staff': null,
    'server_time': '2026-11-11T10:00:00+07:00',
  },
};

void main() {
  late DeviceCredentials credentials;

  setUp(() => credentials = DeviceCredentials()
    ..deviceToken = 'dev-token'
    ..staffSessionToken = 'staff-token');

  PosApiClient clientWith(FakeAdapter adapter) =>
      PosApiClient(baseUrl: 'http://pos.test', credentials: credentials, adapter: adapter);

  test('sends the device token and staff session on a read, without an idempotency key', () async {
    final adapter = FakeAdapter(200, meBody);
    final me = await clientWith(adapter).call((api) => api.posDeviceMe());

    expect(me.data.device.mode, DeviceModeEnum.printStation);
    final headers = adapter.requests.single.headers;
    expect(headers['Authorization'], 'Device dev-token');
    expect(headers[staffSessionHeader], 'staff-token');
    expect(headers.containsKey(idempotencyHeader), isFalse);
  });

  test('adds a fresh idempotency key to each write and keeps one the caller set', () async {
    final adapter = FakeAdapter(204, null);
    final client = clientWith(adapter);
    await client.call((api) => api.posDeviceStaffSignOut());
    await client.call((api) => api.posDeviceStaffSignOut());
    await client.call((api) => api.posDeviceStaffSignOut(headers: {idempotencyHeader: 'mine'}));

    final keys = adapter.requests.map((request) => request.headers[idempotencyHeader]).toList();
    expect(keys[0], isNot(keys[1]));
    expect(keys[0], matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(keys[2], 'mine');
  });

  test('leaves out the device token before pairing', () async {
    credentials.clear();
    final adapter = FakeAdapter(200, meBody);
    await clientWith(adapter).call((api) => api.posDeviceMe());
    expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse);
  });

  test('reads a 409 as render_pos_conflict sends it', () async {
    final adapter = FakeAdapter(409, {
      'error': {
        'code': 'conflict',
        'message': 'The workspace changed.',
        'details': {'reason': 'revision_mismatch', 'current_revision': 7},
      },
    });
    await expectLater(
      clientWith(adapter).call((api) => api.posDeviceMe()),
      throwsA(isA<ConflictFailure>()
          .having((failure) => failure.reason, 'reason', 'revision_mismatch')
          .having((failure) => failure.currentRevision, 'currentRevision', 7)
          .having((failure) => failure.message, 'message', 'The workspace changed.')),
    );
  });

  test('reads a 409 of the device API, which has a reason and no revision', () async {
    final adapter = FakeAdapter(409, {
      'error': {
        'code': 'conflict',
        'message': 'Stale.',
        'details': {'reason': 'print_claim_stale'},
      },
    });
    await expectLater(
      clientWith(adapter).call((api) => api.posDeviceMe()),
      throwsA(isA<ConflictFailure>()
          .having((failure) => failure.reason, 'reason', 'print_claim_stale')
          .having((failure) => failure.currentRevision, 'currentRevision', isNull)),
    );
  });

  test('falls back to the error code when a 409 has no details', () async {
    final adapter = FakeAdapter(409, {
      'error': {'code': 'printer_in_use', 'message': 'In use.'},
    });
    await expectLater(
      clientWith(adapter).call((api) => api.posDeviceMe()),
      throwsA(isA<ConflictFailure>().having((failure) => failure.reason, 'reason', 'printer_in_use')),
    );
  });

  test('maps the other refusals by status and code', () async {
    final cases = <(int, Object?, Matcher)>[
      (401, {'error': {'code': 'device_unauthorized', 'message': 'x'}}, isA<UnauthorizedFailure>()),
      (403, {'error': {'code': 'device_mode_forbidden', 'message': 'x'}},
          isA<ForbiddenFailure>().having((f) => f.code, 'code', 'device_mode_forbidden')),
      (404, {'error': {'code': 'pairing_invalid', 'message': 'x'}},
          isA<NotFoundFailure>().having((f) => f.code, 'code', 'pairing_invalid')),
      (429, {'error': {'code': 'pin_locked', 'message': 'x'}},
          isA<RateLimitedFailure>().having((f) => f.code, 'code', 'pin_locked')),
      (502, '<html>bad gateway</html>', isA<ServerFailure>().having((f) => f.status, 'status', 502)),
    ];
    for (final (status, body, matcher) in cases) {
      await expectLater(clientWith(FakeAdapter(status, body)).call((api) => api.posDeviceMe()), throwsA(matcher),
          reason: '$status');
    }
  });

  test('tells a timeout and an unreachable server apart', () {
    final options = RequestOptions(path: '/up');
    expect(failureFrom(DioException.connectionTimeout(timeout: Duration.zero, requestOptions: options)),
        isA<TimeoutFailure>());
    expect(failureFrom(DioException.connectionError(requestOptions: options, reason: 'refused')),
        isA<UnreachableFailure>());
    expect(failureFrom(DioException.badCertificate(requestOptions: options)), isA<TlsFailure>());
    expect(
      failureFrom(DioException.connectionError(
        requestOptions: options,
        reason: 'Insecure HTTP is not allowed by platform: 10.0.0.2',
      )),
      isA<CleartextFailure>(),
    );
  });
}
