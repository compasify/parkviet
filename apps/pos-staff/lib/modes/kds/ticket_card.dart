import 'package:flutter/material.dart';
import 'package:pos_api/pos_api.dart';

import '../../l10n/app_localizations.dart';
import 'kds_grouping.dart';
import 'kds_repository.dart';

/// Kitchen buttons are pressed with wet or gloved hands.
const kdsButtonHeight = 56.0;

typedef ItemActionCallback = void Function(KitchenTicketItem item, KitchenAction action);

String serviceModeLabel(AppLocalizations l10n, String mode) => switch (mode) {
      'counter' => l10n.kdsModeCounter,
      'dine_in' => l10n.kdsModeDineIn,
      'takeaway' => l10n.kdsModeTakeaway,
      'delivery' => l10n.kdsModeDelivery,
      _ => mode,
    };

String statusLabel(AppLocalizations l10n, KitchenTicketItemStatusEnum status) => switch (status) {
      KitchenTicketItemStatusEnum.preparing => l10n.kdsStatusPreparing,
      KitchenTicketItemStatusEnum.ready => l10n.kdsStatusReady,
      KitchenTicketItemStatusEnum.served => l10n.kdsStatusServed,
      KitchenTicketItemStatusEnum.voided => l10n.kdsStatusVoided,
      _ => l10n.kdsStatusNew,
    };

/// The next step of an item on an open ticket, if it has one.
KitchenAction? nextAction(KitchenTicketItem item) => switch (item.status) {
      KitchenTicketItemStatusEnum.new_ => KitchenAction.start,
      KitchenTicketItemStatusEnum.preparing => KitchenAction.ready,
      KitchenTicketItemStatusEnum.ready => KitchenAction.serve,
      _ => null,
    };

String actionLabel(AppLocalizations l10n, KitchenAction action) => switch (action) {
      KitchenAction.start => l10n.kdsStart,
      KitchenAction.ready => l10n.kdsReady,
      KitchenAction.serve => l10n.kdsServe,
      KitchenAction.recall => l10n.kdsRecall,
    };

/// One ticket: its number, order, wait (coloured against the station's
/// thresholds) and items, each with its next step, and "bump" for all.
/// A finished ticket ([recall] true) offers recall on its ready items.
class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.ticket,
    required this.station,
    required this.now,
    required this.onAction,
    this.onBump,
    this.onServeOrder,
    this.showStation = false,
    this.recall = false,
  });

  final KitchenTicket ticket;
  final KitchenStation? station;
  final DateTime now;
  final ItemActionCallback onAction;
  final VoidCallback? onBump;

  /// Hands the whole order over at the counter, offered on a finished
  /// ticket that still has ready items.
  final VoidCallback? onServeOrder;
  final bool showStation;
  final bool recall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final urgency = recall ? TicketUrgency.normal : urgencyOf(ticket, station, now);
    final border = switch (urgency) {
      TicketUrgency.late => theme.colorScheme.error,
      TicketUrgency.warn => Colors.amber.shade700,
      TicketUrgency.normal => theme.colorScheme.outlineVariant,
    };
    final label = orderLabel(ticket);
    final note = headerText(ticket, 'note');
    final source = headerText(ticket, 'order_source');
    final guest = headerText(ticket, 'guest_name');
    final platform = platformLabel(l10n, source);
    final pickup = headerText(ticket, 'pickup_code');
    final handOver = recall && onServeOrder != null && ticket.items.any((item) => item.status == KitchenTicketItemStatusEnum.ready);
    return Card(
      key: Key('ticket-${ticket.id}'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border, width: urgency == TicketUrgency.normal ? 1 : 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    [
                      l10n.kdsTicketNumber(ticket.sequence),
                      ?label,
                      if (showStation) ticket.stationName,
                    ].join(' · '),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  recall ? '' : elapsedLabel(ticket.sentAt, now),
                  key: Key('ticket-timer-${ticket.id}'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: urgency == TicketUrgency.normal ? null : border,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              [serviceModeLabel(l10n, ticket.serviceMode), if (platform == null) ?source].join(' · '),
              style: theme.textTheme.bodyMedium,
            ),
            if (platform != null)
              _NoteBand(
                key: Key('ticket-platform-${ticket.id}'),
                text: [platform, if (pickup != null) l10n.kdsPickupCode(pickup)].join(' · '),
              ),
            if (guest != null)
              Text(
                l10n.kdsGuest(guest),
                key: Key('ticket-guest-${ticket.id}'),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            if (note != null) _NoteBand(text: l10n.kdsNote(note)),
            const Divider(),
            for (final item in ticket.items)
              if (!recall || item.status == KitchenTicketItemStatusEnum.ready || isOpen(item))
                ItemView(item: item, recall: recall, onAction: onAction),
            if (!recall && onBump != null && ticket.items.any(isOpen)) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: kdsButtonHeight,
                child: FilledButton.icon(
                  key: Key('bump-${ticket.id}'),
                  onPressed: onBump,
                  icon: const Icon(Icons.done_all),
                  label: Text(l10n.kdsBump, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ],
            if (handOver) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: kdsButtonHeight,
                child: FilledButton.icon(
                  key: Key('serve-order-${ticket.id}'),
                  onPressed: onServeOrder,
                  icon: const Icon(Icons.room_service_outlined),
                  label: Text(l10n.kdsServeOrder, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One item: quantity and name large, options, combo parts, the line note
/// white on black, and its next step.
class ItemView extends StatelessWidget {
  const ItemView({super.key, required this.item, required this.onAction, this.recall = false});

  final KitchenTicketItem item;
  final ItemActionCallback onAction;
  final bool recall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final action = recall
        ? (item.status == KitchenTicketItemStatusEnum.ready ? KitchenAction.recall : null)
        : nextAction(item);
    final finished = !isOpen(item);
    final options = modifiersLabel(item);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${quantityLabel(item.quantity)} x ${item.name}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    decoration: finished && !recall ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (options.isNotEmpty) Text('+ $options', style: theme.textTheme.bodyLarge),
                for (final part in item.components)
                  Text('- ${part.name} x${quantityLabel(part.quantity)}', style: theme.textTheme.bodyLarge),
                if (item.note != null && item.note!.isNotEmpty) _NoteBand(text: l10n.kdsNote(item.note!)),
                Text(statusLabel(l10n, item.status), style: theme.textTheme.labelMedium),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            SizedBox(
              height: kdsButtonHeight,
              child: action == KitchenAction.recall || action == KitchenAction.serve
                  ? OutlinedButton(
                      key: Key('item-${action.name}-${item.id}'),
                      onPressed: () => onAction(item, action),
                      child: Text(actionLabel(l10n, action), style: const TextStyle(fontSize: 18)),
                    )
                  : FilledButton.tonal(
                      key: Key('item-${action.name}-${item.id}'),
                      onPressed: () => onAction(item, action),
                      child: Text(actionLabel(l10n, action), style: const TextStyle(fontSize: 18)),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A note the kitchen must not miss, white on black like the printed ticket.
/// The delivery platform of a platform order, null for any other source.
String? platformLabel(AppLocalizations l10n, String? source) => switch (source) {
      'grabfood' => l10n.kdsPlatformGrabfood,
      'shopeefood' => l10n.kdsPlatformShopeefood,
      _ => null,
    };

class _NoteBand extends StatelessWidget {
  const _NoteBand({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: Colors.black,
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
      );
}
