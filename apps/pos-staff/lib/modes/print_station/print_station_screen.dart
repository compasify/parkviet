import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/app_mode.dart';
import '../../core/failure_messages.dart';
import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../mode_scaffold.dart';
import 'print_loop.dart';
import 'print_station_providers.dart';
import 'printer_profile.dart';
import 'test_page.dart';

/// The print station: printers it has served, recent jobs, errors, and a
/// local test print.
class PrintStationScreen extends ConsumerStatefulWidget {
  const PrintStationScreen({super.key});

  @override
  ConsumerState<PrintStationScreen> createState() => _PrintStationScreenState();
}

class _PrintStationScreenState extends ConsumerState<PrintStationScreen> {
  late final _keepAwake = ref.read(stationKeepAwakeProvider);
  bool _awakeStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_awakeStarted) return;
    _awakeStarted = true;
    final l10n = AppLocalizations.of(context);
    _keepAwake.start(title: l10n.stationForegroundTitle, text: l10n.stationForegroundText).ignore();
  }

  @override
  void dispose() {
    _keepAwake.stop().ignore();
    super.dispose();
  }

  Future<void> _testPrint(PrintLoop loop, PrinterProfile printer) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final session = ref.read(sessionProvider).value;
    final document = stationTestPage(
      title: l10n.stationTestTitle,
      sample: l10n.stationTestSample,
      printer: printer,
      stationName: session is Paired ? session.me.device.name : '',
      printedAt: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
    );
    final error = await loop.printLocal(printer, document, kind: 'test');
    messenger.showSnackBar(SnackBar(content: Text(error == null ? l10n.stationTestDone : l10n.stationFailed(error))));
  }

  @override
  Widget build(BuildContext context) {
    final loop = ref.watch(printLoopProvider);
    return ModeScaffold(
      mode: AppMode.printStation,
      body: loop.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (loop) => ValueListenableBuilder<PrintStationState>(
          valueListenable: loop.state,
          builder: (context, state, _) => _StationBody(
            state: state,
            runsInBackground: _keepAwake.runsInBackground,
            onTestPrint: (printer) => _testPrint(loop, printer),
          ),
        ),
      ),
    );
  }
}

class _StationBody extends StatelessWidget {
  const _StationBody({required this.state, required this.runsInBackground, required this.onTestPrint});

  final PrintStationState state;
  final bool runsInBackground;
  final void Function(PrinterProfile printer) onTestPrint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final time = DateFormat.Hms();
    final failure = state.serverFailure;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!runsInBackground)
          Card(
            color: theme.colorScheme.tertiaryContainer,
            child: ListTile(leading: const Icon(Icons.warning_amber), title: Text(l10n.stationIosWarning)),
          ),
        if (failure != null)
          Card(
            color: theme.colorScheme.errorContainer,
            child: ListTile(
              leading: const Icon(Icons.cloud_off),
              title: Text(l10n.stationServerError(failureMessage(l10n, failure))),
            ),
          ),
        if (state.busy) const LinearProgressIndicator(),
        const SizedBox(height: 8),
        Text(l10n.stationPrinters, style: theme.textTheme.titleMedium),
        if (state.printers.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l10n.stationNoPrinters))
        else
          for (final printer in state.printers.values)
            ListTile(
              leading: const Icon(Icons.print),
              title: Text(printer.name),
              subtitle: Text([printer.connection, printer.address ?? printer.bluetoothId ?? '', printer.paper]
                  .where((part) => part.isNotEmpty)
                  .join(' · ')),
              trailing: TextButton(
                key: Key('test-print-${printer.id}'),
                onPressed: () => onTestPrint(printer),
                child: Text(l10n.stationTestPrint),
              ),
            ),
        const SizedBox(height: 16),
        Text(l10n.stationRecent, style: theme.textTheme.titleMedium),
        if (state.recent.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l10n.stationNoJobs))
        else
          for (final entry in state.recent)
            ListTile(
              dense: true,
              leading: Icon(
                entry.printed ? Icons.check_circle : Icons.error,
                color: entry.printed ? Colors.green : theme.colorScheme.error,
              ),
              title: Text('${entry.kind} · ${entry.printerName}${entry.jobId == null ? ' · ${l10n.stationLocalTest}' : ''}'),
              subtitle: Text(entry.printed ? l10n.stationPrinted : l10n.stationFailed(entry.error ?? '')),
              trailing: Text(time.format(entry.at)),
            ),
      ],
    );
  }
}
