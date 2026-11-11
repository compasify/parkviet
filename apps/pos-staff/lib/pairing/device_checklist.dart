import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_api/pos_api.dart';

import '../core/app_mode.dart';
import '../core/errors.dart';
import '../core/failure_messages.dart';
import '../core/session.dart';
import '../l10n/app_localizations.dart';

/// Whether the device was just paired and has not been through its
/// checklist yet. Kept in memory: a restart goes straight to the mode.
class DeviceChecklistPending extends Notifier<bool> {
  @override
  bool build() => false;

  void open() => state = true;

  void done() => state = false;
}

final deviceChecklistPendingProvider = NotifierProvider<DeviceChecklistPending, bool>(DeviceChecklistPending.new);

enum ChecklistKind { station, printer, staff }

/// One line of the checklist: ready ([ok]) or still to do, with what it
/// found ([name], [count]).
class ChecklistItem {
  const ChecklistItem(this.kind, {required this.ok, this.name, this.count = 0});

  final ChecklistKind kind;
  final bool ok;
  final String? name;
  final int count;
}

/// What a just-paired device still needs, for its mode: a kitchen or expo
/// screen its station and that station's printer; a waiter or owner phone
/// someone who can sign in with a PIN. Other modes need nothing more.
List<ChecklistItem> checklistItems({
  required AppMode mode,
  String? stationId,
  List<KitchenStation> stations = const [],
  List<DeviceStaffMember> staff = const [],
}) {
  if (mode == AppMode.kds || mode == AppMode.expo) {
    final station = stations.where((row) => row.id == stationId).firstOrNull;
    return [
      ChecklistItem(ChecklistKind.station, ok: station != null, name: station?.name),
      ChecklistItem(ChecklistKind.printer, ok: station?.printerName != null, name: station?.printerName),
    ];
  }
  if (mode.staffSignIn) {
    final withPin = staff.where((member) => member.pinSet).length;
    return [ChecklistItem(ChecklistKind.staff, ok: withPin > 0, count: withPin)];
  }
  return const [];
}

/// Reads what [checklistItems] needs for the paired device.
final deviceChecklistProvider = FutureProvider.autoDispose<List<ChecklistItem>>((ref) async {
  final session = ref.watch(sessionProvider).value;
  if (session is! Paired) return const [];
  final mode = AppMode.of(session.me.device.mode);
  final client = ref.watch(apiClientProvider);
  if (mode == AppMode.kds || mode == AppMode.expo) {
    final stations = (await client.call((api) => api.posDeviceKitchenStations())).data.toList();
    return checklistItems(mode: mode, stationId: session.me.kitchenStationId, stations: stations);
  }
  if (mode.staffSignIn) {
    final staff = (await client.call((api) => api.posDeviceStaff())).data.toList();
    return checklistItems(mode: mode, staff: staff);
  }
  return checklistItems(mode: mode);
});

/// The first screen after pairing: the device's branch and the checklist of
/// its mode. "Bắt đầu dùng" opens the mode, whatever is still to do.
class DeviceChecklistScreen extends ConsumerWidget {
  const DeviceChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider).value;
    final branch = session is Paired ? session.me.branch.name : '';
    final items = ref.watch(deviceChecklistProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.checklistTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(l10n.checklistIntro(branch)),
              const SizedBox(height: 16),
              ...items.when(
                loading: () => [const Center(child: CircularProgressIndicator())],
                error: (error, _) => [
                  Text(failureMessage(l10n, failureFrom(error))),
                  TextButton(onPressed: () => ref.invalidate(deviceChecklistProvider), child: Text(l10n.retry)),
                ],
                data: (rows) =>
                    rows.isEmpty ? [Text(l10n.checklistNothing)] : [for (final row in rows) _ChecklistTile(item: row)],
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('checklist-start'),
                onPressed: () => ref.read(deviceChecklistPendingProvider.notifier).done(),
                child: Text(l10n.checklistStart),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.item});

  final ChecklistItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (title, detail) = switch (item.kind) {
      ChecklistKind.station => (
        l10n.checklistStation,
        item.ok ? l10n.checklistStationOk(item.name!) : l10n.checklistStationMissing,
      ),
      ChecklistKind.printer => (
        l10n.checklistPrinter,
        item.ok ? l10n.checklistPrinterOk(item.name!) : l10n.checklistPrinterMissing,
      ),
      ChecklistKind.staff => (
        l10n.checklistStaff,
        item.ok ? l10n.checklistStaffOk(item.count) : l10n.checklistStaffMissing,
      ),
    };
    return ListTile(
      key: Key('checklist-${item.kind.name}'),
      contentPadding: EdgeInsets.zero,
      leading: Icon(item.ok ? Icons.check_circle : Icons.error_outline, color: item.ok ? scheme.primary : scheme.error),
      title: Text(title),
      subtitle: Text(detail),
    );
  }
}
