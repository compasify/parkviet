import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_api/pos_api.dart';

import '../../core/errors.dart';
import '../../core/menu/modifier_sheet.dart' show money, moneyLabel;
import '../../l10n/app_localizations.dart';
import 'table_order_screen.dart';
import 'waiter_context.dart';
import 'waiter_messages.dart';

/// A bar's open tabs on the waiter's phone: a search by guest name, table
/// or tab number, opening a tab with only a name, and adding to any tab.
/// Tabs take items from every device without a lease.
class TabListScreen extends StatefulWidget {
  const TabListScreen({super.key, required this.waiter});

  final WaiterContext waiter;

  @override
  State<TabListScreen> createState() => _TabListScreenState();
}

class _TabListScreenState extends State<TabListScreen> {
  final _search = TextEditingController();
  List<WorkspaceSummary>? _tabs;
  AppFailure? _failure;
  Timer? _debounce;
  StreamSubscription<Map<String, Object?>>? _events;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _events = widget.waiter.events.listen((event) {
      if (event['event'] == 'workspace.updated') unawaited(_load());
    });
    unawaited(_load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _events?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    try {
      final tabs = await widget.waiter.api.tabs(widget.waiter.branchId, query: _search.text);
      if (!mounted || generation != _generation) return;
      setState(() {
        _tabs = tabs;
        _failure = null;
      });
    } on AppFailure catch (failure) {
      if (mounted && generation == _generation) setState(() => _failure = failure);
    }
  }

  void _searchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => unawaited(_load()));
  }

  Future<void> _show(String workspaceId) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => TableOrderScreen(waiter: widget.waiter, workspaceId: workspaceId),
    ));
    unawaited(_load());
  }

  Future<void> _open() async {
    final l10n = AppLocalizations.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (dialog) => _TabNameDialog(initial: _search.text.trim()),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;
    try {
      final opened = await widget.waiter.api.openTab(widget.waiter.branchId, name, editorId: widget.waiter.editorId);
      _search.clear();
      unawaited(_load());
      await _show(opened.id);
    } on AppFailure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(waiterFailureMessage(l10n, failure))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = _tabs;
    final time = DateFormat.Hm();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.waiterTabsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('tab-open'),
        onPressed: _open,
        icon: const Icon(Icons.add),
        label: Text(l10n.waiterTabOpen),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              key: const Key('tab-search'),
              controller: _search,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.waiterTabSearch,
                border: const OutlineInputBorder(),
              ),
              onChanged: _searchChanged,
              onSubmitted: (_) {
                final rows = _tabs ?? const [];
                if (rows.length == 1) unawaited(_show(rows.single.id));
              },
            ),
          ),
          if (_failure != null)
            MaterialBanner(
              content: Text(waiterFailureMessage(l10n, _failure!)),
              actions: [TextButton(onPressed: _load, child: Text(l10n.retry))],
            ),
          Expanded(
            child: tabs == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: tabs.isEmpty
                        ? ListView(children: [
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Text(_search.text.trim().isEmpty ? l10n.waiterTabsNone : l10n.waiterTabsNoMatch),
                              ),
                            ),
                          ])
                        : ListView.separated(
                            key: const Key('tab-list'),
                            itemCount: tabs.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final tab = tabs[index];
                              final opened = tab.openedAt;
                              return ListTile(
                                key: Key('tab-${tab.id}'),
                                minTileHeight: 64,
                                title: Text(tab.tabName ?? tab.guestName ?? '#${tab.orderNumber ?? ''}'),
                                subtitle: Text([
                                  if (tab.resource != null) tab.resource!.name,
                                  if (opened != null) l10n.waiterTabOpenedAt(time.format(opened.toLocal())),
                                ].join(' · ')),
                                trailing: Text(
                                  moneyLabel(money(tab.total)),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                onTap: () => _show(tab.id),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TabNameDialog extends StatefulWidget {
  const _TabNameDialog({required this.initial});

  final String initial;

  @override
  State<_TabNameDialog> createState() => _TabNameDialogState();
}

class _TabNameDialogState extends State<_TabNameDialog> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.waiterTabOpen),
      content: TextField(
        key: const Key('tab-name'),
        controller: _name,
        autofocus: true,
        maxLength: 60,
        decoration: InputDecoration(labelText: l10n.waiterTabName),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(
          key: const Key('tab-name-confirm'),
          onPressed: () => Navigator.of(context).pop(_name.text),
          child: Text(l10n.waiterTabOpen),
        ),
      ],
    );
  }
}
