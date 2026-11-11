// The waiter's phone end to end against a running development server, on a
// device or emulator:
//
//   flutter test integration_test/waiter_flow_test.dart \
//     --dart-define=PARKVIET_SERVER=http://10.0.2.2:3000 \
//     --dart-define=PARKVIET_WAITER_CODE=<pairing code of a waiter device> \
//     --dart-define=PARKVIET_WAITER_PIN=<PIN of a person with pos.table.serve>
//
// Set the branch up first in the POS dashboard: `fnb.tables` and
// `fnb.kitchen` on, a table register with an open shift, one free table,
// a kitchen station and a menu item without required options. The test
// signs in with the first person's PIN, opens the first free table for two
// guests, adds the first dish, sends it to the kitchen and checks the line
// shows as new in the kitchen. Skipped without the values.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:parkviet_staff/app.dart';
import 'package:parkviet_staff/core/session.dart';

const server = String.fromEnvironment('PARKVIET_SERVER');
const waiterCode = String.fromEnvironment('PARKVIET_WAITER_CODE');
const waiterPin = String.fromEnvironment('PARKVIET_WAITER_PIN');

/// Screens show spinners while they wait, so pumpAndSettle would not end.
Future<void> pumpFor(WidgetTester tester, [Duration span = const Duration(seconds: 1)]) async {
  final end = DateTime.now().add(span);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Finder keyed(String prefix) => find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey<String> && key.value.startsWith(prefix);
    });

Future<void> tapFirst(WidgetTester tester, String prefix) async {
  expect(keyed(prefix), findsWidgets, reason: 'nothing keyed $prefix');
  await tester.tap(keyed(prefix).first);
  await pumpFor(tester, const Duration(seconds: 2));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a waiter opens a table, orders a dish and sends it to the kitchen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ParkvietStaffApp()));
    await pumpFor(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(ParkvietStaffApp)));
    await container.read(sessionProvider.future);
    await container.read(sessionProvider.notifier).unpair();
    await pumpFor(tester);

    await tester.tap(find.byKey(const Key('welcome-manual')));
    await pumpFor(tester);
    await tester.enterText(find.byKey(const Key('manual-server')), server);
    await tester.enterText(find.byKey(const Key('manual-code')), waiterCode);
    await tester.tap(find.byKey(const Key('manual-submit')));
    await pumpFor(tester, const Duration(seconds: 3));

    // A waiter device asks who is working, then their PIN.
    await tapFirst(tester, 'staff-');
    await tester.enterText(find.byKey(const Key('pin-input')), waiterPin);
    await tester.tap(find.byKey(const Key('pin-submit')));
    await pumpFor(tester, const Duration(seconds: 3));
    expect(find.byKey(const Key('table-grid')), findsOneWidget);

    await tester.tap(find.byKey(const Key('filter-free')));
    await pumpFor(tester);
    await tapFirst(tester, 'table-');
    await tester.tap(find.byKey(const Key('guest-key-2')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('guest-confirm')));
    await pumpFor(tester, const Duration(seconds: 3));
    expect(find.byKey(const Key('order-lines')), findsOneWidget);

    await tester.tap(find.byKey(const Key('order-add')));
    await pumpFor(tester, const Duration(seconds: 2));
    await tapFirst(tester, 'dish-');
    if (find.byKey(const Key('modifier-add')).evaluate().isNotEmpty) {
      await tester.tap(find.byKey(const Key('modifier-add')));
      await pumpFor(tester);
    }
    await tester.tap(find.byKey(const Key('cart-add-send')));
    await pumpFor(tester, const Duration(seconds: 3));

    expect(find.textContaining('mới'), findsWidgets, reason: 'the kitchen has the dish as new');
  }, skip: server.isEmpty || waiterCode.isEmpty || waiterPin.isEmpty);
}
