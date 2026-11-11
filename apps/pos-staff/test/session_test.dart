import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/auth/staff_session.dart';
import 'package:parkviet_staff/core/api_client.dart';
import 'package:parkviet_staff/core/device_info.dart';
import 'package:parkviet_staff/core/errors.dart';
import 'package:parkviet_staff/core/secure_storage.dart';
import 'package:parkviet_staff/core/server_time.dart';
import 'package:parkviet_staff/core/session.dart';
import 'package:parkviet_staff/router.dart';
import 'package:pos_api/pos_api.dart';

Map<String, Object?> meJson(String mode) => {
      'device': {'id': 'posdev_1', 'name': 'Máy 1', 'mode': mode, 'status': 'active', 'branch_id': 'posbr_1'},
      'branch': {'id': 'posbr_1', 'name': 'CN1', 'timezone': 'Asia/Ho_Chi_Minh'},
      'register_id': null,
      'kitchen_station_id': null,
      'staff': null,
      'server_time': '2026-11-11T10:00:00+07:00',
    };

DeviceSession me(String mode) => standardSerializers.deserializeWith(DeviceSession.serializer, meJson(mode))!;

/// A server answering by method and path.
class FakeServer implements HttpClientAdapter {
  final routes = <String, (int, Object?)>{};
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final (status, body) = routes['${options.method} ${options.uri.path}'] ?? (404, null);
    return ResponseBody.fromString(body == null ? '' : jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('redirect', () {
    AsyncValue<AppSession> paired(String mode) =>
        AsyncData(AppSession.paired(serverUrl: 'http://pos.local', me: me(mode), clock: ServerClock.zero));
    final staff = StaffSession(staffId: 'u1', expiresAt: DateTime(2026, 11, 11, 18));

    String? go(AsyncValue<AppSession> session, String location,
            {StaffSession? signedIn, bool manager = false, bool checklist = false}) =>
        redirectFor(session: session, staff: signedIn, managerAccess: manager, location: location, checklist: checklist);

    test('waits on the splash while the pairing loads', () {
      expect(go(const AsyncLoading(), '/'), isNull);
      expect(go(const AsyncLoading(), '/mode/kds'), '/');
    });

    test('sends an unpaired device to the welcome screen and lets it pair', () {
      const unpaired = AsyncData<AppSession>(AppSession.unpaired());
      expect(go(unpaired, '/'), '/welcome');
      expect(go(unpaired, '/mode/kds'), '/welcome');
      expect(go(unpaired, '/pair/manual'), isNull);
      expect(go(unpaired, '/pair/scan'), isNull);
    });

    test('keeps an unreachable device on the offline screen', () {
      const offline = AsyncData<AppSession>(
        AppSession.offline(serverUrl: 'http://pos.local', failure: AppFailure.unreachable()),
      );
      expect(go(offline, '/mode/kds'), '/offline');
      expect(go(offline, '/offline'), isNull);
    });

    test('opens a device mode straight away', () {
      expect(go(paired('print_station'), '/'), '/mode/print-station');
      expect(go(paired('kds'), '/staff'), '/mode/kds');
      expect(go(paired('kds'), '/mode/kds'), isNull);
      expect(go(paired('kds'), '/mode/waiter'), '/mode/kds');
    });

    test('asks for a PIN before a staff mode and opens it after', () {
      expect(go(paired('waiter'), '/'), '/staff');
      expect(go(paired('waiter'), '/mode/waiter'), '/staff');
      expect(go(paired('waiter'), '/staff/pin/m1'), isNull);
      expect(go(paired('waiter'), '/staff', signedIn: staff), '/mode/waiter');
      expect(go(paired('owner'), '/', signedIn: staff), '/mode/owner');
    });

    test('shows a just-paired device its checklist first, then its mode', () {
      expect(go(paired('kds'), '/', checklist: true), '/checklist');
      expect(go(paired('waiter'), '/staff', checklist: true), '/checklist');
      expect(go(paired('kds'), '/checklist', checklist: true), isNull);
      expect(go(paired('kds'), '/checklist'), '/mode/kds');
      expect(go(paired('waiter'), '/checklist'), '/staff');
    });

    test('opens management only after a manager PIN', () {
      expect(go(paired('kds'), '/manage/staff'), isNull);
      expect(go(paired('kds'), '/manage'), '/mode/kds');
      expect(go(paired('kds'), '/manage', manager: true), isNull);
    });
  });

  group('pairing', () {
    late FakeServer server;
    late MemorySecretStore secrets;
    late ProviderContainer container;

    setUp(() {
      server = FakeServer();
      secrets = MemorySecretStore();
      container = ProviderContainer(overrides: [
        deviceStoreProvider.overrideWithValue(DeviceStore(secrets)),
        deviceDescriptorProvider.overrideWith(
          (ref) async => const DeviceDescriptor(platform: 'android', model: 'SUNMI V2s', appVersion: '1.0.0+1'),
        ),
        apiClientFactoryProvider.overrideWith((ref) {
          final credentials = ref.watch(credentialsProvider);
          return (url) => PosApiClient(baseUrl: url, credentials: credentials, adapter: server);
        }),
      ]);
    });

    tearDown(() => container.dispose());

    test('starts unpaired with nothing stored', () async {
      expect(await container.read(sessionProvider.future), const AppSession.unpaired());
    });

    test('checks the server, exchanges the code, keeps the token and loads the device', () async {
      server.routes
        ..['GET /up'] = (200, null)
        ..['POST /api/v3/pos_device/pair'] = (
          201,
          {
            'data': {
              'device': meJson('kds')['device'],
              'token': 'secret-device-token',
            },
          },
        )
        ..['GET /api/v3/pos_device/me'] = (200, {'data': meJson('kds')});

      await container.read(sessionProvider.future);
      await container.read(sessionProvider.notifier).pair(serverUrl: 'http://pos.local/', code: ' AB12 ', name: '');

      final session = container.read(sessionProvider).value;
      expect(session, isA<Paired>().having((paired) => paired.serverUrl, 'serverUrl', 'http://pos.local'));
      expect(secrets.values['device_token'], 'secret-device-token');
      expect(secrets.values['server_url'], 'http://pos.local');
      expect(secrets.values['editor_id'], isNotNull);

      final pair = server.requests.firstWhere((request) => request.path.endsWith('/pair'));
      final body = jsonDecode(jsonEncode(pair.data)) as Map<String, Object?>;
      expect(body, containsPair('code', 'AB12'));
      expect(body, containsPair('platform', 'android'));
      expect(body, containsPair('name', 'SUNMI V2s'));
      expect(body, containsPair('app_version', '1.0.0+1'));
      expect(pair.headers.containsKey('Authorization'), isFalse);
      expect(server.requests.last.headers['Authorization'], 'Device secret-device-token');
    });

    test('forgets a token the server no longer accepts and says so', () async {
      secrets.values
        ..['server_url'] = 'http://pos.local'
        ..['device_token'] = 'revoked-token'
        ..['editor_id'] = 'kept';
      server.routes['GET /api/v3/pos_device/me'] = (
        401,
        {
          'error': {'code': 'device_unauthorized', 'message': 'Revoked.'},
        },
      );

      expect(await container.read(sessionProvider.future), const AppSession.unpaired(revoked: true));
      expect(secrets.values.keys, ['editor_id']);
    });

    test('stays paired but offline when the server is not there', () async {
      secrets.values
        ..['server_url'] = 'http://pos.local'
        ..['device_token'] = 'token';
      server.routes['GET /api/v3/pos_device/me'] = (503, null);

      final session = await container.read(sessionProvider.future);
      expect(session, isA<Offline>().having((offline) => offline.failure, 'failure', isA<ServerFailure>()));
      expect(secrets.values['device_token'], 'token');
    });

    test('does not keep anything when the code is refused', () async {
      server.routes
        ..['GET /up'] = (200, null)
        ..['POST /api/v3/pos_device/pair'] = (
          404,
          {
            'error': {'code': 'pairing_invalid', 'message': 'Invalid.'},
          },
        );
      await container.read(sessionProvider.future);
      await expectLater(
        container.read(sessionProvider.notifier).pair(serverUrl: 'http://pos.local', code: 'BAD'),
        throwsA(isA<NotFoundFailure>().having((failure) => failure.code, 'code', 'pairing_invalid')),
      );
      expect(secrets.values.containsKey('device_token'), isFalse);
    });
  });
}
