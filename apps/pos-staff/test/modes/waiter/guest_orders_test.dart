import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/realtime_provider.dart';
import 'package:parkviet_staff/modes/waiter/guest_orders/guest_inbox.dart';
import 'package:parkviet_staff/modes/waiter/guest_orders/guest_orders_api.dart';
import 'package:parkviet_staff/modes/waiter/guest_orders/guest_orders_screen.dart';
import 'package:parkviet_staff/modes/waiter/waiter_context.dart';
import 'package:parkviet_staff/modes/waiter/waiter_screen.dart';
import 'package:parkviet_staff/modes/waiter/waiter_state.dart';
import 'package:pos_api/pos_api.dart';

import 'waiter_fixtures.dart';

Map<String, Object?> guestOrderJson(
  String id, {
  String table = 'Bàn 4',
  String area = 'posarea_1',
}) => {
  'id': id,
  'branch_id': 'posbranch_1',
  'workspace_id': 'posws_$id',
  'resource_id': 'posres_$id',
  'table_name': table,
  'area_id': area,
  'status': 'pending',
  'automatic': false,
  'items': [
    {
      'variant_id': 'variant_1',
      'menu_item_id': 'posmenuitem_1',
      'name': 'Trà đào',
      'size': 'L',
      'quantity': 2,
      'unit_price': '35000.0',
      'amount': '70000.0',
      'note': 'ít đá',
      'modifiers': [
        {'option_id': 'opt_1', 'name': 'Trân châu', 'quantity': 1},
      ],
    },
  ],
  'quoted_total': '70000.0',
  'currency': 'VND',
  'item_count': 2,
  'reject_reason': null,
  'decided_by_id': null,
  'decided_by_name': null,
  'decided_at': null,
  'created_at': '2026-11-12T03:00:00Z',
};

Map<String, Object?> guestRequestJson(
  String id, {
  String kind = 'call_staff',
}) => {
  'id': id,
  'branch_id': 'posbranch_1',
  'resource_id': 'posres_9',
  'table_name': 'Bàn 9',
  'area_id': 'posarea_1',
  'workspace_id': 'posws_9',
  'kind': kind,
  'status': 'open',
  'handled_by_name': null,
  'handled_at': null,
  'created_at': '2026-11-12T03:01:00Z',
};

class FakeGuestOrdersApi implements GuestOrdersApi {
  FakeGuestOrdersApi({
    List<Map<String, Object?>> orders = const [],
    List<Map<String, Object?>> requests = const [],
  }) : orders = [for (final row in orders) parse(GuestOrder.serializer, row)],
       open = [for (final row in requests) parse(GuestRequest.serializer, row)];

  List<GuestOrder> orders;
  List<GuestRequest> open;
  final calls = <String>[];

  @override
  Future<List<GuestOrder>> pending(String branchId, {String? areaId}) async {
    calls.add('pending:${areaId ?? 'all'}');
    return orders
        .where((row) => areaId == null || row.areaId == areaId)
        .toList();
  }

  @override
  Future<List<GuestRequest>> requests(String branchId, {String? areaId}) async {
    calls.add('requests:${areaId ?? 'all'}');
    return open;
  }

  @override
  Future<GuestOrder> accept(String id) async {
    calls.add('accept:$id');
    final order = orders.firstWhere((row) => row.id == id);
    orders = orders.where((row) => row.id != id).toList();
    return order.rebuild((b) => b.status = GuestOrderStatusEnum.accepted);
  }

  @override
  Future<GuestOrder> reject(String id, String reason) async {
    calls.add('reject:$id:$reason');
    final order = orders.firstWhere((row) => row.id == id);
    orders = orders.where((row) => row.id != id).toList();
    return order.rebuild(
      (b) => b
        ..status = GuestOrderStatusEnum.rejected
        ..rejectReason = reason,
    );
  }

  @override
  Future<GuestRequest> done(String id) async {
    calls.add('done:$id');
    final request = open.firstWhere((row) => row.id == id);
    open = [];
    return request.rebuild((b) => b.status = GuestRequestStatusEnum.done);
  }
}

void main() {
  test(
    'reads the inbox again on guest events and rings only for new arrivals',
    () async {
      final events = StreamController<Map<String, Object?>>.broadcast();
      addTearDown(events.close);
      final api = FakeGuestOrdersApi();
      var rings = 0;
      final inbox = GuestInbox(
        api: api,
        branchId: 'posbranch_1',
        events: events.stream,
        onArrive: () => rings++,
      );
      addTearDown(inbox.dispose);

      api.orders = [
        parse(GuestOrder.serializer, guestOrderJson('posguestorder_1')),
      ];
      events.add({'event': 'guest_order.created', 'id': 'posguestorder_1'});
      await pumpEventQueue();
      expect(inbox.waiting, 1);
      expect(rings, 1);

      events.add({'event': 'guest_order.updated', 'id': 'posguestorder_1'});
      events.add({'event': 'menu.sold_out', 'id': 'posmenuitem_1'});
      await pumpEventQueue();
      expect(rings, 1);
      expect(
        api.calls.where((call) => call.startsWith('pending')),
        hasLength(2),
      );
    },
  );

  testWidgets(
    'accepts one order, rejects another with a reason and closes a call',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final api = FakeGuestOrdersApi(
        orders: [
          guestOrderJson('posguestorder_1'),
          guestOrderJson('posguestorder_2', table: 'Bàn 7'),
        ],
        requests: [guestRequestJson('posguestreq_1')],
      );
      final inbox = GuestInbox(
        api: api,
        branchId: 'posbranch_1',
        events: const Stream.empty(),
      );
      addTearDown(inbox.dispose);
      await tester.pumpWidget(
        localized(GuestOrdersScreen(inbox: inbox, canDecide: true)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bàn 9 gọi phục vụ'), findsOneWidget);
      expect(
        find.textContaining('2 × Trà đào (L) · Trân châu · ít đá'),
        findsNWidgets(2),
      );

      await tester.tap(find.byKey(const Key('guest-accept-posguestorder_1')));
      await tester.pumpAndSettle();
      expect(api.calls, contains('accept:posguestorder_1'));
      expect(
        find.byKey(const Key('guest-order-posguestorder_1')),
        findsNothing,
      );
      expect(find.text('Đã thêm vào đơn Bàn 4 và báo bếp.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('guest-reject-posguestorder_2')));
      await tester.pumpAndSettle();
      final confirm = find.byKey(const Key('guest-reject-confirm'));
      expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
      await tester.tap(find.text('Món đã hết'));
      await tester.pumpAndSettle();
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(api.calls, contains('reject:posguestorder_2:Món đã hết'));

      await tester.tap(find.byKey(const Key('guest-done-posguestreq_1')));
      await tester.pumpAndSettle();
      expect(api.calls, contains('done:posguestreq_1'));
      expect(
        find.text('Không có đơn hay yêu cầu nào của khách đang chờ.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows the followed area first, every area on request, and no decision without the right',
    (tester) async {
      final api = FakeGuestOrdersApi(
        orders: [
          guestOrderJson('posguestorder_1'),
          guestOrderJson('posguestorder_2', table: 'Sân 1', area: 'posarea_2'),
        ],
      );
      final inbox = GuestInbox(
        api: api,
        branchId: 'posbranch_1',
        events: const Stream.empty(),
      );
      addTearDown(inbox.dispose);
      await tester.pumpWidget(
        localized(
          GuestOrdersScreen(
            inbox: inbox,
            canDecide: false,
            followedAreaId: 'posarea_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('guest-order-posguestorder_1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('guest-order-posguestorder_2')),
        findsNothing,
      );
      expect(
        find.text('Bạn chưa có quyền duyệt đơn khách gọi qua QR.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('guest-accept-posguestorder_1')),
            )
            .onPressed,
        isNull,
      );

      await tester.tap(find.byKey(const Key('guest-area-all')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('guest-order-posguestorder_2')),
        findsOneWidget,
      );
      expect(
        api.calls,
        containsAllInOrder(['pending:posarea_1', 'pending:all']),
      );
    },
  );

  testWidgets(
    'puts the QR orders on the table board with a count where the branch runs them',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final waiterApi = FakeWaiterApi(
        workspace: workspace(),
        menu: menu(items: const []),
        board: boardOf([tileJson('posres_1', name: 'Bàn 1')]),
      );
      final waiter = WaiterContext(
        api: waiterApi,
        branchId: 'posbranch_1',
        deviceId: 'posdev_1',
        editorId: 'editor-1',
        baseUrl: 'http://pos.test',
      );
      addTearDown(waiter.dispose);
      final ready = ReadyWatcher(api: waiterApi);
      addTearDown(ready.dispose);
      final api = FakeGuestOrdersApi(
        orders: [guestOrderJson('posguestorder_1')],
        requests: [guestRequestJson('posguestreq_1')],
      );
      final inbox = GuestInbox(
        api: api,
        branchId: 'posbranch_1',
        events: const Stream.empty(),
      );
      addTearDown(inbox.dispose);
      await inbox.refresh();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [realtimeProvider.overrideWithValue(null)],
          child: localized(
            TableBoard(
              waiter: waiter,
              ready: ready,
              guests: inbox,
              onFollow: (_) async {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('waiter-guest-orders')), findsNothing);

      waiter.modules.value = {'fnb.qr_order'};
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('waiter-guest-orders')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('waiter-guest-orders')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('waiter-guest-orders')));
      await tester.pumpAndSettle();
      expect(find.byType(GuestOrdersScreen), findsOneWidget);
    },
  );
}
