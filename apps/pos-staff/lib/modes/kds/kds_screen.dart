import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_api/pos_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/app_mode.dart';
import '../../core/errors.dart';
import '../../core/failure_messages.dart';
import '../../core/realtime_provider.dart';
import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../mode_scaffold.dart';
import 'board_screen.dart';
import 'kds_repository.dart';
import 'sold_out_sheet.dart';
import 'ticket_card.dart';

final kitchenApiProvider = Provider<KitchenApi>((ref) => ApiKitchenApi(ref.watch(apiClientProvider)));

/// Keeps the kitchen screen on while it shows the board.
class KdsKeepAwake {
  const KdsKeepAwake();

  Future<void> enable() => WakelockPlus.enable();
  Future<void> disable() => WakelockPlus.disable();
}

final kdsKeepAwakeProvider = Provider<KdsKeepAwake>((ref) => const KdsKeepAwake());

/// The sound of a new ticket.
final kdsChimeProvider = Provider<VoidCallback>((ref) => () => SystemSound.play(SystemSoundType.alert));

/// The stations a kitchen screen shows, kept on the device: the server
/// remembers one station per device, a screen may show several.
class KdsStationMemory {
  const KdsStationMemory();

  static const _key = 'kds.station_ids';
  static const _every = '*';

  /// Null when nothing is stored; an empty list for every station.
  Future<List<String>?> read() async {
    final stored = (await SharedPreferences.getInstance()).getStringList(_key);
    if (stored == null) return null;
    return stored.contains(_every) ? const [] : stored;
  }

  Future<void> write(List<String>? stationIds) async =>
      (await SharedPreferences.getInstance()).setStringList(_key, stationIds ?? const [_every]);
}

final kdsStationMemoryProvider = Provider<KdsStationMemory>((ref) => const KdsStationMemory());

/// The kitchen screen (`kds`) shows the stations picked on the screen, one
/// or several; the pass (`expo`) has its own screen. It works as the
/// device: no PIN except to mark a dish sold out.
class KdsScreen extends ConsumerStatefulWidget {
  const KdsScreen({super.key});

  @override
  ConsumerState<KdsScreen> createState() => _KdsScreenState();
}

class _KdsScreenState extends ConsumerState<KdsScreen> {
  late final _keepAwake = ref.read(kdsKeepAwakeProvider);
  late final _memory = ref.read(kdsStationMemoryProvider);
  KdsController? _controller;
  bool _picking = false;
  bool _loading = true;
  String? _stationsLabel;

  @override
  void initState() {
    super.initState();
    _keepAwake.enable().ignore();
    _open();
  }

  Future<void> _open() async {
    final session = ref.read(sessionProvider).value;
    final home = session is Paired ? session.me.device.kitchenStationId : null;
    final stored = await _memory.read();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (stored != null) {
        _start(stored.isEmpty ? null : stored);
      } else if (home != null) {
        _start([home]);
      } else {
        _picking = true;
      }
    });
  }

  @override
  void dispose() {
    _keepAwake.disable().ignore();
    _controller?.dispose();
    super.dispose();
  }

  void _start(List<String>? stationIds) {
    final realtime = ref.read(realtimeProvider);
    final chime = ref.read(kdsChimeProvider);
    _controller = KdsController(api: ref.read(kitchenApiProvider), stationIds: stationIds, onNewTicket: chime)
      ..state.addListener(_named)
      ..start(events: realtime?.events, subscribed: realtime?.subscribed, status: realtime?.status);
  }

  void _named() {
    final controller = _controller;
    final board = controller?.state.value.board;
    if (board == null) return;
    final label = controller!.stationIds == null ? null : board.stations.map((row) => row.name).join(', ');
    if (label != _stationsLabel && mounted) setState(() => _stationsLabel = label);
  }

  Future<void> _pick(List<String>? stationIds) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final controller = _controller;
      if (controller == null) {
        await ref.read(kitchenApiProvider).selectStation(stationIds?.first);
        _start(stationIds);
      } else {
        await controller.selectStations(stationIds);
      }
      await _memory.write(stationIds);
      if (mounted) setState(() => _picking = false);
    } on AppFailure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(failureMessage(l10n, failure))));
    }
  }

  void _soldOut() {
    final session = ref.read(sessionProvider).value;
    if (session is! Paired) return;
    showSoldOutSheet(context, api: ref.read(kitchenApiProvider), branchId: session.me.branch.id,
        stationId: _controller?.stationId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller;
    final session = ref.watch(sessionProvider).value;
    return DefaultTabController(
      length: 3,
      child: ModeScaffold(
        mode: AppMode.kds,
        actions: [
          if (!_picking && controller != null)
            _ServiceModeMenu(
              value: controller.serviceMode,
              onChanged: (mode) async {
                await controller.setServiceMode(mode);
                if (mounted) setState(() {});
              },
            ),
          if (!_picking)
            TextButton.icon(
              key: const Key('kds-change-station'),
              onPressed: () => setState(() => _picking = true),
              icon: const Icon(Icons.swap_horiz),
              label: Text(_stationsLabel ?? l10n.kdsAllStations, overflow: TextOverflow.ellipsis),
            ),
          if (!_picking)
            TextButton.icon(
              key: const Key('kds-sold-out'),
              onPressed: _soldOut,
              icon: const Icon(Icons.block),
              label: Text(l10n.kdsSoldOut),
            ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _picking || controller == null
                ? KdsStationPicker(
                    api: ref.read(kitchenApiProvider),
                    initial: controller?.stationIds,
                    onPick: _pick,
                  )
                : KdsBoard(
                    controller: controller,
                    onSoldOut: session is Paired
                        ? (item) => showSoldOutSheet(context,
                            api: ref.read(kitchenApiProvider),
                            branchId: session.me.branch.id,
                            stationId: controller.stationId,
                            query: item.name)
                        : null,
                  ),
      ),
    );
  }
}

/// Narrows the board to one way of serving.
class _ServiceModeMenu extends StatelessWidget {
  const _ServiceModeMenu({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  static const modes = ['dine_in', 'takeaway', 'delivery', 'counter'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      key: const Key('kds-service-mode'),
      tooltip: l10n.kdsServiceModeFilter,
      initialValue: value ?? '',
      onSelected: (mode) => onChanged(mode.isEmpty ? null : mode),
      itemBuilder: (_) => [
        PopupMenuItem(key: const Key('kds-mode-all'), value: '', child: Text(l10n.kdsServiceModeAll)),
        for (final mode in modes)
          PopupMenuItem(key: Key('kds-mode-$mode'), value: mode, child: Text(serviceModeLabel(l10n, mode))),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            const Icon(Icons.filter_list),
            const SizedBox(width: 4),
            Text(value == null ? l10n.kdsServiceModeAll : serviceModeLabel(l10n, value!)),
          ],
        ),
      ),
    );
  }
}

/// Picks one station, several, or every station of the branch.
class KdsStationPicker extends StatefulWidget {
  const KdsStationPicker({super.key, required this.api, required this.onPick, this.initial});

  final KitchenApi api;
  final List<String>? initial;

  /// Null for every station.
  final Future<void> Function(List<String>? stationIds) onPick;

  @override
  State<KdsStationPicker> createState() => _KdsStationPickerState();
}

class _KdsStationPickerState extends State<KdsStationPicker> {
  late final Future<List<KitchenStation>> _stations = widget.api.stations();
  late final _chosen = <String>{...?widget.initial};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<List<KitchenStation>>(
      future: _stations,
      builder: (context, snapshot) {
        final error = snapshot.error;
        if (error != null) {
          return Center(child: Text(error is AppFailure ? failureMessage(l10n, error) : '$error'));
        }
        final stations = snapshot.data;
        if (stations == null) return const Center(child: CircularProgressIndicator());
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.kdsStationPick, style: Theme.of(context).textTheme.headlineSmall),
            Text(l10n.kdsStationPickHint),
            const SizedBox(height: 16),
            if (stations.isEmpty) Text(l10n.kdsNoStations),
            for (final station in stations)
              CheckboxListTile(
                key: Key('pick-${station.id}'),
                value: _chosen.contains(station.id),
                title: Text(station.name, style: const TextStyle(fontSize: 20)),
                subtitle: station.kind == KitchenStationKindEnum.expo ? Text(l10n.kdsStationExpo) : null,
                onChanged: (on) => setState(() => on == true ? _chosen.add(station.id) : _chosen.remove(station.id)),
              ),
            const SizedBox(height: 16),
            SizedBox(
              height: 64,
              child: FilledButton(
                key: const Key('pick-confirm'),
                onPressed: _chosen.isEmpty
                    ? null
                    : () => widget.onPick([for (final station in stations) if (_chosen.contains(station.id)) station.id]),
                child: Text(l10n.kdsStationShow(_chosen.length), style: const TextStyle(fontSize: 20)),
              ),
            ),
            if (stations.length > 1) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 64,
                child: OutlinedButton(
                  key: const Key('pick-all'),
                  onPressed: () => widget.onPick(null),
                  child: Text(l10n.kdsAllStations, style: const TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
