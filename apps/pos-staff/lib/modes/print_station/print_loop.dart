import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_api/pos_api.dart';

import '../../core/config.dart';
import '../../core/errors.dart';
import 'document_renderer.dart';
import 'drivers/driver_registry.dart';
import 'drivers/printer_driver.dart';
import 'print_queue.dart';
import 'printer_profile.dart';

part 'print_loop.freezed.dart';

@freezed
abstract class PrintLogEntry with _$PrintLogEntry {
  const factory PrintLogEntry({
    /// Null for a local test print, which the server does not know about.
    String? jobId,
    required String kind,
    required String printerName,
    required bool printed,
    String? error,
    required DateTime at,
  }) = _PrintLogEntry;
}

@freezed
abstract class PrintStationState with _$PrintStationState {
  const factory PrintStationState({
    @Default(false) bool running,
    @Default(false) bool busy,
    /// The last time the server could not be reached, cleared on success.
    AppFailure? serverFailure,
    @Default({}) Map<String, PrinterProfile> printers,
    @Default([]) List<PrintLogEntry> recent,
  }) = _PrintStationState;
}

class PrintReport {
  const PrintReport(this.jobId, this.attempt, this.printed, this.error);

  final String jobId;
  final int attempt;
  final bool printed;
  final String? error;
}

/// The report the server has not taken yet. It lives outside any one
/// [PrintLoop]: the loop is rebuilt when the session or the realtime
/// connection changes, and a held report must reach the server from the
/// next loop instead of being lost with the old one.
class PendingPrintReport {
  PrintReport? report;
}

/// Claims, prints and reports, one job at a time.
///
/// It drains the queue when `print_job.created` arrives, after every
/// realtime (re)subscription, and every [pollInterval] in case an event was
/// lost. Printing is at-least-once: the report of an attempt is delivered
/// before the next claim, and kept for retry while the server is away.
class PrintLoop {
  PrintLoop({
    required this.queue,
    required this.renderer,
    this.drivers = defaultDriverFor,
    this.pollInterval = AppConfig.printPollInterval,
    this.recentLimit = 30,
    PendingPrintReport? pending,
    DateTime Function()? now,
  })  : _pending = pending ?? PendingPrintReport(),
        _now = now ?? DateTime.now;

  final PrintQueue queue;
  final DocumentRenderer renderer;
  final DriverResolver drivers;
  final Duration pollInterval;
  final int recentLimit;
  final DateTime Function() _now;

  final ValueNotifier<PrintStationState> state = ValueNotifier(const PrintStationState());

  Timer? _poll;
  StreamSubscription<Object?>? _events;
  StreamSubscription<void>? _subscribed;
  final PendingPrintReport _pending;
  Future<void>? _draining;
  bool _again = false;

  void start({Stream<Map<String, Object?>>? events, Stream<void>? subscribed}) {
    if (state.value.running) return;
    state.value = state.value.copyWith(running: true);
    _events = events?.listen((event) {
      if (event['event'] == 'print_job.created') unawaited(drain());
    });
    _subscribed = subscribed?.listen((_) => unawaited(drain()));
    _poll = Timer.periodic(pollInterval, (_) => unawaited(drain()));
    unawaited(drain());
  }

  Future<void> stop() async {
    _poll?.cancel();
    await _events?.cancel();
    await _subscribed?.cancel();
    _poll = null;
    _events = null;
    _subscribed = null;
    state.value = state.value.copyWith(running: false);
    await _draining;
  }

  void dispose() {
    _poll?.cancel();
    unawaited(_events?.cancel());
    unawaited(_subscribed?.cancel());
    state.dispose();
  }

  /// Runs until the queue is empty. A call while one runs makes it go
  /// round once more instead of starting a second.
  Future<void> drain() {
    if (_draining != null) {
      _again = true;
      return _draining!;
    }
    final run = _drainLoop().whenComplete(() => _draining = null);
    _draining = run;
    return run;
  }

  Future<void> _drainLoop() async {
    do {
      _again = false;
      _setBusy(true);
      try {
        while (state.value.running) {
          if (!await _deliverPending()) return;
          final job = await queue.claim();
          _serverReached();
          if (job == null) break;
          await _printClaimed(job);
        }
      } on AppFailure catch (failure) {
        state.value = state.value.copyWith(serverFailure: failure);
        return;
      } finally {
        _setBusy(false);
      }
    } while (_again && state.value.running);
  }

  Future<void> _printClaimed(PrintJobClaim job) async {
    final printer = PrinterProfile.fromClaim(job.printer);
    state.value = state.value.copyWith(printers: {...state.value.printers, printer.id: printer});
    final document = job.document.value;
    final error = await _print(printer, document is Map ? document.cast<String, Object?>() : null);
    _log(PrintLogEntry(
      jobId: job.id,
      kind: job.kind,
      printerName: printer.name,
      printed: error == null,
      error: error,
      at: _now(),
    ));
    _pending.report = PrintReport(job.id, job.attempt, error == null, error);
    await _deliverPending();
  }

  /// Prints a document on a printer without the server: the station's own
  /// test page. Returns the error, or null when it printed.
  Future<String?> printLocal(PrinterProfile printer, Map<String, Object?> document, {required String kind}) async {
    final error = await _print(printer, document);
    _log(PrintLogEntry(kind: kind, printerName: printer.name, printed: error == null, error: error, at: _now()));
    return error;
  }

  Future<String?> _print(PrinterProfile printer, Map<String, Object?>? document) async {
    if (document == null) return 'document: not an object';
    try {
      final bytes = await renderer.render(document, printer);
      await drivers(printer).send(printer, bytes);
      return null;
    } on PrinterDeliveryError catch (error) {
      return error.message;
    } on Object catch (error) {
      return 'render: $error';
    }
  }

  /// False when the server could not take the report yet.
  Future<bool> _deliverPending() async {
    final pending = _pending.report;
    if (pending == null) return true;
    try {
      await queue.report(pending.jobId, attempt: pending.attempt, printed: pending.printed, error: pending.error);
      _serverReached();
    } on ConflictFailure {
      // The lease ran out and the job went to another attempt; this report
      // can no longer count.
    } on AppFailure catch (failure) {
      if (isTransient(failure)) {
        state.value = state.value.copyWith(serverFailure: failure);
        return false;
      }
    }
    // Only this report: an older loop still finishing may have stored a newer one.
    if (identical(_pending.report, pending)) _pending.report = null;
    return true;
  }

  void _serverReached() {
    if (state.value.serverFailure != null) state.value = state.value.copyWith(serverFailure: null);
  }

  void _setBusy(bool busy) {
    if (state.value.busy != busy) state.value = state.value.copyWith(busy: busy);
  }

  void _log(PrintLogEntry entry) {
    final recent = [entry, ...state.value.recent];
    state.value = state.value.copyWith(
      recent: recent.length > recentLimit ? recent.sublist(0, recentLimit) : recent,
    );
  }
}
