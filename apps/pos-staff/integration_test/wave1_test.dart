// The print station of a first food & drink shop end to end against a running
// development server, on a device or emulator, with a fake LAN printer: a TCP
// server inside this test that takes ESC/POS on port 9100.
//
//   flutter test integration_test/wave1_test.dart \
//     --dart-define=PARKVIET_SERVER=http://10.0.2.2:3000 \
//     --dart-define=PARKVIET_PRINT_STATION_CODE=<pairing code of a print_station device> \
//     --dart-define=PARKVIET_PRINTER_ID=<prefixed id of a LAN printer at 127.0.0.1:9100> \
//     --dart-define=PARKVIET_EXPECT_JOBS=1
//
// Set the branch up first in the POS dashboard: a cafe, quán ăn or căng tin
// branch, a LAN kitchen printer whose address is 127.0.0.1:9100 (the device
// itself) and whose connection goes through the print station. The test pairs
// the station, prints a test page to the fake printer and, with
// PARKVIET_EXPECT_JOBS=1, waits for the server's queued print jobs (kitchen
// tickets of a sale sent to the kitchen) to reach the printer too. Skipped
// without the values. The kitchen screen side is kds_flow_test.dart.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:parkviet_staff/app.dart';
import 'package:parkviet_staff/core/session.dart';

const server = String.fromEnvironment('PARKVIET_SERVER');
const stationCode = String.fromEnvironment('PARKVIET_PRINT_STATION_CODE');
const printerId = String.fromEnvironment('PARKVIET_PRINTER_ID');
const expectJobs = String.fromEnvironment('PARKVIET_EXPECT_JOBS') == '1';

/// A LAN printer stand-in: every connection is one print, its bytes kept.
class FakeEscPosPrinter {
  FakeEscPosPrinter._(this._socket);

  final ServerSocket _socket;
  final List<List<int>> prints = [];

  static Future<FakeEscPosPrinter> start() async {
    final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 9100);
    final printer = FakeEscPosPrinter._(socket);
    socket.listen((client) {
      final bytes = <int>[];
      client.listen(bytes.addAll, onDone: () {
        printer.prints.add(bytes);
        client.destroy();
      });
    });
    return printer;
  }

  Future<void> close() => _socket.close();
}

/// Screens show spinners while they wait, so pumpAndSettle would not end.
Future<void> pumpFor(WidgetTester tester, [Duration span = const Duration(seconds: 1)]) async {
  final end = DateTime.now().add(span);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> pumpUntil(WidgetTester tester, bool Function() done, {Duration timeout = const Duration(seconds: 30)}) async {
  final end = DateTime.now().add(timeout);
  while (!done() && DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a print station prints a test page and the queued kitchen tickets to a LAN printer', (tester) async {
    final printer = await FakeEscPosPrinter.start();
    addTearDown(printer.close);

    await tester.pumpWidget(const ProviderScope(child: ParkvietStaffApp()));
    await pumpFor(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(ParkvietStaffApp)));
    await container.read(sessionProvider.future);
    await container.read(sessionProvider.notifier).unpair();
    await pumpFor(tester);

    await tester.tap(find.byKey(const Key('welcome-manual')));
    await pumpFor(tester);
    await tester.enterText(find.byKey(const Key('manual-server')), server);
    await tester.enterText(find.byKey(const Key('manual-code')), stationCode);
    await tester.tap(find.byKey(const Key('manual-submit')));
    await pumpFor(tester, const Duration(seconds: 3));
    // Just paired, the device shows its checklist first.
    await tester.tap(find.byKey(const Key('checklist-start')));
    await pumpFor(tester);

    final testPrint = find.byKey(const Key('test-print-$printerId'));
    await pumpUntil(tester, () => testPrint.evaluate().isNotEmpty);
    expect(testPrint, findsOneWidget, reason: 'printer $printerId is not on this print station');
    final before = printer.prints.length;
    await tester.tap(testPrint);
    await pumpUntil(tester, () => printer.prints.length > before);
    expect(printer.prints.length, greaterThan(before), reason: 'the test page never reached the printer');
    expect(printer.prints.last, isNotEmpty);

    if (expectJobs) {
      final afterTest = printer.prints.length;
      await pumpUntil(tester, () => printer.prints.length > afterTest, timeout: const Duration(seconds: 60));
      expect(printer.prints.length, greaterThan(afterTest), reason: 'no queued print job reached the printer');
    }
  }, skip: server.isEmpty || stationCode.isEmpty || printerId.isEmpty);
}
