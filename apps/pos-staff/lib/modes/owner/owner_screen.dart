import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_api/pos_api.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/app_mode.dart';
import '../../core/approval_requests.dart';
import '../../core/errors.dart';
import '../../core/menu/modifier_sheet.dart';
import '../../core/realtime.dart';
import '../../core/realtime_provider.dart';
import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../mode_scaffold.dart';
import '../waiter/waiter_messages.dart';
import 'owner_device.dart';
import 'owner_home.dart';
import 'owner_watch_api.dart';

/// What the owner's phone asks of the server about bookings, as the person
/// signed in with their PIN: the day's bookings, a booking confirmed with the guest or canceled,
/// and a deposit refunded or kept. The owner may grant approvals, so a deposit asks for no code;
/// anyone else is refused with `approval_required`.
abstract interface class OwnerApi {
  Future<List<Reservation>> reservations(String branchId);

  Future<Reservation> confirm(String reservationId);

  Future<Reservation> cancel(String reservationId);

  Future<Reservation> refundDeposit(String depositId);

  Future<Reservation> forfeitDeposit(String depositId);
}

class ApiOwnerApi implements OwnerApi {
  ApiOwnerApi(this.client, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  final PosApiClient client;
  final Uuid _uuid;

  @override
  Future<List<Reservation>> reservations(String branchId) async =>
      (await client.call((api) => api.posReservationList(branchId: branchId))).data.toList();

  @override
  Future<Reservation> confirm(String reservationId) async => (await client.call(
    (api) => api.posReservationConfirm(idempotencyKey: _uuid.v4(), id: reservationId),
  )).data;

  @override
  Future<Reservation> cancel(String reservationId) async => (await client.call(
    (api) => api.posReservationCancel(
      idempotencyKey: _uuid.v4(),
      id: reservationId,
      reservationCancelInput: ReservationCancelInput((b) => b.status = ReservationCancelInputStatusEnum.canceled),
    ),
  )).data;

  @override
  Future<Reservation> refundDeposit(String depositId) async => (await client.call(
    (api) => api.posReservationDepositRefund(
      idempotencyKey: _uuid.v4(),
      depositId: depositId,
      reservationDepositResolveInput: ReservationDepositResolveInput(),
    ),
  )).data;

  @override
  Future<Reservation> forfeitDeposit(String depositId) async => (await client.call(
    (api) => api.posReservationDepositForfeit(
      idempotencyKey: _uuid.v4(),
      depositId: depositId,
      reservationDepositResolveInput: ReservationDepositResolveInput(),
    ),
  )).data;
}

final ownerApiProvider = Provider<OwnerApi>((ref) => ApiOwnerApi(ref.watch(apiClientProvider)));

/// A deposit that may still be given back: held, or applied with money left.
bool refundable(Reservation reservation, ReservationDeposit deposit) =>
    reservation.status != ReservationStatusEnum.seated &&
    (deposit.status == ReservationDepositStatusEnum.held || deposit.status == ReservationDepositStatusEnum.applied) &&
    money(deposit.available) > 0;

/// Only the deposit of a canceled or no-show booking is kept.
bool forfeitable(Reservation reservation, ReservationDeposit deposit) =>
    (reservation.status == ReservationStatusEnum.canceled || reservation.status == ReservationStatusEnum.noShow) &&
    deposit.status == ReservationDepositStatusEnum.held;

class OwnerScreen extends ConsumerWidget {
  const OwnerScreen({super.key, this.initialTab = OwnerTab.today});

  /// The tab a notification opens.
  final OwnerTab initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    return ModeScaffold(
      mode: AppMode.owner,
      body: session is Paired
          ? OwnerHome(
              watch: ref.read(ownerWatchApiProvider),
              approvals: ref.read(approvalRequestsApiProvider),
              reservations: ref.read(ownerApiProvider),
              confirmation: ref.read(approverConfirmationProvider),
              pushTokens: ref.read(pushTokenSourceProvider),
              initialTab: initialTab,
              eventsFor: (branchId) => _eventsFor(ref, session, branchId),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  // The paired branch shares the device's stream; another branch the owner
  // watches gets its own, which the server allows an owner device.
  static BranchEvents _eventsFor(WidgetRef ref, Paired session, String branchId) {
    final shared = ref.read(realtimeProvider);
    if (branchId == session.me.branch.id) return BranchEvents(shared?.events ?? const Stream.empty());
    final credentials = ref.read(credentialsProvider);
    final client = ActionCableClient(
      uri: cableUri(session.serverUrl),
      protocols: () => deviceProtocols(
        credentials.deviceToken ?? '',
        staffSessionToken: credentials.staffSessionToken,
      ),
      identifier: {'channel': 'Spree::Pos::BranchChannel', 'branch_id': branchId},
    );
    client.start();
    return BranchEvents(client.events, client.dispose);
  }
}

/// The day's bookings of the branch, with their deposits. Someone who books at the branch also
/// confirms a waiting booking with the guest or cancels it.
class OwnerReservations extends StatefulWidget {
  const OwnerReservations({super.key, required this.api, required this.branchId, this.canManage = false});

  final OwnerApi api;
  final String branchId;
  final bool canManage;

  @override
  State<OwnerReservations> createState() => _OwnerReservationsState();
}

class _OwnerReservationsState extends State<OwnerReservations> {
  List<Reservation>? _rows;
  AppFailure? _failure;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final rows = await widget.api.reservations(widget.branchId);
      if (mounted) setState(() => (_rows = rows, _failure = null));
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    }
  }

  Future<void> _resolve(Reservation reservation, ReservationDeposit deposit, {required bool refund}) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final amount = moneyLabel(money(deposit.available));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        content: Text(
          refund
              ? l10n.ownerConfirmRefund(amount, reservation.guestName)
              : l10n.ownerConfirmForfeit(amount, reservation.guestName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: Text(l10n.ownerKeep)),
          FilledButton(
            key: const Key('owner-confirm'),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.ownerConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      final updated = refund ? await widget.api.refundDeposit(deposit.id) : await widget.api.forfeitDeposit(deposit.id);
      if (!mounted) return;
      setState(() => _rows = [for (final row in _rows ?? const <Reservation>[]) row.id == updated.id ? updated : row]);
      messenger.showSnackBar(SnackBar(content: Text(refund ? l10n.ownerRefunded : l10n.ownerForfeited)));
    } on AppFailure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(waiterFailureMessage(l10n, failure))));
      unawaited(_load());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _change(Reservation reservation, {required bool cancel}) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (cancel) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          content: Text(l10n.ownerReservationCancelAsk(reservation.guestName, clockLabel(reservation.startsAt))),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: Text(l10n.ownerKeep)),
            FilledButton(
              key: const Key('owner-reservation-cancel-confirm'),
              onPressed: () => Navigator.of(dialog).pop(true),
              child: Text(l10n.ownerReservationCancel),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      final updated = cancel ? await widget.api.cancel(reservation.id) : await widget.api.confirm(reservation.id);
      if (!mounted) return;
      setState(() => _rows = [for (final row in _rows ?? const <Reservation>[]) row.id == updated.id ? updated : row]);
      messenger.showSnackBar(
        SnackBar(content: Text(cancel ? l10n.ownerReservationCancelDone : l10n.ownerReservationConfirmDone)),
      );
    } on AppFailure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(reservationFailureMessage(l10n, failure))));
      unawaited(_load());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = _rows;
    if (rows == null) {
      return Center(
        child: _failure == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(waiterFailureMessage(l10n, _failure!)),
                  TextButton(onPressed: _load, child: Text(l10n.retry)),
                ],
              ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        key: const Key('owner-reservations'),
        children: [
          ListTile(title: Text(l10n.ownerReservationsTitle, style: Theme.of(context).textTheme.titleLarge)),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(l10n.ownerNoReservations)),
            ),
          for (final reservation in rows)
            _ReservationCard(
              reservation: reservation,
              busy: _busy,
              canManage: widget.canManage,
              onConfirm: () => _change(reservation, cancel: false),
              onCancel: () => _change(reservation, cancel: true),
              onRefund: (deposit) => _resolve(reservation, deposit, refund: true),
              onForfeit: (deposit) => _resolve(reservation, deposit, refund: false),
            ),
        ],
      ),
    );
  }
}

/// HH:mm of a time on this phone.
String clockLabel(DateTime at) {
  final local = at.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

String reservationFailureMessage(AppLocalizations l10n, AppFailure failure) => switch (failure) {
  ConflictFailure(reason: 'reservation_not_booked') => l10n.ownerReservationNotWaiting,
  _ => waiterFailureMessage(l10n, failure),
};

String reservationStatusLabel(AppLocalizations l10n, ReservationStatusEnum status) => switch (status) {
  ReservationStatusEnum.seated => l10n.reservationSeated,
  ReservationStatusEnum.completed => l10n.reservationCompleted,
  ReservationStatusEnum.noShow => l10n.reservationNoShow,
  ReservationStatusEnum.canceled => l10n.reservationCanceled,
  _ => l10n.reservationBooked,
};

String depositStatusLabel(AppLocalizations l10n, ReservationDepositStatusEnum status) => switch (status) {
  ReservationDepositStatusEnum.applied => l10n.depositApplied,
  ReservationDepositStatusEnum.refunded => l10n.depositRefunded,
  ReservationDepositStatusEnum.forfeited => l10n.depositForfeited,
  _ => l10n.depositHeld,
};

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.busy,
    required this.canManage,
    required this.onConfirm,
    required this.onCancel,
    required this.onRefund,
    required this.onForfeit,
  });

  final Reservation reservation;
  final bool busy;
  final bool canManage;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final void Function(ReservationDeposit deposit) onRefund;
  final void Function(ReservationDeposit deposit) onForfeit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final time = clockLabel(reservation.startsAt);
    final waiting = reservation.status == ReservationStatusEnum.booked;
    return Card(
      key: Key('owner-reservation-${reservation.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$time · ${reservation.guestName} · ${l10n.waiterGuests(reservation.partySize)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              [
                reservationStatusLabel(l10n, reservation.status),
                if (waiting && reservation.confirmedAt != null) l10n.ownerReservationConfirmed,
                ...reservation.resources.map((row) => row.name),
              ].join(' · '),
            ),
            if (canManage && waiting)
              Wrap(
                spacing: 8,
                children: [
                  if (reservation.confirmedAt == null)
                    FilledButton.tonal(
                      key: Key('owner-reservation-confirm-${reservation.id}'),
                      onPressed: busy ? null : onConfirm,
                      child: Text(l10n.ownerReservationConfirm),
                    ),
                  OutlinedButton(
                    key: Key('owner-reservation-cancel-${reservation.id}'),
                    onPressed: busy ? null : onCancel,
                    child: Text(l10n.ownerReservationCancel),
                  ),
                ],
              ),
            for (final deposit in reservation.deposits) ...[
              const SizedBox(height: 4),
              Text(l10n.ownerDeposit(moneyLabel(money(deposit.amount)), depositStatusLabel(l10n, deposit.status))),
              Wrap(
                spacing: 8,
                children: [
                  if (refundable(reservation, deposit))
                    OutlinedButton(
                      key: Key('owner-refund-${deposit.id}'),
                      onPressed: busy ? null : () => onRefund(deposit),
                      child: Text(l10n.ownerRefund),
                    ),
                  if (forfeitable(reservation, deposit))
                    FilledButton.tonal(
                      key: Key('owner-forfeit-${deposit.id}'),
                      onPressed: busy ? null : () => onForfeit(deposit),
                      child: Text(l10n.ownerForfeit),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
