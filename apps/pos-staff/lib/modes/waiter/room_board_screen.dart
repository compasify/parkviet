import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_api/pos_api.dart';

import '../../core/errors.dart';
import '../../core/menu/modifier_sheet.dart' show money, moneyLabel;
import '../../l10n/app_localizations.dart';
import 'table_order_screen.dart';
import 'waiter_context.dart';
import 'waiter_messages.dart';
import 'waiter_screen.dart' show tableStateLabel;

/// Who may start, stop and move a room's clock.
const timedOperateCapability = 'pos.timed.operate';

/// The karaoke rooms and billiard tables of the branch on the waiter's
/// phone: each room's clock counting from the server's start, the price so
/// far, and starting, stopping or moving the clock. Takes no money: the
/// room's order opens for dishes and asking for the bill.
class RoomBoardScreen extends StatefulWidget {
  const RoomBoardScreen({
    super.key,
    required this.waiter,
    this.now = DateTime.now,
  });

  final WaiterContext waiter;

  /// This phone's clock; only ever moved by the measured server offset.
  final DateTime Function() now;

  @override
  State<RoomBoardScreen> createState() => _RoomBoardScreenState();
}

class _RoomBoardScreenState extends State<RoomBoardScreen> {
  ResourceBoard? _board;
  AppFailure? _failure;
  // How far the server clock is ahead of this phone, measured when the board was read.
  Duration _offset = Duration.zero;
  StreamSubscription<Map<String, Object?>>? _events;
  Timer? _tick;
  Timer? _quote;
  Future<void>? _inflight;
  bool _again = false;
  bool _busy = false;

  static const _boardEvents = {'workspace.updated', 'resource.updated'};

  /// The server's price of a running clock is read again every minute.
  static const quoteRefresh = Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
    _events = widget.waiter.events.listen((event) {
      if (_boardEvents.contains(event['event'])) unawaited(_refresh());
    });
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _rooms.any((tile) => clockRunning(tile.timed))) {
        setState(() {});
      }
    });
    _quote = Timer.periodic(quoteRefresh, (_) {
      if (_rooms.any((tile) => clockRunning(tile.timed))) unawaited(_refresh());
    });
    unawaited(_refresh());
  }

  @override
  void dispose() {
    _events?.cancel();
    _tick?.cancel();
    _quote?.cancel();
    super.dispose();
  }

  List<ResourceBoardTile> get _rooms =>
      (_board?.resources ?? const <ResourceBoardTile>[])
          .where((tile) => tile.kind != ResourceBoardTileKindEnum.table)
          .toList();

  Future<void> _refresh() {
    if (_inflight != null) {
      _again = true;
      return _inflight!;
    }
    return _inflight = _load().whenComplete(() {
      _inflight = null;
      if (_again) {
        _again = false;
        unawaited(_refresh());
      }
    });
  }

  Future<void> _load() async {
    try {
      final board = await widget.waiter.api.tables(widget.waiter.branchId);
      if (!mounted) return;
      setState(() {
        _board = board;
        _offset = board.serverNow.difference(widget.now());
        _failure = null;
      });
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    }
  }

  void _say(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on AppFailure catch (failure) {
      if (mounted) {
        _say(waiterFailureMessage(AppLocalizations.of(context), failure));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
      unawaited(_refresh());
    }
  }

  Future<void> _actions(ResourceBoardTile tile) async {
    final l10n = AppLocalizations.of(context);
    final operate = widget.waiter.capabilities.value.contains(
      timedOperateCapability,
    );
    final running = clockRunning(tile.timed);
    final usable =
        tile.state != ResourceBoardTileStateEnum.cleaning &&
        tile.state != ResourceBoardTileStateEnum.outOfService;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(tile.name),
              subtitle: Text(tableStateLabel(l10n, tile.state)),
            ),
            if (operate && !running && usable)
              ListTile(
                key: Key('room-start-${tile.id}'),
                minTileHeight: 64,
                leading: const Icon(Icons.play_arrow),
                title: Text(l10n.waiterClockStart),
                onTap: () => Navigator.of(sheet).pop('start'),
              ),
            if (operate && running) ...[
              ListTile(
                key: Key('room-stop-${tile.id}'),
                minTileHeight: 64,
                leading: const Icon(Icons.stop),
                title: Text(l10n.waiterClockStop),
                onTap: () => Navigator.of(sheet).pop('stop'),
              ),
              ListTile(
                key: Key('room-move-${tile.id}'),
                minTileHeight: 64,
                leading: const Icon(Icons.swap_horiz),
                title: Text(l10n.waiterClockMove),
                onTap: () => Navigator.of(sheet).pop('move'),
              ),
            ],
            if (tile.orders.isNotEmpty)
              ListTile(
                key: Key('room-order-${tile.id}'),
                minTileHeight: 64,
                leading: const Icon(Icons.restaurant_menu),
                title: Text(l10n.waiterClockOpenOrder),
                onTap: () => Navigator.of(sheet).pop('order'),
              ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'start':
        await _start(tile);
      case 'stop':
        await _stop(tile);
      case 'move':
        await _move(tile);
      case 'order':
        final id = tile.timed?.workspaceId ?? await _pickOrder(tile);
        if (id != null) await _show(id);
    }
  }

  Future<String?> _pickOrder(ResourceBoardTile tile) async {
    if (tile.orders.length == 1) return tile.orders.single.id;
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(l10n.waiterPickOrder(tile.name))),
            for (final (index, order) in tile.orders.indexed)
              ListTile(
                key: Key('room-pick-${order.id}'),
                minTileHeight: 64,
                title: Text(
                  order.tableLabel ??
                      l10n.waiterOrderLetter(String.fromCharCode(65 + index)),
                ),
                onTap: () => Navigator.of(sheet).pop(order.id),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _start(ResourceBoardTile tile) async {
    String? workspaceId;
    if (tile.orders.length > 1) {
      workspaceId = await _pickOrder(tile);
      if (workspaceId == null) return;
    }
    await _run(() async {
      await widget.waiter.api.startClock(
        widget.waiter.branchId,
        tile.id,
        editorId: widget.waiter.editorId,
        workspaceId: workspaceId,
      );
    });
  }

  Future<void> _stop(ResourceBoardTile tile) async {
    final l10n = AppLocalizations.of(context);
    final timed = tile.timed;
    if (timed == null) return;
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        content: Text(l10n.waiterClockStopConfirm(tile.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('room-stop-confirm'),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.waiterClockStop),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    await _run(() async {
      final stopped = await widget.waiter.api.stopClock(timed.id);
      if (mounted) {
        _say(
          l10n.waiterClockStopped(
            moneyLabel(money(stopped.timedSession.amount)),
          ),
        );
      }
    });
  }

  Future<void> _move(ResourceBoardTile tile) async {
    final l10n = AppLocalizations.of(context);
    final timed = tile.timed;
    if (timed == null) return;
    final free = _rooms
        .where(
          (row) =>
              row.id != tile.id &&
              row.orders.isEmpty &&
              row.state == ResourceBoardTileStateEnum.available,
        )
        .toList();
    if (free.isEmpty) {
      _say(l10n.waiterClockMoveNone);
      return;
    }
    final target = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: Text(l10n.waiterClockMoveTo(tile.name))),
            for (final room in free)
              ListTile(
                key: Key('room-move-to-${room.id}'),
                minTileHeight: 64,
                title: Text(room.name),
                onTap: () => Navigator.of(sheet).pop(room.id),
              ),
          ],
        ),
      ),
    );
    if (target == null) return;
    await _run(() async {
      await widget.waiter.api.moveClock(timed.id, target);
    });
  }

  Future<void> _show(String workspaceId) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            TableOrderScreen(waiter: widget.waiter, workspaceId: workspaceId),
      ),
    );
    unawaited(_refresh());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rooms = _rooms;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.waiterRoomsTitle)),
      body: Column(
        children: [
          if (_failure != null)
            MaterialBanner(
              content: Text(waiterFailureMessage(l10n, _failure!)),
              actions: [
                TextButton(onPressed: _refresh, child: Text(l10n.retry)),
              ],
            ),
          if (_busy) const LinearProgressIndicator(),
          Expanded(
            child: _board == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refresh,
                    child: rooms.isEmpty
                        ? ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: Center(
                                  child: Text(l10n.waiterRoomsNone),
                                ),
                              ),
                            ],
                          )
                        : GridView.builder(
                            key: const Key('room-grid'),
                            padding: const EdgeInsets.all(8),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 1.1,
                                ),
                            itemCount: rooms.length,
                            itemBuilder: (context, index) => RoomTile(
                              tile: rooms[index],
                              now: widget.now().add(_offset),
                              onTap: () => _actions(rooms[index]),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

bool clockRunning(ResourceBoardTimed? timed) =>
    timed != null &&
    (timed.status == ResourceBoardTimedStatusEnum.running ||
        timed.status == ResourceBoardTimedStatusEnum.paused);

/// How long a clock has run on the server's clock: until it stopped, else
/// until [serverNow]. Never negative.
Duration clockElapsed(ResourceBoardTimed timed, DateTime serverNow) {
  final end = timed.stoppedAt ?? serverNow;
  final elapsed = end.difference(timed.startedAt);
  return elapsed.isNegative ? Duration.zero : elapsed;
}

/// "1:05:09", or "05:09" under an hour.
String formatClock(Duration elapsed) {
  String pad(int value) => value.toString().padLeft(2, '0');
  final hours = elapsed.inHours;
  final minutes = elapsed.inMinutes % 60;
  final seconds = elapsed.inSeconds % 60;
  return hours > 0
      ? '$hours:${pad(minutes)}:${pad(seconds)}'
      : '${pad(minutes)}:${pad(seconds)}';
}

/// One room: its name, state, the running clock and the price so far.
class RoomTile extends StatelessWidget {
  const RoomTile({
    super.key,
    required this.tile,
    required this.now,
    required this.onTap,
  });

  final ResourceBoardTile tile;

  /// The server's time now, as this phone estimates it.
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final timed = tile.timed;
    final running = clockRunning(timed);
    final (background, foreground) = switch (tile.state) {
      ResourceBoardTileStateEnum.available => (
        scheme.surfaceContainerHighest,
        scheme.onSurface,
      ),
      ResourceBoardTileStateEnum.endingSoon ||
      ResourceBoardTileStateEnum.paymentRequested ||
      ResourceBoardTileStateEnum.prebilled => (
        Colors.amber.shade200,
        Colors.black,
      ),
      ResourceBoardTileStateEnum.cleaning ||
      ResourceBoardTileStateEnum.outOfService => (
        scheme.outlineVariant,
        scheme.onSurface,
      ),
      _ => (scheme.primaryContainer, scheme.onPrimaryContainer),
    };
    return Material(
      key: Key('room-${tile.id}'),
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: DefaultTextStyle(
            style: theme.textTheme.bodyMedium!.copyWith(color: foreground),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tile.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(tableStateLabel(l10n, tile.state)),
                  if (running) ...[
                    const SizedBox(height: 4),
                    Text(
                      formatClock(clockElapsed(timed!, now)),
                      key: Key('room-clock-${tile.id}'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: foreground,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      l10n.waiterClockQuote(
                        moneyLabel(money(timed.quoteAmount)),
                      ),
                    ),
                  ],
                  if (tile.guestCount != null)
                    Text(l10n.waiterGuests(tile.guestCount!)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
