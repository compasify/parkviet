import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/errors.dart';
import 'package:parkviet_staff/core/realtime.dart';
import 'package:parkviet_staff/l10n/app_localizations.dart';
import 'package:parkviet_staff/modes/kds/board_screen.dart';
import 'package:parkviet_staff/modes/kds/kds_repository.dart';

import 'kds_fixtures.dart';

Widget app(KdsController controller) => MaterialApp(
      locale: const Locale('vi'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: DefaultTabController(length: 3, child: KdsBoard(controller: controller, tick: const Duration(hours: 1))),
      ),
    );

final live = ValueNotifier(RealtimeStatus.connected);

void main() {
  const now = '2026-11-11T12:10:00.000+07:00';

  testWidgets('shows a late ticket with its note, moves an item and bumps the ticket', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = FakeKitchenApi(board(serverNow: now, open: [
      ticketJson('t1', sentAt: '2026-11-11T11:54:00.000+07:00', items: [
        itemJson('i1', name: 'Phở bò', quantity: '2.0', note: 'Không hành'),
        itemJson('i2', name: 'Trà đá', status: 'preparing'),
      ]),
    ]));
    final controller = KdsController(api: api, stationId: 'poskstation_1')..start(status: live);
    addTearDown(controller.dispose);
    await tester.pumpWidget(app(controller));
    await tester.pumpAndSettle();

    expect(find.text('2 x Phở bò'), findsOneWidget);
    expect(find.text('Ghi chú: Không hành'), findsOneWidget);
    expect(find.text('16:00'), findsOneWidget, reason: 'sent 16 minutes ago on the server clock');
    // Past the 15 minute threshold: the card border is the error colour.
    final card = tester.widget<Card>(find.byKey(const Key('ticket-t1')));
    final side = (card.shape! as RoundedRectangleBorder).side;
    expect(side.width, 4);

    api.actionResults.add(ticket(ticketJson('t1', sentAt: '2026-11-11T11:54:00.000+07:00', items: [
      itemJson('i1', name: 'Phở bò', quantity: '2.0', note: 'Không hành', status: 'preparing'),
      itemJson('i2', name: 'Trà đá', status: 'preparing'),
    ])));
    api.current = board(serverNow: now, open: [ticketJson('t1', sentAt: '2026-11-11T11:54:00.000+07:00', items: [
      itemJson('i1', name: 'Phở bò', quantity: '2.0', note: 'Không hành', status: 'preparing'),
      itemJson('i2', name: 'Trà đá', status: 'preparing'),
    ])]);
    await tester.tap(find.byKey(const Key('item-start-i1')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('start:i1'));
    expect(find.byKey(const Key('item-ready-i1')), findsOneWidget);

    api.actionResults.add(ticket(ticketJson('t1', sentAt: '2026-11-11T11:54:00.000+07:00', done: true, items: [
      itemJson('i1', name: 'Phở bò', quantity: '2.0', status: 'ready'),
      itemJson('i2', name: 'Trà đá', status: 'ready'),
    ])));
    api.current = board(serverNow: now);
    await tester.tap(find.byKey(const Key('bump-t1')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('bump:t1'));
    expect(find.text('Chưa có món nào cần làm.'), findsOneWidget);
  });

  testWidgets('offers recall on a finished ticket', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = FakeKitchenApi(board(serverNow: now, done: [
      ticketJson('t9', sentAt: '2026-11-11T12:00:00.000+07:00', done: true, items: [
        itemJson('r1', name: 'Bún chả', status: 'ready', readyAt: '2026-11-11T12:05:00.000+07:00'),
      ]),
    ]));
    final controller = KdsController(api: api, stationId: 'poskstation_1')..start(status: live);
    addTearDown(controller.dispose);
    await tester.pumpWidget(app(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('kds-done')));
    await tester.pumpAndSettle();
    api.actionResults.add(ticket(ticketJson('t9', sentAt: '2026-11-11T12:00:00.000+07:00', items: [
      itemJson('r1', name: 'Bún chả', status: 'preparing'),
    ])));
    api.current = board(serverNow: now, open: [
      ticketJson('t9', sentAt: '2026-11-11T12:00:00.000+07:00', items: [itemJson('r1', name: 'Bún chả', status: 'preparing')]),
    ]);
    await tester.tap(find.byKey(const Key('item-recall-r1')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('recall:r1'));
    expect(find.byKey(const Key('ticket-t9')), findsOneWidget);
    expect(find.byKey(const Key('item-ready-r1')), findsOneWidget);
  });

  testWidgets('shows the call number and guest, and hands a ready order over at the counter', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const header = {'service_mode': 'counter', 'order_number': 12, 'guest_name': 'Lan'};
    final api = FakeKitchenApi(board(serverNow: now, done: [
      ticketJson('t5', sentAt: '2026-11-11T12:00:00.000+07:00', done: true, header: header, items: [
        itemJson('d1', name: 'Trà sữa', status: 'ready', readyAt: '2026-11-11T12:05:00.000+07:00'),
      ]),
    ]));
    final controller = KdsController(api: api, stationId: 'poskstation_1')..start(status: live);
    addTearDown(controller.dispose);
    await tester.pumpWidget(app(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('kds-done')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Phiếu #1 · 12'), findsOneWidget);
    expect(find.text('Khách: Lan'), findsOneWidget);

    api.servedResult = [
      ticket(ticketJson('t5', sentAt: '2026-11-11T12:00:00.000+07:00', done: true, header: header, items: [
        itemJson('d1', name: 'Trà sữa', status: 'served'),
      ])),
    ];
    api.current = board(serverNow: now, done: [
      ticketJson('t5', sentAt: '2026-11-11T12:00:00.000+07:00', done: true, header: header, items: [
        itemJson('d1', name: 'Trà sữa', status: 'served'),
      ]),
    ]);
    await tester.tap(find.byKey(const Key('serve-order-t5')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('serveOrder:posws_aaaa1111'));
    // Nothing ready is left on the order: no hand-over, no recall.
    expect(find.byKey(const Key('serve-order-t5')), findsNothing);
    expect(find.byKey(const Key('item-recall-d1')), findsNothing);
  });

  testWidgets('marks a delivery platform order with the platform and the pickup code', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const header = {
      'service_mode': 'delivery',
      'order_source': 'grabfood',
      'order_number': 3,
      'platform_order_ref': 'GF-1001',
      'pickup_code': 'A12',
    };
    final api = FakeKitchenApi(board(serverNow: now, open: [
      ticketJson('t7', sentAt: '2026-11-11T12:08:00.000+07:00', header: header),
    ]));
    final controller = KdsController(api: api, stationId: 'poskstation_1')..start(status: live);
    addTearDown(controller.dispose);
    await tester.pumpWidget(app(controller));
    await tester.pumpAndSettle();

    final band = find.byKey(const Key('ticket-platform-t7'));
    expect(band, findsOneWidget);
    expect(find.descendant(of: band, matching: find.text('GRABFOOD · Mã lấy: A12')), findsOneWidget);
    expect(find.textContaining('grabfood'), findsNothing);
  });

  testWidgets('sums dishes on the by-item tab and names orders on the by-order tab', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = FakeKitchenApi(board(serverNow: now, open: [
      ticketJson('t1', sentAt: '2026-11-11T12:00:00.000+07:00', items: [itemJson('a', name: 'Cơm tấm')]),
      ticketJson('t2', sequence: 2, workspaceId: 'posws_bbbb2222', sentAt: '2026-11-11T12:02:00.000+07:00',
          header: {'service_mode': 'takeaway', 'customer_name': 'Chị Lan'}, items: [itemJson('b', name: 'Cơm tấm')]),
    ]));
    final controller = KdsController(api: api, stationId: 'poskstation_1')..start(status: live);
    addTearDown(controller.dispose);
    await tester.pumpWidget(app(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('kds-tab-items')));
    await tester.pumpAndSettle();
    expect(find.text('2 x Cơm tấm'), findsOneWidget);
    expect(find.textContaining('#1, #2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('kds-tab-orders')));
    await tester.pumpAndSettle();
    expect(find.text('Đơn 1111'), findsOneWidget);
    expect(find.text('Chị Lan'), findsOneWidget);
  });

  testWidgets('shows when the board was last updated while offline', (tester) async {
    final api = FakeKitchenApi(board(serverNow: now))..boardFailures.add(const AppFailure.unreachable());
    final controller = KdsController(api: api, stationId: 'poskstation_1')..start();
    await tester.pumpWidget(app(controller));
    await tester.pump();
    expect(find.text('Mất kết nối · chưa tải được bếp'), findsOneWidget);

    // The next poll, five seconds on, works.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    // Still no socket: offline, with the time of the good fetch.
    expect(find.textContaining('Mất kết nối · cập nhật lúc'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await controller.dispose();
  });
}
