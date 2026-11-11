import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_mode.dart';
import '../core/session.dart';
import '../l10n/app_localizations.dart';
import '../modes/mode_names.dart';
import 'manager_access.dart';
import 'staff_session.dart';

final _editorId = FutureProvider.autoDispose<String>((ref) => ref.read(deviceStoreProvider).editorId());

/// Device information, and unpairing, behind a manager PIN.
class ManageScreen extends ConsumerWidget {
  const ManageScreen({super.key});

  Future<void> _unpair(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.manageUnpairConfirmTitle),
        content: Text(l10n.manageUnpairConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(
            key: const Key('manage-unpair-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.manageUnpair),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (ref.read(staffSessionControllerProvider) != null) {
      await ref.read(staffSessionControllerProvider.notifier).signOut();
    }
    ref.read(managerAccessProvider.notifier).close();
    await ref.read(sessionProvider.notifier).unpair();
  }

  void _close(BuildContext context, WidgetRef ref) {
    ref.read(managerAccessProvider.notifier).close();
    context.go('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider).value;
    if (session is! Paired) return const SizedBox.shrink();
    final me = session.me;
    final editorId = ref.watch(_editorId).value ?? '';
    final descriptor = ref.watch(deviceDescriptorProvider).value;
    final offset = session.clock.offset.inMilliseconds / 1000;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close(context, ref);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.manageTitle),
          leading: IconButton(icon: const Icon(Icons.close), onPressed: () => _close(context, ref)),
        ),
        body: ListView(
          children: [
            ListTile(title: Text(l10n.manageDeviceName), subtitle: Text(me.device.name)),
            ListTile(title: Text(l10n.manageMode), subtitle: Text(modeName(l10n, AppMode.of(me.device.mode)))),
            ListTile(title: Text(l10n.manageBranch), subtitle: Text(me.branch.name)),
            ListTile(title: Text(l10n.manageServer), subtitle: Text(session.serverUrl)),
            ListTile(title: Text(l10n.manageAppVersion), subtitle: Text(descriptor?.appVersion ?? '')),
            ListTile(title: Text(l10n.manageEditorId), subtitle: SelectableText(editorId)),
            ListTile(title: Text(l10n.manageClockOffset), subtitle: Text(offset.toStringAsFixed(1))),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.manageRevokeHint),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.tonalIcon(
                key: const Key('manage-unpair'),
                onPressed: () => _unpair(context, ref),
                icon: const Icon(Icons.link_off),
                label: Text(l10n.manageUnpair),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
