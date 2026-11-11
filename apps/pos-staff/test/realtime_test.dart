import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/realtime.dart';

/// A local Action Cable server that speaks just enough of the protocol.
class FakeCable {
  FakeCable._(this._server) {
    _server.listen(_accept);
  }

  static Future<FakeCable> start() async => FakeCable._(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));

  final HttpServer _server;
  final offeredProtocols = <List<String>>[];
  final sockets = <WebSocket>[];
  final received = <Map<String, Object?>>[];

  /// What the server answers a subscribe with.
  String answer = 'confirm_subscription';

  Uri get uri => Uri.parse('ws://127.0.0.1:${_server.port}/cable');

  Future<void> _accept(HttpRequest request) async {
    offeredProtocols.add(
      (request.headers['sec-websocket-protocol'] ?? const <String>[])
          .expand((value) => value.split(','))
          .map((value) => value.trim())
          .toList(),
    );
    final socket = await WebSocketTransformer.upgrade(
      request,
      protocolSelector: (protocols) => 'actioncable-v1-json',
    );
    sockets.add(socket);
    socket.add(jsonEncode({'type': 'welcome'}));
    socket.listen((frame) {
      final command = jsonDecode(frame as String) as Map<String, Object?>;
      received.add(command);
      if (command['command'] == 'subscribe') {
        socket.add(jsonEncode({'type': answer, 'identifier': command['identifier']}));
      }
    });
  }

  void broadcast(Map<String, Object?> message) {
    final identifier = received.lastWhere((command) => command['command'] == 'subscribe')['identifier'];
    sockets.last.add(jsonEncode({'identifier': identifier, 'message': message}));
  }

  Future<void> close() async {
    for (final socket in sockets) {
      await socket.close();
    }
    await _server.close(force: true);
  }
}

void main() {
  late FakeCable cable;
  late ActionCableClient client;

  setUp(() async {
    cable = await FakeCable.start();
    client = ActionCableClient(
      uri: cable.uri,
      protocols: () => deviceProtocols('dev-token', staffSessionToken: 'staff-token'),
      identifier: const {'channel': 'Spree::Pos::BranchChannel', 'branch_id': 'posbr_1'},
      backoff: const Backoff(base: Duration(milliseconds: 20), max: Duration(milliseconds: 80)),
    );
  });

  tearDown(() async {
    await client.dispose();
    await cable.close();
  });

  test('builds the cable address from the server address', () {
    expect(cableUri('http://192.168.1.10'), Uri.parse('ws://192.168.1.10/cable'));
    expect(cableUri('https://pos.example.vn/staff'), Uri.parse('wss://pos.example.vn/staff/cable'));
  });

  test('offers the cable protocol and the credentials, subscribes after welcome and passes messages on', () async {
    final subscribed = client.subscribed.first;
    final event = client.events.first;
    client.start();
    await subscribed.timeout(const Duration(seconds: 5));

    expect(cable.offeredProtocols.single, ['actioncable-v1-json', 'pos-device.dev-token', 'pos-staff-session.staff-token']);
    final subscribe = cable.received.single;
    expect(subscribe['command'], 'subscribe');
    expect(jsonDecode(subscribe['identifier']! as String), {'channel': 'Spree::Pos::BranchChannel', 'branch_id': 'posbr_1'});
    expect(client.status.value, RealtimeStatus.connected);

    cable.broadcast({'event': 'print_job.created', 'id': 'posjob_1'});
    expect(await event.timeout(const Duration(seconds: 5)), {'event': 'print_job.created', 'id': 'posjob_1'});
  });

  test('reconnects after the socket drops and announces the new subscription', () async {
    var confirmations = 0;
    final twice = Completer<void>();
    client.subscribed.listen((_) {
      confirmations += 1;
      if (confirmations == 2) twice.complete();
    });
    client.start();
    await client.subscribed.first.timeout(const Duration(seconds: 5));

    await cable.sockets.single.close();
    await twice.future.timeout(const Duration(seconds: 5));

    expect(cable.sockets, hasLength(2));
    expect(client.status.value, RealtimeStatus.connected);
  });

  test('stops for good when the server rejects the subscription', () async {
    cable.answer = 'reject_subscription';
    final rejected = Completer<void>();
    client.status.addListener(() {
      if (client.status.value == RealtimeStatus.rejected && !rejected.isCompleted) rejected.complete();
    });
    client.start();
    await rejected.future.timeout(const Duration(seconds: 5));

    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(cable.sockets, hasLength(1));
    expect(client.status.value, RealtimeStatus.rejected);
  });

  test('backs off up to the cap with some jitter', () {
    const backoff = Backoff();
    final random = _FixedRandom(0.999);
    expect(backoff.delay(0, random).inMilliseconds, inInclusiveRange(1000, 1250));
    expect(backoff.delay(3, random).inMilliseconds, inInclusiveRange(8000, 10000));
    expect(backoff.delay(20, random).inMilliseconds, inInclusiveRange(30000, 37500));
  });
}

class _FixedRandom implements Random {
  _FixedRandom(this.value);

  final double value;

  @override
  double nextDouble() => value;

  @override
  bool nextBool() => value >= 0.5;

  @override
  int nextInt(int max) => (value * max).floor();
}
