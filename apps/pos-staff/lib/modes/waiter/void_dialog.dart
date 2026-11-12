import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_api/pos_api.dart';

import '../../core/errors.dart';
import '../../l10n/app_localizations.dart';
import 'table_order_screen.dart';
import 'void_reasons.dart';
import 'waiter_context.dart';
import 'waiter_messages.dart';

/// The most characters of a void note.
const voidNoteMax = 200;

/// Takes back dishes the kitchen has. Answers the order after the void,
/// or null when closed.
Future<Workspace?> showVoidDialog(
  BuildContext context, {
  required WaiterContext waiter,
  required String workspaceId,
  required WorkspaceLine line,
}) =>
    showDialog<Workspace>(
      context: context,
      builder: (_) => VoidDialog(waiter: waiter, workspaceId: workspaceId, line: line),
    );

/// How many, why, and for a person who may not void, the code of a
/// manager's approval: "Chờ quản lý duyệt" until the manager grants it. A
/// grant for this order announced on the branch channel fills the code
/// and tries again by itself. "Gửi chủ duyệt" asks the manager on their
/// own phone; a grant arrives the same way, a refusal is shown here.
class VoidDialog extends StatefulWidget {
  const VoidDialog({super.key, required this.waiter, required this.workspaceId, required this.line});

  final WaiterContext waiter;
  final String workspaceId;
  final WorkspaceLine line;

  @override
  State<VoidDialog> createState() => _VoidDialogState();
}

class _VoidDialogState extends State<VoidDialog> {
  late final int _sent = sentQuantity(widget.line);
  int _quantity = 1;
  // The branch's reasons as the phone last read them.
  late final List<String> _reasons = widget.waiter.voidReasons.value;
  late String _reason = _reasons.first;
  final _note = TextEditingController();
  final _approval = TextEditingController();
  bool _needsApproval = false;
  bool _busy = false;
  String? _error;
  StreamSubscription<Map<String, Object?>>? _grants;
  // The order's revision the server refused at, for asking the manager.
  int? _revision;
  ApprovalRequest? _request;
  String? _answer;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _grants = widget.waiter.events.listen(_onEvent);
  }

  void _onEvent(Map<String, Object?> event) {
    final refs = event['refs'];
    final id = event['id'];
    if (event['event'] == 'approval_request.updated' && id is String && id == _request?.id) {
      unawaited(_readAnswer(id));
      return;
    }
    if (!_needsApproval || event['event'] != 'approval.requested' || id is! String) return;
    if (refs is Map && refs['workspace_id'] == widget.workspaceId) {
      _approval.text = id;
      unawaited(_submit());
    }
  }

  // A refusal or a lapse is told here; a grant comes as `approval.requested`.
  Future<void> _readAnswer(String id) async {
    final approvals = widget.waiter.approvals;
    if (approvals == null) return;
    try {
      final request = await approvals.show(id);
      if (!mounted || request.status == ApprovalRequestStatusEnum.pending) return;
      if (request.status == ApprovalRequestStatusEnum.granted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _request = null;
        _answer = switch (request.status) {
          ApprovalRequestStatusEnum.declined => (request.reason ?? '').isEmpty
              ? l10n.waiterOwnerDeclined
              : l10n.waiterOwnerDeclinedReason(request.reason!),
          _ => l10n.waiterOwnerExpired,
        };
      });
    } on AppFailure {
      // The dialog keeps waiting; a code typed in still works.
    }
  }

  Future<void> _askOwner() async {
    final approvals = widget.waiter.approvals;
    final revision = _revision;
    if (approvals == null || revision == null || _busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _answer = null;
      _error = null;
    });
    try {
      final request = await approvals.ask(
        branchId: widget.waiter.branchId,
        workspaceId: widget.workspaceId,
        action: 'kitchen.void_sent',
        revision: revision,
        reason: _note.text.trim().isEmpty ? voidReasonLabel(l10n, _reason) : _note.text.trim(),
      );
      if (mounted) setState(() => _request = request);
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = waiterFailureMessage(l10n, failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _grants?.cancel();
    // Closed without the void: the manager is no longer asked.
    final request = _request;
    if (request != null && !_done) unawaited(widget.waiter.approvals?.cancel(request.id).then((_) {}, onError: (_) {}));
    _note.dispose();
    _approval.dispose();
    super.dispose();
  }

  bool get _valid =>
      _quantity >= 1 &&
      _quantity <= _sent &&
      (_reason != voidOther || _note.text.trim().isNotEmpty) &&
      (!_needsApproval || _approval.text.trim().isNotEmpty);

  Future<void> _submit() async {
    if (!_valid || _busy) return;
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final saleLineId = widget.line.saleLineId!;
      final workspace = await widget.waiter.api.voidSent(
        widget.workspaceId,
        saleLineId,
        quantity: _quantity,
        reasonCode: _reason,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        approvalId: _approval.text.trim().isEmpty ? null : _approval.text.trim(),
      );
      _done = true;
      navigator.pop(workspace);
    } on AppFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        if (failure case ConflictFailure(reason: 'approval_required', :final currentRevision)) {
          _needsApproval = true;
          _revision = currentRevision ?? _revision;
          _error = null;
        } else {
          _error = waiterFailureMessage(l10n, failure);
        }
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l10n.waiterVoidTitle(widget.line.name)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.waiterVoidSentCount(_sent)),
            Row(
              children: [
                IconButton(
                  key: const Key('void-less'),
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_quantity', key: const Key('void-quantity'), style: theme.textTheme.headlineSmall),
                IconButton(
                  key: const Key('void-more'),
                  onPressed: _quantity < _sent ? () => setState(() => _quantity++) : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            for (final code in _reasons)
              RadioListTile<String>(
                key: Key('void-reason-$code'),
                contentPadding: EdgeInsets.zero,
                value: code,
                groupValue: _reason,
                title: Text(voidReasonLabel(l10n, code)),
                onChanged: (value) => setState(() => _reason = value ?? _reason),
              ),
            TextField(
              key: const Key('void-note'),
              controller: _note,
              maxLength: voidNoteMax,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: _reason == voidOther ? l10n.waiterVoidNoteRequired : l10n.waiterVoidNote,
              ),
            ),
            if (_needsApproval) ...[
              Container(
                key: const Key('void-waiting-approval'),
                padding: const EdgeInsets.all(12),
                color: theme.colorScheme.tertiaryContainer,
                child: Text(l10n.waiterWaitingApproval, style: theme.textTheme.titleMedium),
              ),
              TextField(
                key: const Key('void-approval'),
                controller: _approval,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: l10n.waiterApprovalCode),
              ),
              if (widget.waiter.approvals != null && _revision != null)
                _request == null
                    ? OutlinedButton.icon(
                        key: const Key('void-ask-owner'),
                        onPressed: _busy ? null : _askOwner,
                        icon: const Icon(Icons.phonelink_ring_outlined),
                        label: Text(l10n.waiterAskOwner),
                      )
                    : Padding(
                        key: const Key('void-asked-owner'),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(l10n.waiterAskedOwner),
                      ),
              if (_answer != null)
                Text(_answer!, key: const Key('void-owner-answer'), style: TextStyle(color: theme.colorScheme.error)),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(
          key: const Key('void-confirm'),
          onPressed: _valid && !_busy ? _submit : null,
          child: Text(l10n.waiterVoidConfirm),
        ),
      ],
    );
  }
}
