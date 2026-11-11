// End to end against a running development server, on a device or emulator:
//
//   flutter test integration_test/app_test.dart \
//     --dart-define=PARKVIET_SERVER=http://10.0.2.2:3000 \
//     --dart-define=PARKVIET_WAITER_CODE=<pairing code of a waiter device> \
//     --dart-define=PARKVIET_STAFF_ID=<membership id with a PIN> \
//     --dart-define=PARKVIET_STAFF_PIN=<that PIN> \
//     --dart-define=PARKVIET_STATION_CODE=<pairing code of a print station> \
//     --dart-define=PARKVIET_PRINTER_PORT=<port of the station's LAN printer>
//
// Create the devices and codes in the POS dashboard first. For the print
// station, bind a LAN printer at 127.0.0.1:<PARKVIET_PRINTER_PORT> to it and
// queue a job for it (a test print from the dashboard): the test stands in
// for the printer on that port. A test whose values are missing is skipped.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:parkviet_staff/app.dart';
import 'package:parkviet_staff/core/session.dart';
import 'package:parkviet_staff/modes/print_station/print_station_providers.dart';

const server = String.fromEnvironment('PARKVIET_SERVER');
const waiterCode = String.fromEnvironment('PARKVIET_WAITER_CODE');
const staffId = String.fromEnvironment('PARKVIET_STAFF_ID');
const staffPin = String.fromEnvironment('PARKVIET_STAFF_PIN');
const stationCode = String.fromEnvironment('PARKVIET_STATION_CODE');
const printerPort = int.fromEnvironment('PARKVIET_PRINTER_PORT');

Future<ProviderContainer> launch(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: ParkvietStaffApp()));
  await pumpFor(tester);
  final container = ProviderScope.containerOf(tester.element(find.byType(ParkvietStaffApp)));
  // Start from a fresh installation; the pairing survives between runs.
  await container.read(sessionProvider.future);
  await container.read(sessionProvider.notifier).unpair();
  await pumpFor(tester);
  return container;
}

Future<void> pairByCode(WidgetTester tester, String code) async {
  await tester.tap(find.byKey(const Key('welcome-manual')));
  await pumpFor(tester);
  await tester.enterText(find.byKey(const Key('manual-server')), server);
  await tester.enterText(find.byKey(const Key('manual-code')), code);
  await tester.tap(find.byKey(const Key('manual-submit')));
  await pumpFor(tester, const Duration(seconds: 3));
}

/// Screens show spinners while they wait, so pumpAndSettle would not end.
Future<void> pumpFor(WidgetTester tester, [Duration span = const Duration(seconds: 1)]) async {
  final end = DateTime.now().add(span);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> settleUntil(WidgetTester tester, bool Function() done, {Duration timeout = const Duration(seconds: 30)}) async {
  final end = DateTime.now().add(timeout);
  while (!done()) {
    if (DateTime.now().isAfter(end)) fail('timed out');
    await tester.pump(const Duration(milliseconds: 250));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'pairs a waiter device by code and signs a person in with a PIN',
    (tester) async {
      final container = await launch(tester);
      await pairByCode(tester, waiterCode);

      expect(container.read(sessionProvider).value, isA<Paired>());
      await settleUntil(tester, () => find.byKey(const Key('staff-$staffId')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('staff-$staffId')));
      await pumpFor(tester);
      await tester.enterText(find.byKey(const Key('pin-input')), staffPin);
      await tester.tap(find.byKey(const Key('pin-submit')));
      await pumpFor(tester, const Duration(seconds: 3));

      expect(find.byKey(const Key('staff-sign-out')), findsOneWidget);
      await tester.tap(find.byKey(const Key('staff-sign-out')));
      await pumpFor(tester);
      await container.read(sessionProvider.notifier).unpair();
    },
    skip: server.isEmpty || waiterCode.isEmpty || staffId.isEmpty || staffPin.isEmpty,
  );

  testWidgets(
    'a print station claims a queued job, prints it over LAN and reports it printed',
    (tester) async {
      final printer = await ServerSocket.bind(InternetAddress.loopbackIPv4, printerPort);
      final received = <int>[];
      final listening = printer.listen((socket) => socket.listen(received.addAll));

      final container = await launch(tester);
      await pairByCode(tester, stationCode);
      expect(container.read(sessionProvider).value, isA<Paired>());

      final loop = await container.read(printLoopProvider.future);
      await settleUntil(tester, () => loop.state.value.recent.any((entry) => entry.jobId != null));

      final entry = loop.state.value.recent.firstWhere((entry) => entry.jobId != null);
      expect(entry.printed, isTrue, reason: entry.error);
      expect(received, isNotEmpty);
      // The report went out with the print; nothing is left to deliver.
      await settleUntil(tester, () => !loop.state.value.busy);
      expect(loop.state.value.serverFailure, isNull);

      await container.read(sessionProvider.notifier).unpair();
      await pumpFor(tester);
      await listening.cancel();
      await printer.close();
    },
    skip: server.isEmpty || stationCode.isEmpty || printerPort == 0,
  );
}
