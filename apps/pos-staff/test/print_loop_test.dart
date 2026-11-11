import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/errors.dart';
import 'package:parkviet_staff/modes/print_station/document_renderer.dart';
import 'package:parkviet_staff/modes/print_station/drivers/lan_driver.dart';
import 'package:parkviet_staff/modes/print_station/drivers/printer_driver.dart';
import 'package:parkviet_staff/modes/print_station/escpos_renderer.dart';
import 'package:parkviet_staff/modes/print_station/print_loop.dart';
import 'package:parkviet_staff/modes/print_station/print_queue.dart';
import 'package:parkviet_staff/modes/print_station/printer_profile.dart';
import 'package:parkviet_staff/modes/print_station/tspl_renderer.dart';
import 'package:pos_api/pos_api.dart';

PrintJobClaim claim(String id, {int attempt = 1, String? address = '127.0.0.1'}) =>
    standardSerializers.deserializeWith(PrintJobClaim.serializer, {
      'id': id,
      'kind': 'kitchen_ticket',
      'attempt': attempt,
      'claim_expires_at': '2026-11-11T10:01:00+07:00',
      'printer': {
        'id': 'posprn_1',
        'name': 'Bếp',
        'connection': 'escpos_lan',
        'address': address,
        'bluetooth_id': null,
        'paper': '80mm',
        'command_language': 'escpos',
        'settings': {'cut': true},
      },
      'document': {
        'version': 1,
        'banners': ['BẾP'],
      },
    })!;

class Report {
  Report(this.jobId, this.attempt, this.printed, this.error);

  final String jobId;
  final int attempt;
  final bool printed;
  final String? error;

  @override
  String toString() => 'Report($jobId, $attempt, $printed, $error)';
}

class FakeQueue implements PrintQueue {
  FakeQueue(this.jobs);

  final List<PrintJobClaim> jobs;
  final reports = <Report>[];
  final calls = <String>[];

  /// Thrown, in order, by the next reports.
  final reportFailures = <AppFailure>[];

  @override
  Future<PrintJobClaim?> claim() async {
    calls.add('claim');
    return jobs.isEmpty ? null : jobs.removeAt(0);
  }

  @override
  Future<void> report(String jobId, {required int attempt, required bool printed, String? error}) async {
    calls.add('report $jobId');
    if (reportFailures.isNotEmpty) throw reportFailures.removeAt(0);
    reports.add(Report(jobId, attempt, printed, error));
  }
}

class FakeRenderer implements DocumentRenderer {
  @override
  EscPosRenderer get escPos => throw UnimplementedError();

  @override
  TsplRenderer get tspl => const TsplRenderer();

  @override
  Future<List<int>> render(Map<String, Object?> document, PrinterProfile printer) async => [0x1b, 0x40, 0x42];
}

class FakeDriver implements PrinterDriver {
  final sent = <List<int>>[];

  /// Thrown by every send while set.
  PrinterDeliveryError? failure;

  @override
  Future<void> send(PrinterProfile printer, List<int> bytes) async {
    if (failure != null) throw failure!;
    sent.add(bytes);
  }
}

void main() {
  late FakeDriver driver;

  setUp(() => driver = FakeDriver());

  PrintLoop loopFor(PrintQueue queue) => PrintLoop(
        queue: queue,
        renderer: FakeRenderer(),
        drivers: (_) => driver,
        pollInterval: const Duration(hours: 1),
      );

  Future<void> run(PrintLoop loop) async {
    loop.start();
    await loop.drain();
  }

  test('prints each claimed job and reports it printed, until the queue is empty', () async {
    final queue = FakeQueue([claim('posjob_1'), claim('posjob_2', attempt: 2)]);
    final loop = loopFor(queue);
    await run(loop);

    expect(driver.sent, hasLength(2));
    expect(queue.reports.map((report) => (report.jobId, report.attempt, report.printed)),
        [('posjob_1', 1, true), ('posjob_2', 2, true)]);
    expect(queue.calls.last, 'claim');
    expect(loop.state.value.recent.map((entry) => entry.jobId), ['posjob_2', 'posjob_1']);
    expect(loop.state.value.printers.keys, ['posprn_1']);
    await loop.stop();
  });

  test('reports a printer that did not take the job as failed, with the reason', () async {
    driver.failure = const PrinterDeliveryError('lan: Connection refused (127.0.0.1:9100)');
    final queue = FakeQueue([claim('posjob_1')]);
    final loop = loopFor(queue);
    await run(loop);

    final report = queue.reports.single;
    expect(report.printed, isFalse);
    expect(report.error, 'lan: Connection refused (127.0.0.1:9100)');
    expect(loop.state.value.recent.single.printed, isFalse);
    await loop.stop();
  });

  test('keeps a report the server could not take and delivers it before the next claim', () async {
    final queue = FakeQueue([claim('posjob_1'), claim('posjob_2')])
      ..reportFailures.addAll(const [AppFailure.unreachable(), AppFailure.unreachable()]);
    final loop = loopFor(queue);
    await run(loop);

    // Reported once after printing, once more before claiming again.
    expect(queue.calls, ['claim', 'report posjob_1', 'report posjob_1']);
    expect(loop.state.value.serverFailure, isA<UnreachableFailure>());
    expect(driver.sent, hasLength(1));

    await loop.drain();
    expect(queue.calls.sublist(3), ['report posjob_1', 'claim', 'report posjob_2', 'claim']);
    expect(queue.reports.map((report) => report.jobId), ['posjob_1', 'posjob_2']);
    expect(loop.state.value.serverFailure, isNull);
    expect(driver.sent, hasLength(2), reason: 'the first job is not printed twice');
    await loop.stop();
  });

  test('hands a held report to the next loop when the loop is rebuilt', () async {
    final pending = PendingPrintReport();
    final first = FakeQueue([claim('posjob_1')])
      ..reportFailures.addAll(const [AppFailure.unreachable(), AppFailure.unreachable()]);
    final before = PrintLoop(
        queue: first, renderer: FakeRenderer(), drivers: (_) => driver, pollInterval: const Duration(hours: 1), pending: pending);
    await run(before);
    await before.stop();
    before.dispose();
    expect(pending.report?.jobId, 'posjob_1');

    final second = FakeQueue([]);
    final after = PrintLoop(
        queue: second, renderer: FakeRenderer(), drivers: (_) => driver, pollInterval: const Duration(hours: 1), pending: pending);
    await run(after);

    expect(second.calls.first, 'report posjob_1', reason: 'delivered before the first claim');
    expect(second.calls.skip(1), everyElement('claim'));
    expect(second.reports.single.printed, isTrue);
    expect(pending.report, isNull);
    expect(driver.sent, hasLength(1), reason: 'the job is reported, not printed again');
    await after.stop();
  });

  test('drops a report the server refused as stale and goes on', () async {
    final queue = FakeQueue([claim('posjob_1'), claim('posjob_2')])
      ..reportFailures.add(const AppFailure.conflict(reason: 'print_claim_stale'));
    final loop = loopFor(queue);
    await run(loop);

    expect(queue.reports.map((report) => report.jobId), ['posjob_2']);
    expect(driver.sent, hasLength(2));
    expect(loop.state.value.serverFailure, isNull);
    await loop.stop();
  });

  test('stops claiming while the server is away', () async {
    final queue = _UnreachableQueue();
    final loop = loopFor(queue);
    await run(loop);
    expect(loop.state.value.serverFailure, isA<TimeoutFailure>());
    expect(loop.state.value.busy, isFalse);
    await loop.stop();
  });

  group('LAN driver', () {
    test('sends the bytes over TCP to the printer address', () async {
      final printer = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final received = printer.first.then((socket) => socket.fold<List<int>>([], (all, chunk) => all..addAll(chunk)));

      await const LanDriver().send(
        PrinterProfile(id: 'p', name: 'p', connection: PrinterProfile.lan, address: '127.0.0.1:${printer.port}'),
        [0x1b, 0x40, 0x41],
      );
      expect(await received, [0x1b, 0x40, 0x41]);
      await printer.close();
    });

    const lanPrinter = PrinterProfile(id: 'p', name: 'p', connection: PrinterProfile.lan, address: '127.0.0.1:9100');

    test('counts a job as printed when the printer is slow to close after taking every byte', () async {
      final socket = _StalledSocket(stallClose: true);
      await LanDriver(timeout: const Duration(milliseconds: 50), connect: socket.connect)
          .send(lanPrinter, [0x1b, 0x40, 0x41]);

      expect(socket.written, [0x1b, 0x40, 0x41]);
      expect(socket.destroyed, isTrue);
    });

    test('fails a job whose bytes never left', () async {
      final socket = _StalledSocket(stallFlush: true);
      await expectLater(
        LanDriver(timeout: const Duration(milliseconds: 50), connect: socket.connect).send(lanPrinter, [0x00]),
        throwsA(isA<PrinterDeliveryError>().having((error) => error.message, 'message', contains('timeout'))),
      );
      expect(socket.destroyed, isTrue);
    });

    test('names the address when nothing listens there', () async {
      final unused = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = unused.port;
      await unused.close();
      await expectLater(
        const LanDriver(timeout: Duration(seconds: 2)).send(
          PrinterProfile(id: 'p', name: 'p', connection: PrinterProfile.lan, address: '127.0.0.1:$port'),
          [0x00],
        ),
        throwsA(isA<PrinterDeliveryError>().having((error) => error.message, 'message', contains('127.0.0.1:$port'))),
      );
    });

    test('reads the port from the address, 9100 by default', () {
      expect(LanDriver.parseAddress('192.168.1.50'), ('192.168.1.50', 9100));
      expect(LanDriver.parseAddress(' 192.168.1.50:9101 '), ('192.168.1.50', 9101));
      expect(() => LanDriver.parseAddress(''), throwsA(isA<PrinterDeliveryError>()));
      expect(() => LanDriver.parseAddress('host:99999'), throwsA(isA<PrinterDeliveryError>()));
    });
  });
}

/// A printer connection whose flush or close never finishes.
class _StalledSocket implements Socket {
  _StalledSocket({this.stallFlush = false, this.stallClose = false});

  final bool stallFlush;
  final bool stallClose;
  final written = <int>[];
  bool destroyed = false;

  Future<Socket> connect(dynamic host, int port, {Duration? timeout}) async => this;

  @override
  void add(List<int> data) => written.addAll(data);

  @override
  Future<void> flush() => stallFlush ? Completer<void>().future : Future.value();

  @override
  Future<void> close() => stallClose ? Completer<void>().future : Future.value();

  @override
  void destroy() => destroyed = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnreachableQueue implements PrintQueue {
  @override
  Future<PrintJobClaim?> claim() async => throw const AppFailure.timeout();

  @override
  Future<void> report(String jobId, {required int attempt, required bool printed, String? error}) async {}
}
