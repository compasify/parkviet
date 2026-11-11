import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_api/pos_api.dart';

import '../../auth/staff_session.dart';
import '../../core/errors.dart';
import '../../core/failure_messages.dart';
import '../../l10n/app_localizations.dart';
import 'kds_repository.dart';

void showSoldOutSheet(
  BuildContext context, {
  required KitchenApi api,
  required String branchId,
  required String? stationId,
  String? query,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SoldOutSheet(api: api, branchId: branchId, stationId: stationId, query: query),
    );

/// "Hết món": the dishes this station makes and whether each is sold out
/// today. A change names a person, who picks their name and enters their
/// PIN; the session it opens ends with the change.
class SoldOutSheet extends ConsumerStatefulWidget {
  const SoldOutSheet({super.key, required this.api, required this.branchId, required this.stationId, this.query});

  final KitchenApi api;
  final String branchId;
  final String? stationId;

  /// Opened from an item of a ticket: only the dishes of that name.
  final String? query;

  @override
  ConsumerState<SoldOutSheet> createState() => _SoldOutSheetState();
}

class _SoldOutSheetState extends ConsumerState<SoldOutSheet> {
  late Future<List<KitchenMenuItem>> _items = widget.api.menuItems(widget.stationId);

  Future<void> _toggle(KitchenMenuItem item, bool soldOut) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final who = await showDialog<_Signer>(context: context, builder: (_) => const _SignerDialog());
    if (who == null) return;
    try {
      await widget.api.soldOut(
        branchId: widget.branchId,
        menuItemId: item.id,
        soldOut: soldOut,
        membershipId: who.membershipId,
        pin: who.pin,
      );
      if (mounted) setState(() => _items = widget.api.menuItems(widget.stationId));
    } on AppFailure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(failureMessage(l10n, failure))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: FutureBuilder<List<KitchenMenuItem>>(
        future: _items,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final error = snapshot.error;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Text(error is AppFailure ? failureMessage(l10n, error) : '$error'),
            );
          }
          final items = snapshot.data;
          if (items == null) return const Padding(padding: EdgeInsets.all(24), child: LinearProgressIndicator());
          final query = widget.query?.toLowerCase();
          final shown = query == null
              ? items
              : items.where((item) => item.name.toLowerCase().contains(query) || query.contains(item.name.toLowerCase())).toList();
          return ListView(
            shrinkWrap: true,
            children: [
              ListTile(title: Text(l10n.kdsSoldOutTitle, style: Theme.of(context).textTheme.titleLarge)),
              for (final item in shown)
                SwitchListTile(
                  key: Key('sold-out-${item.id}'),
                  title: Text(item.name, style: const TextStyle(fontSize: 18)),
                  subtitle: item.kitchenCategory == null ? null : Text(item.kitchenCategory!),
                  value: item.soldOut,
                  onChanged: (value) => _toggle(item, value),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Signer {
  const _Signer(this.membershipId, this.pin);

  final String membershipId;
  final String pin;
}

/// Picks a name at the branch, then takes that person's PIN.
class _SignerDialog extends ConsumerStatefulWidget {
  const _SignerDialog();

  @override
  ConsumerState<_SignerDialog> createState() => _SignerDialogState();
}

class _SignerDialogState extends ConsumerState<_SignerDialog> {
  DeviceStaffMember? _member;
  final _pin = TextEditingController();

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final member = _member;
    if (member == null) {
      final staff = ref.watch(branchStaffProvider);
      return SimpleDialog(
        title: Text(l10n.kdsSoldOutWho),
        children: staff.when(
          loading: () => [const Padding(padding: EdgeInsets.all(24), child: LinearProgressIndicator())],
          error: (error, _) => [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(error is AppFailure ? failureMessage(l10n, error) : '$error'),
            ),
          ],
          data: (people) => [
            for (final person in people.where((row) => row.pinSet))
              SimpleDialogOption(
                key: Key('signer-${person.id}'),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                onPressed: () => setState(() => _member = person),
                child: Text(person.name, style: const TextStyle(fontSize: 18)),
              ),
          ],
        ),
      );
    }
    void submit() => Navigator.of(context).pop(_Signer(member.id, _pin.text));
    return AlertDialog(
      title: Text(l10n.kdsPinFor(member.name)),
      content: TextField(
        key: const Key('signer-pin'),
        controller: _pin,
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 24, letterSpacing: 8),
        onSubmitted: (_) => submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(key: const Key('signer-confirm'), onPressed: submit, child: Text(l10n.kdsConfirm)),
      ],
    );
  }
}
