import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/realtime_provider.dart';
import '../../core/session.dart';
import 'document_renderer.dart';
import 'escpos_renderer.dart';
import 'print_loop.dart';
import 'print_queue.dart';
import 'station_keep_awake.dart';

part 'print_station_providers.g.dart';

@Riverpod(keepAlive: true)
Future<DocumentRenderer> documentRenderer(Ref ref) async =>
    DocumentRenderer(escPos: await EscPosRenderer.load());

@riverpod
StationKeepAwake stationKeepAwake(Ref ref) => const StationKeepAwake();

/// The report the server has not taken yet, kept across rebuilds of
/// [printLoop] (a new session or realtime connection builds a new loop).
@Riverpod(keepAlive: true)
PendingPrintReport pendingPrintReport(Ref ref) => PendingPrintReport();

/// The running loop of this print station, alive while its screen is.
@riverpod
Future<PrintLoop> printLoop(Ref ref) async {
  final renderer = await ref.watch(documentRendererProvider.future);
  final loop = PrintLoop(
    queue: ApiPrintQueue(ref.watch(apiClientProvider)),
    renderer: renderer,
    pending: ref.watch(pendingPrintReportProvider),
  );
  final realtime = ref.watch(realtimeProvider);
  loop.start(events: realtime?.events, subscribed: realtime?.subscribed);
  ref.onDispose(() async {
    await loop.stop();
    loop.dispose();
  });
  return loop;
}
