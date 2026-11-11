import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_api/pos_api.dart';
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

/// The kitchen screen (`kds`) shows one station, picked on the screen and
/// remembered on the server; the pass (`expo`) shows every station. Both
/// work as the device: no PIN except to mark a dish sold out.
class KdsScreen extends ConsumerStatefulWidget {
  const KdsScreen({super.key, this.mode = AppMode.kds});

  final AppMode mode;

  @override
  ConsumerState<KdsScreen> createState() => _KdsScreenState();
}

class _KdsScreenState extends ConsumerState<KdsScreen> {
  late final _keepAwake = ref.read(kdsKeepAwakeProvider);
  KdsController? _controller;
  bool _picking = false;
  String? _stationName;

  bool get _kitchen => widget.mode == AppMode.kds;

  @override
  void initState() {
    super.initState();
    _keepAwake.enable().ignore();
    final session = ref.read(sessionProvider).value;
    final stationId = session is Paired ? session.me.device.kitchenStationId : null;
    if (_kitchen && stationId == null) {
      _picking = true;
    } else {
      _start(_kitchen ? stationId : null);
    }
  }

  @override
  void dispose() {
    _keepAwake.disable().ignore();
    _controller?.dispose();
    super.dispose();
  }

  void _start(String? stationId) {
    final realtime = ref.read(realtimeProvider);
    final chime = ref.read(kdsChimeProvider);
    _controller = KdsController(api: ref.read(kitchenApiProvider), stationId: stationId, onNewTicket: chime)
      ..state.addListener(_named)
      ..start(events: realtime?.events, subscribed: realtime?.subscribed, status: realtime?.status);
  }

  void _named() {
    final name = _controller?.state.value.board?.station?.name;
    if (name != _stationName && mounted) setState(() => _stationName = name);
  }

  Future<void> _pick(String? stationId) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final controller = _controller;
      if (controller == null) {
        await ref.read(kitchenApiProvider).selectStation(stationId);
        _start(stationId);
      } else {
        await controller.selectStation(stationId);
      }
      if (mounted) setState(() => _picking = false);
    } on AppFailure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(failureMessage(l10n, failure))));
    }
  }

  void _soldOut() {
    final session = ref.read(sessionProvider).value;
    if (session is! Paired) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SoldOutSheet(
        api: ref.read(kitchenApiProvider),
        branchId: session.me.branch.id,
        stationId: _controller?.stationId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller;
    return DefaultTabController(
      length: 3,
      child: ModeScaffold(
        mode: widget.mode,
        actions: [
          if (_kitchen && !_picking)
            TextButton.icon(
              key: const Key('kds-change-station'),
              onPressed: () => setState(() => _picking = true),
              icon: const Icon(Icons.swap_horiz),
              label: Text(_stationName ?? l10n.kdsAllStations),
            ),
          if (_kitchen && !_picking)
            TextButton.icon(
              key: const Key('kds-sold-out'),
              onPressed: _soldOut,
              icon: const Icon(Icons.block),
              label: Text(l10n.kdsSoldOut),
            ),
        ],
        body: _picking || controller == null
            ? _StationPicker(api: ref.read(kitchenApiProvider), onPick: _pick)
            : KdsBoard(controller: controller),
      ),
    );
  }
}

class _StationPicker extends StatefulWidget {
  const _StationPicker({required this.api, required this.onPick});

  final KitchenApi api;
  final Future<void> Function(String? stationId) onPick;

  @override
  State<_StationPicker> createState() => _StationPickerState();
}

class _StationPickerState extends State<_StationPicker> {
  late final Future<List<KitchenStation>> _stations = widget.api.stations();

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
            const SizedBox(height: 16),
            if (stations.isEmpty) Text(l10n.kdsNoStations),
            for (final station in stations)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  height: 64,
                  child: FilledButton.tonal(
                    key: Key('pick-${station.id}'),
                    onPressed: () => widget.onPick(station.id),
                    child: Text(station.name, style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            if (stations.length > 1)
              SizedBox(
                height: 64,
                child: OutlinedButton(
                  key: const Key('pick-all'),
                  onPressed: () => widget.onPick(null),
                  child: Text(l10n.kdsAllStations, style: const TextStyle(fontSize: 20)),
                ),
              ),
          ],
        );
      },
    );
  }
}
