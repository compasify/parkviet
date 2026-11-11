import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_api/pos_api.dart';

import '../../core/app_mode.dart';
import '../../core/errors.dart';
import '../../core/failure_messages.dart';
import '../../core/realtime_provider.dart';
import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../kds/kds_grouping.dart';
import '../kds/kds_repository.dart';
import '../kds/kds_screen.dart';
import '../kds/ticket_card.dart';
import '../mode_scaffold.dart';

/// The pass: the ready items waiting to go out, one card per table or
/// order, oldest first. "Đã ra" serves one item, "Ra cả đơn" every ready
/// item of the order; the waiter's phone hears it. A pass paired to an
/// expo station shows what the stations handing to it finished; without a
/// station it shows every station's ready items.
class ExpoScreen extends ConsumerStatefulWidget {
  const ExpoScreen({super.key});

  @override
  ConsumerState<ExpoScreen> createState() => _ExpoScreenState();
}

class _ExpoScreenState extends ConsumerState<ExpoScreen> {
  late final _keepAwake = ref.read(kdsKeepAwakeProvider);
  late final KdsController _controller;

  @override
  void initState() {
    super.initState();
    _keepAwake.enable().ignore();
    final session = ref.read(sessionProvider).value;
    final stationId = session is Paired ? session.me.device.kitchenStationId : null;
    final realtime = ref.read(realtimeProvider);
    _controller = KdsController(
      api: ref.read(kitchenApiProvider),
      stationIds: stationId == null ? null : [stationId],
      onNewTicket: ref.read(kdsChimeProvider),
    )..start(events: realtime?.events, subscribed: realtime?.subscribed, status: realtime?.status);
  }

  @override
  void dispose() {
    _keepAwake.disable().ignore();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ModeScaffold(mode: AppMode.expo, body: ExpoBoard(controller: _controller));
}

/// The ready items of a board's `expo`, by order.
class ExpoBoard extends StatefulWidget {
  const ExpoBoard({super.key, required this.controller, this.tick = const Duration(seconds: 1)});

  final KdsController controller;
  final Duration tick;

  @override
  State<ExpoBoard> createState() => _ExpoBoardState();
}

class _ExpoBoardState extends State<ExpoBoard> {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ValueListenableBuilder<KdsState>(
      valueListenable: widget.controller.state,
      builder: (context, state, _) {
        final board = state.board;
        if (board == null) return const Center(child: CircularProgressIndicator());
        final now = widget.controller.clock.now();
        return Column(
          children: [
            if (!state.live)
              Container(
                key: const Key('expo-offline'),
                width: double.infinity,
                color: theme.colorScheme.errorContainer,
                padding: const EdgeInsets.all(12),
                child: Text(l10n.kdsOfflineNever, style: theme.textTheme.titleMedium),
              ),
            Expanded(
              child: board.expo.isEmpty
                  ? Center(child: Text(l10n.expoNothingReady, style: const TextStyle(fontSize: 18)))
                  : ListView(
                      key: const Key('expo-orders'),
                      padding: const EdgeInsets.all(8),
                      children: [
                        for (final order in board.expo)
                          _ExpoOrderCard(
                            order: order,
                            now: now,
                            onServe: (item) => _run(() => widget.controller.act(item, KitchenAction.serve)),
                            onServeAll: () => _run(() => widget.controller.serveOrder(order.workspaceId)),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ExpoOrderCard extends StatelessWidget {
  const _ExpoOrderCard({required this.order, required this.now, required this.onServe, required this.onServeAll});

  final KitchenExpoOrder order;
  final DateTime now;
  final void Function(KitchenTicketItem item) onServe;
  final VoidCallback onServeAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final label = headerLabel((key) => order.header[key]?.value) ?? l10n.kdsOrder(order.workspaceId);
    final since = order.readySince;
    return Card(
      key: Key('expo-${order.workspaceId}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$label · ${serviceModeLabel(l10n, order.serviceMode)}',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (since != null)
                  Text(elapsedLabel(since, now), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const Divider(),
            for (final row in order.items)
              ListTile(
                key: Key('expo-item-${row.item.id}'),
                minTileHeight: kdsButtonHeight,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${quantityLabel(row.item.quantity)} x ${row.item.name}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  [
                    if (modifiersLabel(row.item).isNotEmpty) '+ ${modifiersLabel(row.item)}',
                    row.stationName,
                  ].join(' · '),
                ),
                trailing: SizedBox(
                  height: kdsButtonHeight,
                  child: OutlinedButton(
                    key: Key('expo-serve-${row.item.id}'),
                    onPressed: () => onServe(row.item),
                    child: Text(l10n.kdsServe, style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              height: kdsButtonHeight,
              child: FilledButton.icon(
                key: Key('expo-serve-all-${order.workspaceId}'),
                onPressed: onServeAll,
                icon: const Icon(Icons.room_service_outlined),
                label: Text(l10n.expoServeAll, style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
