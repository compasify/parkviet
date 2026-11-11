// A restaurant's waiter phone and kitchen screen end to end against a
// running development server, on a device or emulator, one after the other
// on the same device:
//
//   flutter test integration_test/wave2_waiter_kds_test.dart \
//     --dart-define=PARKVIET_SERVER=http://10.0.2.2:3000 \
//     --dart-define=PARKVIET_WAITER_CODE=<pairing code of a waiter device> \
//     --dart-define=PARKVIET_WAITER_PIN=<PIN of a person with pos.table.serve> \
//     --dart-define=PARKVIET_KDS_CODE=<pairing code of a kds device> \
//     --dart-define=PARKVIET_WAITER_CODE_2=<a second waiter pairing code>
//
// Set the branch up first: the demo seed (`POS_FNB_DEMO=1 pnpm spree seed`)
// gives a `nha_hang` branch with tables, the Bếp and Bar stations and a
// menu; open a shift on its table register. Pairing codes are used once,
// so the waiter comes back with a second code.
//
// 1. The waiter phone pairs, its checklist shows someone with a PIN, then
//    it opens a free table for four and sends a first round.
// 2. The kitchen screen pairs, its checklist names no station yet, then it
//    picks the first station and bumps the oldest ticket.
// 3. The waiter phone pairs again: the dish shows as done, a second round
//    sends only what is new, and voiding a sent dish offers the branch's
//    reasons with "Khác" last. Skipped without the values.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:parkviet_staff/app.dart';
import 'package:parkviet_staff/core/session.dart';

const server = String.fromEnvironment('PARKVIET_SERVER');
const waiterCode = String.fromEnvironment('PARKVIET_WAITER_CODE');
const waiterPin = String.fromEnvironment('PARKVIET_WAITER_PIN');
const kdsCode = String.fromEnvironment('PARKVIET_KDS_CODE');
const waiterCode2 = String.fromEnvironment('PARKVIET_WAITER_CODE_2');

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

/// Forgets any pairing, pairs with [code] and looks at the checklist;
/// [check] sees it before "Bắt đầu dùng".
Future<void> pair(WidgetTester tester, ProviderContainer container, String code, void Function() check) async {
  await container.read(sessionProvider.notifier).unpair();
  await pumpFor(tester);
  await tester.tap(find.byKey(const Key('welcome-manual')));
  await pumpFor(tester);
  await tester.enterText(find.byKey(const Key('manual-server')), server);
  await tester.enterText(find.byKey(const Key('manual-code')), code);
  await tester.tap(find.byKey(const Key('manual-submit')));
  await pumpFor(tester, const Duration(seconds: 3));
  check();
  await tester.tap(find.byKey(const Key('checklist-start')));
  await pumpFor(tester);
}

Future<void> signIn(WidgetTester tester) async {
  await tapFirst(tester, 'staff-');
  await tester.enterText(find.byKey(const Key('pin-input')), waiterPin);
  await tester.tap(find.byKey(const Key('pin-submit')));
  await pumpFor(tester, const Duration(seconds: 3));
  expect(find.byKey(const Key('table-grid')), findsOneWidget);
}

Future<void> orderFirstDish(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('order-add')));
  await pumpFor(tester, const Duration(seconds: 2));
  await tapFirst(tester, 'dish-');
  if (find.byKey(const Key('modifier-add')).evaluate().isNotEmpty) {
    await tester.tap(find.byKey(const Key('modifier-add')));
    await pumpFor(tester);
  }
  await tester.tap(find.byKey(const Key('cart-add-send')));
  await pumpFor(tester, const Duration(seconds: 3));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a waiter and the kitchen serve a table in two rounds, with a void', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ParkvietStaffApp()));
    await pumpFor(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(ParkvietStaffApp)));
    await container.read(sessionProvider.future);

    // 1. The waiter seats four at a free table and sends round one.
    await pair(tester, container, waiterCode, () {
      expect(find.byKey(const Key('checklist-staff')), findsOneWidget);
      expect(find.textContaining('đăng nhập được bằng PIN'), findsOneWidget);
    });
    await signIn(tester);
    await tester.tap(find.byKey(const Key('filter-free')));
    await pumpFor(tester);
    await tapFirst(tester, 'table-posres');
    await tester.tap(find.byKey(const Key('guest-key-4')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('guest-confirm')));
    await pumpFor(tester, const Duration(seconds: 3));
    expect(find.byKey(const Key('order-lines')), findsOneWidget);
    await orderFirstDish(tester);
    expect(find.textContaining('mới'), findsWidgets, reason: 'the kitchen has round one as new');

    // 2. The kitchen screen picks its station and bumps the ticket.
    await pair(tester, container, kdsCode, () {
      expect(find.byKey(const Key('checklist-station')), findsOneWidget);
      expect(find.byKey(const Key('checklist-printer')), findsOneWidget);
    });
    await tapFirst(tester, 'pick-poskstation');
    expect(find.byKey(const Key('kds-priority')), findsOneWidget);
    await tapFirst(tester, 'bump-');

    // 3. Back on a waiter phone: done, round two sends only the new dish, and a void offers the branch reasons.
    await pair(tester, container, waiterCode2, () {});
    await signIn(tester);
    await tapFirst(tester, 'table-posres');
    expect(find.textContaining('xong'), findsWidgets, reason: 'the bumped dish shows as done');
    await orderFirstDish(tester);
    expect(find.textContaining('1 mới'), findsWidgets, reason: 'only the new dish went to the kitchen');
    await tapFirst(tester, 'line-');
    await tapFirst(tester, 'line-void-');
    expect(find.byKey(const Key('void-reason-khac')), findsOneWidget);
    expect(keyed('void-reason-'), findsAtLeastNWidgets(2));
    await tester.tap(find.text('Hủy').last);
    await pumpFor(tester);
  }, skip: server.isEmpty || waiterCode.isEmpty || waiterPin.isEmpty || kdsCode.isEmpty || waiterCode2.isEmpty);
}
