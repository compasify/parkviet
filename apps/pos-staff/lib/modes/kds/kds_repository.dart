import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_api/pos_api.dart';

import '../../auth/staff_session.dart';
import '../../core/api_client.dart';
import '../../core/errors.dart';
import '../../core/realtime.dart';
import '../../core/server_time.dart';

/// A step a kitchen item takes on the screen.
enum KitchenAction { start, ready, serve, recall }

/// What the kitchen screen asks of the server, as the device itself.
abstract interface class KitchenApi {
  /// The board of [stationIds]; null for every station of the branch.
  /// [serviceMode] narrows it to one way of serving.
  Future<KitchenBoard> board(List<String>? stationIds, {String? serviceMode});

  Future<List<KitchenStation>> stations();

  /// Remembers the home station of this screen; null for every station.
  Future<Device> selectStation(String? stationId);

  Future<KitchenTicket> item(String itemId, KitchenAction action);

  Future<KitchenTicket> bump(String ticketId);

  /// Makes the oldest open items of one dish of the all-day view ready,
  /// first sent first, until [quantity] units are covered.
  Future<List<KitchenTicket>> allDayBump(List<String>? stationIds, String key, int quantity);

  /// Hands an order over at the counter: every ready item of the order is
  /// served. Answers the tickets that changed, none when nothing was ready.
  Future<List<KitchenTicket>> serveOrder(String workspaceId);

  Future<List<KitchenMenuItem>> menuItems(String? stationId);

  /// Marks an item sold out (or back on sale) for today in the name of the
  /// person whose PIN this is. The staff session it opens is closed again.
  Future<void> soldOut({
    required String branchId,
    required String menuItemId,
    required bool soldOut,
    required String membershipId,
    required String pin,
  });
}

/// [KitchenApi] over the generated client.
class ApiKitchenApi implements KitchenApi {
  ApiKitchenApi(this.client);

  final PosApiClient client;

  // An empty station id asks for every station; absent would mean the
  // station stored on the device, which the screen already passes itself.
  @override
  Future<KitchenBoard> board(List<String>? stationIds, {String? serviceMode}) async {
    final several = stationIds != null && stationIds.length > 1;
    final response = await client.call((api) => api.posDeviceKitchenBoard(
          stationId: several ? null : (stationIds?.single ?? ''),
          stationIds: several ? stationIds.join(',') : null,
          serviceMode: serviceMode,
        ));
    return response.data;
  }

  @override
  Future<List<KitchenStation>> stations() async =>
      (await client.call((api) => api.posDeviceKitchenStations())).data.toList();

  @override
  Future<Device> selectStation(String? stationId) async => (await client.call((api) => api.posDeviceKitchenSelectStation(
            posDeviceKitchenSelectStationRequest: PosDeviceKitchenSelectStationRequest((b) => b..stationId = stationId),
          )))
      .data;

  @override
  Future<KitchenTicket> item(String itemId, KitchenAction action) async {
    final response = await client.call((api) => switch (action) {
          KitchenAction.start => api.posDeviceKitchenItemStart(id: itemId),
          KitchenAction.ready => api.posDeviceKitchenItemReady(id: itemId),
          KitchenAction.serve => api.posDeviceKitchenItemServe(id: itemId),
          KitchenAction.recall => api.posDeviceKitchenItemRecall(id: itemId),
        });
    return response.data;
  }

  @override
  Future<KitchenTicket> bump(String ticketId) async =>
      (await client.call((api) => api.posDeviceKitchenTicketBump(id: ticketId))).data;

  @override
  Future<List<KitchenTicket>> allDayBump(List<String>? stationIds, String key, int quantity) async {
    final response = await client.call((api) => api.posDeviceKitchenAllDayBump(
          kitchenAllDayBumpInput: KitchenAllDayBumpInput((b) {
            b
              ..key = key
              ..quantity = quantity;
            if (stationIds != null) b.stationIds.replace(stationIds);
          }),
        ));
    return response.data.toList();
  }

  @override
  Future<List<KitchenTicket>> serveOrder(String workspaceId) async =>
      (await client.call((api) => api.posDeviceKitchenOrderServe(workspaceId: workspaceId))).data.tickets.toList();

  @override
  Future<List<KitchenMenuItem>> menuItems(String? stationId) async =>
      (await client.call((api) => api.posDeviceKitchenMenuItems(stationId: stationId ?? ''))).data.toList();

  @override
  Future<void> soldOut({
    required String branchId,
    required String menuItemId,
    required bool soldOut,
    required String membershipId,
    required String pin,
  }) async {
    final opened = await openStaffSession(client, membershipId: membershipId, pin: pin);
    try {
      await client.call((api) => api.posMenuSoldOut(
            posMenuSoldOutRequest: PosMenuSoldOutRequest((b) => b
              ..branchId = branchId
              ..menuItemId = menuItemId
              ..soldOut = soldOut),
            headers: {staffSessionHeader: opened.token},
          ));
    } finally {
      await closeStaffSession(client, opened.token);
    }
  }
}

/// What the screen shows: the last board, whether it is live, and when it
/// was last fetched.
@immutable
class KdsState {
  const KdsState({this.board, this.live = false, this.lastSync, this.failure});

  final KitchenBoard? board;

  /// The socket is up and the last fetch worked.
  final bool live;

  /// Device time of the last good fetch.
  final DateTime? lastSync;
  final AppFailure? failure;

  KdsState copyWith({KitchenBoard? board, bool? live, DateTime? lastSync, AppFailure? failure, bool clearFailure = false}) =>
      KdsState(
        board: board ?? this.board,
        live: live ?? this.live,
        lastSync: lastSync ?? this.lastSync,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}

/// Keeps one kitchen board current: fetched again on every
/// `kitchen_ticket.updated`, on every (re)subscription, and every
/// [pollInterval] while the socket is down. Timers run on [clock], taken
/// from the board's `server_now`.
class KdsController {
  KdsController({
    required this.api,
    required List<String>? stationIds,
    String? serviceMode,
    this.pollInterval = const Duration(seconds: 5),
    this.onNewTicket,
    DateTime Function()? deviceNow,
  })  : _stationIds = stationIds,
        _serviceMode = serviceMode,
        _deviceNow = deviceNow ?? DateTime.now;

  final KitchenApi api;
  final Duration pollInterval;

  /// Called when a ticket the screen has not seen before arrives, after the
  /// first load.
  final VoidCallback? onNewTicket;
  final DateTime Function() _deviceNow;

  final state = ValueNotifier(const KdsState());
  ServerClock clock = ServerClock.zero;

  List<String>? _stationIds;

  /// The stations shown; null for every station.
  List<String>? get stationIds => _stationIds;

  /// The one station shown, or null for several or every station.
  String? get stationId => _stationIds?.length == 1 ? _stationIds!.single : null;

  String? _serviceMode;
  String? get serviceMode => _serviceMode;

  final _seen = <String>{};
  bool _loadedOnce = false;
  bool _socketUp = false;
  Future<void>? _inflight;
  bool _again = false;
  Timer? _poll;
  StreamSubscription<Object?>? _events;
  StreamSubscription<void>? _subscribed;
  ValueListenable<RealtimeStatus>? _status;

  void start({
    Stream<Map<String, Object?>>? events,
    Stream<void>? subscribed,
    ValueListenable<RealtimeStatus>? status,
  }) {
    _events = events?.listen((event) {
      if (event['event'] == 'kitchen_ticket.updated') unawaited(refresh());
    });
    _subscribed = subscribed?.listen((_) => unawaited(refresh()));
    _status = status?..addListener(_statusChanged);
    _statusChanged();
    unawaited(refresh());
  }

  void _statusChanged() {
    _socketUp = _status?.value == RealtimeStatus.connected;
    if (_socketUp) {
      _poll?.cancel();
      _poll = null;
    } else {
      _poll ??= Timer.periodic(pollInterval, (_) => unawaited(refresh()));
    }
    state.value = state.value.copyWith(live: _socketUp && state.value.failure == null);
  }

  /// Shows other stations; null for every station. The first one is
  /// remembered on the server as this device's station; the screen keeps
  /// the whole choice on the device.
  Future<void> selectStations(List<String>? stationIds) async {
    final chosen = stationIds == null || stationIds.isEmpty ? null : List<String>.unmodifiable(stationIds);
    await api.selectStation(chosen?.first);
    _stationIds = chosen;
    _restart();
    await refresh();
  }

  /// Shows only one way of serving; null for all of them.
  Future<void> setServiceMode(String? serviceMode) {
    _serviceMode = serviceMode;
    _restart();
    return refresh();
  }

  void _restart() {
    _seen.clear();
    _loadedOnce = false;
    state.value = const KdsState().copyWith(live: _socketUp);
  }

  /// Fetches the board. Calls that arrive during a fetch share one more
  /// fetch after it, so a burst of events costs two requests.
  Future<void> refresh() {
    if (_inflight != null) {
      _again = true;
      return _inflight!;
    }
    return _inflight = _load().whenComplete(() {
      _inflight = null;
      if (_again) {
        _again = false;
        unawaited(refresh());
      }
    });
  }

  Future<void> _load() async {
    final sentAt = _deviceNow();
    try {
      final board = await api.board(_stationIds, serviceMode: _serviceMode);
      final receivedAt = _deviceNow();
      clock = ServerClock.measure(serverTime: board.serverNow, sentAt: sentAt, receivedAt: receivedAt);
      _announce(board);
      state.value = KdsState(board: board, live: _socketUp, lastSync: receivedAt);
    } on AppFailure catch (failure) {
      state.value = state.value.copyWith(live: false, failure: failure);
    }
  }

  void _announce(KitchenBoard board) {
    final fresh = board.open.map((ticket) => ticket.id).where((id) => !_seen.contains(id)).toList();
    _seen.addAll(fresh);
    if (_loadedOnce && fresh.isNotEmpty) onNewTicket?.call();
    _loadedOnce = true;
  }

  /// Moves one item; the answer replaces its ticket at once and a fetch
  /// follows. Returns the failure, or null.
  Future<AppFailure?> act(KitchenTicketItem item, KitchenAction action) =>
      _change(() async => [await api.item(item.id, action)]);

  /// Marks every open item of the ticket ready.
  Future<AppFailure?> bump(KitchenTicket ticket) => _change(() async => [await api.bump(ticket.id)]);

  /// Marks the oldest [quantity] units of one all-day dish ready.
  Future<AppFailure?> bumpAllDay(KitchenAllDayRow row, int quantity) =>
      _change(() => api.allDayBump(_stationIds, row.key, quantity));

  /// Hands the order over: every ready item of it is served.
  Future<AppFailure?> serveOrder(String workspaceId) => _change(() => api.serveOrder(workspaceId));

  Future<AppFailure?> _change(Future<List<KitchenTicket>> Function() request) async {
    try {
      (await request()).forEach(_apply);
      unawaited(refresh());
      return null;
    } on AppFailure catch (failure) {
      unawaited(refresh());
      return failure;
    }
  }

  void _apply(KitchenTicket ticket) {
    final board = state.value.board;
    if (board == null) return;
    final open = board.open.where((row) => row.id != ticket.id).toList();
    final done = board.done.where((row) => row.id != ticket.id).toList();
    if (ticket.done) {
      done.insert(0, ticket);
    } else {
      open
        ..add(ticket)
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    }
    state.value = state.value.copyWith(
      board: board.rebuild((b) => b
        ..open.replace(open)
        ..done.replace(done)),
    );
  }

  Future<void> dispose() async {
    _poll?.cancel();
    _status?.removeListener(_statusChanged);
    await _events?.cancel();
    await _subscribed?.cancel();
    state.dispose();
  }
}
