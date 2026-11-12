import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/errors.dart';
import 'package:parkviet_staff/modes/expo/expo_screen.dart';
import 'package:parkviet_staff/modes/kds/kds_repository.dart';
import 'package:parkviet_staff/modes/owner/owner_screen.dart';
import 'package:parkviet_staff/modes/waiter/order_menu_screen.dart';
import 'package:parkviet_staff/modes/waiter/table_courses.dart';
import 'package:parkviet_staff/modes/waiter/table_order_screen.dart';
import 'package:pos_api/pos_api.dart';

import 'kds/kds_board_test.dart' show live;
import 'kds/kds_fixtures.dart';
import 'waiter/waiter_fixtures.dart';
import 'waiter/waiter_screens_test.dart' show contextFor;

/// The owner's API from memory: the day's bookings and what was resolved.
class FakeOwnerApi implements OwnerApi {
  FakeOwnerApi(this.rows);

  List<Reservation> rows;
  final calls = <String>[];
  AppFailure? failure;

  @override
  Future<List<Reservation>> reservations(String branchId) async => rows;

  Reservation _resolve(String depositId, String status) {
    final row = rows.firstWhere((row) => row.deposits.any((deposit) => deposit.id == depositId));
    return row.rebuild(
      (b) => b.deposits.map(
        (deposit) => deposit.id == depositId
            ? deposit.rebuild(
                (d) => d
                  ..status = ReservationDepositStatusEnum.valueOf(status)
                  ..available = '0.0',
              )
            : deposit,
      ),
    );
  }

  Reservation _change(String reservationId, void Function(ReservationBuilder b) update) {
    final row = rows.firstWhere((row) => row.id == reservationId).rebuild(update);
    rows = [for (final old in rows) old.id == reservationId ? row : old];
    return row;
  }

  @override
  Future<Reservation> confirm(String reservationId) async {
    calls.add('confirm:$reservationId');
    if (failure != null) throw failure!;
    return _change(reservationId, (b) => b.confirmedAt = DateTime.utc(2026, 11, 12, 9));
  }

  @override
  Future<Reservation> cancel(String reservationId) async {
    calls.add('cancel:$reservationId');
    if (failure != null) throw failure!;
    return _change(reservationId, (b) => b.status = ReservationStatusEnum.canceled);
  }

  @override
  Future<Reservation> refundDeposit(String depositId) async {
    calls.add('refund:$depositId');
    if (failure != null) throw failure!;
    return _resolve(depositId, 'refunded');
  }

  @override
  Future<Reservation> forfeitDeposit(String depositId) async {
    calls.add('forfeit:$depositId');
    if (failure != null) throw failure!;
    return _resolve(depositId, 'forfeited');
  }
}

Reservation reservationOf(
  String id, {
  required String status,
  required String depositStatus,
  String guest = 'Chị Mai',
}) => parse(Reservation.serializer, {
  'id': id,
  'branch_id': 'posbranch_1',
  'status': status,
  'source': 'phone',
  'guest_name': guest,
  'phone': null,
  'party_size': 4,
  'note': null,
  'starts_at': '2026-11-12T12:00:00.000Z',
  'ends_at': '2026-11-12T14:00:00.000Z',
  'revision': 2,
  'customer_id': null,
  'workspace_id': null,
  'seated_at': null,
  'canceled_at': null,
  'resources': [
    {'id': 'posres_5', 'name': 'Bàn 5', 'kind': 'table', 'area_id': 'posarea_1'},
  ],
  'deposits': [
    {
      'id': 'dep_$id',
      'reservation_id': id,
      'received_funds_id': 'posfunds_$id',
      'kind': 'cash',
      'amount': '200000.0',
      'currency': 'VND',
      'status': depositStatus,
      'available': depositStatus == 'held' ? '200000.0' : '0.0',
      'resolution_order_id': null,
      'liability_payout_id': null,
      'funds_allocation_id': null,
      'received_at': '2026-11-11T10:00:00.000Z',
      'resolved_at': null,
    },
  ],
  'deposit_held': depositStatus == 'held' ? '200000.0' : '0.0',
});

void main() {
  test('held courses are grouped by course, first course first', () {
    final order = workspace(
      lines: [
        lineJson('a', quantity: 1, course: 3, courseStatus: 'held'),
        lineJson('b', quantity: 2, course: 2, courseStatus: 'held', seat: 1),
        lineJson('c', quantity: 1, course: 2, courseStatus: 'fired'),
      ],
    );
    expect(heldCourses(order).map((row) => (row.course, row.count)), [(2, 2), (3, 1)]);
    expect(const TablePlacement(hold: true).holds, isFalse, reason: 'only a dish with a course is held');
    expect(const TablePlacement(course: 2, hold: true).copyWith(course: () => null).hold, isFalse);
  });

  testWidgets('the waiter orders a main course for seat 2, held until it is fired', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = FakeWaiterApi(
      workspace: workspace(),
      menu: menu(items: [menuItemJson('mi_pho', name: 'Phở bò')]),
    );
    final waiter = contextFor(api);
    addTearDown(waiter.dispose);
    await tester.pumpWidget(
      localized(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<AddOutcome>(
                MaterialPageRoute(
                  builder: (_) => OrderMenuScreen(waiter: waiter, workspaceId: 'posws_1', title: 'Bàn 5'),
                ),
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('course-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('course-hold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('seat-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ghế 2').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dish-mi_pho')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cart-add')));
    await tester.pumpAndSettle();
    expect(api.calls.singleWhere((call) => call.startsWith('append:')), startsWith('append:variant_mi_phox1@c2s2h:'));
  });

  testWidgets('a held course is fired from the table order', (tester) async {
    final api = FakeWaiterApi(
      workspace: workspace(lines: [lineJson('l1', quantity: 2, course: 2, courseStatus: 'held', seat: 2)]),
    );
    final waiter = contextFor(api);
    addTearDown(waiter.dispose);
    await tester.pumpWidget(localized(TableOrderScreen(waiter: waiter, workspaceId: 'posws_1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ghế 2 · Món chính · Giữ lại, chờ gọi'), findsOneWidget);
    await tester.tap(find.byKey(const Key('fire-2')));
    await tester.pumpAndSettle();
    expect(api.calls.last, 'fire:posws_1:2');
    expect(find.text('Đã gửi bếp: Món chính'), findsOneWidget);
  });

  testWidgets('the pass fires a held course and keeps to one area', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const now = '2026-11-11T12:10:00.000+07:00';
    final item = itemJson('r1', name: 'Gỏi cuốn', status: 'ready', readyAt: '2026-11-11T12:06:00.000+07:00', seat: 3);
    final api = FakeKitchenApi(
      board(
        serverNow: now,
        expo: [
          {
            'workspace_id': 'posws_5',
            'area_id': 'posarea_1',
            'header': {'service_mode': 'dine_in', 'table': 'Bàn 5'},
            'service_mode': 'dine_in',
            'ready_since': '2026-11-11T12:06:00.000+07:00',
            'items': [
              {'item': item, 'kitchen_ticket_id': 't1', 'station_name': 'Bếp lạnh'},
            ],
          },
        ],
        held: [
          {
            'workspace_id': 'posws_5',
            'resource_name': 'Bàn 5',
            'area_id': 'posarea_1',
            'course': 2,
            'course_name': 'Món chính',
            'held_since': '2026-11-11T12:00:00.000+07:00',
            'lines': [
              {'sale_line_id': 'sl1', 'name': 'Bò lúc lắc', 'quantity': '2.0', 'seat': 1},
            ],
          },
          {
            'workspace_id': 'posws_9',
            'resource_name': 'Sân 1',
            'area_id': 'posarea_2',
            'course': 3,
            'course_name': 'Tráng miệng',
            'held_since': '2026-11-11T12:05:00.000+07:00',
            'lines': [
              {'sale_line_id': 'sl2', 'name': 'Chè', 'quantity': '1.0', 'seat': null},
            ],
          },
        ],
      ),
    );
    final controller = KdsController(api: api, stationIds: null)..start(status: live);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      localized(
        Scaffold(
          body: ExpoBoard(controller: controller, tick: const Duration(hours: 1)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chờ gọi món'), findsOneWidget);
    expect(find.text('Đã xong, cần mang ra'), findsOneWidget);
    expect(find.textContaining('Ghế 3'), findsOneWidget);
    expect(find.byKey(const Key('expo-held-posws_9-3')), findsOneWidget);

    await tester.tap(find.byKey(const Key('expo-area-posarea_1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('expo-held-posws_9-3')), findsNothing);

    await tester.tap(find.byKey(const Key('expo-fire-posws_5-2')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('fire:posws_5:2'));
  });

  testWidgets('the owner refunds a held deposit and keeps the deposit of a no-show', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = FakeOwnerApi([
      reservationOf('res_1', status: 'booked', depositStatus: 'held'),
      reservationOf('res_2', status: 'no_show', depositStatus: 'held', guest: 'Anh Minh'),
      reservationOf('res_3', status: 'seated', depositStatus: 'held', guest: 'Chị Hoa'),
    ]);
    await tester.pumpWidget(
      localized(
        Scaffold(
          body: OwnerReservations(api: api, branchId: 'posbranch_1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('owner-forfeit-dep_res_1')),
      findsNothing,
      reason: 'a booking still waiting keeps its deposit',
    );
    expect(find.byKey(const Key('owner-refund-dep_res_3')), findsNothing, reason: 'a seated party pays with it');

    await tester.tap(find.byKey(const Key('owner-refund-dep_res_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('owner-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Đã hoàn cọc.'), findsOneWidget);
    expect(find.byKey(const Key('owner-refund-dep_res_1')), findsNothing);

    await tester.tap(find.byKey(const Key('owner-forfeit-dep_res_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('owner-confirm')));
    await tester.pumpAndSettle();
    expect(api.calls, ['refund:dep_res_1', 'forfeit:dep_res_2']);
    expect(find.textContaining('đã giữ cọc'), findsOneWidget);
  });

  testWidgets('someone who books confirms a waiting booking and cancels another', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = FakeOwnerApi([
      reservationOf('res_1', status: 'booked', depositStatus: 'held'),
      reservationOf('res_2', status: 'booked', depositStatus: 'held', guest: 'Anh Minh'),
      reservationOf('res_3', status: 'seated', depositStatus: 'held', guest: 'Chị Hoa'),
    ]);
    await tester.pumpWidget(
      localized(
        Scaffold(
          body: OwnerReservations(api: api, branchId: 'posbranch_1', canManage: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('owner-reservation-confirm-res_3')), findsNothing, reason: 'a seated party is no longer waiting');
    expect(find.byKey(const Key('owner-reservation-cancel-res_3')), findsNothing);

    await tester.tap(find.byKey(const Key('owner-reservation-confirm-res_1')));
    await tester.pumpAndSettle();
    expect(find.text('Đã xác nhận đặt bàn.'), findsOneWidget);
    expect(find.textContaining('Đã xác nhận với khách'), findsOneWidget);
    expect(find.byKey(const Key('owner-reservation-confirm-res_1')), findsNothing);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold))).removeCurrentSnackBar();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('owner-reservation-cancel-res_2')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hủy đặt bàn của Anh Minh'), findsOneWidget);
    await tester.tap(find.byKey(const Key('owner-reservation-cancel-confirm')));
    await tester.pumpAndSettle();
    expect(api.calls, ['confirm:res_1', 'cancel:res_2']);
    expect(find.text('Đã hủy đặt bàn.'), findsOneWidget);
    expect(find.byKey(const Key('owner-reservation-cancel-res_2')), findsNothing);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold))).removeCurrentSnackBar();
    await tester.pumpAndSettle();

    api.failure = const AppFailure.conflict(reason: 'reservation_not_booked');
    await tester.tap(find.byKey(const Key('owner-reservation-cancel-res_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('owner-reservation-cancel-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Đặt bàn này không còn chờ khách.'), findsOneWidget);
  });

  testWidgets('without the right to book, the owner sees bookings but cannot change them', (tester) async {
    final api = FakeOwnerApi([reservationOf('res_1', status: 'booked', depositStatus: 'held')]);
    await tester.pumpWidget(localized(Scaffold(body: OwnerReservations(api: api, branchId: 'posbranch_1'))));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('owner-reservation-res_1')), findsOneWidget);
    expect(find.byKey(const Key('owner-reservation-confirm-res_1')), findsNothing);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold))).removeCurrentSnackBar();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('owner-reservation-cancel-res_1')), findsNothing);
  });
}