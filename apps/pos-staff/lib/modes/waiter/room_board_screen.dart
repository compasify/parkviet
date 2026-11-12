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
/// phone: each room's clock counting the time played on the server's clock,
/// the price so far, and starting, pausing, stopping or moving the clock.
/// The branch's alerts (a room ten minutes from its end, a package used up,
/// a pause run too long) show as a notice. Takes no money: the room's
/// order opens for dishes and asking for the bill.
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
      if (!_boardEvents.contains(event['event'])) return;
      _alert(event);
      unawaited(_refresh());
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

  /// A `resource.updated` that names an alert, about a room on this board.
  void _alert(Map<String, Object?> event) {
    final alert = event['alert'];
    if (!mounted || alert is! String) return;
    final room = _rooms.where((tile) => tile.id == event['id']).firstOrNull;
    if (room == null) return;
    final l10n = AppLocalizations.of(context);
    final text = switch (alert) {
      'ending_soon' => l10n.waiterAlertEndingSoon(room.name),
      'ended_package' => l10n.waiterAlertEndedPackage(room.name),
      'pause_too_long' => l10n.waiterAlertPauseTooLong(room.name),
      _ => null,
    };
    if (text != null) _say(text);
  }

  /// Runs a clock command; [refused] words a refusal reason its own way.
  Future<void> _run(
    Future<void> Function() action, {
    Map<String, String> refused = const {},
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on AppFailure catch (failure) {
      if (mounted) {
        final own = failure is ConflictFailure ? refused[failure.reason] : null;
        _say(own ?? waiterFailureMessage(AppLocalizations.of(context), failure));
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
    final paused = tile.timed?.status == ResourceBoardTimedStatusEnum.paused;
    final staffId = widget.waiter.staffId.value;
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
              if (paused)
                ListTile(
                  key: Key('room-resume-${tile.id}'),
                  minTileHeight: 64,
                  leading: const Icon(Icons.play_circle),
                  title: Text(l10n.waiterClockResume),
                  onTap: () => Navigator.of(sheet).pop('resume'),
                )
              else
                ListTile(
                  key: Key('room-pause-${tile.id}'),
                  minTileHeight: 64,
                  leading: const Icon(Icons.pause),
                  title: Text(l10n.waiterClockPause),
                  onTap: () => Navigator.of(sheet).pop('pause'),
                ),
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
            if (operate && staffId != null && usable && tile.orders.isNotEmpty)
              ListTile(
                key: Key('room-serve-${tile.id}'),
                minTileHeight: 64,
                leading: const Icon(Icons.person_pin),
                title: Text(l10n.waiterServeRoom),
                onTap: () => Navigator.of(sheet).pop('serve'),
              ),
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
      case 'pause':
        final id = tile.timed!.id;
        await _run(() => widget.waiter.api.pauseClock(id));
      case 'resume':
        final id = tile.timed!.id;
        // A pause longer than the branch allows is reopened at the counter.
        await _run(
          () => widget.waiter.api.resumeClock(id),
          refused: {'approval_required': l10n.waiterClockLongPause},
        );
      case 'serve':
        await _serve(tile, staffId!);
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

  Future<void> _serve(ResourceBoardTile tile, String staffId) async {
    final l10n = AppLocalizations.of(context);
    await _run(() async {
      await widget.waiter.api.serveRoom(widget.waiter.branchId, tile.id, staffId);
      if (mounted) _say(l10n.waiterServingRoom(tile.name));
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
                              readAt: _board!.serverNow,
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

/// How long a clock has played on the server's clock, pauses not counted:
/// the seconds the board read at [readAt], plus the time since while it
/// runs. Without them (a stopped clock, an older server), from its start
/// until it stopped, else until [serverNow]. Never negative.
Duration clockElapsed(ResourceBoardTimed timed, DateTime serverNow, {DateTime? readAt}) {
  final played = timed.playedSeconds;
  if (played != null && readAt != null) {
    final since = timed.status == ResourceBoardTimedStatusEnum.running
        ? serverNow.difference(readAt)
        : Duration.zero;
    final elapsed = Duration(seconds: played) + since;
    return elapsed.isNegative ? Duration.zero : elapsed;
  }
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
    this.readAt,
  });

  final ResourceBoardTile tile;

  /// The server's time now, as this phone estimates it.
  final DateTime now;

  /// The server's time the board was read at.
  final DateTime? readAt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final timed = tile.timed;
    final running = clockRunning(timed);
    final paused = timed?.status == ResourceBoardTimedStatusEnum.paused;
    final prepaid = timed?.prepaidMinutes;
    final elapsed = running ? clockElapsed(timed!, now, readAt: readAt) : Duration.zero;
    final (background, foreground) = timed?.pauseTooLong == true || timed?.packageEnded == true
        ? (scheme.errorContainer, scheme.onErrorContainer)
        : switch (tile.state) {
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
                  Text(paused ? l10n.waiterClockPaused : tableStateLabel(l10n, tile.state)),
                  if (running) ...[
                    const SizedBox(height: 4),
                    Text(
                      formatClock(elapsed),
                      key: Key('room-clock-${tile.id}'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: foreground,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      l10n.waiterClockQuote(
                        moneyLabel(money(timed!.quoteAmount)),
                      ),
                    ),
                    if (prepaid != null)
                      Text(
                        l10n.waiterClockPackageLeft(
                          (prepaid - elapsed.inMinutes).clamp(0, prepaid),
                        ),
                        key: Key('room-package-${tile.id}'),
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
