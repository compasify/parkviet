import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_api/pos_api.dart';

import '../../core/errors.dart';
import '../../core/menu/modifier_sheet.dart';
import '../../l10n/app_localizations.dart';
import '../print_station/document_renderer.dart';
import '../print_station/drivers/bluetooth_driver.dart';
import '../print_station/drivers/printer_driver.dart';
import '../print_station/escpos_renderer.dart';
import '../print_station/printer_profile.dart';
import 'order_menu_screen.dart';
import 'void_dialog.dart';
import 'waiter_context.dart';
import 'waiter_messages.dart';

/// The kitchen state of a line: "2 mới · 1 đang làm · 1 xong · 1 đã ra",
/// and what is not sent yet.
String kitchenStatusLabel(AppLocalizations l10n, WorkspaceLine line) {
  String count(String? value) {
    final number = num.tryParse(value ?? '') ?? 0;
    return number == number.truncate() ? '${number.truncate()}' : '$number';
  }

  final status = line.kitchenStatus;
  final pending = num.tryParse(line.pendingKitchenQuantity ?? '') ?? 0;
  return [
    if (pending > 0) l10n.waiterLineUnsent(count(line.pendingKitchenQuantity)),
    if ((num.tryParse(status?.new_ ?? '') ?? 0) > 0) l10n.waiterLineNew(count(status!.new_)),
    if ((num.tryParse(status?.preparing ?? '') ?? 0) > 0) l10n.waiterLinePreparing(count(status!.preparing)),
    if ((num.tryParse(status?.ready ?? '') ?? 0) > 0) l10n.waiterLineReady(count(status!.ready)),
    if ((num.tryParse(status?.served ?? '') ?? 0) > 0) l10n.waiterLineServed(count(status!.served)),
  ].join(' · ');
}

int sentQuantity(WorkspaceLine line) => (num.tryParse(line.kitchenSentQuantity ?? '') ?? 0).floor();

/// One table order on the phone: its lines with their kitchen state, and
/// "Gọi món", "Báo bếp", payment request, move, merge, checklist and
/// prebill. A refused change that came from an older copy of the order
/// says so and reads the order again.
class TableOrderScreen extends StatefulWidget {
  const TableOrderScreen({super.key, required this.waiter, required this.workspaceId});

  final WaiterContext waiter;
  final String workspaceId;

  @override
  State<TableOrderScreen> createState() => _TableOrderScreenState();
}

class _TableOrderScreenState extends State<TableOrderScreen> {
  Workspace? _workspace;
  AppFailure? _failure;
  bool _busy = false;
  StreamSubscription<void>? _events;

  @override
  void initState() {
    super.initState();
    _events = widget.waiter.workspaceEvents(widget.workspaceId).listen((_) => unawaited(_load()));
    unawaited(_load());
  }

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final workspace = await widget.waiter.api.workspace(widget.workspaceId);
      if (mounted) setState(() => (_workspace = workspace, _failure = null));
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    }
  }

  String get _title {
    final workspace = _workspace;
    if (workspace == null) return '';
    final name = workspace.resource?.name ?? '';
    return workspace.tableLabel == null ? name : '$name ${workspace.tableLabel}';
  }

  void _say(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  /// Runs a command, shows what went wrong, and reads the order again when
  /// the refusal came from an older copy of it.
  Future<T?> _run<T>(Future<T> Function() command, {String? done}) async {
    if (_busy) return null;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final result = await command();
      if (result is Workspace && mounted) setState(() => _workspace = result);
      if (done != null && mounted) _say(done);
      return result;
    } on AppFailure catch (failure) {
      if (mounted) _say(waiterFailureMessage(l10n, failure));
      if (needsRefetch(failure)) unawaited(_load());
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _order() async {
    final l10n = AppLocalizations.of(context);
    final outcome = await Navigator.of(context).push<AddOutcome>(MaterialPageRoute(
      builder: (_) => OrderMenuScreen(waiter: widget.waiter, workspaceId: widget.workspaceId, title: _title),
    ));
    if (!mounted) return;
    if (outcome == null) {
      unawaited(_load());
      return;
    }
    setState(() => _workspace = outcome.workspace);
    _say(outcome.sent ? l10n.waiterAddedAndSent : l10n.waiterAdded);
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    await _run(() => widget.waiter.api.sendToKitchen(widget.workspaceId), done: l10n.waiterSent);
  }

  Future<void> _line(WorkspaceLine line) async {
    final l10n = AppLocalizations.of(context);
    final sent = sentQuantity(line);
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('${line.quantity} x ${line.name}'), subtitle: Text(kitchenStatusLabel(l10n, line))),
            if (sent > 0 && line.saleLineId != null)
              ListTile(
                key: Key('line-void-${line.id}'),
                leading: const Icon(Icons.remove_circle_outline),
                title: Text(l10n.waiterVoidSent),
                onTap: () => Navigator.of(sheet).pop('void'),
              ),
            if (sent == 0)
              ListTile(
                key: Key('line-remove-${line.id}'),
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.waiterRemoveUnsent),
                onTap: () => Navigator.of(sheet).pop('remove'),
              ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (choice == 'remove') {
      await _run(() => widget.waiter.api.removeUnsent(widget.workspaceId, line));
    } else if (choice == 'void') {
      final voided = await showVoidDialog(context, waiter: widget.waiter, workspaceId: widget.workspaceId, line: line);
      if (voided != null && mounted) {
        setState(() => _workspace = voided);
        _say(l10n.waiterVoided);
      } else {
        unawaited(_load());
      }
    }
  }

  Future<void> _requestPayment() async {
    final l10n = AppLocalizations.of(context);
    await _run(() => widget.waiter.api.requestPayment(widget.workspaceId), done: l10n.waiterPaymentRequestSent);
  }

  /// Another table of the branch: a free one to move to, or a busy one to
  /// merge into.
  Future<void> _moveOrMerge({required bool merge}) async {
    final l10n = AppLocalizations.of(context);
    final workspace = _workspace;
    if (workspace == null) return;
    final ResourceBoard board;
    try {
      board = await widget.waiter.api.tables(widget.waiter.branchId);
    } on AppFailure catch (failure) {
      _say(waiterFailureMessage(l10n, failure));
      return;
    }
    if (!mounted) return;
    final options = [
      for (final tile in board.resources)
        if (tile.id != workspace.resource?.id)
          if (merge)
            for (final order in tile.orders) (id: order.id, label: order.tableLabel == null ? tile.name : '${tile.name} ${order.tableLabel}')
          else if (tile.state == ResourceBoardTileStateEnum.available)
            (id: tile.id, label: tile.name),
    ];
    final target = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(title: Text(merge ? l10n.waiterMergeInto : l10n.waiterMoveTo)),
          if (options.isEmpty) ListTile(title: Text(l10n.waiterNoTables)),
          for (final option in options)
            ListTile(
              key: Key('target-${option.id}'),
              minTileHeight: 56,
              title: Text(option.label),
              onTap: () => Navigator.of(sheet).pop(option.id),
            ),
        ],
      ),
    );
    if (target == null || !mounted) return;
    final api = widget.waiter.api;
    final editor = widget.waiter.editorId;
    if (merge) {
      final merged = await _run(() => api.merge(workspace, editorId: editor, targetWorkspaceId: target), done: l10n.waiterMerged);
      if (merged != null && mounted) Navigator.of(context).pop();
    } else {
      await _run(() => api.move(workspace, editorId: editor, resourceId: target), done: l10n.waiterMoved);
    }
  }

  /// The printer for a document: the only one the branch has for the role,
  /// or the one picked. Null when there is none (the document is shown).
  Future<Printer?> _printer(PrinterRolesEnum role) async {
    List<Printer> printers;
    try {
      printers = await widget.waiter.api.printers(widget.waiter.branchId);
    } on AppFailure {
      printers = const [];
    }
    final usable = printers
        .where((printer) => printer.status == PrinterStatusEnum.active && printer.roles.contains(role))
        .toList();
    if (usable.length <= 1 || !mounted) return usable.firstOrNull;
    return showModalBottomSheet<Printer>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final printer in usable)
              ListTile(
                key: Key('printer-${printer.id}'),
                leading: const Icon(Icons.print),
                title: Text(printer.name),
                onTap: () => Navigator.of(sheet).pop(printer),
              ),
          ],
        ),
      ),
    );
  }

  /// A Bluetooth printer kept by this phone prints here; any other one
  /// gets a print job from the server.
  bool _local(Printer? printer) =>
      printer != null &&
      printer.connection == PrinterConnectionEnum.escposBluetooth &&
      printer.printStationDeviceId == widget.waiter.deviceId;

  Future<void> _printLocally(Printer printer, Object? document) async {
    final l10n = AppLocalizations.of(context);
    if (document is! Map) return;
    try {
      final profile = PrinterProfile.fromPrinter(printer);
      final renderer = DocumentRenderer(escPos: await EscPosRenderer.load());
      final bytes = await renderer.render(document.cast<String, Object?>(), profile);
      await const BluetoothDriver().send(profile, bytes);
      if (mounted) _say(l10n.waiterPrinted(printer.name));
    } on PrinterDeliveryError catch (error) {
      if (mounted) _say(l10n.waiterPrintFailed('$error'));
    }
  }

  Future<void> _checklist() async {
    final l10n = AppLocalizations.of(context);
    final printer = await _printer(PrinterRolesEnum.checklist);
    if (!mounted) return;
    final local = _local(printer);
    final outcome = await _run(() => widget.waiter.api.checklist(widget.workspaceId, printerId: local ? null : printer?.id));
    if (outcome == null || !mounted) return;
    if (local) {
      await _printLocally(printer!, outcome.document.value);
    } else if (outcome.printJob != null) {
      _say(l10n.waiterPrintQueued(outcome.printJob!.printerName));
    } else {
      await _preview(outcome.document.value);
    }
  }

  Future<void> _prebill() async {
    final l10n = AppLocalizations.of(context);
    final printer = await _printer(PrinterRolesEnum.prebill);
    if (!mounted) return;
    final local = _local(printer);
    final outcome = await _run(() => widget.waiter.api.prebill(widget.workspaceId, printerId: local ? null : printer?.id));
    if (outcome == null || !mounted) return;
    unawaited(_load());
    if (local) {
      await _printLocally(printer!, outcome.document?.value);
    } else if (outcome.printJob != null) {
      _say(l10n.waiterPrintQueued(outcome.printJob!.printerName));
    } else {
      await _preview(outcome.document?.value);
    }
  }

  /// The document as text, when no printer takes it.
  Future<void> _preview(Object? document) async {
    final l10n = AppLocalizations.of(context);
    final lines = <String>[];
    if (document is Map) {
      for (final key in ['title', 'number']) {
        if (document[key] is String) lines.add(document[key] as String);
      }
      for (final section in ['header', 'lines', 'body', 'footer']) {
        final blocks = document[section];
        if (blocks is! List) continue;
        for (final block in blocks) {
          if (block is Map && block['lines'] is List) lines.addAll((block['lines'] as List).whereType<String>());
          if (block is Map && block['text'] is String) lines.add(block['text'] as String);
        }
      }
    }
    await showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.waiterNoPrinter),
        content: SingleChildScrollView(
          child: Text(lines.join('\n'), key: const Key('document-preview'), style: const TextStyle(fontFamily: 'monospace')),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(dialog).pop(), child: Text(l10n.waiterClose))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final workspace = _workspace;
    final lines = workspace?.lineItems?.toList() ?? const <WorkspaceLine>[];
    final pending = lines.fold<num>(0, (sum, line) => sum + (num.tryParse(line.pendingKitchenQuantity ?? '') ?? 0));
    final subtotal = lines.fold<num>(0, (sum, line) => sum + money(line.amount));
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          PopupMenuButton<String>(
            key: const Key('order-actions'),
            enabled: workspace != null && !_busy,
            onSelected: (action) => switch (action) {
              'payment' => _requestPayment(),
              'move' => _moveOrMerge(merge: false),
              'merge' => _moveOrMerge(merge: true),
              'checklist' => _checklist(),
              'prebill' => _prebill(),
              _ => null,
            },
            itemBuilder: (_) => [
              PopupMenuItem(key: const Key('action-payment'), value: 'payment', child: Text(l10n.waiterRequestPayment)),
              PopupMenuItem(key: const Key('action-move'), value: 'move', child: Text(l10n.waiterMove)),
              PopupMenuItem(key: const Key('action-merge'), value: 'merge', child: Text(l10n.waiterMerge)),
              PopupMenuItem(key: const Key('action-checklist'), value: 'checklist', child: Text(l10n.waiterChecklist)),
              PopupMenuItem(key: const Key('action-prebill'), value: 'prebill', child: Text(l10n.waiterPrebill)),
            ],
          ),
        ],
      ),
      body: workspace == null
          ? Center(
              child: _failure == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(waiterFailureMessage(l10n, _failure!)),
                        TextButton(onPressed: _load, child: Text(l10n.retry)),
                      ],
                    ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                key: const Key('order-lines'),
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  ListTile(
                    title: Text(l10n.waiterGuests(workspace.guestCount ?? 0)),
                    subtitle: workspace.paymentRequest?.status == PaymentRequestStatusEnum.open
                        ? Text(l10n.waiterPaymentRequested, style: const TextStyle(fontWeight: FontWeight.w700))
                        : null,
                    trailing: Text(l10n.waiterSubtotal(moneyLabel(subtotal)), style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const Divider(height: 1),
                  if (lines.isEmpty) Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(l10n.waiterEmptyOrder))),
                  for (final line in lines)
                    ListTile(
                      key: Key('line-${line.id}'),
                      onTap: _busy ? null : () => _line(line),
                      title: Text('${line.quantity} x ${line.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text([
                        if (line.modifiers?.isNotEmpty ?? false)
                          '+ ${line.modifiers!.map((row) => row.quantity > 1 ? '${row.name} x${row.quantity}' : row.name).join(', ')}',
                        if (line.note?.isNotEmpty ?? false) line.note!,
                        kitchenStatusLabel(l10n, line),
                      ].join('\n')),
                      trailing: Text(moneyLabel(money(line.amount))),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: workspace == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: FilledButton.icon(
                          key: const Key('order-add'),
                          onPressed: _busy ? null : _order,
                          icon: const Icon(Icons.add),
                          label: Text(l10n.waiterOrderDishes),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: FilledButton.tonalIcon(
                          key: const Key('order-send'),
                          onPressed: _busy || pending <= 0 ? null : _send,
                          icon: const Icon(Icons.soup_kitchen_outlined),
                          label: Text(pending > 0 ? l10n.waiterSendCount(pending.round()) : l10n.waiterSend),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
