import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_api/pos_api.dart';

import '../../core/errors.dart';
import '../../core/failure_messages.dart';
import '../../l10n/app_localizations.dart';
import 'kds_grouping.dart';
import 'kds_repository.dart';
import 'ticket_card.dart';

/// The board of the chosen stations, or of every station: three ways to
/// read the open tickets (oldest first with late ones on top, all-day by
/// dish, by order) and "Đã xong gần đây", the tickets finished in the last
/// 30 minutes, for recall or for handing the order over. Shows a banner
/// with the last update while the server cannot be reached.
class KdsBoard extends StatefulWidget {
  const KdsBoard({super.key, required this.controller, this.onSoldOut, this.tick = const Duration(seconds: 1)});

  final KdsController controller;

  /// "Hết món" for the dish of an item, offered when an item is held.
  final ItemSoldOutCallback? onSoldOut;

  /// How often the timers move.
  final Duration tick;

  @override
  State<KdsBoard> createState() => _KdsBoardState();
}

class _KdsBoardState extends State<KdsBoard> {
  late final Timer _ticker = Timer.periodic(widget.tick, (_) => setState(() {}));

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  Future<void> _run(Future<AppFailure?> Function() change) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final failure = await change();
    if (failure != null && mounted) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.kdsActionFailed(failureMessage(l10n, failure)))));
    }
  }

  void _onAction(KitchenTicketItem item, KitchenAction action) => _run(() => widget.controller.act(item, action));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<KdsState>(
      valueListenable: widget.controller.state,
      builder: (context, state, _) {
        final board = state.board;
        final now = widget.controller.clock.now();
        return Column(
          children: [
            if (!state.live) _OfflineBanner(lastSync: state.lastSync),
            TabBar(
              tabs: [
                Tab(key: const Key('kds-tab-priority'), text: l10n.kdsTabPriority),
                Tab(key: const Key('kds-tab-items'), text: l10n.kdsTabByItem),
                Tab(key: const Key('kds-tab-orders'), text: l10n.kdsTabByOrder),
              ],
            ),
            Expanded(
              child: board == null
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _PriorityView(
                          board: board,
                          now: now,
                          onAction: _onAction,
                          onSoldOut: widget.onSoldOut,
                          onBump: _bump,
                          onServeOrder: _serveOrder,
                        ),
                        _AllDayView(board: board, onBump: _bumpAllDay),
                        _OrdersView(
                          board: board,
                          now: now,
                          onAction: _onAction,
                          onSoldOut: widget.onSoldOut,
                          onBump: _bump,
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  void _bump(KitchenTicket ticket) => _run(() => widget.controller.bump(ticket));

  void _bumpAllDay(KitchenAllDayRow row, int quantity) => _run(() => widget.controller.bumpAllDay(row, quantity));

  void _serveOrder(KitchenTicket ticket) => _run(() => widget.controller.serveOrder(ticket.workspaceId));
}

String _shortId(String id) => id.length > 4 ? id.substring(id.length - 4) : id;

KitchenStation? _stationOf(KitchenBoard board, KitchenTicket ticket) {
  for (final station in board.stations) {
    if (station.id == ticket.kitchenStationId) return station;
  }
  return board.station;
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.lastSync});

  final DateTime? lastSync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      key: const Key('kds-offline'),
      width: double.infinity,
      color: theme.colorScheme.errorContainer,
      padding: const EdgeInsets.all(12),
      child: Text(
        lastSync == null ? l10n.kdsOfflineNever : l10n.kdsOffline(DateFormat.Hms().format(lastSync!)),
        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onErrorContainer),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(text, style: const TextStyle(fontSize: 18))));
}

/// Wide screens show tickets side by side; a phone shows one column.
class _TicketGrid extends StatelessWidget {
  const _TicketGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = (constraints.maxWidth / 360).floor().clamp(1, 4);
          final width = (constraints.maxWidth - 16 - (columns - 1) * 8) / columns;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final child in children) SizedBox(width: width, child: child)],
          );
        },
      );
}

class _PriorityView extends StatelessWidget {
  const _PriorityView({
    required this.board,
    required this.now,
    required this.onAction,
    required this.onSoldOut,
    required this.onBump,
    required this.onServeOrder,
  });

  final KitchenBoard board;
  final DateTime now;
  final ItemActionCallback onAction;
  final ItemSoldOutCallback? onSoldOut;
  final void Function(KitchenTicket ticket) onBump;
  final void Function(KitchenTicket ticket) onServeOrder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final all = board.station == null;
    return ListView(
      key: const Key('kds-priority'),
      padding: const EdgeInsets.all(8),
      children: [
        if (board.open.isEmpty) _Empty(l10n.kdsNothingOpen),
        _TicketGrid(
          children: [
            for (final ticket in board.open)
              TicketCard(
                ticket: ticket,
                station: _stationOf(board, ticket),
                now: now,
                showStation: all,
                onAction: onAction,
                onSoldOut: onSoldOut,
                onBump: () => onBump(ticket),
              ),
          ],
        ),
        ExpansionTile(
          key: const Key('kds-done'),
          title: Text('${l10n.kdsDone} (${board.done.length})'),
          subtitle: Text(l10n.kdsDoneHint),
          children: [
            if (board.done.isEmpty) _Empty(l10n.kdsNothingDone),
            _TicketGrid(
              children: [
                for (final ticket in board.done)
                  TicketCard(
                    ticket: ticket,
                    station: _stationOf(board, ticket),
                    now: now,
                    showStation: all,
                    recall: true,
                    onAction: onAction,
                    onServeOrder: () => onServeOrder(ticket),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Every open dish added up across tickets by the server (`all_day`), to
/// cook in batches. "Xong 1" makes the oldest unit ready; "Xong hết" the
/// whole batch, first sent first.
class _AllDayView extends StatelessWidget {
  const _AllDayView({required this.board, required this.onBump});

  final KitchenBoard board;
  final void Function(KitchenAllDayRow row, int quantity) onBump;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final rows = board.allDay.toList()
      ..sort((a, b) {
        final byQuantity = (num.tryParse(b.quantity) ?? 0).compareTo(num.tryParse(a.quantity) ?? 0);
        return byQuantity != 0 ? byQuantity : a.oldestSentAt.compareTo(b.oldestSentAt);
      });
    if (rows.isEmpty) return _Empty(l10n.kdsNothingOpen);
    return ListView.separated(
      key: const Key('kds-items'),
      padding: const EdgeInsets.all(8),
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final row = rows[index];
        final total = (num.tryParse(row.quantity) ?? 1).ceil().clamp(1, 99);
        final options = allDayModifiersLabel(row);
        return ListTile(
          key: Key('tally-$index'),
          minTileHeight: kdsButtonHeight + 16,
          title: Text(
            '${quantityLabel(row.quantity)} x ${row.name}',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: options.isEmpty
              ? null
              : Text('+ $options', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
          trailing: Wrap(
            spacing: 8,
            children: [
              SizedBox(
                height: kdsButtonHeight,
                child: FilledButton.tonal(
                  key: Key('all-day-one-$index'),
                  onPressed: () => onBump(row, 1),
                  child: Text(l10n.kdsAllDayOne, style: const TextStyle(fontSize: 18)),
                ),
              ),
              if (total > 1)
                SizedBox(
                  height: kdsButtonHeight,
                  child: FilledButton(
                    key: Key('all-day-all-$index'),
                    onPressed: () => onBump(row, total),
                    child: Text(l10n.kdsAllDayAll(total), style: const TextStyle(fontSize: 18)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Open tickets by table, call number or order, the longest waiting first.
class _OrdersView extends StatelessWidget {
  const _OrdersView({
    required this.board,
    required this.now,
    required this.onAction,
    required this.onSoldOut,
    required this.onBump,
  });

  final KitchenBoard board;
  final DateTime now;
  final ItemActionCallback onAction;
  final ItemSoldOutCallback? onSoldOut;
  final void Function(KitchenTicket ticket) onBump;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final groups = groupByOrder(board.open);
    if (groups.isEmpty) return _Empty(l10n.kdsNothingOpen);
    return ListView(
      key: const Key('kds-orders'),
      padding: const EdgeInsets.all(8),
      children: [
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
            child: Text(
              group.label ?? l10n.kdsOrder(_shortId(group.workspaceId)),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _TicketGrid(
            children: [
              for (final ticket in group.tickets)
                TicketCard(
                  ticket: ticket,
                  station: _stationOf(board, ticket),
                  now: now,
                  showStation: board.station == null,
                  onAction: onAction,
                  onSoldOut: onSoldOut,
                  onBump: () => onBump(ticket),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
