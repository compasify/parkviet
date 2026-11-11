// The kitchen screen end to end against a running development server, on a
// device or emulator:
//
//   flutter test integration_test/kds_flow_test.dart \
//     --dart-define=PARKVIET_SERVER=http://10.0.2.2:3000 \
//     --dart-define=PARKVIET_KDS_CODE=<pairing code of a kds device>
//
// Set the branch up first in the POS dashboard: `fnb.kitchen` on, one
// kitchen station, and a sale sent to the kitchen ("Báo bếp" at the counter,
// or completed with the on_complete trigger), so the station has an open
// ticket. The test picks the first station, starts the oldest item, bumps
// its ticket and recalls it from the done list. Skipped without the values.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:parkviet_staff/app.dart';
import 'package:parkviet_staff/core/session.dart';

const server = String.fromEnvironment('PARKVIET_SERVER');
const kdsCode = String.fromEnvironment('PARKVIET_KDS_CODE');

/// Screens show spinners while they wait, so pumpAndSettle would not end.
Future<void> pumpFor(WidgetTester tester, [Duration span = const Duration(seconds: 1)]) async {
  final end = DateTime.now().add(span);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tapFirst(WidgetTester tester, String keyPrefix) async {
  final target = find.byWidgetPredicate((widget) {
    final key = widget.key;
    return key is ValueKey<String> && key.value.startsWith(keyPrefix);
  });
  expect(target, findsWidgets, reason: 'nothing keyed $keyPrefix');
  await tester.tap(target.first);
  await pumpFor(tester, const Duration(seconds: 2));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a kitchen screen picks its station, works a ticket and recalls it', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ParkvietStaffApp()));
    await pumpFor(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(ParkvietStaffApp)));
    await container.read(sessionProvider.future);
    await container.read(sessionProvider.notifier).unpair();
    await pumpFor(tester);

    await tester.tap(find.byKey(const Key('welcome-manual')));
    await pumpFor(tester);
    await tester.enterText(find.byKey(const Key('manual-server')), server);
    await tester.enterText(find.byKey(const Key('manual-code')), kdsCode);
    await tester.tap(find.byKey(const Key('manual-submit')));
    await pumpFor(tester, const Duration(seconds: 3));
    // Just paired, the device shows its checklist first.
    await tester.tap(find.byKey(const Key('checklist-start')));
    await pumpFor(tester);

    // A new kitchen screen asks which station it shows.
    await tapFirst(tester, 'pick-poskstation');
    expect(find.byKey(const Key('kds-priority')), findsOneWidget);

    await tapFirst(tester, 'item-start-');
    expect(find.byWidgetPredicate((widget) => widget.key is ValueKey<String> &&
        (widget.key! as ValueKey<String>).value.startsWith('item-ready-')), findsWidgets);

    await tapFirst(tester, 'bump-');
    await tester.tap(find.byKey(const Key('kds-done')));
    await pumpFor(tester);
    await tapFirst(tester, 'item-recall-');
    expect(find.byKey(const Key('kds-offline')), findsNothing);
  }, skip: server.isEmpty || kdsCode.isEmpty);
}
