import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum RealtimeStatus { idle, connecting, connected, disconnected, rejected }

typedef SocketConnector = WebSocketChannel Function(Uri uri, List<String> protocols);

WebSocketChannel _ioConnector(Uri uri, List<String> protocols) =>
    IOWebSocketChannel.connect(uri, protocols: protocols, connectTimeout: const Duration(seconds: 10));

/// `/cable` on the same server, ws for http and wss for https.
Uri cableUri(String serverUrl) {
  final base = Uri.parse(serverUrl);
  final path = base.path.endsWith('/') ? '${base.path}cable' : '${base.path}/cable';
  return base.replace(scheme: base.scheme == 'https' ? 'wss' : 'ws', path: path);
}

/// The subprotocols a paired device offers. Action Cable's own protocol
/// comes first: without it the server selects none for the socket.
List<String> deviceProtocols(String deviceToken, {String? staffSessionToken}) => [
      'actioncable-v1-json',
      'pos-device.$deviceToken',
      if (staffSessionToken != null) 'pos-staff-session.$staffSessionToken',
    ];

/// Waits 1s, 2s, 4s… up to [max], with up to a quarter more at random so a
/// room of devices does not reconnect in step.
class Backoff {
  const Backoff({this.base = const Duration(seconds: 1), this.max = const Duration(seconds: 30)});

  final Duration base;
  final Duration max;

  Duration delay(int attempt, Random random) {
    final exponent = min(attempt, 16);
    final raw = base * pow(2, exponent).toInt();
    final capped = raw > max ? max : raw;
    return capped + capped * (random.nextDouble() / 4);
  }
}

/// A small Action Cable client for one channel subscription.
///
/// The protocol: the server sends `welcome`, the client sends `subscribe`,
/// the server answers `confirm_subscription` (or `reject_subscription`), then
/// sends `ping` every few seconds and `message` frames for the stream. A
/// socket that stops pinging is treated as dead. Events sent while the
/// socket was down are not replayed, so [subscribed] fires on every
/// confirmation and listeners refetch what they show.
class ActionCableClient {
  ActionCableClient({
    required this.uri,
    required List<String> Function() protocols,
    required Map<String, String> identifier,
    SocketConnector? connector,
    this.staleAfter = const Duration(seconds: 6),
    this.backoff = const Backoff(),
    Random? random,
  })  : _protocols = protocols,
        _identifier = jsonEncode(identifier),
        _connector = connector ?? _ioConnector,
        _random = random ?? Random();

  final Uri uri;
  final Duration staleAfter;
  final Backoff backoff;
  final List<String> Function() _protocols;
  final String _identifier;
  final SocketConnector _connector;
  final Random _random;

  final ValueNotifier<RealtimeStatus> status = ValueNotifier(RealtimeStatus.idle);
  final _events = StreamController<Map<String, Object?>>.broadcast();
  final _subscribed = StreamController<void>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<Object?>? _listener;
  Timer? _watchdog;
  Timer? _retry;
  DateTime _lastSeen = DateTime.now();
  int _attempt = 0;
  bool _running = false;

  /// Each `message` of the subscribed stream.
  Stream<Map<String, Object?>> get events => _events.stream;

  /// Fires after each confirmed subscription, the first one included.
  Stream<void> get subscribed => _subscribed.stream;

  void start() {
    if (_running) return;
    _running = true;
    _connect();
  }

  Future<void> stop() async {
    _running = false;
    _retry?.cancel();
    await _drop();
    status.value = RealtimeStatus.idle;
  }

  Future<void> dispose() async {
    await stop();
    await _events.close();
    await _subscribed.close();
    status.dispose();
  }

  void _connect() {
    if (!_running) return;
    status.value = RealtimeStatus.connecting;
    final WebSocketChannel channel;
    try {
      channel = _connector(uri, _protocols());
    } on Object {
      _scheduleReconnect();
      return;
    }
    _channel = channel;
    _lastSeen = DateTime.now();
    _listener = channel.stream.listen(
      _onFrame,
      onError: (Object _) => _lost(channel),
      onDone: () => _lost(channel),
      cancelOnError: true,
    );
    channel.ready.catchError((Object _) => _lost(channel));
    _watchdog = Timer.periodic(staleAfter ~/ 3, (_) {
      if (DateTime.now().difference(_lastSeen) > staleAfter) _lost(channel);
    });
  }

  void _onFrame(Object? frame) {
    _lastSeen = DateTime.now();
    if (frame is! String) return;
    final Object? decoded;
    try {
      decoded = jsonDecode(frame);
    } on FormatException {
      return;
    }
    if (decoded is! Map<String, Object?>) return;

    switch (decoded['type']) {
      case 'welcome':
        _channel?.sink.add(jsonEncode({'command': 'subscribe', 'identifier': _identifier}));
      case 'ping':
        break;
      case 'confirm_subscription':
        if (decoded['identifier'] != _identifier) return;
        _attempt = 0;
        status.value = RealtimeStatus.connected;
        _subscribed.add(null);
      case 'reject_subscription':
        if (decoded['identifier'] != _identifier) return;
        _refuse();
      case 'disconnect':
        if (decoded['reconnect'] == false) {
          _refuse();
        } else {
          final channel = _channel;
          if (channel != null) _lost(channel);
        }
      default:
        final message = decoded['message'];
        if (decoded['identifier'] == _identifier && message is Map<String, Object?>) {
          _events.add(message);
        }
    }
  }

  /// The server refused these credentials; trying again would only be
  /// refused again until something else changes them.
  void _refuse() {
    _running = false;
    unawaited(_drop());
    status.value = RealtimeStatus.rejected;
  }

  void _lost(WebSocketChannel channel) {
    if (!identical(channel, _channel)) return;
    unawaited(_drop());
    if (!_running) return;
    status.value = RealtimeStatus.disconnected;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_running) return;
    _retry?.cancel();
    _retry = Timer(backoff.delay(_attempt, _random), _connect);
    _attempt += 1;
  }

  Future<void> _drop() async {
    _watchdog?.cancel();
    _watchdog = null;
    final channel = _channel;
    final listener = _listener;
    _channel = null;
    _listener = null;
    await listener?.cancel();
    try {
      await channel?.sink.close();
    } on Object {
      // Already closed.
    }
  }
}
