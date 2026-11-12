import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_api/pos_api.dart';

import '../../../core/errors.dart';
import '../../../core/menu/modifier_sheet.dart' show money, moneyLabel;
import '../../../l10n/app_localizations.dart';
import '../waiter_messages.dart';
import 'guest_inbox.dart';

/// "Đơn từ QR" on the waiter's phone: what guests of the followed area (or
/// every area) ordered from the table QR and wait to have confirmed, and
/// their calls for staff or the bill. Accept adds the items to the table's
/// order and sends them to the kitchen; reject needs a reason the guest
/// reads on their phone.
class GuestOrdersScreen extends StatefulWidget {
  const GuestOrdersScreen({
    super.key,
    required this.inbox,
    required this.canDecide,
    this.followedAreaId,
  });

  final GuestInbox inbox;
  final bool canDecide;

  /// The area this phone follows for ready dishes; offered as "my area".
  final String? followedAreaId;

  @override
  State<GuestOrdersScreen> createState() => _GuestOrdersScreenState();
}

class _GuestOrdersScreenState extends State<GuestOrdersScreen> {
  bool _busy = false;

  GuestInbox get _inbox => widget.inbox;

  @override
  void initState() {
    super.initState();
    unawaited(_inbox.show(widget.followedAreaId ?? _inbox.areaId));
  }

  Future<void> _run(Future<String> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final text = await action();
      messenger.showSnackBar(SnackBar(content: Text(text)));
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(waiterFailureMessage(l10n, failure))),
      );
    } finally {
      await _inbox.refresh();
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject(GuestOrder order) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _RejectDialog(),
    );
    if (reason == null || reason.trim().isEmpty || !mounted) return;
    final l10n = AppLocalizations.of(context);
    await _run(() async {
      await _inbox.api.reject(order.id, reason.trim());
      return l10n.waiterGuestRejected(order.tableName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final followed = widget.followedAreaId;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.waiterGuestTitle)),
      body: RefreshIndicator(
        onRefresh: _inbox.refresh,
        child: ListenableBuilder(
          listenable: Listenable.merge([
            _inbox.orders,
            _inbox.requests,
            _inbox.failure,
          ]),
          builder: (context, _) {
            final orders = _inbox.orders.value;
            final requests = _inbox.requests.value;
            final failure = _inbox.failure.value;
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (followed != null)
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        key: const Key('guest-area-mine'),
                        label: Text(l10n.waiterGuestMyArea),
                        selected: _inbox.areaId == followed,
                        onSelected: (_) => unawaited(
                          _inbox.show(followed).then((_) => setState(() {})),
                        ),
                      ),
                      ChoiceChip(
                        key: const Key('guest-area-all'),
                        label: Text(l10n.waiterGuestAllAreas),
                        selected: _inbox.areaId == null,
                        onSelected: (_) => unawaited(
                          _inbox.show(null).then((_) => setState(() {})),
                        ),
                      ),
                    ],
                  ),
                if (failure != null)
                  MaterialBanner(
                    content: Text(waiterFailureMessage(l10n, failure)),
                    actions: [
                      TextButton(
                        onPressed: _inbox.refresh,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                if (!widget.canDecide && orders.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(l10n.waiterGuestNoDecide),
                  ),
                if (orders.isEmpty && requests.isEmpty && failure == null)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.waiterGuestEmpty,
                      textAlign: TextAlign.center,
                    ),
                  ),
                for (final request in requests)
                  Card(
                    key: Key('guest-request-${request.id}'),
                    child: ListTile(
                      leading: Icon(
                        request.kind == GuestRequestKindEnum.requestBill
                            ? Icons.receipt_outlined
                            : Icons.front_hand_outlined,
                      ),
                      title: Text(
                        request.kind == GuestRequestKindEnum.requestBill
                            ? l10n.waiterGuestRequestBill(request.tableName)
                            : l10n.waiterGuestCallStaff(request.tableName),
                      ),
                      trailing: TextButton(
                        key: Key('guest-done-${request.id}'),
                        onPressed: _busy
                            ? null
                            : () => _run(() async {
                                await _inbox.api.done(request.id);
                                return l10n.waiterGuestDone;
                              }),
                        child: Text(l10n.waiterGuestDone),
                      ),
                    ),
                  ),
                for (final order in orders)
                  _OrderCard(
                    order: order,
                    enabled: widget.canDecide && !_busy,
                    onAccept: () => _run(() async {
                      await _inbox.api.accept(order.id);
                      return l10n.waiterGuestAccepted(order.tableName);
                    }),
                    onReject: () => _reject(order),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.enabled,
    required this.onAccept,
    required this.onReject,
  });

  final GuestOrder order;
  final bool enabled;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      key: Key('guest-order-${order.id}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${order.tableName} · ${moneyLabel(money(order.quotedTotal))}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            for (final item in order.items)
              Text(
                [
                  '${item.quantity} × ${item.name}${item.size == null ? '' : ' (${item.size})'}',
                  if (item.modifiers.isNotEmpty)
                    item.modifiers
                        .map(
                          (pick) => pick.quantity > 1
                              ? '${pick.name} x${pick.quantity}'
                              : pick.name,
                        )
                        .join(', '),
                  if (item.note != null && item.note!.isNotEmpty) item.note!,
                ].join(' · '),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  key: Key('guest-reject-${order.id}'),
                  onPressed: enabled ? onReject : null,
                  child: Text(l10n.waiterGuestReject),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: Key('guest-accept-${order.id}'),
                  onPressed: enabled ? onAccept : null,
                  child: Text(l10n.waiterGuestAccept),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final presets = [
      l10n.waiterGuestRejectSoldOut,
      l10n.waiterGuestRejectKitchenClosed,
      l10n.waiterGuestRejectAskStaff,
    ];
    return AlertDialog(
      title: Text(l10n.waiterGuestRejectTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final preset in presets)
                ActionChip(
                  label: Text(preset),
                  onPressed: () => setState(() => _reason.text = preset),
                ),
            ],
          ),
          TextField(
            key: const Key('guest-reject-reason'),
            controller: _reason,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: l10n.waiterGuestRejectTitle,
              helperText: l10n.waiterGuestRejectHint,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('guest-reject-confirm'),
          onPressed: _reason.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_reason.text),
          child: Text(l10n.waiterGuestReject),
        ),
      ],
    );
  }
}
