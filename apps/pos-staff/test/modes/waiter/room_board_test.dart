import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/errors.dart';
import 'package:parkviet_staff/modes/waiter/room_board_screen.dart';
import 'package:parkviet_staff/modes/waiter/table_order_screen.dart';
import 'package:parkviet_staff/modes/waiter/waiter_context.dart';

import 'waiter_fixtures.dart';

WaiterContext roomContext(
  FakeWaiterApi api, {
  Set<String> capabilities = const {timedOperateCapability},
  Stream<Map<String, Object?>> events = const Stream.empty(),
  String? staffId,
}) => WaiterContext(
  api: api,
  branchId: 'posbranch_1',
  deviceId: 'posdev_1',
  editorId: 'editor-1',
  baseUrl: 'http://pos.test',
  events: events,
)
  ..capabilities.value = capabilities
  ..staffId.value = staffId;

FakeWaiterApi pausedApi({bool tooLong = false}) => FakeWaiterApi(
  workspace: workspace(),
  board: boardOf([
    roomJson(
      'posres_1',
      name: 'P1',
      state: 'playing',
      orders: [orderJson('posws_1')],
      timed: timedJson(
        'postimed_1',
        status: 'paused',
        playedSeconds: 30 * 60,
        prepaidMinutes: 120,
        pauseTooLong: tooLong,
      ),
    ),
  ]),
);

FakeWaiterApi roomApi() => FakeWaiterApi(
  workspace: workspace(),
  board: boardOf([
    tileJson('posres_t', name: 'Bàn 1'),
    roomJson(
      'posres_1',
      name: 'P1',
      state: 'playing',
      orders: [orderJson('posws_1')],
      timed: timedJson('postimed_1'),
    ),
    roomJson('posres_2', name: 'VIP 1'),
    roomJson('posres_3', name: 'Bida 1', kind: 'billiard'),
  ]),
);

Future<void> pumpRooms(
  WidgetTester tester,
  WaiterContext waiter, {
  DateTime Function() now = DateTime.now,
}) async {
  await tester.binding.setSurfaceSize(const Size(800, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  addTearDown(waiter.dispose);
  await tester.pumpWidget(localized(RoomBoardScreen(waiter: waiter, now: now)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'shows rooms with a clock counted from the server start and the price so far',
    (tester) async {
      final api = roomApi();
      // This phone's clock runs 5 minutes behind the server's.
      var phone = DateTime.parse('2026-11-12T04:55:00Z');
      await pumpRooms(tester, roomContext(api), now: () => phone);

      expect(find.byKey(const Key('room-posres_1')), findsOneWidget);
      expect(find.byKey(const Key('room-posres_3')), findsOneWidget);
      // Tables are not rooms.
      expect(find.byKey(const Key('room-posres_t')), findsNothing);
      // The board was read at 12:00 on the server; the clock started at 11:20.
      final clock = tester.widget<Text>(
        find.byKey(const Key('room-clock-posres_1')),
      );
      expect(clock.data, '40:00');
      expect(find.text('Tạm tính 75.000đ'), findsOneWidget);
      expect(find.text('Đang tính giờ'), findsOneWidget);

      phone = phone.add(const Duration(seconds: 65));
      await tester.pump(const Duration(seconds: 1));
      final later = tester.widget<Text>(
        find.byKey(const Key('room-clock-posres_1')),
      );
      expect(later.data, '41:05');
    },
  );

  testWidgets('starts a free room without sending a time', (tester) async {
    final api = roomApi();
    await pumpRooms(tester, roomContext(api));

    await tester.tap(find.byKey(const Key('room-posres_2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('room-stop-posres_2')), findsNothing);
    await tester.tap(find.byKey(const Key('room-start-posres_2')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('start-clock:posres_2:-'));
  });

  testWidgets(
    'hides the clock commands from someone who does not run play time',
    (tester) async {
      final api = roomApi();
      await pumpRooms(tester, roomContext(api, capabilities: const {}));

      await tester.tap(find.byKey(const Key('room-posres_1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('room-stop-posres_1')), findsNothing);
      expect(find.byKey(const Key('room-move-posres_1')), findsNothing);
      expect(find.byKey(const Key('room-order-posres_1')), findsOneWidget);
    },
  );

  testWidgets('stops a running room after asking and says what was billed', (
    tester,
  ) async {
    final api = roomApi();
    await pumpRooms(tester, roomContext(api));

    await tester.tap(find.byKey(const Key('room-posres_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('room-stop-posres_1')));
    await tester.pumpAndSettle();
    expect(api.calls, isNot(contains('stop-clock:postimed_1')));
    await tester.tap(find.byKey(const Key('room-stop-confirm')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('stop-clock:postimed_1'));
    expect(find.text('Đã dừng giờ, tiền giờ 100.000đ.'), findsOneWidget);
  });

  testWidgets('moves a running clock to a free room', (tester) async {
    final api = roomApi();
    await pumpRooms(tester, roomContext(api));

    await tester.tap(find.byKey(const Key('room-posres_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('room-move-posres_1')));
    await tester.pumpAndSettle();
    // Only free rooms are offered, not tables.
    expect(find.byKey(const Key('room-move-to-posres_t')), findsNothing);
    await tester.tap(find.byKey(const Key('room-move-to-posres_3')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('move-clock:postimed_1:posres_3'));
  });

  testWidgets('says why a start is refused', (tester) async {
    final api = roomApi();
    await pumpRooms(tester, roomContext(api));
    api.failures.add(const AppFailure.conflict(reason: 'rate_plan_missing'));

    await tester.tap(find.byKey(const Key('room-posres_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('room-start-posres_2')));
    await tester.pumpAndSettle();
    expect(
      find.text('Phòng này chưa có bảng giá giờ. Báo quản lý thêm bảng giá.'),
      findsOneWidget,
    );
  });

  testWidgets('pauses a running room', (tester) async {
    final api = roomApi();
    await pumpRooms(tester, roomContext(api));

    await tester.tap(find.byKey(const Key('room-posres_1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('room-resume-posres_1')), findsNothing);
    await tester.tap(find.byKey(const Key('room-pause-posres_1')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('pause-clock:postimed_1'));
  });

  testWidgets(
    'shows a paused clock standing still, with the package left, and resumes it',
    (tester) async {
      final api = pausedApi();
      var phone = DateTime.parse('2026-11-12T05:00:00Z');
      await pumpRooms(tester, roomContext(api), now: () => phone);

      // 30 minutes played; a pause does not count.
      Text clock() =>
          tester.widget<Text>(find.byKey(const Key('room-clock-posres_1')));
      expect(clock().data, '30:00');
      expect(find.text('Đang tạm dừng'), findsOneWidget);
      expect(find.text('Gói còn 90 phút'), findsOneWidget);
      phone = phone.add(const Duration(minutes: 2));
      await tester.pump(const Duration(seconds: 1));
      expect(clock().data, '30:00');

      await tester.tap(find.byKey(const Key('room-posres_1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('room-pause-posres_1')), findsNothing);
      await tester.tap(find.byKey(const Key('room-resume-posres_1')));
      await tester.pumpAndSettle();
      expect(api.calls, contains('resume-clock:postimed_1'));
    },
  );

  testWidgets('says a long pause is reopened by a manager', (tester) async {
    final api = pausedApi(tooLong: true);
    await pumpRooms(tester, roomContext(api));
    api.failures.add(const AppFailure.conflict(reason: 'approval_required'));

    await tester.tap(find.byKey(const Key('room-posres_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('room-resume-posres_1')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Tạm dừng quá lâu: cần quản lý duyệt tại quầy để tính giờ tiếp.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('writes the waiter in the attendants book', (tester) async {
    final api = roomApi();
    await pumpRooms(tester, roomContext(api, staffId: 'admin_7'));

    await tester.tap(find.byKey(const Key('room-posres_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('room-serve-posres_1')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('serve:posres_1:admin_7'));
    expect(find.text('Đã nhận phục vụ P1.'), findsOneWidget);
  });

  testWidgets('hides serving a room until the person is known', (
    tester,
  ) async {
    final api = roomApi();
    await pumpRooms(tester, roomContext(api));

    await tester.tap(find.byKey(const Key('room-posres_1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('room-serve-posres_1')), findsNothing);
  });

  testWidgets('tells the waiter when a room has ten minutes left', (
    tester,
  ) async {
    final api = roomApi();
    final events = eventSource();
    addTearDown(events.close);
    await pumpRooms(tester, roomContext(api, events: events.stream));

    events.add({
      'event': 'resource.updated',
      'id': 'posres_1',
      'alert': 'ending_soon',
      'refs': {'timed_session_id': 'postimed_1'},
    });
    await tester.pumpAndSettle();
    expect(find.text('P1 còn 10 phút'), findsOneWidget);

    // An update without an alert only rereads the board.
    events.add({'event': 'resource.updated', 'id': 'posres_2'});
    await tester.pumpAndSettle();
    expect(find.text('VIP 1 còn 10 phút'), findsNothing);
  });

  testWidgets("opens the room's order", (tester) async {
    final api = roomApi();
    await pumpRooms(tester, roomContext(api));

    await tester.tap(find.byKey(const Key('room-posres_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('room-order-posres_1')));
    await tester.pumpAndSettle();
    expect(find.byType(TableOrderScreen), findsOneWidget);
  });
}
