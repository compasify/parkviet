import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_api/pos_api.dart';

import '../../core/errors.dart';
import 'waiter_api.dart';

/// The filters over the table grid.
enum TableFilter { all, free, seated, waiting, payment, mine }

/// Whether [tile] shows under [filter]. "Của tôi" is the tables the phone
/// follows and the open orders its person added to ([mine]).
bool tableMatches(ResourceBoardTile tile, TableFilter filter, Set<String> mine) => switch (filter) {
      TableFilter.all => true,
      TableFilter.free => tile.state == ResourceBoardTileStateEnum.available,
      TableFilter.seated => tile.orders.isNotEmpty,
      TableFilter.waiting => tile.state == ResourceBoardTileStateEnum.ordered ||
          tile.state == ResourceBoardTileStateEnum.waitingLong ||
          tile.orders.any((order) => order.pendingKitchenItems > 0),
      TableFilter.payment => tile.paymentRequested || tile.orders.any((order) => order.paymentRequested),
      TableFilter.mine => mine.contains(tile.id),
    };

/// "Bàn 5: Phở bò ×2 đã xong".
@immutable
class ReadyNotice {
  const ReadyNotice(this.item);

  final ReadyFeedItem item;

  String get table => item.tableLabel == null ? item.tableName : '${item.tableName} ${item.tableLabel}';
}

/// Keeps the phone's ready feed current: fetched when the screen opens,
/// on every (re)subscription and on every `kitchen_ticket.updated`. A dish
/// that became ready since the last fetch is announced once
/// ([onAnnounce]: vibration and sound) and shown in the banner. The first
/// fetch announces nothing, so reopening the app does not ring for dishes
/// already seen; the banner still counts what is ready.
class ReadyWatcher {
  ReadyWatcher({required this.api, this.onAnnounce});

  final WaiterApi api;
  final void Function(ReadyNotice notice)? onAnnounce;

  /// The ready dishes not handed out yet, newest first.
  final ready = ValueNotifier<List<ReadyFeedItem>>(const []);

  /// The last announcement, until it is dismissed.
  final notice = ValueNotifier<ReadyNotice?>(null);

  String? _areaId;
  String? get areaId => _areaId;

  final _seen = <String>{};
  bool _loaded = false;
  StreamSubscription<Map<String, Object?>>? _events;
  StreamSubscription<void>? _subscribed;
  Future<void>? _inflight;
  bool _again = false;

  void start({Stream<Map<String, Object?>>? events, Stream<void>? subscribed, String? areaId}) {
    _areaId = areaId;
    _events = events?.listen((event) {
      if (event['event'] == 'kitchen_ticket.updated') unawaited(refresh());
    });
    _subscribed = subscribed?.listen((_) => unawaited(refresh()));
    unawaited(refresh());
  }

  /// Hears every table of [areaId] too; null for only this phone's tables.
  Future<void> follow(String? areaId) {
    _areaId = areaId;
    return refresh();
  }

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
    try {
      final feed = await api.readyFeed(areaId: _areaId);
      final readyNow = feed.items.where((item) => item.status == ReadyFeedItemStatusEnum.ready).toList();
      final fresh = readyNow.where((item) => !_seen.contains(item.id)).toList();
      _seen.addAll(readyNow.map((item) => item.id));
      ready.value = readyNow;
      if (_loaded && fresh.isNotEmpty) {
        final latest = ReadyNotice(fresh.first);
        notice.value = latest;
        onAnnounce?.call(latest);
      }
      _loaded = true;
    } on AppFailure {
      // The next event or resubscription fetches again.
    }
  }

  void dismiss() => notice.value = null;

  Future<void> dispose() async {
    await _events?.cancel();
    await _subscribed?.cancel();
    ready.dispose();
    notice.dispose();
  }
}
