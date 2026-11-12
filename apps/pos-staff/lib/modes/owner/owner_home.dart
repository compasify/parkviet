import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_api/pos_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/approval_requests.dart';
import '../../core/errors.dart';
import '../../core/menu/modifier_sheet.dart';
import '../../l10n/app_localizations.dart';
import '../kds/ticket_card.dart' show platformLabel;
import '../waiter/waiter_messages.dart';
import 'owner_device.dart';
import 'owner_screen.dart';
import 'owner_watch_api.dart';

/// One branch's events while the owner watches it; closed when another
/// branch is chosen.
class BranchEvents {
  BranchEvents(this.events, [this._close]);

  final Stream<Map<String, Object?>> events;
  final void Function()? _close;

  void close() => _close?.call();
}

/// The branch the owner last watched, kept on the phone.
class OwnerBranchMemory {
  const OwnerBranchMemory();

  static const _key = 'owner.branch_id';

  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  Future<void> write(String branchId) async =>
      (await SharedPreferences.getInstance()).setString(_key, branchId);
}

/// The tabs of the owner's phone.
enum OwnerTab { today, open, approvals, reservations, alerts }

/// The owner's phone: a branch at a time, its day so far, its open orders,
/// the approvals waiting for the owner, its bookings and its alerts. Each
/// refreshes on the branch's events while the app is open.
class OwnerHome extends StatefulWidget {
  const OwnerHome({
    super.key,
    required this.watch,
    required this.approvals,
    required this.reservations,
    required this.confirmation,
    required this.pushTokens,
    required this.eventsFor,
    this.memory = const OwnerBranchMemory(),
    this.initialTab = OwnerTab.today,
  });

  final OwnerWatchApi watch;
  final ApprovalRequestsApi approvals;
  final OwnerApi reservations;
  final ApproverConfirmation confirmation;
  final PushTokenSource pushTokens;
  final BranchEvents Function(String branchId) eventsFor;
  final OwnerBranchMemory memory;

  /// Opened from a notification about an approval, the approvals tab.
  final OwnerTab initialTab;

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: OwnerTab.values.length,
    vsync: this,
    initialIndex: widget.initialTab.index,
  );
  List<OwnerBranch>? _branches;
  OwnerBranch? _branch;
  AppFailure? _failure;
  OwnerToday? _today;
  List<OwnerOpenUnit>? _open;
  List<ApprovalRequest>? _pending;
  List<OwnerAlert>? _alerts;
  BranchEvents? _events;
  StreamSubscription<Map<String, Object?>>? _subscription;
  Timer? _debounce;
  final Set<String> _deciding = {};

  @override
  void initState() {
    super.initState();
    unawaited(_loadBranches());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    unawaited(_subscription?.cancel());
    _events?.close();
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    try {
      final branches = await widget.watch.branches();
      final remembered = await widget.memory.read();
      if (!mounted) return;
      setState(() {
        _branches = branches;
        _failure = null;
      });
      if (branches.isEmpty) return;
      _select(
        branches.firstWhere(
          (row) => row.id == remembered,
          orElse: () => branches.first,
        ),
      );
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    }
  }

  void _select(OwnerBranch branch) {
    unawaited(widget.memory.write(branch.id));
    unawaited(_subscription?.cancel());
    _events?.close();
    setState(() {
      _branch = branch;
      _today = null;
      _open = null;
      _pending = null;
      _alerts = null;
    });
    _events = widget.eventsFor(branch.id);
    _subscription = _events!.events.listen(_onEvent);
    unawaited(_refresh());
  }

  void _onEvent(Map<String, Object?> event) {
    switch (event['event']) {
      case 'approval_request.created' || 'approval_request.updated':
        unawaited(_loadPending());
      case 'owner_alert.created':
        unawaited(_loadAlerts());
      case 'workspace.updated' || 'kitchen_ticket.updated':
        // A busy floor sends many; one read after they settle.
        _debounce?.cancel();
        _debounce = Timer(
          const Duration(seconds: 2),
          () => unawaited(_loadDay()),
        );
    }
  }

  Future<void> _refresh() =>
      Future.wait([_loadDay(), _loadPending(), _loadAlerts()]);

  Future<void> _guard(Future<void> Function(OwnerBranch branch) load) async {
    final branch = _branch;
    if (branch == null) return;
    try {
      await load(branch);
    } on AppFailure catch (failure) {
      if (mounted && _branch?.id == branch.id) {
        setState(() => _failure = failure);
      }
    }
  }

  Future<void> _loadDay() => _guard((branch) async {
    if (!branch.canReadReports) return;
    final today = await widget.watch.today(branch.id);
    final open = await widget.watch.openUnits(branch.id);
    if (mounted && _branch?.id == branch.id) {
      setState(() => (_today = today, _open = open, _failure = null));
    }
  });

  Future<void> _loadPending() => _guard((branch) async {
    if (!branch.canApprove) return;
    final pending = await widget.approvals.pending(branch.id);
    if (mounted && _branch?.id == branch.id) setState(() => _pending = pending);
  });

  Future<void> _loadAlerts() => _guard((branch) async {
    if (!branch.canReadReports) return;
    final alerts = await widget.watch.alerts(branch.id);
    if (mounted && _branch?.id == branch.id) setState(() => _alerts = alerts);
  });

  Future<void> _grant(ApprovalRequest request) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final check = await widget.confirmation.confirm(
      l10n.ownerGrantBiometricReason,
    );
    if (!mounted) return;
    if (check == ApproverCheck.failed) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.ownerGrantNotConfirmed)),
      );
      return;
    }
    if (check == ApproverCheck.unavailable) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          content: Text(
            l10n.ownerGrantConfirm(approvalActionLabel(l10n, request.action)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialog).pop(false),
              child: Text(l10n.ownerKeep),
            ),
            FilledButton(
              key: const Key('owner-grant-confirm'),
              onPressed: () => Navigator.of(dialog).pop(true),
              child: Text(l10n.ownerGrant),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    await _decide(request, () => widget.approvals.grant(request.id));
  }

  Future<void> _decline(ApprovalRequest request) async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => const _DeclineDialog(),
    );
    if (text == null || !mounted) return;
    await _decide(
      request,
      () => widget.approvals.decline(
        request.id,
        reason: text.isEmpty ? null : text,
      ),
    );
  }

  Future<void> _decide(
    ApprovalRequest request,
    Future<ApprovalRequest> Function() call,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _deciding.add(request.id));
    try {
      final decided = await call();
      messenger.showSnackBar(
        SnackBar(content: Text(approvalOutcomeLabel(l10n, decided.status))),
      );
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(ownerFailureMessage(l10n, failure))),
      );
    } finally {
      if (mounted) setState(() => _deciding.remove(request.id));
    }
    await _loadPending();
  }

  Future<void> _openPush() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) =>
          OwnerPushSheet(watch: widget.watch, tokens: widget.pushTokens),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final branches = _branches;
    if (branches == null) {
      return Center(
        child: _failure == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ownerFailureMessage(l10n, _failure!)),
                  TextButton(onPressed: _loadBranches, child: Text(l10n.retry)),
                ],
              ),
      );
    }
    final branch = _branch;
    if (branch == null) {
      return Center(
        child: Text(l10n.ownerNoBranches, key: const Key('owner-no-branches')),
      );
    }
    final pendingCount = _pending?.length ?? 0;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
          child: Row(
            children: [
              Expanded(
                child: branches.length == 1
                    ? Text(
                        branch.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    : DropdownButton<String>(
                        key: const Key('owner-branch'),
                        isExpanded: true,
                        value: branch.id,
                        items: [
                          for (final row in branches)
                            DropdownMenuItem(
                              value: row.id,
                              child: Text(row.name),
                            ),
                        ],
                        onChanged: (id) {
                          if (id != null && id != branch.id) {
                            _select(branches.firstWhere((row) => row.id == id));
                          }
                        },
                      ),
              ),
              IconButton(
                key: const Key('owner-push'),
                tooltip: l10n.ownerPushTitle,
                onPressed: _openPush,
                icon: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: [
            Tab(key: const Key('owner-tab-today'), text: l10n.ownerTabToday),
            Tab(key: const Key('owner-tab-open'), text: l10n.ownerTabOpen),
            Tab(
              key: const Key('owner-tab-approvals'),
              child: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: Text(l10n.ownerTabApprovals),
              ),
            ),
            Tab(
              key: const Key('owner-tab-reservations'),
              text: l10n.ownerTabReservations,
            ),
            Tab(key: const Key('owner-tab-alerts'), text: l10n.ownerTabAlerts),
          ],
        ),
        if (_failure != null)
          MaterialBanner(
            content: Text(ownerFailureMessage(l10n, _failure!)),
            actions: [TextButton(onPressed: _refresh, child: Text(l10n.retry))],
          ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _Refreshable(
                onRefresh: _loadDay,
                child: !branch.canReadReports
                    ? _Note(l10n.ownerNoReports)
                    : _today == null
                    ? const _Loading()
                    : OwnerTodayView(today: _today!),
              ),
              _Refreshable(
                onRefresh: _loadDay,
                child: !branch.canReadReports
                    ? _Note(l10n.ownerNoReports)
                    : _open == null
                    ? const _Loading()
                    : OwnerOpenUnitsView(units: _open!),
              ),
              _Refreshable(
                onRefresh: _loadPending,
                child: !branch.canApprove
                    ? _Note(l10n.ownerNoApprove)
                    : _pending == null
                    ? const _Loading()
                    : _pending!.isEmpty
                    ? _Note(l10n.ownerNoPending)
                    : Column(
                        children: [
                          for (final request in _pending!)
                            ApprovalRequestCard(
                              request: request,
                              busy: _deciding.contains(request.id),
                              onGrant: () => _grant(request),
                              onDecline: () => _decline(request),
                            ),
                        ],
                      ),
              ),
              OwnerReservations(
                key: ValueKey('reservations-${branch.id}'),
                api: widget.reservations,
                branchId: branch.id,
              ),
              _Refreshable(
                onRefresh: _loadAlerts,
                child: !branch.canReadReports
                    ? _Note(l10n.ownerNoReports)
                    : _alerts == null
                    ? const _Loading()
                    : _alerts!.isEmpty
                    ? _Note(l10n.ownerNoAlerts)
                    : Column(
                        children: [
                          for (final alert in _alerts!)
                            OwnerAlertTile(alert: alert),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Why the owner says no, optional. Answers the reason, empty for none, or
/// null when the owner keeps the request.
class _DeclineDialog extends StatefulWidget {
  const _DeclineDialog();

  @override
  State<_DeclineDialog> createState() => _DeclineDialogState();
}

class _DeclineDialogState extends State<_DeclineDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.ownerDeclineTitle),
      content: TextField(
        key: const Key('owner-decline-reason'),
        controller: _reason,
        maxLength: 200,
        decoration: InputDecoration(labelText: l10n.ownerDeclineReason),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.ownerKeep),
        ),
        FilledButton(
          key: const Key('owner-decline-confirm'),
          onPressed: () => Navigator.of(context).pop(_reason.text.trim()),
          child: Text(l10n.ownerDecline),
        ),
      ],
    );
  }
}

class _Refreshable extends StatelessWidget {
  const _Refreshable({required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [child],
    ),
  );
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(32),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Center(child: Text(text)),
  );
}

/// The day so far: the sales report's own totals, by source and by hour.
class OwnerTodayView extends StatelessWidget {
  const OwnerTodayView({super.key, required this.today});

  final OwnerToday today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hours = today.byHour.toList();
    final peak = hours.fold<num>(
      0,
      (top, row) => money(row.salesTotal) > top ? money(row.salesTotal) : top,
    );
    Widget figure(String key, String label, String value) => SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              Text(
                value,
                key: Key('owner-today-$key'),
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              figure(
                'sales',
                l10n.ownerSales,
                moneyLabel(money(today.salesTotal)),
              ),
              figure(
                'net',
                l10n.ownerNetSales,
                moneyLabel(money(today.netSales)),
              ),
              figure('orders', l10n.ownerOrders, '${today.orders}'),
              figure(
                'open',
                l10n.ownerOpenOrders,
                '${today.openOrders} · ${moneyLabel(money(today.openTotal))}',
              ),
              figure('shifts', l10n.ownerOpenShifts, '${today.openShifts}'),
              figure(
                'canceled',
                l10n.ownerCanceled,
                '${today.canceledOrders} · ${l10n.ownerVoided(today.voidedItems)}',
              ),
            ],
          ),
          if (today.bySource.isNotEmpty) ...[
            ListTile(
              title: Text(
                l10n.ownerBySource,
                style: theme.textTheme.titleMedium,
              ),
            ),
            for (final row in today.bySource)
              ListTile(
                dense: true,
                title: Text(orderSourceLabel(l10n, row.orderSource)),
                subtitle: Text(l10n.ownerSourceOrders(row.orders)),
                trailing: Text(moneyLabel(money(row.salesTotal))),
              ),
          ],
          if (hours.isNotEmpty) ...[
            ListTile(
              title: Text(l10n.ownerByHour, style: theme.textTheme.titleMedium),
            ),
            for (final row in hours)
              Padding(
                key: Key('owner-hour-${row.hour}'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text('${row.hour.toString().padLeft(2, '0')}h'),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: peak == 0
                            ? 0
                            : (money(row.salesTotal) / peak).toDouble(),
                        minHeight: 10,
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: Text(
                        moneyLabel(money(row.salesTotal)),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

String orderSourceLabel(AppLocalizations l10n, String source) =>
    platformLabel(l10n, source) ??
    switch (source) {
      'counter' => l10n.ownerSourceCounter,
      'kiosk' => l10n.ownerSourceKiosk,
      'facebook' => 'Facebook',
      'zalo' => 'Zalo',
      _ => l10n.ownerSourceOther,
    };

/// The open orders, oldest first, with how long and how much.
class OwnerOpenUnitsView extends StatelessWidget {
  const OwnerOpenUnitsView({super.key, required this.units});

  final List<OwnerOpenUnit> units;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (units.isEmpty) return _Note(l10n.ownerNoOpen);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final unit in units)
            SizedBox(
              width: 160,
              child: Card(
                key: Key('owner-open-${unit.workspaceId}'),
                color: unit.kitchenLate
                    ? theme.colorScheme.errorContainer
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.label ?? l10n.ownerTakeaway,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(l10n.ownerMinutesOpen(unit.minutesOpen)),
                      Text(moneyLabel(money(unit.total))),
                      if (unit.kitchenWaiting > 0)
                        Text(
                          unit.kitchenLate
                              ? l10n.ownerKitchenLate(unit.kitchenWaiting)
                              : l10n.ownerKitchenWaiting(unit.kitchenWaiting),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One approval waiting for the owner: who asks, for what, on which order,
/// how much and until when.
class ApprovalRequestCard extends StatelessWidget {
  const ApprovalRequestCard({
    super.key,
    required this.request,
    required this.busy,
    required this.onGrant,
    required this.onDecline,
  });

  final ApprovalRequest request;
  final bool busy;
  final VoidCallback onGrant;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final expires = request.expiresAt.toLocal();
    final time =
        '${expires.hour.toString().padLeft(2, '0')}:${expires.minute.toString().padLeft(2, '0')}';
    return Card(
      key: Key('owner-request-${request.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              approvalActionLabel(l10n, request.action),
              style: theme.textTheme.titleMedium,
            ),
            Text(
              [
                if (request.subjectLabel != null) request.subjectLabel!,
                l10n.ownerRequestedBy(request.requesterName ?? '—'),
              ].join(' · '),
            ),
            if (request.amount != null)
              Text(
                moneyLabel(money(request.amount)),
                style: theme.textTheme.titleLarge,
              ),
            if ((request.reason ?? '').isNotEmpty)
              Text(l10n.ownerRequestReason(request.reason!)),
            Text(
              l10n.ownerRequestExpires(time),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  key: Key('owner-grant-${request.id}'),
                  onPressed: busy ? null : onGrant,
                  child: Text(l10n.ownerGrant),
                ),
                OutlinedButton(
                  key: Key('owner-decline-${request.id}'),
                  onPressed: busy ? null : onDecline,
                  child: Text(l10n.ownerDecline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String approvalActionLabel(AppLocalizations l10n, String action) =>
    switch (action) {
      'workspace.apply_discount' ||
      'workspace.clear_discount' => l10n.ownerActionDiscount,
      'workspace.apply_line_discount' ||
      'workspace.clear_line_discount' => l10n.ownerActionLineDiscount,
      'workspace.override_price' => l10n.ownerActionOverridePrice,
      'workspace.reprint_prebill' ||
      'workspace.cancel_prebill' => l10n.ownerActionPrebill,
      'kitchen.void_sent' => l10n.ownerActionVoid,
      'platform_order.cancel' => l10n.ownerActionPlatformCancel,
      'buffet.override_round' => l10n.ownerActionBuffet,
      'tab.waive_minimum_spend' => l10n.ownerActionMinimumSpend,
      'timed.edit_segment' => l10n.ownerActionTimedEdit,
      'timed.long_pause' => l10n.ownerActionLongPause,
      'reservation.refund_deposit' => l10n.ownerActionDepositRefund,
      'reservation.forfeit_deposit' => l10n.ownerActionDepositForfeit,
      'bottle_keep.adjust' => l10n.ownerActionBottleKeep,
      'meal_wallet.refund' ||
      'meal_wallet.adjust' ||
      'meal_account.override_limit' => l10n.ownerActionMealWallet,
      'vehicle_visit.adjust' => l10n.ownerActionCommission,
      'stored_value.adjust' ||
      'stored_value.refund' => l10n.ownerActionStoredValue,
      _ => action,
    };

String approvalOutcomeLabel(
  AppLocalizations l10n,
  ApprovalRequestStatusEnum status,
) => switch (status) {
  ApprovalRequestStatusEnum.granted => l10n.ownerGranted,
  ApprovalRequestStatusEnum.declined => l10n.ownerDeclined,
  ApprovalRequestStatusEnum.expired => l10n.ownerRequestExpired,
  _ => l10n.ownerRequestCanceled,
};

String ownerFailureMessage(AppLocalizations l10n, AppFailure failure) =>
    switch (failure) {
      ConflictFailure(reason: 'approver_is_requester') =>
        l10n.ownerSelfApproval,
      ConflictFailure(reason: 'approval_request_decided') =>
        l10n.ownerAlreadyDecided,
      _ => waiterFailureMessage(l10n, failure),
    };

class OwnerAlertTile extends StatelessWidget {
  const OwnerAlertTile({super.key, required this.alert});

  final OwnerAlert alert;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final at = alert.occurredAt.toLocal();
    final time =
        '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
    String detail(String key) => alert.details[key]?.value.toString() ?? '';
    final (icon, title) = switch (alert.kind) {
      OwnerAlertKindEnum.kitchenLate => (
        Icons.timer_outlined,
        l10n.ownerAlertKitchenLate(detail('minutes')),
      ),
      OwnerAlertKindEnum.shiftVariance => (
        Icons.point_of_sale_outlined,
        l10n.ownerAlertShiftVariance(moneyLabel(money(detail('variance')))),
      ),
      OwnerAlertKindEnum.voidBurst => (
        Icons.remove_shopping_cart_outlined,
        l10n.ownerAlertVoidBurst(detail('voids')),
      ),
      OwnerAlertKindEnum.revenueMilestone => (
        Icons.trending_up,
        l10n.ownerAlertRevenue(detail('percent')),
      ),
      OwnerAlertKindEnum.printFailed => (
        Icons.print_disabled_outlined,
        l10n.ownerAlertPrintFailed,
      ),
      _ => (Icons.receipt_long_outlined, l10n.ownerAlertEinvoiceFailed),
    };
    return ListTile(
      key: Key('owner-alert-${alert.id}'),
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(time),
    );
  }
}

/// Background notifications on this phone: on only with a push token and a
/// store relay; otherwise the owner hears events while the app is open.
class OwnerPushSheet extends StatefulWidget {
  const OwnerPushSheet({super.key, required this.watch, required this.tokens});

  final OwnerWatchApi watch;
  final PushTokenSource tokens;

  @override
  State<OwnerPushSheet> createState() => _OwnerPushSheetState();
}

class _OwnerPushSheetState extends State<OwnerPushSheet> {
  PushRegistrationState? _state;
  PushToken? _token;
  bool _loaded = false;
  bool _busy = false;
  AppFailure? _failure;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final token = await widget.tokens.token();
      final state = await widget.watch.push();
      if (mounted) {
        setState(
          () =>
              (_token = token, _state = state, _loaded = true, _failure = null),
        );
      }
    } on AppFailure catch (failure) {
      if (mounted) setState(() => (_failure = failure, _loaded = true));
    }
  }

  Future<void> _toggle(bool on) async {
    final token = _token;
    setState(() => _busy = true);
    try {
      final state = on && token != null
          ? await widget.watch.updatePush(
              platform: token.platform,
              token: token.token,
              enabled: true,
            )
          : await widget.watch.updatePush(enabled: false);
      if (mounted) setState(() => _state = state);
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = _state;
    final registration = state?.registration;
    final available = _token != null && (state?.relay ?? false);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.ownerPushTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (!_loaded)
              const _Loading()
            else ...[
              SwitchListTile(
                key: const Key('owner-push-toggle'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.ownerPushToggle),
                value: available && (registration?.enabled ?? false),
                onChanged: available && !_busy ? _toggle : null,
              ),
              Text(
                key: const Key('owner-push-note'),
                _token == null
                    ? l10n.ownerPushNoToken
                    : (state?.relay ?? false)
                    ? l10n.ownerPushReady
                    : l10n.ownerPushNoRelay,
              ),
              if (registration?.lastError != null)
                Text(l10n.ownerPushLastError(registration!.lastError!)),
              if (_failure != null) Text(ownerFailureMessage(l10n, _failure!)),
            ],
          ],
        ),
      ),
    );
  }
}
