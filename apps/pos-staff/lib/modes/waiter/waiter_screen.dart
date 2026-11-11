import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_api/pos_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_mode.dart';
import '../../core/errors.dart';
import '../../core/realtime_provider.dart';
import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../mode_scaffold.dart';
import 'guest_keypad.dart';
import 'table_order_screen.dart';
import 'waiter_api.dart';
import 'waiter_context.dart';
import 'waiter_messages.dart';
import 'waiter_state.dart';

final waiterApiProvider = Provider<WaiterApi>((ref) => ApiWaiterApi(ref.watch(apiClientProvider)));

/// This phone as an editor of orders, for the whole run of the app.
final waiterEditorIdProvider = Provider<String>((ref) => const Uuid().v4());

/// Vibration and sound when a dish is ready.
final waiterAlertProvider = Provider<VoidCallback>((ref) => () {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
    });

/// The area whose every table this phone hears about, kept on the phone.
class WaiterFollowMemory {
  const WaiterFollowMemory();

  static const _key = 'waiter.follow_area_id';

  Future<String?> read() async => (await SharedPreferences.getInstance()).getString(_key);

  Future<void> write(String? areaId) async {
    final preferences = await SharedPreferences.getInstance();
    if (areaId == null) {
      await preferences.remove(_key);
    } else {
      await preferences.setString(_key, areaId);
    }
  }
}

final waiterFollowMemoryProvider = Provider<WaiterFollowMemory>((ref) => const WaiterFollowMemory());

/// The waiter's phone: the tables of the branch, by area and state, with
/// guests, minutes seated and dishes waiting; a banner when a dish of the
/// phone's tables is ready. Tapping a table opens it or its order.
class WaiterScreen extends ConsumerStatefulWidget {
  const WaiterScreen({super.key});

  @override
  ConsumerState<WaiterScreen> createState() => _WaiterScreenState();
}

class _WaiterScreenState extends ConsumerState<WaiterScreen> {
  WaiterContext? _context;
  ReadyWatcher? _ready;

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionProvider).value;
    if (session is! Paired) return;
    final realtime = ref.read(realtimeProvider);
    final api = ref.read(waiterApiProvider);
    _context = WaiterContext(
      api: api,
      branchId: session.me.branch.id,
      deviceId: session.me.device.id,
      editorId: ref.read(waiterEditorIdProvider),
      baseUrl: session.serverUrl,
      events: realtime?.events ?? const Stream.empty(),
    );
    unawaited(_context!.menu.load());
    _ready = ReadyWatcher(api: api, onAnnounce: (_) => ref.read(waiterAlertProvider)());
    _startReady(realtime?.subscribed);
  }

  Future<void> _startReady(Stream<void>? subscribed) async {
    final area = await ref.read(waiterFollowMemoryProvider).read();
    _ready?.start(events: _context?.events, subscribed: subscribed, areaId: area);
  }

  @override
  void dispose() {
    _ready?.dispose();
    _context?.dispose();
    super.dispose();
  }

  Future<void> _follow(String? areaId) async {
    await ref.read(waiterFollowMemoryProvider).write(areaId);
    await _ready?.follow(areaId);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final waiter = _context;
    final ready = _ready;
    if (waiter == null || ready == null) {
      return const ModeScaffold(mode: AppMode.waiter, body: Center(child: CircularProgressIndicator()));
    }
    return TableBoard(
      waiter: waiter,
      ready: ready,
      onFollow: _follow,
    );
  }
}

/// The table grid with its filters and the ready banner.
class TableBoard extends StatefulWidget {
  const TableBoard({super.key, required this.waiter, required this.ready, required this.onFollow});

  final WaiterContext waiter;
  final ReadyWatcher ready;
  final Future<void> Function(String? areaId) onFollow;

  @override
  State<TableBoard> createState() => _TableBoardState();
}

class _TableBoardState extends State<TableBoard> {
  ResourceBoard? _board;
  TablePins _pins = TablePins();
  AppFailure? _failure;
  String? _areaId;
  TableFilter _filter = TableFilter.all;
  StreamSubscription<Map<String, Object?>>? _events;
  late final AppLifecycleListener _lifecycle;
  Future<void>? _inflight;
  bool _again = false;

  WaiterApi get _api => widget.waiter.api;

  static const _boardEvents = {
    'workspace.updated',
    'resource.updated',
    'payment.requested',
    'kitchen_ticket.updated',
  };

  @override
  void initState() {
    super.initState();
    _events = widget.waiter.events.listen((event) {
      if (_boardEvents.contains(event['event'])) unawaited(_refresh());
    });
    // A phone in a pocket loses its socket; coming back reads everything.
    _lifecycle = AppLifecycleListener(onResume: () {
      unawaited(_refresh());
      unawaited(widget.ready.refresh());
    });
    unawaited(_refresh());
  }

  @override
  void dispose() {
    _events?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

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
      final board = await _api.tables(widget.waiter.branchId);
      final pins = await _api.pins();
      if (!mounted) return;
      setState(() {
        _board = board;
        _pins = pins;
        _failure = null;
      });
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    }
  }

  Set<String> get _mine => {..._pins.pinned, ..._pins.serving};

  void _message(AppFailure failure) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(waiterFailureMessage(l10n, failure))));
  }

  Future<void> _openTile(ResourceBoardTile tile) async {
    final l10n = AppLocalizations.of(context);
    String? workspaceId;
    if (tile.orders.length == 1) {
      workspaceId = tile.orders.single.id;
    } else if (tile.orders.length > 1) {
      final picked = await showModalBottomSheet<String>(
        context: context,
        builder: (sheet) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text(l10n.waiterPickOrder(tile.name))),
              for (final (index, order) in tile.orders.indexed)
                ListTile(
                  key: Key('pick-order-${order.id}'),
                  minTileHeight: 64,
                  title: Text(order.tableLabel ?? l10n.waiterOrderLetter(String.fromCharCode(65 + index))),
                  subtitle: Text(l10n.waiterGuests(order.guestCount ?? 0)),
                  onTap: () => Navigator.of(sheet).pop(order.id),
                ),
            ],
          ),
        ),
      );
      if (picked == null) return;
      workspaceId = picked;
    }
    if (workspaceId == null) {
      if (!mounted) return;
      final guests = await askGuestCount(context, table: tile.name, capacity: tile.capacity);
      if (guests == null) return;
      try {
        final opened = await _api.open(widget.waiter.branchId, tile.id,
            editorId: widget.waiter.editorId, guestCount: guests);
        workspaceId = opened.id;
        unawaited(_refresh());
      } on AppFailure catch (failure) {
        if (mounted) _message(failure);
        unawaited(_refresh());
        return;
      }
    }
    await _show(workspaceId);
  }

  /// A second order on a busy table ("đơn B").
  Future<void> _openSecond(ResourceBoardTile tile) async {
    final guests = await askGuestCount(context, table: tile.name, capacity: tile.capacity);
    if (guests == null) return;
    try {
      final opened = await _api.open(widget.waiter.branchId, tile.id,
          editorId: widget.waiter.editorId, guestCount: guests, addOrder: true);
      unawaited(_refresh());
      await _show(opened.id);
    } on AppFailure catch (failure) {
      if (mounted) _message(failure);
    }
  }

  Future<void> _show(String workspaceId) async {
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => TableOrderScreen(waiter: widget.waiter, workspaceId: workspaceId),
    ));
    unawaited(_refresh());
  }

  Future<void> _tileMenu(ResourceBoardTile tile) async {
    final l10n = AppLocalizations.of(context);
    final pinned = _pins.pinned.contains(tile.id);
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(tile.name)),
            ListTile(
              key: Key('tile-pin-${tile.id}'),
              leading: Icon(pinned ? Icons.push_pin : Icons.push_pin_outlined),
              title: Text(pinned ? l10n.waiterUnpin : l10n.waiterPin),
              onTap: () => Navigator.of(sheet).pop('pin'),
            ),
            if (tile.orders.isNotEmpty)
              ListTile(
                key: Key('tile-second-${tile.id}'),
                leading: const Icon(Icons.add),
                title: Text(l10n.waiterSecondOrder),
                onTap: () => Navigator.of(sheet).pop('second'),
              ),
          ],
        ),
      ),
    );
    if (choice == 'pin') {
      try {
        final pins = await _api.pin(tile.id, pinned: !pinned);
        if (mounted) setState(() => _pins = pins);
        unawaited(widget.ready.refresh());
      } on AppFailure catch (failure) {
        if (mounted) _message(failure);
      }
    } else if (choice == 'second') {
      await _openSecond(tile);
    }
  }

  Future<void> _followMenu() async {
    final l10n = AppLocalizations.of(context);
    final board = _board;
    if (board == null) return;
    final current = widget.ready.areaId;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: Text(l10n.waiterFollowTitle), subtitle: Text(l10n.waiterFollowHint)),
            RadioListTile<String>(
              key: const Key('follow-mine'),
              value: '',
              groupValue: current ?? '',
              title: Text(l10n.waiterFollowMine),
              onChanged: (value) => Navigator.of(sheet).pop(value),
            ),
            for (final area in board.areas)
              RadioListTile<String>(
                key: Key('follow-${area.id}'),
                value: area.id,
                groupValue: current ?? '',
                title: Text(l10n.waiterFollowArea(area.name)),
                onChanged: (value) => Navigator.of(sheet).pop(value),
              ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    await widget.onFollow(choice.isEmpty ? null : choice);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final board = _board;
    return ModeScaffold(
      mode: AppMode.waiter,
      actions: [
        IconButton(
          key: const Key('waiter-follow'),
          tooltip: l10n.waiterFollowTitle,
          icon: Icon(widget.ready.areaId == null ? Icons.notifications_outlined : Icons.notifications_active),
          onPressed: _followMenu,
        ),
      ],
      body: Column(
        children: [
          _ReadyBanner(ready: widget.ready, onOpen: _show),
          if (board != null && board.areas.length > 1)
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                children: [
                  _chip(const Key('area-all'), l10n.waiterAllAreas, _areaId == null, () => setState(() => _areaId = null)),
                  for (final area in board.areas)
                    _chip(Key('area-${area.id}'), area.name, _areaId == area.id, () => setState(() => _areaId = area.id)),
                ],
              ),
            ),
          SizedBox(
            height: 56,
            child: ListView(
              key: const Key('table-filters'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              children: [
                for (final filter in TableFilter.values)
                  _chip(Key('filter-${filter.name}'), filterLabel(l10n, filter), _filter == filter,
                      () => setState(() => _filter = filter)),
              ],
            ),
          ),
          if (_failure != null)
            MaterialBanner(
              content: Text(waiterFailureMessage(l10n, _failure!)),
              actions: [TextButton(onPressed: _refresh, child: Text(l10n.retry))],
            ),
          Expanded(
            child: board == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(onRefresh: _refresh, child: _grid(board)),
          ),
        ],
      ),
    );
  }

  Widget _chip(Key key, String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(key: key, label: Text(label), selected: selected, onSelected: (_) => onTap()),
      );

  Widget _grid(ResourceBoard board) {
    final l10n = AppLocalizations.of(context);
    final mine = _mine;
    final tiles = board.resources
        .where((tile) => _areaId == null || tile.areaId == _areaId)
        .where((tile) => tableMatches(tile, _filter, mine))
        .toList();
    if (tiles.isEmpty) {
      return ListView(children: [Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(l10n.waiterNoTables)))]);
    }
    return GridView.builder(
      key: const Key('table-grid'),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return TableTile(
          tile: tile,
          pinned: _pins.pinned.contains(tile.id),
          onTap: () => _openTile(tile),
          onLongPress: () => _tileMenu(tile),
        );
      },
    );
  }
}

String filterLabel(AppLocalizations l10n, TableFilter filter) => switch (filter) {
      TableFilter.all => l10n.waiterFilterAll,
      TableFilter.free => l10n.waiterFilterFree,
      TableFilter.seated => l10n.waiterFilterSeated,
      TableFilter.waiting => l10n.waiterFilterWaiting,
      TableFilter.payment => l10n.waiterFilterPayment,
      TableFilter.mine => l10n.waiterFilterMine,
    };

/// One table: its name, state colour, guests, minutes seated and dishes
/// still to send to or come from the kitchen.
class TableTile extends StatelessWidget {
  const TableTile({super.key, required this.tile, required this.pinned, required this.onTap, required this.onLongPress});

  final ResourceBoardTile tile;
  final bool pinned;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (background, foreground) = switch (tile.state) {
      ResourceBoardTileStateEnum.available => (scheme.surfaceContainerHighest, scheme.onSurface),
      ResourceBoardTileStateEnum.paymentRequested ||
      ResourceBoardTileStateEnum.prebilled =>
        (Colors.amber.shade200, Colors.black),
      ResourceBoardTileStateEnum.waitingLong => (scheme.errorContainer, scheme.onErrorContainer),
      ResourceBoardTileStateEnum.cleaning || ResourceBoardTileStateEnum.outOfService => (scheme.outlineVariant, scheme.onSurface),
      _ => (scheme.primaryContainer, scheme.onPrimaryContainer),
    };
    final pending = tile.orders.fold(0, (sum, order) => sum + order.pendingKitchenItems);
    final requested = tile.paymentRequested || tile.orders.any((order) => order.paymentRequested);
    return Material(
      key: Key('table-${tile.id}'),
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: DefaultTextStyle(
            style: theme.textTheme.bodyMedium!.copyWith(color: foreground),
            // A small tile on a large font clips the last lines instead of
            // overflowing.
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tile.name,
                        style: theme.textTheme.titleLarge?.copyWith(color: foreground, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (pinned) Icon(Icons.push_pin, size: 18, color: foreground),
                  ],
                ),
                Text(tableStateLabel(l10n, tile.state)),
                const SizedBox(height: 4),
                if (tile.guestCount != null) Text(l10n.waiterGuests(tile.guestCount!)),
                if (tile.seatedMinutes != null) Text(l10n.waiterSeatedMinutes(tile.seatedMinutes!)),
                if (pending > 0)
                  Text(l10n.waiterPendingItems(pending), style: const TextStyle(fontWeight: FontWeight.w700)),
                if (requested) Text(l10n.waiterPaymentRequested, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (tile.orders.length > 1) Text(l10n.waiterOrders(tile.orders.length)),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}

String tableStateLabel(AppLocalizations l10n, ResourceBoardTileStateEnum state) => switch (state) {
      ResourceBoardTileStateEnum.available => l10n.waiterStateFree,
      ResourceBoardTileStateEnum.occupied => l10n.waiterStateSeated,
      ResourceBoardTileStateEnum.ordered => l10n.waiterStateOrdered,
      ResourceBoardTileStateEnum.waitingLong => l10n.waiterStateWaitingLong,
      ResourceBoardTileStateEnum.paymentRequested => l10n.waiterStatePayment,
      ResourceBoardTileStateEnum.prebilled => l10n.waiterStatePrebilled,
      ResourceBoardTileStateEnum.cleaning => l10n.waiterStateCleaning,
      ResourceBoardTileStateEnum.outOfService => l10n.waiterStateOut,
      _ => state.name,
    };

/// "Bàn 5: Phở bò ×2 đã xong", and how many dishes are ready in all.
/// Tapping it opens the table.
class _ReadyBanner extends StatelessWidget {
  const _ReadyBanner({required this.ready, required this.onOpen});

  final ReadyWatcher ready;
  final Future<void> Function(String workspaceId) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ValueListenableBuilder<ReadyNotice?>(
      valueListenable: ready.notice,
      builder: (context, notice, _) => ValueListenableBuilder<List<ReadyFeedItem>>(
        valueListenable: ready.ready,
        builder: (context, items, _) {
          if (notice == null && items.isEmpty) return const SizedBox.shrink();
          final target = notice?.item ?? items.first;
          final text = notice == null
              ? l10n.waiterReadyCount(items.length)
              : l10n.waiterReadyNotice(notice.table, notice.item.name, _quantity(notice.item.quantity));
          return Material(
            key: const Key('ready-banner'),
            color: Colors.green.shade700,
            child: InkWell(
              onTap: () {
                ready.dismiss();
                onOpen(target.workspaceId);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.room_service, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(text, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                    ),
                    if (notice != null)
                      IconButton(
                        key: const Key('ready-dismiss'),
                        tooltip: l10n.waiterClose,
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: ready.dismiss,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _quantity(String quantity) {
  final value = num.tryParse(quantity);
  if (value == null) return quantity;
  return value == value.truncate() ? value.truncate().toString() : value.toString();
}
