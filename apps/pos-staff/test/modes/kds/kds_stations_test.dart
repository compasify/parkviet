import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/realtime.dart';
import 'package:parkviet_staff/l10n/app_localizations.dart';
import 'package:parkviet_staff/modes/expo/expo_screen.dart';
import 'package:parkviet_staff/modes/kds/board_screen.dart';
import 'package:parkviet_staff/modes/kds/kds_repository.dart';
import 'package:parkviet_staff/modes/kds/kds_screen.dart';
import 'package:pos_api/pos_api.dart';

import 'kds_fixtures.dart';

Widget localized(Widget body) => MaterialApp(
      locale: const Locale('vi'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: body),
    );

final live = ValueNotifier(RealtimeStatus.connected);

void main() {
  const now = '2026-11-11T12:10:00.000+07:00';

  test('reads several stations at once and narrows them to one way of serving', () async {
    final api = FakeKitchenApi(board(serverNow: now));
    final controller = KdsController(api: api, stationIds: ['s1', 's2'])..start(status: live);
    addTearDown(controller.dispose);
    await pumpEventQueue();
    await controller.setServiceMode('dine_in');
    await controller.selectStations(['s2']);
    expect(api.calls, ['board:s1,s2', 'board:s1,s2:dine_in', 'select:s2', 'board:s2:dine_in']);
    expect(controller.stationId, 's2');
  });

  testWidgets('picks several stations for one screen', (tester) async {
    final api = FakeKitchenApi(board(serverNow: now))
      ..current = board(serverNow: now).rebuild((b) => b.stations.replace([
            standardSerializers.deserializeWith(KitchenStation.serializer, stationJson(id: 's1', name: 'Bếp nóng'))!,
            standardSerializers.deserializeWith(KitchenStation.serializer, stationJson(id: 's2', name: 'Bar'))!,
          ]));
    List<String>? picked;
    await tester.pumpWidget(localized(KdsStationPicker(api: api, onPick: (ids) async => picked = ids)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-s2')));
    await tester.tap(find.byKey(const Key('pick-s1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-confirm')));
    await tester.pumpAndSettle();
    expect(picked, ['s1', 's2'], reason: 'in the order of the stations');
  });

  testWidgets('holds an item to recall it or mark its dish sold out, and strikes a void in red', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = FakeKitchenApi(board(serverNow: now, open: [
      ticketJson('t1', sentAt: '2026-11-11T12:05:00.000+07:00', items: [
        itemJson('i1', name: 'Phở bò', modifiers: [
          {'name': 'Không hành', 'group_name': 'Tùy chọn', 'quantity': 1},
        ]),
        itemJson('i2', name: 'Trà đá', status: 'voided'),
      ]),
    ], done: [
      ticketJson('t2', sentAt: '2026-11-11T12:00:00.000+07:00', done: true, items: [
        itemJson('d1', name: 'Bún chả', status: 'served', recallCount: 1),
      ]),
    ]));
    final controller = KdsController(api: api, stationIds: ['poskstation_1'])..start(status: live);
    addTearDown(controller.dispose);
    final soldOut = <String>[];
    await tester.pumpWidget(localized(DefaultTabController(
      length: 3,
      child: KdsBoard(controller: controller, tick: const Duration(hours: 1), onSoldOut: (item) => soldOut.add(item.name)),
    )));
    await tester.pumpAndSettle();

    final voided = tester.widget<Text>(find.text('1 x Trà đá'));
    expect(voided.style?.decoration, TextDecoration.lineThrough);
    expect(voided.style?.color, Theme.of(tester.element(find.text('1 x Trà đá'))).colorScheme.error);
    expect(tester.widget<Text>(find.text('+ Không hành')).style?.fontWeight, FontWeight.w800);

    await tester.longPress(find.byKey(const Key('item-i1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hold-recall-i1')), findsNothing, reason: 'nothing to recall yet');
    await tester.tap(find.byKey(const Key('hold-sold-out-i1')));
    await tester.pumpAndSettle();
    expect(soldOut, ['Phở bò']);

    await tester.tap(find.byKey(const Key('kds-done')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Gọi lại 1 lần'), findsOneWidget);
    api.actionResults.add(ticket(ticketJson('t2', sentAt: '2026-11-11T12:00:00.000+07:00', items: [
      itemJson('d1', name: 'Bún chả', status: 'preparing', recallCount: 2),
    ])));
    await tester.longPress(find.byKey(const Key('item-d1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hold-recall-d1')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('recall:d1'));
  });

  testWidgets('the pass lists ready items by table and serves one or the whole order', (tester) async {
    final item = itemJson('r1', name: 'Phở bò', status: 'ready', readyAt: '2026-11-11T12:06:00.000+07:00');
    final api = FakeKitchenApi(board(serverNow: now, expo: [
      {
        'workspace_id': 'posws_5',
        'header': {'service_mode': 'dine_in', 'table': 'Bàn 5'},
        'service_mode': 'dine_in',
        'ready_since': '2026-11-11T12:06:00.000+07:00',
        'items': [
          {'item': item, 'kitchen_ticket_id': 't1', 'station_name': 'Bếp nóng'},
        ],
      },
    ]));
    final controller = KdsController(api: api, stationIds: null)..start(status: live);
    addTearDown(controller.dispose);
    await tester.pumpWidget(localized(ExpoBoard(controller: controller, tick: const Duration(hours: 1))));
    await tester.pumpAndSettle();

    expect(find.text('Bàn 5 · Tại bàn'), findsOneWidget);
    expect(find.text('04:00'), findsOneWidget, reason: 'ready four minutes ago on the server clock');
    api.actionResults.add(ticket(ticketJson('t1', sentAt: '2026-11-11T12:00:00.000+07:00', done: true, items: [
      itemJson('r1', name: 'Phở bò', status: 'served'),
    ])));
    await tester.tap(find.byKey(const Key('expo-serve-r1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('expo-serve-all-posws_5')));
    await tester.pumpAndSettle();
    expect(api.calls, containsAllInOrder(['serve:r1', 'serveOrder:posws_5']));
  });
}
